#!/bin/bash
## used for swifts3 and wasabi
## just change the number of node, the s3provider and the S3 access info.
#SBATCH -N 4
#SBATCH --partition=compute
#SBATCH --time=01:30:00
#SBATCH --job-name=S3API
#SBATCH --account=accountname
# limit stacksize ... adjust to your programs need
# and core file size
ulimit -s 102400
ulimit -c 0

#Modules to load
module purge
module load openmpi


# Settings for OpenMPI and MXM (MellanoX Messaging)
# library
export OMPI_MCA_pml=cm
export OMPI_MCA_mtl=mxm
export OMPI_MCA_mtl_mxm_np=0
export MXM_RDMA_PORTS=mlx5_0:1
export MXM_LOG_LEVEL=ERROR
# Disable GHC algorithm for collective communication
export OMPI_MCA_coll=^ghc


s3provider=aws
s3Mode=${s3provider}-${SLURM_NNODES}-io500		

IO500=$HOME/tools/emb/io500/io500
IOR=$HOME/tools/emb/io500/bin/ior
MDWORKBENCH=$HOME/tools/emb/io500/bin/md-workbench

DATUM=$(date +'%Y%m%d-%H%M%S')

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/tools/emb/io500/lib
export PATH=$HOME/bin:$HOME/go/bin:$PATH

## S3 access info
export S3_ENDPOINT="s3.xxx.com:443"									 
export ACCESS_KEY="xx"
export SECRET_KEY="xx"


echo START
echo "SLURM_JOBID  = ${SLURM_JOBID}"
echo "SLURM_JOB_NODELIST = ${SLURM_JOB_NODELIST}"
echo "SLURM_NNODES = ${SLURM_NNODES}"
echo "SLURM_NTASKS = ${SLURM_NTASKS}"
echo "SLURMTMPDIR  = ${SLURMTMPDIR}"
echo "Submission directory = ${SLURM_SUBMIT_DIR}"

NODES=$(srun -w $SLURM_JOB_NODELIST hostname)
echo $NODES

nodes_arr=($NODES)
echo nodes_arr = ${nodes_arr[*]} 
echo "nodes_arr size: ${#nodes_arr[*]}"

echo "nodes_arr items and indexes:"
for index in ${!nodes_arr[*]}
do
    printf "%4d: %s\n" $index ${nodes_arr[$index]}
done


echo hostname:
hostname

echo STARTING BENCHMARKS at $(date +'%Y%m%d-%H%M%S') on ${nodes_arr[*]}
#TESTS
tpn=20 ##tasks per node

RESULT_DIR=$HOME/tests/$s3Mode/$DATUM-${tpn}tpn
echo "creating DIR $RESULT_DIR"
mkdir -p $RESULT_DIR
cd $RESULT_DIR

MPI_CMD="srun --ntasks-per-node=${tpn}"
FLAGS="-a=S3-libs3 --S3-libs3.host=${S3_ENDPOINT} --S3-libs3.access-key=${ACCESS_KEY} --S3-libs3.secret-key=${SECRET_KEY} -R 1 --latency-all -D 10 -P 300 -I 100 -L ${RESULT_DIR}/latency --S3-libs3.s3-compatible --S3-libs3.use-ssl"

echo starting ... $MPI_CMD $MDWORKBENCH -1 $FLAGS

$MPI_CMD $MDWORKBENCH -1 $FLAGS | tee $RESULT_DIR/md-workbench-precreate.txt
# Originalwert
$MPI_CMD $MDWORKBENCH -2 --run-info-file=mdtest.status $FLAGS | tee $RESULT_DIR/md-workbench-original.txt

cat <<EOT |cat - > $RESULT_DIR/config-s3.ini
[global]
datadir = ./datafiles
timestamp-datadir = True
resultdir = ./results
timestamp-resultdir = True
api = S3-libs3 --S3-libs3.host=${S3_ENDPOINT} --S3-libs3.secret-key=${SECRET_KEY} --S3-libs3.access-key=${ACCESS_KEY} --S3-libs3.s3-compatible --S3-libs3.use-ssl  

[debug]
# Stonewall time must be 300 for a valid result, can be smaller for testing
stonewall-time = 300

[find]
noRun = True

[find-easy]
noRun = TRUE

[find-hard]
noRun = TRUE

EOT

cat $RESULT_DIR/config-s3.ini

$MPI_CMD $IO500 $RESULT_DIR/config-s3.ini

# Cache free wert:
$MPI_CMD $MDWORKBENCH -2 --run-info-file=mdtest.status $FLAGS | tee $RESULT_DIR/md-workbench-cachefree.txt

$MPI_CMD $MDWORKBENCH -3 $FLAGS

##cleanup
rm -f mdtest.status

echo DONE at $(date +'%Y%m%d-%H%M%S')