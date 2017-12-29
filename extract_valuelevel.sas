data xfdf;
	/* import */
	/* https://www.pharmasug.org/proceedings/2011/CC/PharmaSUG-2011-CC22.pdf */
	length line $32767  _pagenum $3 _fontsize $4 text $50;
	infile "blankcrf.xfdf" lrecl = 32767 length = lg;
	input line $varying32767. lg;

	/* filter */
	if find(line, 'font-size') > 0 or find(line, 'page') > 0 or find(line, '</p') > 0 ;

	/* page number */
	if find(line, 'page') > 0 then do;
		entry+1;
		_pagenum = substr(line, find(line, 'page') + 6, 3);
		_pagenum = compress(_pagenum, '"');
		pagenum = input(_pagenum, 3.);

		/* adjustment as xfdf identifies page 2 as page 1 */
		pagenum = pagenum + 1;
	end;
	else if find(line, 'font-size') > 0 then do;
		_fontsize = substr(line, find(line, 'font-size') + 10, 4);
		fontsize = input(_fontsize, best8.);
	end;
	else if find(line, '</p') > 0 and find(line, '></p') = 0 then do;
		text = substr(line, 2, length(strip(line))-4);
		
		/* remove spaces surrounding equals sign */
		text = tranwrd(text, ' = ', '=');
		text = tranwrd(text, ' =', '=');
		text = tranwrd(text, '= ', '=');

		fontsize = input(_fontsize, best8.);
	end;

	keep entry pagenum fontsize text;
run;

data xfdf_;
	update xfdf (obs=0) xfdf;
	by entry;
run;

data xfdf_;
	set xfdf_;

	length dataset variable testcd qnam $8 _where_clause where_clause $50;
	if find(text, 'not submitted', 'i') > 0 then delete;
	else if find(text, '=', 'i') = 0 then variable = text;
	else if find(text, 'when', 'i') = 0 then do;
		if fontsize = 11 then variable = scan(text, 1, '=');
		else if fontsize = 14 then dataset = scan(text, 1, '=');
	end;
	else if find(text, 'orres', 'i') > 0 then do;
		dataset = substr(text, 1, 2);
		variable = scan(text, 1);
		testcd = substr(text, find(text, '=', 'i') + 1);
		_where_clause = tranwrd(scan(text, 3), '=', '.');
		where_clause = catx('.', dataset, _where_clause);
	end;
	else if find(text, 'qnam', 'i') > 0 then do;
		dataset = scan(text, 1, '.');
		variable = 'QVAL';
		qnam = substr(text, find(text, '=', 'i') + 1);
		_where_clause = tranwrd(scan(text, 3, ' '), '=', '.');
		where_clause = catx('.', dataset, _where_clause);
	end;

run;

proc sort data=xfdf_;
/*	by pagenum  descending fontsize  text;*/
	by dataset variable where_clause pagenum;
run;

/*proc print data=&syslast (obs=30);*/
/*	where where_clause ne ' ';*/
/*run;*/


data _valuelevel;
	set xfdf_;
	where where_clause ne ' ';
	keep pagenum dataset variable where_clause ;
run;
proc sort data=&syslast noduprecs;
	by dataset variable where_clause pagenum;
run;

/* concatenate page numbers */
data valuelevel;
	length pages $50;
	do until (last.where_clause);
    	set _valuelevel;
		by dataset variable where_clause notsorted;
		pages = catx(' ', pages, put(pagenum, 3.) );
	end;
	drop pagenum;
run;

%let valuelevel_vars = 
	order dataset variable where_clause data_type length 
	Significant_Digits Format Mandatory Codelist Origin Pages 
	;

data valuelevel;
	format &valuelevel_vars ;
	set valuelevel;
	by dataset variable ;

	if first.variable then order = .;
	order+1;

	origin = 'CRF';

	array blanks[*] $ data_type length Significant_Digits Format Codelist ;
	do i = 1 to dim(blanks);
		blanks[i] = ' ';
	end;

	keep &valuelevel_vars ;
run;

proc print data=&syslast (obs=30);
run;

proc export 
	data=valuelevel 
	dbms=xlsx 
	outfile="valuelevel.xlsx" 
	replace;
run;
