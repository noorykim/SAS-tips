# Add a SUPP-- (supplementary) data set for an SDTM domain

The SAS functions vname() and vlabel() help leverage SDTM value-level metadata for populating QNAM and QLABEL in SUPP-- (supplementary) data sets.

```
%macro add_supp(qnams, inlib=work, outlib=sdtm);
  /* author: Noory Kim
     last updated: 2017-08-22
     expected input: 
     - qnams: list of variables with names to be saved as QNAM and labels to be saved as QLABEL 
     other assumptions:
     - &outlib refers to an existing libname/library
     - &domain is already defined as an uppercase string (of length 2)
  */

  data supp;
    set &inlib..&domain (keep=studyid domain usubjid &domain.SEQ &qnams);
    if coalescec(&qnams) ne ' ';

    RDOMAIN = domain;
    IDVAR = "&domain.SEQ";

    array q[*] &qnams;
      do i = 1 to dim(q);
        IDVARVAL = strip(put(&domain.SEQ, 8.));
        QNAM = upcase(vname(q[i]));
        QLABEL = vlabel(q[i]);
        QVAL = q[i];
        
        /* placeholders */
        QORIG = ' ';
        QEVAL = ' ';

        if q[i] ne ' ' then output;
      end;

    label
      STUDYID = 'Study Identifier'
      RDOMAIN = 'Related Domain Abbreviation'
      USUBJID = 'Unique Subject Identifier'
      IDVAR = 'Identifying Variable'
      IDVARVAL = 'Identifying Variable Value'
      QNAM = 'Qualifier Variable Name'
      QLABEL = 'Qualifier Variable Label'
      QVAL = 'Data Value'
      QORIG = 'Origin'
      QEVAL = 'Evaluator'
    ;
  run;

  proc sort data=supp;
    %*by usubjid &domain.SEQ qnam;        /* '10' goes after '9' */
    by usubjid idvarval qnam;             /* '10' goes after '1' */
  run;

  %let suppvars = STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG QEVAL;

  data &outset..SUPP&domain (label="Supplemental Qualifiers for &domain");
    format &suppvars;
    set supp;
    keep &suppvars;
  run;

%mend add_supp;
```


Usage example:

```
data ae;
  ...
  if AESTDTC >= RFSTDTC then TRTEMFL = "Y";
  label TRTEMFL = "Treatment Emergent Flag";
run;

%add_supp(TRTEMFL);
%trimVarlength(supp&domain, libname=sdtm);

proc contents data=&syslast varnum;
run;
proc print data=&syslast (obs=20);
run;

/* export the data set into an XPT file */
libname xpt xport "..\..\..\..\Data\SDTM\SUPP&domain..xpt";
proc copy in=SDTM out=xpt memtype=data;
  select SUPP&domain;
run;
```


#

Posted 2017-08-21

Last updated 2017-08-22

(c) Noory Kim


#

[SAS Tips](/sas-tips)

[Portfolio](/)

