# S3 Benchmarks

S3 Performace Analysis using IO500 benchmark.

## Preparation

This script will retrieve and compile alle the required packages for IOR/MDtest, pfind, md-workbench, and io500:
    $ ./prepare_s3.sh

## Usage

The io500 benchmark requires a .ini file containing the options used to access the S3 endpoint. The file config-s3.ini provides an example for an S3 endpoint configuration.

The io500-s3.sh script launches both io500 and md-workbench benchmarks , please launch this script after adjusting it depending on your environment and, once finished, please share the obtained results.

Detailed help for the io500 benchmark are displayed when running:

    $ ./io500 -h
    Synopsis: ./io500 <INI file> [-v=<verbosity level>] [--dry-run]

	The benchmark output the commands it would run (equivalence of command line invocations of ior/mdtest). Use --dry-run to not invoke any command.

Detailed help for the md-workbench benchmark and the available flags for the s3 interface are displayed when running:
	$ ./bin/md-workbench -i=s3 --help

## Output

  
### Example output on the command line

The following is a sample output:
    
    $io500 config-s3.ini
	IO500 version 9c0f0c6
	[RESULT-invalid]       ior-easy-write        0.015926 GiB/s : time 300.414 seconds
	[RESULT-invalid]    mdtest-easy-write        0.011581 kIOPS : time 300.392 seconds
	[RESULT-invalid]       ior-hard-write        0.000477 GiB/s : time 300.776 seconds
	[RESULT-invalid]    mdtest-hard-write        0.005658 kIOPS : time 300.909 seconds
	[RESULT-invalid]                 find        0.000000 kIOPS : time 0.000 seconds
	[RESULT-invalid]        ior-easy-read        0.085152 GiB/s : time 56.236 seconds
	[RESULT-invalid]     mdtest-easy-stat        0.109214 kIOPS : time 31.936 seconds
	[RESULT-invalid]        ior-hard-read        0.003944 GiB/s : time 36.431 seconds
	[RESULT-invalid]     mdtest-hard-stat        0.107631 kIOPS : time 15.851 seconds
	[RESULT-invalid]   mdtest-easy-delete        0.003029 kIOPS : time 1147.474 seconds
	[RESULT-invalid]     mdtest-hard-read        0.052286 kIOPS : time 32.587 seconds
	[RESULT-invalid]   mdtest-hard-delete        0.003875 kIOPS : time 438.882 seconds
	; [I]  MD = (0.01158092 * 0.00565780 * 0.00000000 * 0.10921435 * 0.10763068 * 0.00302888 * 0.05228598 * 0.00387463)^0.125000
	; [I]  BW = (0.01592619 * 0.00047733 * 0.08515207 * 0.00394409)^0.250000
	[SCORE] Bandwidth 0.007108 GB/s : IOPS 0.000000 kiops : TOTAL 0.000000
