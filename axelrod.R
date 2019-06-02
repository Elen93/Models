# first create data object
# TODO make each of these a variable (number of x, y, features)
features <- c("language", "style", "religion", "party", "cuisine")

seed_features <- function(n_of_features) {
  sample(x = 0:9, size = n_of_features, replace = TRUE)
}

seed_array <- function(features) {
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
 n_of_features <- length(features) 
  # fill in empty array with initial traits
 a2 <- apply(
    X = a, 
    MARGIN = c(1, 2), 
    FUN = function(x) {
      seed_features(n_of_features = n_of_features)
    }
  )
  
  # turn array in the right orientation
  a2 <- aperm(a = a2, perm = c(3, 2, 1))
  dimnames(a2) <- dimnames(a)
  return(a2)
}

# sample

select_site <- function(a){
  x_cor <- sample(x = dim(a)[2], size = 1)
  y_cor <- sample(x = dim(a)[1], size = 1)
  site <- c(x_cor = x_cor, y_cor = y_cor)
  return(site)
} 



##function needs a and x y cor and result of select_site, produce list of vectors, 
#each give name "south, west..", we return list



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

##find the randomly selected neighbor and subset


random_neighbor <- function(neighbors){
  the_neighbor <- sample(x = neighbors, size = 1)
  return(the_neighbor)
}

#its a list

##comparing
find_overlap <- function(a, site, the_neighbor) {
  overlap <- a[the_neighbor[[1]][2], the_neighbor[[1]][1],] ==  a[site[2],site[1],]
  return(overlap)
}

#probability of interaction

find_p_int <- function(overlap, features) {
  p <- sum(overlap)/length(features)
  return(p)
}


make_int <- function(p, a, site, overlap, the_neighbor){
  inter_yn <- sample(x = c(TRUE, FALSE), size=1, prob=c(p, 1-p))
  if(inter_yn & !any(overlap)){
    changed_feature <- sample(which(!overlap), size = 1)
    a[site["y_cor"], site["x_cor"], changed_feature] <- a[the_neighbor[[1]]["y_cor"], the_neighbor[[1]]["x_cor"], changed_feature]
  }
  return(a)
}

###use the overlap object, and sample again, over those tha are 



#function:one iteration for the game
#another function: run it 1000 times(prob a loop)




one_iteration <- function(a){
 features <- dimnames(x = a)$feature
 site <- select_site(a = a)
 neighbors <- find_neighbors(a =a, site = site)
 the_neighbor <- random_neighbor(neighbors = neighbors)
 overlap <- find_overlap(a = a, site = site, the_neighbor = the_neighbor)
 p <- find_p_int(overlap = overlap, features = features)
 a <- make_int(p = p, a = a, site = site, the_neighbor = the_neighbor, overlap = overlap)
 return(a)
}

##looping

setup <- function(features){
  a <- seed_array(features)
  return(a)
}

iterate <- function(features, runs){
  a <- setup(features)
  for (i in 1:runs) {
    a <- one_iteration(a)
  }
  return(a)
}

results <- iterate(features, runs = 20)
###what we had for the looping
#for (i in 1:10000) {
#  a <- one_iteration(a)
#}
