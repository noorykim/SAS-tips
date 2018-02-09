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
