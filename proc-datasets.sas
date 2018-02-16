/*rename dataset*/
proc datasets library=libref nolist;
  change old_ds_name = new_ds_name;
quit;

/*rename variables*/
proc datasets library=libref;
  modify ds_name;
  change old_var_name = new_var_name;
quit;
