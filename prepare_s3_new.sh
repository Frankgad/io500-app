#!/bin/bash -e

set -e

echo This script downloads the code for the benchmarks
echo It will also attempt to build the benchmarks
echo It will output OK at the end if builds succeed
echo

LIBS3_HASH=287e4bee6fd430
IOR_HASH=b12742e1ad

INSTALL_DIR=$PWD
BIN=$INSTALL_DIR/bin
BUILD=$PWD/build
MAKE="make -j$(nproc)"

function main {
  # listed here, easier to spot and run if something fails
  setup
  # Prerequistics
  #	module load curl libxml2 openssl libiconv gcc automake autoconf openmpi cmake
  #	apt install gcc cmake autoconf openssl libssl-dev libcurl4-openssl-dev libxml2-dev openmpi-bin libopenmpi-dev

  get_libs3
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

function get_libs3 {
  echo "Getting latest libs3"
  git_co https://github.com/bji/libs3.git libs3 $LIBS3_HASH
  pushd $BUILD/libs3
  $MAKE clean
  DESTDIR=$INSTALL_DIR $MAKE install
  popd
}



function get_ior {
  echo "Getting IOR and mdtest"
  git_co https://github.com/hpc/ior.git ior $IOR_HASH
  pushd $BUILD/ior
  ./bootstrap
  ./configure --prefix=$INSTALL_DIR --with-S3-libs3 CPPFLAGS=-I$INSTALL_DIR/include LDFLAGS=-L$INSTALL_DIR/lib
  popd
}

function get_pfind {
  echo "Preparing parallel find"
  git_co https://github.com/VI4IO/pfind.git pfind
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
