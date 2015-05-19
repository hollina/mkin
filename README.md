# mkin

The R package **mkin** provides calculation routines for the analysis of
chemical degradation data, including <b>m</b>ulticompartment <b>kin</b>etics as
needed for modelling the formation and decline of transformation products, or
if several compartments are involved.

## Installation

You can install the latest released version from 
[CRAN](http://cran.r-project.org/package=mkin) from within R:


```r
install.packages("mkin")
```

If looking for the latest features, you can install directly from 
[github](http://github.com/jranke/mkin), e.g.  using the `devtools` package.
Using `quick = TRUE` skips docs, multiple-architecture builds, demos, and
vignettes, to make installation as fast and painless as possible.


```r
require(devtools)
install_github("jranke/mkin", quick = TRUE)
```

## Background

In the regulatory evaluation of chemical substances like plant protection
products (pesticides), biocides and other chemicals, degradation data play an
important role. For the evaluation of pesticide degradation experiments, 
detailed guidance and helpful tools have been developed as detailed in
'Credits and historical remarks' below.

## Usage

The simplest usage example that I can think of, using model shorthand notation
(available since mkin 0.9-32) and a built-in dataset is


```r
library(mkin)
```

```
## Loading required package: minpack.lm
## Loading required package: rootSolve
```

```r
fit <- mkinfit("SFO", FOCUS_2006_C, quiet = TRUE)
plot(fit, show_residuals = TRUE) 
```

![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png) 


```r
# Output not shown in this README to avoid distraction
summary(fit)
```

A still very simple usage example including the definition of the same data in R
code would be


```r
example_data = data.frame(
  name = rep("parent", 9),
  time = c(0, 1, 3, 7, 14, 28, 63, 91, 119),
  value = c(85.1, 57.9, 29.9, 14.6, 9.7, 6.6, 4, 3.9, 0.6)
)
fit2 <- mkinfit("FOMC", example_data, quiet = TRUE)
plot(fit2, show_residuals = TRUE) 
```

![plot of chunk unnamed-chunk-5](figure/unnamed-chunk-5-1.png) 

A fairly complex usage example using another built-in dataset:


```
## Loading required package: methods
```


```r
data <- mkin_wide_to_long(schaefer07_complex_case, time = "time")

model <- mkinmod(
  parent = mkinsub("SFO", c("A1", "B1", "C1"), sink = FALSE),
  A1 = mkinsub("SFO", "A2"),
  B1 = mkinsub("SFO"),
  C1 = mkinsub("SFO"),
  A2 = mkinsub("SFO"), use_of_ff = "max")
```

```
## Compiling differential equation model from auto-generated C code...
```

```r
fit3 <- mkinfit(model, data, method.modFit = "Port")
```

```
## Model cost at call  1 :  2511.655 
## Model cost at call  2 :  2511.655 
## Model cost at call  11 :  1436.639 
## Model cost at call  12 :  1436.638 
## Model cost at call  13 :  1436.566 
## Model cost at call  21 :  643.6583 
## Model cost at call  22 :  643.6583 
## Model cost at call  23 :  643.6582 
## Model cost at call  29 :  643.6576 
## Model cost at call  31 :  454.0244 
## Model cost at call  32 :  454.0241 
## Model cost at call  34 :  454.0229 
## Model cost at call  43 :  378.1144 
## Model cost at call  45 :  378.1143 
## Model cost at call  53 :  357.245 
## Model cost at call  55 :  357.2449 
## Model cost at call  56 :  357.2447 
## Model cost at call  63 :  354.3415 
## Model cost at call  64 :  354.3415 
## Model cost at call  65 :  354.3413 
## Model cost at call  73 :  332.49 
## Model cost at call  74 :  332.49 
## Model cost at call  81 :  332.4899 
## Model cost at call  83 :  315.2962 
## Model cost at call  84 :  306.3085 
## Model cost at call  86 :  306.3084 
## Model cost at call  87 :  306.3084 
## Model cost at call  92 :  306.3083 
## Model cost at call  94 :  290.6377 
## Model cost at call  96 :  290.6375 
## Model cost at call  98 :  290.6375 
## Model cost at call  101 :  290.6371 
## Model cost at call  105 :  269.09 
## Model cost at call  107 :  269.0899 
## Model cost at call  115 :  259.7551 
## Model cost at call  120 :  259.7549 
## Model cost at call  123 :  259.7547 
## Model cost at call  126 :  253.7973 
## Model cost at call  128 :  253.7972 
## Model cost at call  137 :  251.7358 
## Model cost at call  139 :  251.7358 
## Model cost at call  147 :  250.7394 
## Model cost at call  149 :  250.7393 
## Model cost at call  157 :  249.1148 
## Model cost at call  159 :  249.1148 
## Model cost at call  167 :  246.8768 
## Model cost at call  169 :  246.8768 
## Model cost at call  177 :  244.9758 
## Model cost at call  179 :  244.9758 
## Model cost at call  187 :  243.2914 
## Model cost at call  189 :  243.2914 
## Model cost at call  190 :  243.2914 
## Model cost at call  194 :  243.2914 
## Model cost at call  199 :  242.9202 
## Model cost at call  201 :  242.9202 
## Model cost at call  202 :  242.9202 
## Model cost at call  209 :  242.7695 
## Model cost at call  211 :  242.7695 
## Model cost at call  216 :  242.7695 
## Model cost at call  219 :  242.5771 
## Model cost at call  221 :  242.5771 
## Model cost at call  229 :  242.4402 
## Model cost at call  231 :  242.4402 
## Model cost at call  239 :  242.1878 
## Model cost at call  241 :  242.1878 
## Model cost at call  249 :  242.0553 
## Model cost at call  251 :  242.0553 
## Model cost at call  256 :  242.0553 
## Model cost at call  259 :  241.8761 
## Model cost at call  260 :  241.7412 
## Model cost at call  261 :  241.6954 
## Model cost at call  264 :  241.6954 
## Model cost at call  275 :  241.5982 
## Model cost at call  277 :  241.5982 
## Model cost at call  285 :  241.5459 
## Model cost at call  287 :  241.5459 
## Model cost at call  295 :  241.4837 
## Model cost at call  297 :  241.4837 
## Model cost at call  305 :  241.3882 
## Model cost at call  306 :  241.3161 
## Model cost at call  307 :  241.2315 
## Model cost at call  309 :  241.2315 
## Model cost at call  314 :  241.2315 
## Model cost at call  317 :  240.9738 
## Model cost at call  322 :  240.9738 
## Model cost at call  327 :  240.8244 
## Model cost at call  329 :  240.8244 
## Model cost at call  337 :  240.7005 
## Model cost at call  339 :  240.7005 
## Model cost at call  342 :  240.7005 
## Model cost at call  347 :  240.629 
## Model cost at call  350 :  240.629 
## Model cost at call  357 :  240.6193 
## Model cost at call  358 :  240.6193 
## Model cost at call  364 :  240.6193 
## Model cost at call  367 :  240.6193 
## Model cost at call  369 :  240.5873 
## Model cost at call  374 :  240.5873 
## Model cost at call  380 :  240.578 
## Model cost at call  382 :  240.578 
## Model cost at call  390 :  240.5723 
## Model cost at call  393 :  240.5723 
## Model cost at call  403 :  240.569 
## Model cost at call  404 :  240.569 
## Model cost at call  413 :  240.569 
## Model cost at call  415 :  240.5688 
## Model cost at call  416 :  240.5688 
## Model cost at call  417 :  240.5688 
## Model cost at call  431 :  240.5686 
## Model cost at call  432 :  240.5686 
## Model cost at call  434 :  240.5686 
## Model cost at call  443 :  240.5686 
## Model cost at call  444 :  240.5686 
## Model cost at call  447 :  240.5686 
## Model cost at call  449 :  240.5686 
## Model cost at call  450 :  240.5686 
## Model cost at call  466 :  240.5686 
## Model cost at call  470 :  240.5686 
## Model cost at call  485 :  240.5686 
## Model cost at call  509 :  240.5686 
## Optimisation by method Port successfully terminated.
```

```r
plot(fit3, show_residuals = TRUE) 
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png) 

```r
#summary(fit3) # Commented out to avoid distraction from README content
mkinparplot(fit3)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-2.png) 

For more examples and to see results, have a look at the examples provided in the
[`mkinfit`](http://kinfit.r-forge.r-project.org/mkin_static/mkinfit.html)
documentation or the package vignettes referenced from the 
[mkin package documentation page](http://kinfit.r-forge.r-project.org/mkin_static/index.html)

## Features

* Highly flexible model specification using
  [`mkinmod`](http://kinfit.r-forge.r-project.org/mkin_static/mkinmod.html),
  including equilibrium reactions and using the single first-order 
  reversible binding (SFORB) model, which will automatically create
  two latent state variables for the observed variable.
* Model solution (forward modelling) in the function
  [`mkinpredict`](http://kinfit.r-forge.r-project.org/mkin_static/mkinpredict.html) 
  is performed either using the analytical solution for the case of 
  parent only degradation, an eigenvalue based solution if only simple
  first-order (SFO) or SFORB kinetics are used in the model, or
  using a numeric solver from the `deSolve` package (default is `lsoda`).
  These have decreasing efficiency, and are automatically chosen 
  by default. 
* As of mkin 0.9-36, model solution for models with more than one observed
  variable is based on the
  [`ccSolve`](https://github.com/karlines/ccSolve) package, if installed.
  This is even faster than eigenvalue based solution, at least in the example
  shown in the [vignette `compiled_models`](http://rawgit.com/jranke/mkin/master/vignettes/compiled_models.html)
* Model optimisation with 
  [`mkinfit`](http://kinfit.r-forge.r-project.org/mkin_static/mkinfit.html)
  internally using the `modFit` function from the `FME` package,
  but using the Port routine `nlminb` per default.
* By default, kinetic rate constants and kinetic formation fractions are
  transformed internally using
  [`transform_odeparms`](http://kinfit.r-forge.r-project.org/mkin_static/transform_odeparms.html)
  so their estimators can more reasonably be expected to follow
  a normal distribution. This has the side effect that no constraints
  are needed in the optimisation. Thanks to René Lehmann for the nice
  cooperation on this, especially the isometric logration transformation
  that is now used for the formation fractions.
* A side effect of this is that when parameter estimates are backtransformed
  to match the model definition, confidence intervals calculated from
  standard errors are also backtransformed to the correct scale, and will
  not include meaningless values like negative rate constants or 
  formation fractions adding up to more than 1, which can not occur in 
  a single experiment with a single defined radiolabel position.
* Summary and plotting functions. The `summary` of an `mkinfit` object is in
  fact a full report that should give enough information to be able to
  approximately reproduce the fit with other tools.
* The chi-squared error level as defined in the FOCUS kinetics guidance
  (see below) is calculated for each observed variable.
* I recently added iteratively reweighted least squares in a similar way
  it is done in KinGUII and CAKE (see below). Simply add the argument
  `reweight = "obs"` to your call to `mkinfit` and a separate variance 
  componenent for each of the observed variables will be optimised
  in a second stage after the primary optimisation algorithm has converged.
* When a metabolite decline phase is not described well by SFO kinetics, 
  either IORE kinetics or SFORB kinetics can be used for the metabolite, 
  adding one respectively two parameters to the system.

## GUI

There is a graphical user interface that I consider useful for real work. Please
refer to its [documentation page](http://kinfit.r-forge.r-project.org/gmkin_static)
for installation instructions and a manual.
  
## News

Yes, there is a ![Changelog](NEWS.md).

## Credits and historical remarks

`mkin` would not be possible without the underlying software stack consisting
of R and the packages [deSolve](http://cran.r-project.org/package=deSolve),
[minpack.lm](http://cran.r-project.org/package=minpack.lm) and
[FME](http://cran.r-project.org/package=FME), to say the least.

It could not have been written without me being introduced to regulatory fate
modelling of pesticides by Adrian Gurney during my time at Harlan Laboratories
Ltd (formerly RCC Ltd). `mkin` greatly profits from and largely follows
the work done by the 
[FOCUS Degradation Kinetics Workgroup](http://focus.jrc.ec.europa.eu/dk),
as detailed in their guidance document from 2006, slightly updated in 2011.

Also, it was inspired by the first version of KinGUI developed by
BayerCropScience, which is based on the MatLab runtime environment.

The companion package 
[kinfit](http://kinfit.r-forge.r-project.org/kinfit_static/index.html) was 
[started in 2008](https://r-forge.r-project.org/scm/viewvc.php?view=rev&root=kinfit&revision=2) and 
[first published](http://cran.r-project.org/src/contrib/Archive/kinfit/) on
CRAN on 01 May 2010.

The first `mkin` code was 
[published on 11 May 2010](https://r-forge.r-project.org/scm/viewvc.php?view=rev&root=kinfit&revision=8) and the 
[first CRAN version](http://cran.r-project.org/src/contrib/Archive/mkin)
on 18 May 2010.

In 2011, Bayer Crop Science started to distribute an R based successor to KinGUI named 
KinGUII whose R code is based on `mkin`, but which added, amongst other
refinements, a closed source graphical user interface (GUI), iteratively
reweighted least squares (IRLS) optimisation of the variance for each of the
observed variables, and Markov Chain Monte Carlo (MCMC) simulation
functionality, similar to what is available e.g. in the `FME` package.

Somewhat in parallel, Syngenta has sponsored the development of an `mkin` and
KinGUII based GUI application called CAKE, which also adds IRLS and MCMC, is
more limited in the model formulation, but puts more weight on usability.
CAKE is available for download from the [CAKE
website](http://projects.tessella.com/cake), where you can also
find a zip archive of the R scripts derived from `mkin`, published under the GPL
license.

Finally, there is 
[KineticEval](http://github.com/zhenglei-gao/KineticEval), which contains 
a further development of the scripts used for KinGUII, so the different tools
will hopefully be able to learn from each other in the future as well.


## Development

Contributions are welcome! Your 
[mkin fork](https://help.github.com/articles/fork-a-repo) is just a mouse click
away... The master branch on github should always be in good shape, I implement 
new features in separate branches now. If you prefer subversion, project
members for the 
[r-forge project](http://r-forge.r-project.org/R/?group_id=615) are welcome as well.
Generally, the source code of the latest CRAN version should be available there.
