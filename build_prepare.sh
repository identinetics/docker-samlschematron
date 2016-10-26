#!/usr/bin/env bash

# optional script to initialize and update the docker build environment

update_pkg="False"

while getopts ":hn:uU" opt; do
  case $opt in
    n)
      config_nr=$OPTARG
      re='^[0-9][0-9]?$'
      if ! [[ $OPTARG =~ $re ]] ; then
         echo "error: -n argument is not a number in the range frmom 2 .. 99" >&2; exit 1
      fi
      ;;
    u)
      update_pkg="True"
      ;;
    U)
      update_pkg="False"
      ;;
    *)
      echo "usage: $0 [-n] [-u]
   -U  do not update git repos in docker build context (default)
   -u  update git repos in docker build context

   To update packages delivered as tar-balls just delete them from install/opt
   "
      exit 0
      ;;
  esac
done

shift $((OPTIND-1))


workdir=$(cd $(dirname $BASH_SOURCE[0]) && pwd)
cd $workdir
source ./conf${config_nr}.sh

get_or_update_repo() {
    if [ -e $repodir ] || [ "$update_pkg" == "True" ]; then
        echo "updating $repodir"
        cd $repodir && git pull && cd $OLDPWD
    else
        echo "cloning $repodir" \
        mkdir -p $repodir
        git clone $repourl $repodir
    fi
}

get_from_tarball() {
    if [ ! -e $pkgroot/$pkgdir ] || [ "$update_pkg" == "True" ]; then
        echo "downloading $pkgdir into $pkgroot"
        mkdir -p $pkgroot/$pkgdir
        curl -L $pkgurl | tar -xz -C $pkgroot
    fi
}

get_from_ziparchive() {
    if [ ! -e $pkgroot/$pkgdir ] || [ "$update_pkg" == "True" ]; then
        echo "downloading $pkgdir into $pkgroot"
        mkdir -p $pkgroot
        wget -qO- -O tmp.zip $pkgurl && unzip -d "$pkgroot" tmp.zip && rm tmp.zip
    fi
}


# --- saml-schematron/branch=master ---
#repodir='install/opt/saml-schematron'
#repourl='https://github.com/identinetics/saml-schematron'
#get_or_update_repo
#cd $repodir && git checkout master && cd $OLDPWD

# --- XMLSECTOOL ---
pkgroot='install/opt'
pkgdir='xmlsectool'
version='2.0.0'
pkgurl="https://shibboleth.net/downloads/tools/xmlsectool/${version}/xmlsectool-${version}-bin.zip"
get_from_ziparchive
cd $pkgroot
ln -s xmlsectool-${version} $pkgdir
cd $OLDPWD
