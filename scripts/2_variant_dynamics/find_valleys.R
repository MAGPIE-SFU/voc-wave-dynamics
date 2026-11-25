## Find Valleys/Troughs
find_valleys <- function(x, peaks) {
  valleys <- numeric(0)
  for (i in 1:(length(peaks) - 1)) {
    min <- which.min(x[peaks[i]:peaks[i + 1]]) + peaks[i] - 1
    valleys <- c(valleys, min)
  }
  # Adding first valley
  first_valley <- which(x > 0)[1] 
  
  # Adding last valley
  last_peak <- length(peaks)
  last_value <- peaks[last_peak]
  last_valley <- which.min(x[(last_value + 1):length(x)]) + last_value
  
  # Putting together in final vector
  valleys <- c(first_valley, valleys, last_valley)
  valleys
}

# Nathan K Smith
# March 2023