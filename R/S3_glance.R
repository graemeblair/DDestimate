# Helpers to retrieve values
retrieve_value <- function(x, what) if(exists(what, x)) x[[what]] else NA_real_
retrieve_fstatistic <- function(x) {
  if (exists("fstatistic", x)) {
    data.frame(
      statistic = x[["fstatistic"]][1],
      p.value = pf(
        x[["fstatistic"]][1],
        x[["fstatistic"]][2],
        x[["fstatistic"]][3],
        lower.tail = FALSE
      )
    )
  } else {
    data.frame(statistic = NA_real_, p.value = NA_real_)
  }
}

#' @importFrom generics glance
#' @export
generics::glance

#' Glance at an estimatr object
#' @name estimatr_glancers
#' @templateVar class lm_robust
#' @return For \code{glance.lm_robust}, a data.frame with columns:
#'   \item{r.squared}{the \eqn{R^2},
#'   \deqn{R^2 = 1 - Sum(e[i]^2) / Sum((y[i] - y^*)^2),} where \eqn{y^*}
#'   is the mean of \eqn{y[i]} if there is an intercept and zero otherwise,
#'   and \eqn{e[i]} is the ith residual.}
#'   \item{adj.r.squared}{the \eqn{R^2} but penalized for having more parameters, \code{rank}}
#'   \item{se_type}{the standard error type specified by the user}
#'   \item{statistic}{the value of the F-statistic}
#'   \item{p.value}{p-value from the F test}
#'   \item{df.residual}{residual degrees of freedom}
#'   \item{nobs}{the number of observations used}
#'
#' @param x An object returned by one of the estimators
#' @param ... extra arguments (not used)
#'
#' @export
#' @family estimatr glancers
#' @seealso [generics::glance()], [estimatr::lm_robust()], [estimatr::lm_lin()], [estimatr::iv_robust()], [estimatr::difference_in_means()], [estimatr::horvitz_thompson()]
#' @md
glance.lm_robust <- function(x, ...) {

  if (length(x[["outcome"]]) > 1) {
    stop("Cannot use `glance` on linear models with multiple responses.")
  }

  ret <- cbind(
    data.frame(
      r.squared = x[["r.squared"]],
      adj.r.squared = x[["adj.r.squared"]]
    ),
    retrieve_fstatistic(x),
    data.frame(
      df.residual = x[["df"]][1],
      nobs = as.integer(x[["nobs"]]),
      se_type = x[["se_type"]],
      stringsAsFactors = FALSE
    )
  )

  rownames(ret) <- NULL

  ret
}

#' @rdname estimatr_glancers
#' @templateVar class lh_robust
#' @return For \code{glance.lh_robust}, we glance the \code{lm_robust} component only. You can access the linear hypotheses as a data.frame directy from the \code{lh} component of the \code{lh_robust} object
#'
#' @export
#' @family estimatr glancers
glance.lh_robust <- function(x, ...) {
  glance(x[["lm_robust"]])
}

