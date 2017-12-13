%macro maxlen(ds1, ds2, lib1=work, lib2=work);
  /* join two tables with variables having same name but different lengths */ 
  
  %global lens;
 
  %let ds1 = %qupcase(&ds1);
  %let ds2 = %qupcase(&ds2);
  %let lib1 = %qupcase(&lib1);
  %let lib2 = %qupcase(&lib2);
 
  proc sql;
    create table lens1 as
      select  
        name,
        length as len1   
      from dictionary.columns
      where libname = "&lib1" and memname = "&ds1" and type = 'char'
      order by name
    ;
    
    create table lens2 as
      select  
        name,
        length as len2
      from dictionary.columns
      where libname = "&lib2" and memname = "&ds2" and type = 'char'
      order by name
    ;
  quit;
               
  data lens;
    merge lens1 lens2;
    by name;
    len = max(of len1-len2);
  run;
 
  proc sql noprint;
    select strip(name) || ' $' || put(len, 3.) into :lens separated by ' '
      from lens
    ;
  quit;
 
%mend maxlen;
