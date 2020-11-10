#!/bin/bash

IO500=$PWD/io500
MDWORKBENCH=$PWD/bin/md-workbench
DATUM=$(date +'%Y%m%d-%H%M%S')

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib



S3_ENDPOINT="localhost:9000"
ACCESSKEY=accesskey
SECRETKEY=secretkey

#TESTS
RESULT_DIR=$HOME/tests/io500-s3/$DATUM
echo "creating DIR $RESULT_DIR"
mkdir -p $RESULT_DIR
cd $RESULT_DIR


FLAGS="-i=s3 -R 1 --latency-all -D 10 -P 300 -I 100 -L ${RESULT_DIR}/latency -- -H=${S3_ENDPOINT} -a=${ACCESSKEY} -s=${SECRETKEY}"
# other md-workbench Flags specific to the s3 interface can be displayed using ./bin/md-workbench -i=s3 --help


$MDWORKBENCH -1 $FLAGS | tee $RESULT_DIR/md-workbench-precreate.txt
# Originalwert
$MDWORKBENCH -2 --run-info-file=mdtest.status $FLAGS | tee $RESULT_DIR/md-workbench-original.txt

cat <<EOT |cat - > $RESULT_DIR/config-s3.ini
[global]
datadir = ./datafiles
timestamp-datadir = True
resultdir = ./results
timestamp-resultdir = True
verbosity = 10
api = S3-libs3 --S3-libs3.host=${S3_ENDPOINT}:9000 --S3-libs3.access-key=${ACCESSKEY} --S3-libs3.secret-key=${SECRETKEY}

[debug]
# Stonewall time must be 300 for a valid result, can be smaller for testing
stonewall-time = 300

[find]
noRun = True
EOT

cat $RESULT_DIR/config-s3.ini

$IO500 $RESULT_DIR/config-s3.ini

# Cache free values:
$MDWORKBENCH -2 --run-info-file=mdtest.status $FLAGS | tee $RESULT_DIR/md-workbench-cachefree.txt

$MDWORKBENCH -3 $FLAGS

##cleanup
rm -f mdtest.status

echo PLEASE UPLOAD the Content of $RESULT_DIR to ...