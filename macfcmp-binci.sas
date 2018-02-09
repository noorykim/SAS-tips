%macro exbinci;
	%if &y eq . %then
		%let y = 0;

	%if &numerator eq . %then
		%let numerator = 0;
	%let denom = %eval(&numerator - &y);

	data temp;
		yn=1;
		wt=&y;
		output;
		yn=2;
		wt=&denom;
		output;
	run;

	ods exclude all;

	proc freq data=temp;
		weight wt / zeroes;

		table yn / binomial (exact) alpha=0.05;
			output out=temp2 binomial;
	run;

	ods exclude none;

	%*          proc print data=temp2;
	%*          run;
	data _null_;
		set temp2;
		call symput('p', _BIN_);

		%*length _lcl _ucl _ci _lcl_pct _ucl_pct _ci_pct $50;
		if 0 le XL_BIN le 1 then
			do;
				_lcl     = strip(put(XL_BIN, 8.&ndecimals));
				_lcl_pct = strip(put(XL_BIN, percent9.&ndecimals));
			end;
		else /*if XL_BIN = 0 then

			*/
		do;
			_lcl     = "NA";
			_lcl_pct = "NA";
		end;

		call symput('LCL', _lcl);
		call symput('LCL_PCT', _lcl_pct);

		if 0 le XU_BIN le 1 then
			do;
				_ucl     = strip(put(XU_BIN, 8.&ndecimals));
				_ucl_pct = strip(put(XU_BIN, percent9.&ndecimals));
			end;
		else /*if XU_BIN = 0 then

			*/
		do;
			_ucl     = "NA";
			_ucl_pct = "NA";
		end;

		call symput('UCL', _ucl);
		call symput('UCL_PCT', _ucl_pct);
		_ci     = '(' || strip(_lcl) || ', ' || strip(_ucl) || ')';
		_ci_pct = '(' || strip(_lcl_pct) || ', ' || strip(_ucl_pct) || ')';
		call symput('CI', _ci);
		call symput('CI_PCT', _ci_pct);
	run;

%mend exbinci;

%macro wald;
	%if &y eq . %then
		%let y = 0;

	%if &numerator eq . %then
		%let numerator = 0;
	%let denom = %eval(&numerator - &y);

	data temp;
		yn=1;
		wt=&y;
		output;
		yn=2;
		wt=&denom;
		output;
	run;

	ods exclude all;

	proc freq data=temp;
		weight wt / zeroes;

		table yn / binomial (wald) alpha=0.05;
			output out=temp2 binomial;
	run;

	ods exclude none;

	proc print data=temp2;
	run;

	data _null_;
		set temp2;
		call symput('p', _BIN_);

		%*length _lcl _ucl _ci _lcl_pct _ucl_pct _ci_pct $50;
		if L_BIN > 0 then
			do;
				_lcl     = strip(put(L_BIN, 8.&ndecimals));
				_lcl_pct = strip(put(L_BIN, percent9.&ndecimals));
			end;
		else if L_BIN = 0 then
			do;
				_lcl     = "NA";
				_lcl_pct = "NA";
			end;

		call symput('LCL', _lcl);
		call symput('LCL_PCT', _lcl_pct);

		if U_BIN > 0 then
			do;
				_ucl     = strip(put(U_BIN, 8.&ndecimals));
				_ucl_pct = strip(put(U_BIN, percent9.&ndecimals));
			end;
		else if U_BIN = 0 then
			do;
				_ucl     = "NA";
				_ucl_pct = "NA";
			end;

		call symput('UCL', _ucl);
		call symput('UCL_PCT', _ucl_pct);
		_ci     = '(' || strip(_lcl) || ', ' || strip(_ucl) || ')';
		_ci_pct = '(' || strip(_lcl_pct) || ', ' || strip(_ucl_pct) || ')';
		call symput('CI', _ci);
		call symput('CI_PCT', _ci_pct);
	run;

%mend wald;

%macro exbinci;
	%if &y eq . %then
		%let y = 0;

	%if &numerator eq . %then
		%let numerator = 0;
	%let denom = %eval(&numerator - &y);

	data temp;
		yn=1;
		wt=&y;
		output;
		yn=2;
		wt=&denom;
		output;
	run;

	ods exclude all;

	proc freq data=temp;
		weight wt / zeroes;

		table yn / binomial (exact) alpha=0.05;
			output out=temp2 binomial;
	run;

	ods exclude none;

	%*          proc print data=temp2;
	%*          run;
	data _null_;
		set temp2;
		call symput('p', _BIN_);

		%*length _lcl _ucl _ci _lcl_pct _ucl_pct _ci_pct $50;
		if XL_BIN > 0 then
			do;
				_lcl     = strip(put(XL_BIN, 8.&ndecimals));
				_lcl_pct = strip(put(XL_BIN, percent9.&ndecimals));
			end;
		else if XL_BIN = 0 then
			do;
				_lcl     = "NA";
				_lcl_pct = "NA";
			end;

		call symput('LCL', _lcl);
		call symput('LCL_PCT', _lcl_pct);

		if XU_BIN > 0 then
			do;
				_ucl     = strip(put(XU_BIN, 8.&ndecimals));
				_ucl_pct = strip(put(XU_BIN, percent9.&ndecimals));
			end;
		else if XU_BIN = 0 then
			do;
				_ucl     = "NA";
				_ucl_pct = "NA";
			end;

		call symput('UCL', _ucl);
		call symput('UCL_PCT', _ucl_pct);
		_ci     = '(' || strip(_lcl) || ', ' || strip(_ucl) || ')';
		_ci_pct = '(' || strip(_lcl_pct) || ', ' || strip(_ucl_pct) || ')';
		call symput('CI', _ci);
		call symput('CI_PCT', _ci_pct);
	run;

%mend exbinci;

proc fcmp outlib=work.funcs.pvals;
	subroutine wald(y, numerator, p, lcl $, ucl $, ci $);

		%*                          length lcl ucl ci $50;
		outargs p, lcl, ucl, ci;
		rc = run_macro('wald', y, numerator, p, lcl, ucl, ci);
	endsub;

	subroutine wald_ci(y, numerator, ci $);
		outargs ci;
		rc = run_macro('wald', y, numerator, ci);
	endsub;

	subroutine wald_ci_pct(y, numerator, ci_pct $);
		outargs ci_pct;
		rc = run_macro('wald', y, numerator, ci_pct);
	endsub;

	subroutine exbin(y, numerator, p, lcl $, ucl $, ci $);
		outargs p, lcl, ucl, ci;
		rc = run_macro('exbinci', y, numerator, p, lcl, ucl, ci);
	endsub;

	subroutine exbin_ci(y, numerator, ci $);
		outargs ci;
		rc = run_macro('exbinci', y, numerator, ci);
	endsub;

	subroutine exbin_ci_pct(y, numerator, ci_pct $);
		outargs ci_pct;
		rc = run_macro('exbinci', y, numerator, ci_pct);
	endsub;
run;

options cmplib=work.funcs;

/*data test;

      a1 = 2; n1 = 10; output;

      a1 = 0; n1 = 10; output;

      a1 = 10; n1 = 10; output;

      a1 = 20; n1 = 110; output;

run;

*/

%*data test;
%*          set test;
%*         

%*          length lcl ucl ci ci2 ci_pct $50;
%*          call missing(p, lcl, ucl, ci, ci2, ci_pct);
%* initialize variables;
%*          call exbin(a1, n1, p, lcl, ucl, ci);
%*          call exbin_ci(a1, n1, ci2);
%*          call exbin_ci_pct(a1, n1, ci_pct);
%*run;
