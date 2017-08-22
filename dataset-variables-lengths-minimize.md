# Minimize the lengths of variables

SDTM datasets submitted to the FDA are expected to have variable lengths equal to the length of the longest value (up to 200 characters). 

Here is my macro for minimizing the lengths of variables:

## Pseudocode
1. Retrieve the names of the character variables in the data set.
2. Use names to construct PROC SQL syntax to find the minmax length needed for each variable. (e.g. "max(length(var1)) as var1")
3. Concatenate the values from step (2) into a single string, separated by commas.
4. Get the minmax lengths of the character variables.
5. Replace the variable lengths with the results from step (4).


## Full code

```
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
```



#

Posted 2017-08-16

Updated 2017-08-22

(c) Noory Kim


#

[SAS Tips](/sas-tips)

[Portfolio](/)

