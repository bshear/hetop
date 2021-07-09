*! version 0.6 02may2018, Benjamin R. Shear benjamin.shear@colorado.edu

* 0.2: refine the Replay / Estimate structure; add title() to maximize; add level(cilevel) support
* 0.3: add if/in support
* 0.4: rename equations "mean" "lnsigma" instead of location and scale
* 0.5: data checking
* 0.6: make mean() and lns() optional to allow blanks that fit constant-only model

cap program drop hetop_pool
program define hetop_pool , eclass sortpreserve
	
	version 13.1
	
	// setup, e.g., macro drop
	macro drop HET_*
	
	if replay() {
		Replay `0'
	}
	else {
		Estimate `0'
	}
	
	// cleanup, e.g. macro or constraint drop
	macro drop HET_*
	
end

program define Estimate , eclass sortpreserve
	version 13.1

	syntax varlist [if] [in] , /// category frequency
		k(varname) /// number of categories in cells
		kappa(varname) /// cutscores
		[ ///
		Mean(string) ///
		LNSigma(string) ///
		Level(cilevel) * ///
		CHECKby(varname) /// integer defining cells; check within this
		]

	marksample touse

	tokenize `varlist'
	local y `1'
	local freq `2'

	local diopts level(`level')
	mlopts mlopts , `options'

	global HET_y `y'
	global HET_freq `freq'
	global HET_k `k'
	global HET_kappa `kappa'

	* data checking
	* order of cut scores matches order of y
	* k is constant within `checkby'
	
	if "`checkby'" != "" {
		preserve
		tempvar c1 c2 c3 c4
		bys `checkby' : egen `c1' = sd(`k')
		qui count if `c1' != 0
		if r(N) > 0 {
			noi di as error "error: `k' is not constant within cells"
			error 499
		}
		sort `checkby' `y'
		g `c2' = _n
		sort `checkby' `kappa' `y'
		g `c3' = _n
		qui count if `c2' != `c3'
		if r(N) > 0 {
			noi di as error "error: order of `y' and `kappa' do not match"
			error 499
		}
		bys `checkby' : g `c4' = _N
		qui count if `c4' != `k'
		if r(N) > 0 {
			noi di as error "error: number of observed categories does not equal `k'"
			error 499
		}
		restore
	}

	ml model lf hetop_pool_lf (mean: `mean') (lnsigma: `lnsigma') if `touse' , ///
		maximize title("hetop_pool estimation") `mlopts' search

	ereturn local cmd "hetop_pool"
	ereturn local predict "hetop_pool_p"

	Replay , `diopts'

end

program Replay
	
	syntax [, Level(cilevel)]
	if "`e(cmd)'" != "hetop_pool" {
		error 301
	}

	local diopts level(`level')

	ml display , `diopts'

end

