find_peaks <- function(ts, tolerance = 1) {
  shape <- diff(sign(diff(ts, na.pad = FALSE)))
  peaks <- numeric(0)
  for (i in which(shape < 0)) {
    left <- i - tolerance + 1
    left <- ifelse(left > 0, left, 1)
    right <- i + tolerance + 1
    right <- ifelse(right < length(ts), right, length(ts))
    identical_peaks <- which(ts[left:right] == ts[i + 1])
    if (identical_peaks[1] == i + 1 - left + 1) {
      if (all(ts[c(left:i, (i + 2):right)] <= ts[i + 1])) {
        peaks <- c(peaks, i + 1)
      }
    }
  }
  peaks
}

# Nathan K Smith
# March 2023