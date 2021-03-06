#' Produce predictions from a kinetic model using specific parameters
#' 
#' This function produces a time series for all the observed variables in a
#' kinetic model as specified by \code{\link{mkinmod}}, using a specific set of
#' kinetic parameters and initial values for the state variables.
#' 
#' @aliases mkinpredict mkinpredict.mkinmod mkinpredict.mkinfit
#' @param x A kinetic model as produced by \code{\link{mkinmod}}, or a kinetic
#'   fit as fitted by \code{\link{mkinfit}}. In the latter case, the fitted
#'   parameters are used for the prediction.
#' @param odeparms A numeric vector specifying the parameters used in the
#'   kinetic model, which is generally defined as a set of ordinary
#'   differential equations.
#' @param odeini A numeric vectory containing the initial values of the state
#'   variables of the model. Note that the state variables can differ from the
#'   observed variables, for example in the case of the SFORB model.
#' @param outtimes A numeric vector specifying the time points for which model
#'   predictions should be generated.
#' @param solution_type The method that should be used for producing the
#'   predictions. This should generally be "analytical" if there is only one
#'   observed variable, and usually "deSolve" in the case of several observed
#'   variables. The third possibility "eigen" is faster but not applicable to
#'   some models e.g.  using FOMC for the parent compound.
#' @param method.ode The solution method passed via \code{\link{mkinpredict}}
#'   to \code{\link{ode}} in case the solution type is "deSolve". The default
#'   "lsoda" is performant, but sometimes fails to converge.
#' @param use_compiled If set to \code{FALSE}, no compiled version of the
#'   \code{\link{mkinmod}} model is used, even if is present.
#' @param atol Absolute error tolerance, passed to \code{\link{ode}}. Default
#'   is 1e-8, lower than in \code{\link{lsoda}}.
#' @param rtol Absolute error tolerance, passed to \code{\link{ode}}. Default
#'   is 1e-10, much lower than in \code{\link{lsoda}}.
#' @param map_output Boolean to specify if the output should list values for
#'   the observed variables (default) or for all state variables (if set to
#'   FALSE).
#' @param \dots Further arguments passed to the ode solver in case such a
#'   solver is used.
#' @import deSolve
#' @importFrom inline getDynLib
#' @return A matrix in the same format as the output of \code{\link{ode}}.
#' @author Johannes Ranke
#' @examples
#' 
#'   SFO <- mkinmod(degradinol = mkinsub("SFO"))
#'   # Compare solution types
#'   mkinpredict(SFO, c(k_degradinol_sink = 0.3), c(degradinol = 100), 0:20,
#'         solution_type = "analytical")
#'   mkinpredict(SFO, c(k_degradinol_sink = 0.3), c(degradinol = 100), 0:20,
#'         solution_type = "deSolve")
#'   mkinpredict(SFO, c(k_degradinol_sink = 0.3), c(degradinol = 100), 0:20,
#'         solution_type = "deSolve", use_compiled = FALSE)
#'   mkinpredict(SFO, c(k_degradinol_sink = 0.3), c(degradinol = 100), 0:20,
#'         solution_type = "eigen")
#' 
#' 
#'   # Compare integration methods to analytical solution
#'   mkinpredict(SFO, c(k_degradinol_sink = 0.3), c(degradinol = 100), 0:20,
#'         solution_type = "analytical")[21,]
#'   mkinpredict(SFO, c(k_degradinol_sink = 0.3), c(degradinol = 100), 0:20,
#'         method = "lsoda")[21,]
#'   mkinpredict(SFO, c(k_degradinol_sink = 0.3), c(degradinol = 100), 0:20,
#'         method = "ode45")[21,]
#'   mkinpredict(SFO, c(k_degradinol_sink = 0.3), c(degradinol = 100), 0:20,
#'         method = "rk4")[21,]
#'  # rk4 is not as precise here
#' 
#'   # The number of output times used to make a lot of difference until the
#'   # default for atol was adjusted
#'   mkinpredict(SFO, c(k_degradinol_sink = 0.3), c(degradinol = 100),
#'         seq(0, 20, by = 0.1))[201,]
#'   mkinpredict(SFO, c(k_degradinol_sink = 0.3), c(degradinol = 100),
#'         seq(0, 20, by = 0.01))[2001,]
#' 
#'   # Check compiled model versions - they are faster than the eigenvalue based solutions!
#'   SFO_SFO = mkinmod(parent = list(type = "SFO", to = "m1"),
#'                     m1 = list(type = "SFO"))
#'   system.time(
#'     print(mkinpredict(SFO_SFO, c(k_parent_m1 = 0.05, k_parent_sink = 0.1, k_m1_sink = 0.01),
#'                 c(parent = 100, m1 = 0), seq(0, 20, by = 0.1),
#'                 solution_type = "eigen")[201,]))
#'   system.time(
#'     print(mkinpredict(SFO_SFO, c(k_parent_m1 = 0.05, k_parent_sink = 0.1, k_m1_sink = 0.01),
#'                 c(parent = 100, m1 = 0), seq(0, 20, by = 0.1),
#'                 solution_type = "deSolve")[201,]))
#'   system.time(
#'     print(mkinpredict(SFO_SFO, c(k_parent_m1 = 0.05, k_parent_sink = 0.1, k_m1_sink = 0.01),
#'                 c(parent = 100, m1 = 0), seq(0, 20, by = 0.1),
#'                 solution_type = "deSolve", use_compiled = FALSE)[201,]))
#' 
#'   \dontrun{
#'     # Predict from a fitted model
#'     f <- mkinfit(SFO_SFO, FOCUS_2006_C)
#'     head(mkinpredict(f))
#'   }
#' 
#' @export
mkinpredict <- function(x, odeparms, odeini,
  outtimes = seq(0, 120, by = 0.1),
  solution_type = "deSolve",
  use_compiled = "auto",
  method.ode = "lsoda", atol = 1e-8, rtol = 1e-10,
  map_output = TRUE, ...)
{
  UseMethod("mkinpredict", x)
}

