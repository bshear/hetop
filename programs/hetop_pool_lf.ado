*! version 0.1 25aug2017, Benjamin R. Shear benjamin.shear@colorado.edu

cap program drop hetop_pool_lf
program define hetop_pool_lf
	version 13.1

	* data are long form
	* arguments are means_equation lnsigma_equation

	gettoken lnf rest: 0
	gettoken mu rest: rest
	gettoken lnsigma rest: rest
	local sigma exp(`lnsigma')

	tempvar p
	qui gen double `p' = .

	#delimit ;

	qui replace `p' = normal(($HET_kappa-`mu')/`sigma') if $HET_y == 1;
	qui replace `p' = normal(($HET_kappa-`mu')/`sigma')-
		normal(($HET_kappa[_n-1]-`mu')/`sigma')
		if $HET_y > 1 & $HET_y < $HET_k;
	qui replace `p' = 1-normal(($HET_kappa-`mu')/`sigma') if $HET_y == $HET_k;

	#delimit cr

	qui replace `lnf' = ln(`p')*$HET_freq

end

