#ifndef IO500_PHASE_MDWORK_H
#define IO500_PHASE_MDWORK_H

#include <io500-util.h>

typedef struct{
  char * mdwork_interface;
  int no_run;
  char * command;
  MPI_Comm mdwork_com;
  int mdwork_obj_per_proc;
  int mdwork_precreate_per_set;
  int mdwork_data_sets;
  char * mdwork_host;
  int mdwork_access_key;
  int mdwork_secret_key;
  int mdwork_s3_compatible;
  int mdwork_s3_use_ssl;
} opt_mdwork_generic;

// typedef struct{
//   int no_run;
//   char * api;
//   uint64_t files_per_proc;
//   char * command;
// } opt_mdwork_generic;

typedef enum {
  MDWORK_DIR_CREATE_NUM = 0,
  MDWORK_DIR_STAT_NUM = 1,
  MDWORK_DIR_READ_NUM = 1,
  MDWORK_DIR_REMOVE_NUM = 3,
  MDWORK_FILE_CREATE_NUM = 4,
  MDWORK_FILE_STAT_NUM = 5,
  MDWORK_FILE_READ_NUM = 6,
  MDWORK_FILE_REMOVE_NUM = 7,
  MDWORK_TREE_CREATE_NUM = 8,
  MDWORK_TREE_REMOVE_NUM = 9,
  MDWORK_LAST_NUM
} mdwork_test_num_t;

typedef struct{
  double rate;
  double rate_stonewall;
  uint64_t items;
  double time;
} mdwork_generic_res;


typedef struct{
  opt_mdwork_generic g;
  mdwork_generic_res res;
} opt_mdwork_easy;

extern opt_mdwork_easy mdwork_easy_o;

typedef struct{
  opt_mdwork_generic g;
  mdwork_generic_res res;
} opt_mdwork_hard;

extern opt_mdwork_hard mdwork_hard_o;

void mdwork_add_generic_params(u_argv_t * argv, opt_mdwork_generic * dflt, opt_mdwork_generic * generic);

void mdwork_easy_add_params(u_argv_t * argv);
void mdwork_hard_add_params(u_argv_t * argv);

void p_mdwork_run(u_argv_t * argv, FILE * out, mdwork_generic_res * d, mdwork_test_num_t test);
#endif
