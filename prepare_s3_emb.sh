#!/bin/bash -e

set -e

echo This script downloads the code for the benchmarks
echo It will also attempt to build the benchmarks
echo It will output OK at the end if builds succeed
echo md-workbench,mdtest and ior are now bundled together
echo

LIBS3_EMB_HASH=FGbranch
IOR_HASH=b12742e1ad
PFIND_HASH=9d77056adce6e0a27a7a33c9eb09c72e11a88d29

INSTALL_DIR=$PWD
BIN=$INSTALL_DIR/bin
BUILD=$PWD/build
MAKE="make -j$(nproc)"

function main {
  # listed here, easier to spot and run if something fails
  setup
  # Prerequistics
  	module load curl libxml2 openssl libiconv gcc automake autoconf openmpi cmake
  #	apt install gcc cmake autoconf openssl libssl-dev libcurl4-openssl-dev libxml2-dev openmpi-bin libopenmpi-dev

  # get_libs3_emb
  get_ior
  get_pfind

  build_ior
  build_pfind
  build_io500_app

  echo
  echo "OK: All required software packages are now prepared"
  ls $BIN
}

function setup {
  #rm -rf $BUILD $BIN
  mkdir -p $BUILD $BIN
  #cp utilities/find/mmfind.sh $BIN
}

function git_co {
  pushd $BUILD
  [ -d "$2" ] || git clone $1 $2
  cd $2
  # turning off the hash thing for now because too many changes happening too quickly
  git checkout $3
  popd
}

###### GET FUNCTIONS

function get_libs3_emb {
  echo "Getting latest libs3"
  git_co git@github.com:JulianKunkel/S3EmbeddedLib.git S3EmbeddedLib $LIBS3_EMB_HASH
  pushd $BUILD/libs3
  $MAKE clean
  $MAKE install
  ln -s ...
  popd
}


function get_ior {
  echo "Getting IOR and mdtest"
  git_co https://github.com/hpc/ior.git ior $IOR_HASH
  pushd $BUILD/ior
  ./bootstrap
  ./configure --prefix=$INSTALL_DIR --with-S3-libs3 CPPFLAGS=-I$HOME/tools/S3EmbeddedLib LDFLAGS=-L$HOME/tools/S3EmbeddedLib
  popd
}

function get_pfind {
  echo "Preparing parallel find"
  git_co https://github.com/VI4IO/pfind.git pfind $PFIND_HASH
}


###### BUILD FUNCTIONS
function build_ior {
  pushd $BUILD/ior/src
  $MAKE clean
  $MAKE install
  echo "IOR: OK"
  echo
  popd
}

function build_pfind {
  pushd $BUILD/pfind
  ./prepare.sh
  ./compile.sh
  ln -sf $BUILD/pfind/pfind $BIN/pfind
  echo "Pfind: OK"
  echo
  popd
}

function build_io500_app {
  make
  echo "io500-app: OK"
  echo
}


###### CALL MAIN
main
