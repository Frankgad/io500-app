#include <sys/stat.h>
#include <unistd.h>
#include <mpi.h>
#include <string.h>


#include <phase_mdwork.h>
#include <io500-phase.h>



typedef struct{
  opt_mdwork_generic g;
  mdwork_generic_res res;
} opt_mdwork;

static opt_mdwork o;

static ini_option_t option[] = {
  {"noRun", "Disable running of this phase", 0, INI_BOOL, NULL, & o.g.no_run},
  {"mdwork-interface", "md-workbench interface", 0, INI_STRING, "s3", & o.g.mdwork_interface},
  {"obj-per-proc", "md-workbench obj-per-proc", 0, INI_INT, "100", & o.g.mdwork_obj_per_proc},
  {"precreate-per-set", "md-workbench precreate-per-set", 0, INI_INT, "300", & o.g.mdwork_precreate_per_set},
  {"data-sets", "md-workbench data-sets", 0, INI_INT, "10", & o.g.mdwork_data_sets},
  {"host", "md-workbench S3 Host", 0, INI_STRING, "localhost:9000", & o.g.mdwork_host},
  {"access-key", "md-workbench S3 Access Key", 0, INI_STRING, "accesskey", & o.g.mdwork_access_key},
  {"secret-key", "md-workbench S3 Secret Key", 0, INI_STRING, "secretkey", & o.g.mdwork_secret_key},
  {"s3-compatible", "S3 compatible", 0, INI_BOOL, "FALSE", & o.g.mdwork_s3_compatible},
  {"use-ssl", "S3 use-ssl", 0, INI_BOOL, "FALSE", & o.g.mdwork_s3_use_ssl},
  {NULL} };


static void validate(void){

}

static double run(void){
    u_argv_t * argv = u_argv_create();
    u_argv_push(argv, "./md-workbench");
    // u_argv_push(argv, opt.datadir);
    u_argv_push(argv, "-i");
    u_argv_push_printf(argv, "%s", o.g.mdwork_interface);
    u_argv_push(argv, "-P");
    u_argv_push_printf(argv, "%d", o.g.mdwork_precreate_per_set);
    u_argv_push(argv, "-D");
    u_argv_push_printf(argv, "%d", o.g.mdwork_data_sets);
    u_argv_push(argv, "-I");
    u_argv_push_printf(argv, "%d", o.g.mdwork_obj_per_proc);
    u_argv_push(argv, "--");
    u_argv_push(argv, "-H");
    u_argv_push_printf(argv, "%s", o.g.mdwork_host);
    u_argv_push(argv, "-a");
    u_argv_push_printf(argv, "%d", o.g.mdwork_access_key);
    u_argv_push(argv, "-s");
    u_argv_push_printf(argv, "%d", o.g.mdwork_secret_key);
    // u_argv_push_printf(argv, "%s/timestampfile", opt.resdir);
    if(o.g.mdwork_s3_compatible){
      u_argv_push(argv, "-c");
    }
    if(o.g.mdwork_s3_use_ssl){
      u_argv_push(argv, "-l");
      }
    

    o.g.command = u_flatten_argv(argv);

  

  // mdwork_add_generic_params(argv, & d.g, & o.g);
    PRINT_PAIR("exe", "%s\n", o.g.command);


  if(opt.dry_run || o.g.no_run  == 1 ){
    u_argv_free(argv);
    return 0;
  }

  // FILE * out = u_res_file_prep(p_mdwork.name);
  // p_mdwork_run(argv, out, & o.res, MDWORK_FILE_CREATE_NUM);

  PRINT_PAIR("rate-stonewall", "%f\n", o.res.rate_stonewall);
  return o.res.rate;
}

u_phase_t p_mdwork = {
  "mdwork",
  IO500_PHASE_DUMMY,
  option,
  validate,
  run,
  .verify_stonewall = 1,
  .group = IO500_SCORE_MD
};
