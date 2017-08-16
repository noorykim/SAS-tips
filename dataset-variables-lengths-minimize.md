Here is my macro for minimizing the lengths of variables:

```
%macro trimVarLength(dataset, libname=WORK);         
  proc sql noprint;                                
    create table vars as
      select cats("max(length(", name, ")) as _", name) as cvar
      from dictionary.columns
      where type = 'char' and libname = upcase("&libname") and memname = upcase("&dataset")
    ;                                

    select cvar into :cvars separated by ','
      from vars                                
    ;

    create table lens as
      select &cvars from &dataset
    ;                
  quit;

  proc transpose data=lens out=tlens (rename=(_name_=name col1=len));
    var _:;
  run;

  proc sql noprint;
    select cat(substr(name, 2), " char(", put(len, 3.), ")") into :alterlen separated by ', '
      from tlens
    ; 

    alter table &dataset
      modify &alterlen
    
    drop table vars;
    drop table lens;
    drop table tlens;                
  quit;

%mend trimVarlength;
```


Drafted 2017-07

Posted 2017-08-16

(c) Noory Kim
