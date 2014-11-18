

# FIXME: atomic posteriors with dim = NULL and dim = n_sims
# Is there a way to further vectorise this function? Ask on stack
summarise_sims <- function(x, fun) {
  dims <- dim(x)

  if (is.null(dims) || length(dims) == 1)
    stop("Not yet implemented for atomic posterior objects",
      call. = FALSE)

  nsims <- dims[1] 
  len <- prod(dims[-1])

  res <- vector("numeric", len)
  for (i in seq_len(len))
    res[i] <- fun(x[seq(i, nsims * len - (len - i), by = len)])

  dim(res) <- dims[-1]
  res
}

`%%` <- summarise_sims
