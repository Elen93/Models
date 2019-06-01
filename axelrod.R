# first create data object
# TODO make each of these a variable (number of x, y, features)
features <- c("language", "style", "religion", "party", "cuisine")

seed_features <- function(n_of_features) {
  sample(x = 0:9, size = n_of_features, replace = TRUE)
}

seed_array <- function(n_of_features) {
  # create empty array
  a <- array(
    data = NA, 
    dim = c(10, 10, length(features)), 
    dimnames = list(
      y_coord = NULL,
      x_coord = NULL,
      feature = features
    )
  )
  
  # fill in empty array with initial traits
  a <- apply(
    X = a, 
    MARGIN = c(1, 2), 
    FUN = function(x) {
      seed_features(n_of_features = n_of_features)
    }
  )
  
  # turn array in the right orientation
  a <- aperm(a = a, perm = c(3, 2, 1))
  return(a)
}

a <- seed_array(n_of_features = length(features))

# subset into the array
a[1, 2, 5]

# sample
sample(1:10)
