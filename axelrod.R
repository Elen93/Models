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
      y_height = NULL,
      x_width = NULL,
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
a[select_site(a)["y_cor"],select_site(a)["x_cor"],]

# sample

select_site <- function(a){
  x_cor <- sample(x = dim(a)[2], size = 1)
  y_cor <- sample(x = dim(a)[1], size = 1)
  site <- c(x_cor = x_cor, y_cor = y_cor)
  return(site)
} 


subset.default(x = a, subset = TRUE)
subset(x = , subset = TRUE, select = 1:10, drop = FALSE)

##function needs a and x y cor and result of select_site, produce list of vectors, 
#each give name "south, west..", we return list

site <- select_site(a)

find_neighbors <- function(a, site){
  # create all neighbors, including impossible
  fake_neighbors <- list(
    north = site + c(-1, 0),
    west = site + c(0, 1),
    south = site + c(1, 0),
    east = site + c(0, -1)
  )
  # find impossible neighbors
  existing_neighbors <- sapply(X = fake_neighbors, FUN = function(x) {
    all(x <= dim(a)[c(1, 2)])
  })
  neighbors <- fake_neighbors[existing_neighbors]
  return(neighbors)
}

