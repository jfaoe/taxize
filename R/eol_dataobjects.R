#' Given the identifier for a data object, return all metadata about the object
#'
#' @export
#' @param id (character) The EOL data object identifier
#' @param taxonomy (logical) Whether to return any taxonomy details from 
#' different taxon hierarchy providers, in an array named 
#' \code{taxonconcepts}
#' @param language (character) provides the results in the specified language. 
#' one of ms, de, en, es, fr, gl, it, nl, nb, oc, pt-BR, sv, tl, mk, sr, uk, ar, 
#' zh-Hans, zh-Hant, ko
#' @param usekey (logical) use your API key or not (\code{TRUE} or \code{FALSE})
#' @param key (character) Your EOL API key; ; see \code{\link{taxize-authentication}} 
#' for help on authentication
#' @param ... Curl options passed on to \code{\link[crul]{HttpClient}}
#' @details It's possible to return JSON or XML with the EOL API. However,
#' 		this function only returns JSON for now.
#' @return A list, optionally with a data.frame if \code{taxonomy=TRUE}
#' @examples \dontrun{
#' eol_dataobjects(id = 7561533)
#'
#' # curl options
#' eol_dataobjects(id = 7561533, verbose = TRUE)
#' }
eol_dataobjects <- function(id, taxonomy = TRUE, language = NULL, usekey = TRUE, 
  key = NULL, ...) {

  if (usekey) key <- getkey(key, "EOL_KEY")
  cli <- crul::HttpClient$new(
    url = file.path(eol_url("data_objects"), paste0(id, ".json")),
    headers = tx_ual,
    opts = list(...)
  )
  args <- argsnull(tc(list(key = key, taxonomy = as_l(taxonomy), language = language)))
  res <- cli$get(query = args)
  res$raise_for_status()
  tt <- res$parse("UTF-8")
  tmp <- jsonlite::fromJSON(tt)
  tmp <- nmslwr(tmp)
  if ("taxonconcepts" %in% names(tmp)) {
    tmp$taxonconcepts <- nmslwr(tmp$taxonconcepts)
    tmp$taxonconcepts$taxonrank <- tolower(tmp$taxonconcepts$taxonrank)
  }
  return(tmp)
}

nmslwr <- function(x) {
  stats::setNames(x, tolower(names(x)))
}
