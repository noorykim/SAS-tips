# Reorder the variables in a data set

There are several options for reordering variables within a DATA step, including LENGTH, RETAIN, and FORMAT. I find using a FORMAT statement before the SET statement is the simplest and cleanest method. It requires only an ordered list of the names of the variables.

```markdown
%let varnames = var1 var2 var3;

data ds;
  format &varnames;
  set ds;
run;
```
A LENGTH statement is more tedious, as it also requires the inclusion of variable lengths, even if they have already been defined. A  RETAIN statement can result in the overwriting of missing values, an undesired side effect. 

If the variables are stored in a macro variable, then we can keep just those variables in the data set with a KEEP option or statement.
```
data ds;
  format &varnames;
  set ds (keep=&varnames);
run;
```

##

[SAS Tips](/sas-tips)

[Portfolio](/)


##

Posted 2017-08-16

Lasted updated 2017-08-21
