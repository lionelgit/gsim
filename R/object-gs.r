

gs <- function(object, class = "data", group = NULL, colnames = NULL) {
  assert_that(class %in% c("numeric", "data", "posterior"))

  if (class == "posterior") {
    if (is.null(dim(object)))
      object <- array(object, c(length(object), 1))

     res <- object %>%
      apply(1, list) %>%
      lapply(function(x) {
        colnames <- last(dimnames(x), default = NULL) %||% colnames
        x[[1]] %>%
          as.gsarray %>%
          ## gs("data", colnames = colnames) %>%
          set_colnames(colnames) %>%
          rbind_cols
      })

    res %>%
      set_gsim_attributes("posterior", group)
  }

  else {
    object %<>% as.gsarray
    colnames(object) <- colnames
    object %>%
      set_gsim_attributes("data", group)
  }
}


set_gsim_attributes <- function(object, class, group = NULL) {
  object <- structure(
    object,
    group = group
  )

  object %<>%
    set_gsim_class(class, grouped = !is.null(group))

  object
}


#' @export
is.gs         <- function(x) inherits(x, "gs")

#' @export
is.grouped_gs <- function(x) inherits(x, "grouped_gs")

#' @export
is.data      <- function(x) inherits(x, "data")

#' @export
is.posterior    <- function(x) inherits(x, "posterior")



#' @export
gsim_class <- function(x) {
  if (is.seq_gs(x)) return("seq_gs")
  else if (is.posterior(x)) return("posterior")
  else if (is.data(x)) return("data")
  else if (is.numeric(x)) return("numeric")
  else NULL
}

set_gsim_class <- function(gs, class, grouped = NULL) {
  new_class <- c("gs", class)

  if (grouped) {
    new_class <- c(new_class, "grouped_gs")
  }

  gs %>%
    set_class(new_class)
}

`gsim_class<-` <- function(gs, class) set_gsim_class(gs, class)

## as.data.frame.gs <- function(gs) {
##   ## fixme: For some reason, method dispatch does not work...
##   if (is.data(gs))
##     as.data.frame.data(gs)
##   else
##     as.data.frame.posterior(gs)
## }

as.data.frame.data <- function(gs, ...) {
  if (dim_length(gs) > 2)
    gs %>% adply(seq_len(dim(gs)))
    
  else {
    names <- colnames(gs) %||% make_default_names(ncol(gs))

    gs %>%
      as.data.frame.matrix %>%
      set_names(names) %>%
      cbind(obs = seq_len(length(gs)), .) %>%
      gs_regroup(group(gs))
  }
}

as.data.frame.posterior <- function(gs, ...) {
  dim <- gsim_dim(gs)

  if (length(dim) > 2)
    "Can only summarise vectors and matrices at the moment"

  else if (dim[2] == 1) {
    res <- vapply(gs, as.matrix, numeric(dim[1])) %>%
      as.data.frame %>%
      set_colnames(seq_along(gs)) %>%
      cbind(obs = seq_len(dim[1]), .) %>%
      gs_regroup(group(gs)) %>%
      gather_("sim", "gs", paste0(1:500))

    if (!is.null(group(gs)))
      regroup(res, list(group(gs)))
    else
      res
  }

  else
    Map(function(sim, x) data.frame(sim = sim, x),
        sim = list(seq_len(first(gsim_dim(gs)))), x = gs) %>%
      rbind_all %>%
      arrange(sim) %>%
      gs_regroup(group(gs))
}

gs_regroup <- function(res, group) {
  if (!is.null(group)) {
    ## group is as.vector'd to convert it to character or numeric
    res <- cbind(as.vector(get_in_input(group)), res)
    names(res)[1] <- group
    res %<>% regroup(list(group))
  }
  res
}


subset_data <- function(gs, name) {
  if (is.col_vector(gs)) {
    if (is.null(attr(gs, "blocks_names")))
      stop("this object has no blocks")

    class <- gsim_class(gs)
    index <- block_index(gs, name)

    gs <- gs[index, , drop = FALSE]
  }
  else stop("not implemented for matrices yet")
  
  gs(gs, class, colnames = name)
}


subset_posterior <- function(gs, name) {
  do_by_sims(gs, fun = subset_data, args = list(name))
}


block_index <- function(gs, name) {
  which <- match(name, attr(gs, "blocks_name")) %||% stop("block not found")
  indices <- attr(gs, "blocks_indices")

  start <- indices[which] + 1
  stop <- indices[which + 1]
  seq(start, stop)
}
