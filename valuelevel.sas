/*--------------------------------------------------*\
| Program Name.....:  ValueLevel.sas   
|                     ValueLevel.log                     
|                     ValueLevel.lst                     
| Version 0.1.2
| Program Purpose..: Help populate part of ValueLevel tab in metadata spreadsheet
|--------------------------------------------------|
Updates made:
                Detect ISO8601 dates and set data_type = date or data_type = datetime
\*--------------------------------------------------*/

 

%include "..\..\utility\sts.inc" ;

 

%let data_library = sasdata;

 

 

proc format;

                value data_type

                                1 = 'text'

                                2 = "float"

                                3 = 'integer'

                                4 = 'date'

                                5 = 'datetime'

                ;

run;

 

 

proc sql noprint;

                select name into :tsval_names separated by ' '

                                from dictionary.columns

                                where libname = upcase("&data_library")

                                                and memname = "TS"

                                                and label ? "Parameter Value"

                                                and find(label, 'CODE', 'i') = 0

                ;

 

%*          create table datetime_vars as

%*                          select *

%*                          from dictionary.columns

%*                          where libname = upcase("&data_library")

%*                                          and substr(memname, 1, 2) ne "AD"

%*                                          and find(label, 'date', 'i') > 0

%*                         

%*          ;

 

quit;

 

 

%let firstcols = order dataset variable where_clause data_type length significant_digits wc_end;

 

%macro valuelevel(domain, main=y, supp=n, ts=n);

 

                %if %qupcase(&main) eq Y %then %do;

                                %if %qupcase(&ts) eq N %then %do;

 

                                                proc sql;

                                                                create table main as

                                                                                select &domain.testcd,

                                                                                                                 max(find(&domain.stresc, '.') > 0) as decimal_present,

                                                                                       max(length(&domain.stresc)) as length length=3,

                                                                                       max(length(scan(&domain.stresc, 2))) as significant_digits,

                                                                                       max(notdigit(strip(compress(&domain.stresc, '.'))) = 0) as numeric

                                                                                from &data_library..&domain

                                                                                group by &domain.testcd

                                                                                order by &domain.testcd

                                                                ;

                                                quit;

                                               

                               

                                                data firstcols;

                                                                format &firstcols;

                                                                set main;

                                                               

                                                                length dataset $6 where_clause $20;

                                                                order = _n_;

                                                                dataset = upcase("&domain");

                                                                variable = upcase("&domain.ORRES");

                                                                where_clause = "&domain..&domain.TESTCD." || strip(&domain.testcd);

               

                                                                wc_end = substr(where_clause , length(where_clause)-2, 3);

                                                                                                               

                                                                if numeric = 0 then do;

                                                                                if wc_end = 'DTC' then do;

                                                                                                if length = 10 then data_typen = 4;

                                                                                                else if length > 10 then data_typen = 5;

                                                                                end;

                                                                                else do;

                                                                                                data_typen = 1;

                                                                                end;

                                                                end;

                                                                else if decimal_present then data_typen = 2;

                                                                else data_typen = 3;

                                                                data_type = put(data_typen, data_type.);

 

                                                                if decimal_present = 0 or data_typen = 1 then significant_digits = .;                                        

                                                               

                                                                keep &firstcols;

                                                run;

                               

                                                proc append base=valuelevel data=firstcols;

                                                run;

 

                                %end;

                                %else %if %qupcase(&ts) eq Y %then %do;

 

                                                %local i next_name;

                                                %do i = 1 %to %sysfunc(countw(&tsval_names));

                                               

                                                   %let next_name = %scan(&tsval_names, &i);

                                                  

                                                                proc sql;

                                                                                create table &next_name as

                                                                                                select tsparmcd,

                                                                                                                    "&next_name" as variable length=7,

                                                                                                                                max(find(&next_name, '.') > 0) as decimal_present,

                                                                                                       max(length(&next_name)) as length length=3,

                                                                                                       max(length(scan(&next_name, 2))) as significant_digits,

                                                                                                       max(notdigit(compress(&next_name, '.')) = 0) as numeric

                                                                                                from &data_library..TS

                                                                                                where &next_name is not null

                                                                                                group by tsparmcd

                                                                                                order by tsparmcd

                                                                                ;                                                                                              

                                                                quit;

                                                               

                                                %end;

 

                                               

                                                data firstcols;

                                                                format &firstcols;

                                                                set &tsval_names;

                                                                by variable;

                                                               

                                                                if first.variable then order = 0;

                                                                order+1;

                                                               

                                                                length dataset $6 where_clause $20;

                                                                dataset = upcase("&domain");

                                                                where_clause = "TS.TSPARMCD." || strip(&domain.parmcd);

                                                               

                                                                wc_end = substr(where_clause , length(where_clause)-2, 3);

                                                                                                               

                                                                if numeric = 0 then do;

                                                                                if wc_end = 'DTC' then do;

                                                                                                if length = 10 then data_typen = 4;

                                                                                                else if length > 10 then data_typen = 5;

                                                                                end;

                                                                                else do;

                                                                                                data_typen = 1;

                                                                                end;

                                                                end;

                                                                else if decimal_present then data_typen = 2;

                                                                else data_typen = 3;

                                                                data_type = put(data_typen, data_type.);

                                               

                                                                if decimal_present = 0 or data_typen = 1 then significant_digits = .;                                        

                                                                                                                               

                                                                keep &firstcols;

                                                run;

                               

                                                proc append base=valuelevel data=firstcols;

                                                run;                       

                               

                                %end;

                %end;

               

                %if %qupcase(&supp) eq Y %then %do;

               

                                proc sql;

                                                create table supp as

                                                                select qnam, qlabel,

                                                                                                max(find(qval, '.') > 0) as decimal_present,

                                                                       max(length(qval)) as length length=3,

                                                                       max(length(scan(qval, 2))) as significant_digits,

                                                                                    max(notdigit(compress(qval, '.')) = 0) as numeric

                                                                from &data_library..supp&domain

                                                                group by qnam, qlabel

                                                                order by qnam, qlabel

                                                ;

                                quit;

               

                                data firstcols;

                                                format &firstcols;

                                                set supp;

 

                                                length variable $7 where_clause $20;                                    

                                                order = _n_;

                                                dataset = "SUPP&domain";

                                                variable = "QVAL";

                                                where_clause = "&domain..QNAM." || strip(qnam);

 

                                                wc_end = substr(where_clause , length(where_clause)-2, 3);

                                                                                               

                                                if numeric = 0 then do;

                                                                if wc_end = 'DTC' or find(qlabel, 'date', 'i') > 0 then do;

                                                                                if length = 10 then data_typen = 4;

                                                                                else if length > 10 then data_typen = 5;

                                                                end;

                                                                else do;

                                                                                data_typen = 1;

                                                                end;

                                                end;

                                                else if decimal_present then data_typen = 2;

                                                else data_typen = 3;

                                                data_type = put(data_typen, data_type.);

                                               

                                                if decimal_present = 0 or data_typen = 1 then significant_digits = .;

                                               

                                                keep &firstcols;

                                run;

               

                                proc append base=valuelevel data=firstcols;

                                run;

                %end;

 

