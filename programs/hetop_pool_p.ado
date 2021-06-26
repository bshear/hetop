*! version 0.4 06feb2018, Benjamin R. Shear benjamin.shear@colorado.edu

* 0.2: add if / in support
* 0.3: rename equations mean and lnsigma
* 0.4: switch to -predict- from -predictnl- for sigma's

cap program drop hetop_pool_p
program define hetop_pool_p , rclass sortpreserve
	version 13.1

	syntax namelist(max=1) [if] [in] [ , mean sigma se ]

	marksample touse , novarlist

	local predtype "`mean'`sigma'"

	if "`predtype'" == "mean" {
		_predict double `namelist' if `touse' , eq(mean) xb
		label var `namelist' "predicted mean"	
		if "`se'" != "" {
			_predict double `namelist'_se if `touse' , eq(mean) stdp
			label var `namelist'_se "SE of predicted mean"
		}
	}
	else if "`predtype'" == "sigma" {
		_predict double `namelist' if `touse' , eq(lnsigma) xb
		qui replace `namelist' = exp(`namelist') if `touse'
		label var `namelist' "predicted sd"		
		if "`se'" != "" {
			_predict double `namelist'_se if `touse' , eq(lnsigma) stdp
			qui replace `namelist'_se = `namelist'_se * `namelist' if `touse'
			label var `namelist'_se "SE of predicted sd"
		}
	}
	else {
		di as error ///
			"error: prediction type must be one of mean or sigma"
		exit 198
	}

end

/*
* not currently used; could be for more complex options in future
program define ParseSyn, sclass
	version 13.1

	syntax anything

	local allopts "`anything'"
	local nopts : word count `allopts'
	if `nopts' > 1 {
		di as error "error: specify only 1 type of prediction"
		exit 198
	}
	if `nopts' == 0 {
		di as error "error: must specify at least 1 type of prediction"
		exit 198
	}

	sreturn local predtype "`anything'"

end
*/

