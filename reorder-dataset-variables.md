There are several options for reordering variables within a DATA step, including LENGTH, RETAIN, and FORMAT. My preferred method is using a FORMAT statement before SET statement. It's simple and carries no side effects.

'''
%let dsvars = STUDYID DOMAIN USUBJID;

data dm;
  format &dsvars;
  set dm;
run;
'''
