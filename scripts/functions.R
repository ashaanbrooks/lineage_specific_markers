find_stable_regions <- function(df, col, threshold, min_length) {
  above <- !is.na(df[[col]]) & df[[col]] >= threshold
  rle_above <- rle(above)
  
  ends <- cumsum(rle_above$lengths)
  starts <- ends - rle_above$lengths + 1
  
  keep <- rle_above$values == TRUE & rle_above$lengths >= min_length
  
  if (!any(keep)) {
    message("No regions found at or above threshold ", threshold, " with minimum length ", min_length)
    return(data.frame(start = integer(0), end = integer(0)))
  }
  
  data.frame(
    start = starts[keep],
    end   = ends[keep]
  )
}
