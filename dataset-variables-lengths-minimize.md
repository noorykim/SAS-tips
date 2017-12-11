# Minimize the lengths of variables

SDTM datasets submitted to the FDA are expected to have variable lengths equal to the length of the longest value (up to 200 characters).  This macro minimizes the lengths of the variables in a data set.

## Macro
[dataset-variables-lengths-minimize.sas](dataset-variables-lengths-minimize.sas)

## Pseudocode
1. Retrieve the names of the character variables in the data set.
2. Use names to construct PROC SQL syntax to find the minmax length needed for each variable. (e.g. "max(length(var1)) as var1")
3. Concatenate the values from step (2) into a single string, separated by commas.
4. Get the minmax lengths of the character variables.
5. Replace the variable lengths with the results from step (4).

## Parameters
```
%trimVarLength(dataset, libname=WORK);
```

## 3rd party macros which minimize variable lengths
[SAS Sample 35230](http://support.sas.com/kb/35/230.html)

[Wayne Zhong](http://www.pharmasug.org/proceedings/2012/CC/PharmaSUG-2012-CC17.pdf)

[Sandra VanPelt Nguyen](http://www.lexjansen.com/pharmasug/2014/CC/PharmaSUG-2014-CC37.pdf)

# .

[Portfolio](/)
