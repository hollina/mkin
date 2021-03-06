#' Extract model parameters from mkinfit models
#'
#' This function always returns degradation model parameters as well as error
#' model parameters, in order to avoid working with a fitted model without
#' considering the error structure that was assumed for the fit.
#'
#' @param object A fitted model object
#' @param \dots Not used
#' @return A numeric vector of fitted model parameters
#' @export
parms <- function(object, ...)
{
  UseMethod("parms", object)
}

#' @param transformed Should the parameters be returned
#'   as used internally during the optimisation?
#' @rdname parms
#' @examples
#' fit <- mkinfit("SFO", FOCUS_2006_C)
#' parms(fit)
#' parms(fit, transformed = TRUE)
#' @export
parms.mkinfit <- function(object, transformed = FALSE, ...)
{
  if (transformed) object$par
  else c(object$bparms.optim, object$errparms)
}
