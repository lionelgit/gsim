
dots <- function (...) {
  eval(substitute(alist(...)))
}

pluck <- function(x, ...) {
  lapply(x, `[[`)
}

vpluck <- function(x, ..., type = NULL) {
  if (is.null(type)) type <- x[[1]][[i]]
  vapply(x, `[[`, ..., FUN.VALUE = type)
}

apluck <- function(x, ...) {
  dots <- dots(...)

  args <- as.pairlist(alist(x=))
  body <- do.call(call, c(list("[", as.name("x")), dots), quote = TRUE)
  fun <- eval(call("function", args, body))

  lapply(x, fun)
}

set_class <- function(x, ..., append = FALSE) {
  class <-
    if (append) 
      union(class(x), c(...))
    else
      c(...)

  class(x) <- class
  x
}

set_attr <- function(x, attribute, value) {
  attr(x, attribute) <- value
  x
}

set_dim <- function(x, dims) {
  dim(x) <- dims
  x
}

set_dimnames <- function(x, names) {
  dimnames(x) <- names
  x
}


first <- function(x) {
  x[[1]]
}

`first<-` <- function(x, value) {
  x[[1]] <- value
  x
}

last <- function(x) {
  x[[length(x)]]
}

`last<-` <- function(x, value) {
  x[[length(x)]] <- value
  x
}

dim_length <- function(x) {
  length(dim(x)) 
}

`%||%` <- function(a, b) {
  if (!is.null(a) && length(a) > 0)
    a
  else
    b
}

compact <- function(list, recursive = FALSE) {
  list <- Filter(Negate(is.null), list)

  if (recursive)
    lapply(list, function(item) {
      if (is.list(item))
        compact(item, recursive = TRUE)
      else
        item
    })

  else
    list
}

isFALSE <- function(x) {
  identical(FALSE, x) 
}

unlist2 <- function(x, recursive = TRUE) {
  .Internal(unlist(x, recursive, FALSE))
}

# `vapply` with logical(1) outputs (p stands for predictate)
papply <- function(X, FUN, ..., USE.NAMES = TRUE) {
  vapply(X, FUN, FUN.VALUE = logical(1), ..., USE.NAMES = USE.NAMES)
}

stopper <- function(x) {
  function() {
    stop(x, call. = FALSE)
  }
}

check_packages <- function(...) {
  packages <- c(...)
  lapply(packages, function(x) {
    if (!requireNamespace(x, quietly = TRUE))
      stop(paste("The package", x, "must be installed"), call. = FALSE)
  })
  invisible(NULL)
}