%mend valuelevel;

 

%valuelevel(LB, main=y, supp=y);

 

%valuelevel(AE, main=n, supp=y);

%valuelevel(CM, main=n, supp=y);

%valuelevel(DA, main=y, supp=y);

%valuelevel(DM, main=n, supp=y);

%valuelevel(DS, main=n, supp=y);

%valuelevel(EX, main=n, supp=y);

%valuelevel(IE, main=y, supp=n);

%valuelevel(LB, main=y, supp=y);

%valuelevel(MH, main=n, supp=y);

%valuelevel(PC, main=y, supp=y);

%valuelevel(PE, main=y, supp=y);

%valuelevel(QS, main=y, supp=y);

%valuelevel(TS, main=y, supp=n, ts=y);

%valuelevel(VS, main=y, supp=n);

%valuelevel(XC, main=y, supp=n);

%valuelevel(XG, main=y, supp=y);

%valuelevel(XM, main=y, supp=y);

%valuelevel(XP, main=y, supp=n);

%valuelevel(XR, main=y, supp=y);

%valuelevel(XV, main=y, supp=n);

 

 

 

 

 

proc sort data=valuelevel;

                by where_clause;

run;

proc print data=&syslast;

     title6 &syslast;

run;

 

/* export as SAS data set */

data 'ValueLevel';

                set valuelevel;

run;

 

/* export as Excel file (buggy in Citrix) */

proc export

                data=valuelevel

                outfile='valuelevel.xls'

                dbms = xls

                replace;

                version = 2003;

run;
