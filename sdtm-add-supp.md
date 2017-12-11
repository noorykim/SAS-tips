# Add a SUPP-- (supplementary) data set for an SDTM domain

This macro facilitates the generation of a SUPP-- data set to accompany an SDTM data set that has already been programmed. 

It is assumed that values to be captured by the SUPP-- data set have been stored in variables named and labeled with the values to be stored in QNAM and QLABEL respectively.  The macro uses the SAS functions vname() and vlabel() to extract this information when populating the SUPP-- (supplementary) data sets.

## Macro download
[sdtm-add-supp.sas](sdtm-add-supp.sas)

## Macro parameters
```
%add_supp(qnams, inlib=work, outlib=sdtm);
  /* parameters: 
     - qnams: list of variables with names to be saved as QNAM 
              and labels to be saved as QLABEL 
     - inlib: libname of the input data set 
              w/ the variables listed in 'qnams'
     - outlib: libname of output data set
     
     other assumptions:
     - &outlib refers to an existing libname/library
     - &domain is already defined as an uppercase string (of length 2)
  */
```

## Usage example
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
libname xpt xport "..\..\Data\SDTM\SUPP&domain..xpt";
proc copy in=SDTM out=xpt memtype=data;
  select SUPP&domain;
run;
```

#
[Portfolio](/)