#' @rdname mkinpredict
#' @export
mkinpredict.mkinmod <- function(x,
  odeparms = c(k_parent_sink = 0.1),
  odeini = c(parent = 100),
  outtimes = seq(0, 120, by = 0.1),
  solution_type = "deSolve",
  use_compiled = "auto",
  method.ode = "lsoda", atol = 1e-8, rtol = 1e-10,
  map_output = TRUE, ...)
{

  # Get the names of the state variables in the model
  mod_vars <- names(x$diffs)

  # Order the inital values for state variables if they are named
  if (!is.null(names(odeini))) {
    odeini <- odeini[mod_vars]
  }

  # Create function for evaluation of expressions with ode parameters and initial values
  evalparse <- function(string)
  {
    eval(parse(text=string), as.list(c(odeparms, odeini)))
  }

  # Create a function calculating the differentials specified by the model
  # if necessary
  if (solution_type == "analytical") {
    parent.type = names(x$map[[1]])[1]
    parent.name = names(x$diffs)[[1]]
    o <- switch(parent.type,
      SFO = SFO.solution(outtimes,
          evalparse(parent.name),
          ifelse(x$use_of_ff == "min",
      evalparse(paste("k", parent.name, "sink", sep="_")),
      evalparse(paste("k", parent.name, sep="_")))),
      FOMC = FOMC.solution(outtimes,
          evalparse(parent.name),
          evalparse("alpha"), evalparse("beta")),
      IORE = IORE.solution(outtimes,
          evalparse(parent.name),
          ifelse(x$use_of_ff == "min",
      evalparse(paste("k__iore", parent.name, "sink", sep="_")),
      evalparse(paste("k__iore", parent.name, sep="_"))),
            evalparse("N_parent")),
      DFOP = DFOP.solution(outtimes,
          evalparse(parent.name),
          evalparse("k1"), evalparse("k2"),
          evalparse("g")),
      HS = HS.solution(outtimes,
          evalparse(parent.name),
          evalparse("k1"), evalparse("k2"),
          evalparse("tb")),
      SFORB = SFORB.solution(outtimes,
          evalparse(parent.name),
          evalparse(paste("k", parent.name, "bound", sep="_")),
          evalparse(paste("k", sub("free", "bound", parent.name), "free", sep="_")),
          evalparse(paste("k", parent.name, "sink", sep="_"))),
      logistic = logistic.solution(outtimes,
          evalparse(parent.name),
          evalparse("kmax"), evalparse("k0"),
          evalparse("r"))
    )
    out <- data.frame(outtimes, o)
    names(out) <- c("time", sub("_free", "", parent.name))
  }
  if (solution_type == "eigen") {
    coefmat.num <- matrix(sapply(as.vector(x$coefmat), evalparse),
      nrow = length(mod_vars))
    e <- eigen(coefmat.num)
    c <- solve(e$vectors, odeini)
    f.out <- function(t) {
      e$vectors %*% diag(exp(e$values * t), nrow=length(mod_vars)) %*% c
    }
    o <- matrix(mapply(f.out, outtimes),
      nrow = length(mod_vars), ncol = length(outtimes))
    out <- data.frame(outtimes, t(o))
    names(out) <- c("time", mod_vars)
  }
  if (solution_type == "deSolve") {
    if (!is.null(x$cf) & use_compiled[1] != FALSE) {
      out <- ode(
        y = odeini,
        times = outtimes,
        func = "func",
        initfunc = "initpar",
        dllname = getDynLib(x$cf)[["name"]],
        parms = odeparms[x$parms], # Order matters when using compiled models
        method = method.ode,
        atol = atol,
        rtol = rtol,
        ...
      )
    } else {
      mkindiff <- function(t, state, parms) {

        time <- t
        diffs <- vector()
        for (box in names(x$diffs))
        {
          diffname <- paste("d", box, sep="_")
          diffs[diffname] <- with(as.list(c(time, state, parms)),
            eval(parse(text=x$diffs[[box]])))
        }
        return(list(c(diffs)))
      }
      out <- ode(
        y = odeini,
        times = outtimes,
        func = mkindiff,
        parms = odeparms,
        method = method.ode,
        atol = atol,
        rtol = rtol,
        ...
      )
    }
    if (sum(is.na(out)) > 0) {
      stop("Differential equations were not integrated for all output times because\n",
     "NaN values occurred in output from ode()")
      }
  }
  if (map_output) {
    # Output transformation for models with unobserved compartments like SFORB
    out_mapped <- data.frame(time = out[,"time"])
    for (var in names(x$map)) {
      if((length(x$map[[var]]) == 1) || solution_type == "analytical") {
        out_mapped[var] <- out[, var]
      } else {
        out_mapped[var] <- rowSums(out[, x$map[[var]]])
      }
    }
    return(out_mapped)
  } else {
    return(out)
  }
}

#' @rdname mkinpredict
#' @export
mkinpredict.mkinfit <- function(x,
  odeparms = x$bparms.ode,
  odeini = x$bparms.state,
  outtimes = seq(0, 120, by = 0.1),
  solution_type = "deSolve",
  use_compiled = "auto",
  method.ode = "lsoda", atol = 1e-8, rtol = 1e-10,
  map_output = TRUE, ...)
{
  mkinpredict(x$mkinmod, odeparms, odeini, outtimes, solution_type, use_compiled,
              method.ode, atol, rtol, map_output, ...)
}
