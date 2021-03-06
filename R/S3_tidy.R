#' @importFrom generics tidy
#' @export
generics::tidy

tidy_data_frame <- function(x, 
                            conf.int = FALSE,
                            conf.level = .95,
                            ...) {
  vec_cols <- c(
    "coefficients",
    "std.error",
    "statistic",
    "p.value",
    "conf.low",
    "conf.high",
    "df"
  )

  tidy_mat <- do.call("cbind", lapply(x[vec_cols], as.vector))
  vec_cols[vec_cols == "coefficients"] <- "estimate"
  colnames(tidy_mat) <- vec_cols
  return_frame <- data.frame(
    term = x[["term"]],
    tidy_mat,
    outcome = rep(x[["outcome"]], each = length(x[["term"]])),
    stringsAsFactors = FALSE
  )

  rownames(return_frame) <- NULL

  # re-calculate CIs if explicitly requested and alpha level has changed
  # x$alpha[1] because lm_robust duplicates alpha with multiple linear_hypotheses
  flag <- conf.int || (utils::hasName(x, 'alpha') && (1 - x$alpha[1] != conf.level))
  if (flag) {
      ci <- stats::confint(x, level = conf.level, ...)
      if (all(row.names(ci) == return_frame$term))  {
          return_frame$conf.low <- ci[, 1]
          return_frame$conf.high <- ci[, 2]
      }
  }


  return(return_frame)
}

warn_singularities <- function(x) {
  if (x$rank < x$k) {
    singularities <- x$k - x$rank
    what <- ifelse(singularities > 1, " coefficients ", " coefficient ")
    message(
      singularities, what,
      " not defined because the design matrix is rank deficient\n"
    )
  }
}

#' Tidy an estimatr object
#' @name estimatr_tidiers
#' @templateVar class lm_robust
#' @return A data.frame with columns for coefficient names, estimates, standard
#' errors, confidence intervals, p-values, degrees of freedom, and the
#' name of the outcome variable
#'
#' @param x An object returned by one of the estimators
#' @param conf.int  Logical indicating whether or not to include a
#'   confidence interval in the tidied output. Defaults to ‘FALSE’.
#' @param conf.level  The confidence level to use for the confidence
#'   interval if ‘conf.int = TRUE’. Must be strictly greater than 0 and less
#'   than 1. Defaults to 0.95, which corresponds to a 95 percent confidence
#'   interval.
#' @param ... extra arguments (not used)
#'
#' @export
#' @family estimatr tidiers
#' @seealso [generics::tidy()], [estimatr::lm_robust()], [estimatr::iv_robust()],  [estimatr::difference_in_means()], [estimatr::horvitz_thompson()]
#' @md
tidy.lm_robust <- function(x,
                           conf.int = FALSE,
                           conf.level = .95,
                           ...) {
  warn_singularities(x)
  tidy_data_frame(x, conf.int = conf.int, conf.level = conf.level, ...)
}

#' @rdname estimatr_tidiers
#' @templateVar class iv_robust
#'
#' @export
#' @family estimatr tidiers
tidy.iv_robust <- function(x, conf.int = FALSE, conf.level = .95, ...) {
  warn_singularities(x)
  tidy_data_frame(x, conf.int = conf.int, conf.level = conf.level, ...)
}

#' @rdname estimatr_tidiers
#' @templateVar class difference_in_means
#'
#' @export
#' @family estimatr tidiers
tidy.difference_in_means <- tidy_data_frame

#' @rdname estimatr_tidiers
#' @templateVar class horvitz_thompson
#'
#' @export
#' @family estimatr tidiers
tidy.horvitz_thompson <- tidy_data_frame

#' @rdname estimatr_tidiers
#' @templateVar class lh_robust
#'
#' @export
#' @family estimatr tidiers
tidy.lh_robust <- function(x, ...) {
  rbind(tidy(x$lm_robust, ...), tidy(x$lh, ...))
}

#' @rdname estimatr_tidiers
#' @templateVar class lh
#'
#' @export
#' @family estimatr tidiers
tidy.lh <- function(x, ...) {
  tidy_data_frame(simplify_lh_outcome(x), ...)
}

# Simplifies the `lh` outcome column for tidy.lh and print.lh
simplify_lh_outcome <- function(x) {
  x_list <- as.list(x)
  x_list[["outcome"]] <- unique(x_list[["outcome"]])
  class(x_list) <- "lh"
  x_list
}

