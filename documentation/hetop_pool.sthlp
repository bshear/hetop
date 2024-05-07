{smcl}
{* last edited 06 May 2024}{...}
{hline}
Help file for {cmd: hetop_pool} version 0.6
{hline}

{title:Title}

{phang}
{bf:hetop_pool} {hline 2} Estimate pooled heteroskedastic ordered probit models via maximum likelihood

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:hetop_pool}
{it: category_var frequency_var}
[{help if}]
[{help in}]
{cmd:,} {opt k(varname)} {opt kappa(varname)}
[ {it:options} ]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Required }

{synopt:{opt k(varname)}}
Name of variable indicating the total number of categories in the cell.

{synopt:{opt kappa(varname)}} 
Name of variable containing the (known) cutscores between categories.

{syntab:Optional}

{synopt:{opt m:ean(string)}}  
Model for group means.

{synopt:{opt lns:igma(string)}}  
Model for group ln(SD) values.

{synopt:{opt l:evel(cilevel)}}  
Set confidence level; default is level(95).

{synopt:{opt check:by(varname)}}  
Integer variable defining the cells.

{synopt:{opt *}}
Additional options for -mlopts-

{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
This program estimates group means and standard deviations based on ordered frequency counts using a heteroskedastic ordered probit (HETOP) model framework. 

{pstd}
Estimation of group means and standard deviations is carried out by {bf: hetop_pool} assuming the cutscores between ordered categories are already known.

{pstd}
Parameters are estimated via maximum likelihood estimation using -ml-.

{pstd}
The raw data for use in {bf: hetop_pool} are observed frequency counts of ordered variables for one or more groups across one or more occasions. Let F_gtk be the observed frequency count of observations Y=k for group g on occasion t in category k.

{pstd}
Let the outcome variable observed across groups on occasion t be Y^t. In the HETOP framework we assume that the observed variable Y^t is a coarsened version of an underlying normally distributed continuous variable Y^(*t). 

{pstd} 
The data for {bf: hetop_pool} must be in long form. Each row represents one observed value F_gtk. This is the variable {it:frequency_var}. Let Y^t have K categories, {1,2,...K}. The variable {it:category_var} indicates which category k the observed count is from.

{pstd}
Sample data structure:

     +--------------------------------------------------------------------+
     |  group  occasion  category_var  frequency_var  k  kappa  cell  X1  |
     |--------------------------------------------------------------------|
     |    1       1           1             100       4   -0.9    1    3  |
     |    1       1           2             125       4    0.0    1    3  |
     |    1       1           3              75       4    0.9    1    3  |
     |    1       1           4              20       4    0.9    1    3  |
     |    1       2           1              15       3   -1.0    2    0  |
     |    1       2           2              90       3   -0.2    2    0  |
     |    1       2           3              80       3   -0.2    2    0  |
     |    2       1           1             150       4   -0.9    3   -1  |
     |    2       1           2             200       4    0.0    3   -1  |
     |    2       1           3             175       4    0.9    3   -1  |
     |    2       1           4              40       4    0.9    3   -1  |
     |   ...     ...         ...            ...      ...   ...   ...  ... |
     |--------------------------------------------------------------------|

{pstd}
A single "cell" consists of the K rows representing all frequency counts for a single group g on occasion t. The mean and standard deviation of the underlying variable in each cell are the targets of estimation. {bf: hetop_pool} allows you to model the mean and standard deviation of the underlying variable Y^(*t) as a function of covariates. These covariates could be indicator variables for each cell to estimate a unique mean and standard deviation in each cell, or a more parametric model can be specified (e.g., the means or standard deviations are modeled as a linear function of covariates). The covariates are assumed to be constant within cells.

{pstd}
The scale of the estimates is determined by the cutscores provided in {it:kappa}.

{pstd}
Various undocumented options can be passed to {bf: hetop_pool} that will be parsed by -mlopts-.

{pstd}
No checks are conducted by {bf: hetop_pool} as to whether there are sufficient data to identify and estimate the intended parameters specified. This must be established by the user.

{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt k(varname)}  
This variable indicates which of the K categories the frequency count in the current row represents. 

{phang}
{opt kappa(varname)}  
The variable {it:kappa} contains the known cutscores separating the observed categories of Y^t on the underlying Y^(*t) metric. These are assumed to already be known. There are K-1 cutscores per cell {c_1, c_2, ... c_(K-1)}. The cutscore in the variable {it:kappa} for the row associated with {it: category_var}=k represents the upper (right hand) boundary of category k, except when {it:category_var}=K for which there is no upper boundary, in which case the highest cutscore is repeated from the row for {it: category_var}=(K-1).

{phang}
{opt m:ean(string)}  
An expression indicating a model for the latent means. If omitted a constant-only model estimating a single mean across all cells will be used. 

{phang}
{opt lns:igma(string)}  
An expression indicating a model for the latent standard deviations (technically, a model for ln(SD)). If omitted a constant-only model estimating a single ln(SD) across all cells will be used. 

{phang}
{opt l:evel(cilevel)}  

{phang}
{opt check:by(varname)}  
If supplied, the variable {it:checkby} indicates which set of rows go together to form the set of K values of F_gtk in a single cell.

{phang}
{opt *} 
Specify additional ML options that will be handled by -mlopts-.

{marker examples}{...}
{title:Examples}

use "hetop_pool-example.dta" , clear

* To estimate a unique mean and standard deviation for each group 
* on each occasion (each "cell"):
hetop_pool y fcount , mean(ibn.cell, nocons) lnsigma(ibn.cell, nocons) ///
	k(k) kappa(kappa)	

* To estimate a model where each cell has a unique mean, 
* but the ln(SD) values are a linear function of the variables "grade" and "year":
hetop_pool y fcount , mean(ibn.cell, nocons) lnsigma(grade year) ///
	k(k) kappa(kappa)	

* After estimation, calculate the model-implied mean (mstar) and SD (sstar) with 
* associated standard errors (mstar_se and sstar_se) for each cell using -predict-:
predict mstar , mean se
predict sstar , sigma se

* Note: the predicted values are constant within each cell and will be repeated 
* in the long form data used for estimation


{title:Stored results}

{pstd}
Standard elements returned by -ml-. 

{pstd}
Use -predict- postestimation command to produce the estimated cell means and standard deviations (see examples).

{synoptset 15 tabbed}{...}

{title:References}

{pstd}
For additional statistical details see:

{pstd}
Reardon, S. F., Shear, B. R., Castellano, K. E., & Ho, A. D.
(2017). Using heteroskedastic ordered probit models to recover moments
of continuous test score distributions from coarsened data.
{it:Journal of Educational and Behavioral Statistics}, {it:42}(1), 3–45.
{browse "https://doi.org/10.3102/1076998616666279"}

{pstd}
Shear, B. R., & Reardon, S. F. (2021). Using pooled heteroskedastic ordered probit models to improve small-sample estimates of latent test score distributions. {it:Journal of Educational and Behavioral Statistics}, {it:46}(1), 3–33.
{browse "https://doi.org/10.3102/1076998620922919"}

{title:Author}

{pstd}
Benjamin R. Shear{break}
University of Colorado Boulder{break}
benjamin.shear@colorado.edu{break}



