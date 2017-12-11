%macro trimVarLength(dataset, libname=WORK);

  proc sql noprint;
    /* retrieve the names of character variables, and 
       form a column with syntax to find the max lengths of those variables; tall */
    create table vars as
      select cats("max(length(", name, ")) as _", name) as cvar
      from dictionary.columns
      where type = 'char' and libname = upcase("&libname") and memname = upcase("&dataset")
    ;                                

    /* concatenate the column values into a single string; flat */
    select cvar into :cvars separated by ','
      from vars                                
    ;

    /* get the maximum lengths of the character variables; flat */
    create table lens as
      select &cvars 
      from &dataset
    ;                
  quit;

  /* transpose; tall */
  proc transpose data=lens out=tlens (rename=(_name_=name col1=len));
    var _:;
  run;

  proc sql noprint;
    /* define the new length values */
    select cat(substr(name, 2), " char(", put(len, 3.), ")") into :alterlen separated by ', '
      from tlens
    ; 

    /* replace the lengths */
    alter table &dataset
      modify &alterlen
    ;
    
    /* clear out temporary data sets */
    drop table vars;
    drop table lens;
    drop table tlens;                
  quit;

%mend trimVarlength;