#' @rdname estimatr_glancers
#' @templateVar class iv_robust
#' @return For \code{glance.iv_robust}, a data.frame with columns:
#'   \item{r.squared}{The \eqn{R^2} of the second stage regression}
#'   \item{adj.r.squared}{The \eqn{R^2} but penalized for having more parameters, \code{rank}}
#'   \item{df.residual}{residual degrees of freedom}
#'   \item{N}{the number of observations used}
#'   \item{se_type}{the standard error type specified by the user}
#'   \item{statistic}{the value of the F-statistic}
#'   \item{p.value}{p-value from the F test}
#'   \item{statistic.weakinst}{the value of the first stage F-statistic, useful for the weak instruments test; only reported if there is only one endogenous variable}
#'   \item{p.value.weakinst}{p-value from the first-stage F test, a test of weak instruments; only reported if there is only one endogenous variable}
#'   \item{statistic.endogeneity}{the value of the F-statistic for the test of endogeneity; often called the Wu-Hausman statistic, with robust standard errors, we employ the regression based test}
#'   \item{p.value.endogeneity}{p-value from the F-test for endogeneity}
#'   \item{statistic.overid}{the value of the chi-squared statistic for the test of instrument correlation with the error term; only reported with overidentification}
#'   \item{p.value.overid}{p-value from the chi-squared test; only reported with overidentification}
#'
#' @export
#' @family estimatr glancers
glance.iv_robust <- function(x, ...) {

  if (length(x[["outcome"]]) > 1) {
    stop("Cannot use `glance` on linear models with multiple responses.")
  }

  ret <- cbind(
    data.frame(
      r.squared = x[["r.squared"]],
      adj.r.squared = x[["adj.r.squared"]],
      df.residual = x[["df.residual"]],
      nobs = as.integer(x[["nobs"]]),
      se_type = x[["se_type"]],
      stringsAsFactors = FALSE
    ),
    retrieve_fstatistic(x),
    if (exists("diagnostic_firststage_fstatistic", x) && length(x[["diagnostic_firststage_fstatistic"]] == 4)) {
      data.frame(
        statistic.weakinst = x[["diagnostic_firststage_fstatistic"]]["value"],
        p.value.weakinst = x[["diagnostic_firststage_fstatistic"]]["p.value"]
      )
    } else {
      data.frame(statistic.weakinst = NA_real_, p.value.weakinst = NA_real_)
    },
    if (exists("diagnostic_endogeneity_fstatistic", x)) {
      data.frame(
        statistic.endogeneity = x[["diagnostic_endogeneity_fstatistic"]]["value"],
        p.value.endogeneity = x[["diagnostic_endogeneity_fstatistic"]]["p.value"]
      )
    } else {
      data.frame(statistic.endogeneity = NA_real_, p.value.endogeneity = NA_real_)
    },
    if (exists("diagnostic_overid_fstatistic", x)) {
      data.frame(
        statistic.overid = x[["diagnostic_overid_fstatistic"]]["value"],
        p.value.overid = x[["diagnostic_overid_fstatistic"]]["p.value"]
      )
    } else {
      data.frame(statistic.overid = NA_real_, p.value.overid = NA_real_)
    }
  )

  ret
}

#' @rdname estimatr_glancers
#' @templateVar class difference_in_means
#' @return For \code{glance.difference_in_means}, a data.frame with columns:
#'   \item{design}{the design used, and therefore the estimator used}
#'   \item{df}{the degrees of freedom}
#'   \item{nobs}{the number of observations used}
#'   \item{nblocks}{the number of blocks, if used}
#'   \item{nclusters}{the number of clusters, if used}
#'   \item{condition2}{the second, "treatment", condition}
#'   \item{condition1}{the first, "control", condition}
#'
#' @export
#' @family estimatr glancers
glance.difference_in_means <- function(x, ...) {
  data.frame(
    design = x[["design"]],
    df = x[["df"]],
    nobs = as.integer(x[["nobs"]]),
    nblocks = retrieve_value(x, "nblocks"),
    nclusters = retrieve_value(x, "nclusters"),
    condition2 = x[["condition2"]],
    condition1 = x[["condition1"]],
    stringsAsFactors = FALSE
  )
}

#' @rdname estimatr_glancers
#' @templateVar class horvitz_thompson
#' @return For \code{glance.horvitz_thompson}, a data.frame with columns:
#'   \item{nobs}{the number of observations used}
#'   \item{se_type}{the type of standard error estimator used}
#'   \item{condition2}{the second, "treatment", condition}
#'   \item{condition1}{the first, "control", condition}
#'
#' @export
#' @family estimatr glancers
glance.horvitz_thompson <- function(x, ...) {
  data.frame(
    nobs = as.integer(x[["nobs"]]),
    se_type = x[["se_type"]],
    condition2 = x[["condition2"]],
    condition1 = x[["condition1"]],
    stringsAsFactors = FALSE
  )
}
