% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helper_condition_pr_matrix.R
\name{declaration_to_condition_pr_mat}
\alias{declaration_to_condition_pr_mat}
\title{Builds condition probability matrices for Horvitz-Thompson estimation from
\pkg{randomizr} declaration}
\usage{
declaration_to_condition_pr_mat(
  ra_declaration,
  condition1 = NULL,
  condition2 = NULL,
  prob_matrix = NULL
)
}
\arguments{
\item{ra_declaration}{An object of class \code{"ra_declaration"}, generated
by the \code{\link[randomizr]{declare_ra}} function in \pkg{randomizr}. This
object contains the experimental design that will be represented in a
condition probability matrix}

\item{condition1}{The name of the first condition, often the control group. If \code{NULL},
defaults to first condition in randomizr declaration. Either both \code{condition1}
and \code{condition2} have to be specified or both left as \code{NULL}.}

\item{condition2}{The name of the second condition, often the treatment group. If \code{NULL},
defaults to second condition in randomizr declaration. Either both \code{condition1}
and \code{condition2} have to be specified or both left as \code{NULL}.}

\item{prob_matrix}{An optional probability matrix to override the one in
\code{ra_declaration}}
}
\value{
a numeric 2n*2n matrix of marginal and joint condition treatment
probabilities to be passed to the \code{condition_pr_mat} argument of
\code{\link{horvitz_thompson}}. See details.
}
\description{
Builds condition probability matrices for Horvitz-Thompson estimation from
\pkg{randomizr} declaration
}
\details{
This function takes a \code{"ra_declaration"}, generated
by the \code{\link[randomizr]{declare_ra}} function in \pkg{randomizr} and
returns a 2n*2n matrix that can be used to fully specify the design for
\code{\link{horvitz_thompson}} estimation. This is done by passing this
matrix to the \code{condition_pr_mat} argument of
\code{\link{horvitz_thompson}}.

Currently, this function can learn the condition probability matrix for a
wide variety of randomizations: simple, complete, simple clustered, complete
clustered, blocked, block-clustered.

A condition probability matrix is made up of four submatrices, each of which
corresponds to the
joint and marginal probability that each observation is in one of the two
treatment conditions.

The upper-left quadrant is an n*n matrix. On the diagonal is the marginal
probability of being in condition 1, often control, for every unit
(Pr(Z_i = Condition1) where Z represents the vector of treatment conditions).
The off-diagonal elements are the joint probabilities of each unit being in
condition 1 with each other unit, Pr(Z_i = Condition1, Z_j = Condition1)
where i indexes the rows and j indexes the columns.

The upper-right quadrant is also an n*n matrix. On the diagonal is the joint
probability of a unit being in condition 1 and condition 2, often the
treatment, and thus is always 0. The off-diagonal elements are the joint
probability of unit i being in condition 1 and unit j being in condition 2,
Pr(Z_i = Condition1, Z_j = Condition2).

The lower-left quadrant is also an n*n matrix. On the diagonal is the joint
probability of a unit being in condition 1 and condition 2, and thus is
always 0. The off-diagonal elements are the joint probability of unit i
being in condition 2 and unit j being in condition 1,
Pr(Z_i = Condition2, Z_j = Condition1).

The lower-right quadrant is an n*n matrix. On the diagonal is the marginal
probability of being in condition 2, often treatment, for every unit
(Pr(Z_i = Condition2)). The off-diagonal elements are the joint probability
of each unit being in condition 2 together,
Pr(Z_i = Condition2, Z_j = Condition2).
}
\examples{

# Learn condition probability matrix from complete blocked design
library(randomizr)
n <- 100
dat <- data.frame(
  blocks = sample(letters[1:10], size = n, replace = TRUE),
  y = rnorm(n)
)

# Declare complete blocked randomization
bl_declaration <- declare_ra(blocks = dat$blocks, prob = 0.4, simple = FALSE)
# Get probabilities
block_pr_mat <- declaration_to_condition_pr_mat(bl_declaration, 0, 1)
# Do randomiztion
dat$z <- conduct_ra(bl_declaration)

horvitz_thompson(y ~ z, data = dat, condition_pr_mat = block_pr_mat)

# When you pass a declaration to horvitz_thompson, this function is called

# Equivalent to above call
horvitz_thompson(y ~ z, data = dat, ra_declaration = bl_declaration)

}
\seealso{
\code{\link{permutations_to_condition_pr_mat}}
}
