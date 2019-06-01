indDF <- data.frame (id=1:2, strategy=NA, num_wins=0)
indDF

choose_Strategy <- function(ind){
  strats <- sample(x=1:3, size=nrow(ind))
  ind$strategy <- strats
  return(ind)
}

##1=Paper, 2=Scissors, 3=Rock

playStrategy <- function(ind){
  if (ind$strategy[1] == ind$strategy[2]) {
    # same strategies, it's a tie
  } else {
    if (any(ind$strategy == 3) && any(ind$strategy == 1)) {
      # this is the special case of rock over paper
      # figure out who of the two IS the winner
      winner_id <- ind[ind$strategy == 1, "id"]
      ind <- increment_winner(ind = ind, winner_id = winner_id)
    } else {
      # find index for higher strategy
      # index also happens to be winner_id as per above
      winner_id <- which(ind[, "strategy"] == max(ind[, "strategy"]))
      ind <- increment_winner(ind = ind, winner_id = winner_id)
    }
  }
  return(ind)
}

increment_winner <- function(ind, winner_id) {
  ind[winner_id, "num_wins"] <- ind[winner_id, "num_wins"] + 1
  return(ind)
}

for (i in 1:1000) {
  indDF <- choose_Strategy(indDF)
  indDF <- playStrategy(indDF)
  i <- i + 1
};indDF

setup <- function(){
  return(data.frame(id=1:2, strategy=NA, num_wins=0))
}


###setup function for setting multiple samples

rounds <- 1000
indDF <- setup()
dat <- matrix(NA, rounds, 2)
for (i in 1:rounds) {
  indDF <- choose_Strategy(indDF)
  indDF <- playStrategy(indDF)
  dat[i,] <- indDF$num_wins
  i <- i + 1
}

plot(dat[,1], type="l", col="#EA3E49", lwd=3, xlab = "time", ylab = "number of rounds won")
lines(dat[,2], col="#77C4D3", lwd=3)

##A player who switches his strategy and a player who uses always the same strategy.
#Who would win?

choose_Strategy2 <- function(ind){
  strats <- sample(x = 1:3, size = 1)
  ind$strategy[1] <- strats
  return(ind)  
}
###################################
##My own try on this modell

exhDF <- data.frame (
  id = c("Mark", "Maria"),
  strategy=NA, 
  num_wins=0)
exhDF
###not use strings for 

choose_Strategy3 <- function(exh){
  strats <- sample(x=1:3, size=nrow(exh))
  exh$strategy <- strats
  return(exh)
}



playStrategy3 <- function(exh){
  if(any(exh$strategy == 2) && any(exh$strategy == 1)){
    tmp <- exh[exh$strategy == 2, "id"]
    exh[tmp, "num_wins"] <- exh[tmp, "num_wins"] + 1
  }
  if(any(exh$strategy == 3) && any(exh$strategy == 2)){
    tmp <- exh[exh$strategy == 3, "id"]
    exh[tmp, "num_wins"] <- exh[tmp, "num_wins"] + 1
  }
  if(any(exh$strategy == 3) && any(exh$strategy == 1)) {
    tmp <- exh[exh$strategy == 1, "id"] 
    exh[tmp, "num_wins"] <- exh[tmp, "num_wins"] + 1
  }
  else {}
  return(exh)
}


for (i in 1:100) {
  exhDF <- choose_Strategy3(exhDF)
  exhDF <- playStrategy3(exhDF)
  i <- i + 1
};exhDF


setup <- function(){
  return(data.frame(
    id = c("Mark", "Maria")),
    strategy=NA, 
    num_wins=0)
}

rounds <- 100
exhDF <- setup()
dat <- matrix(NA, rounds, 2)
for (i in 1:rounds) {
  exhDF <- choose_Strategy3(exhDF)
  exhDF <- playStrategy3(exhDF)
  dat[i,] <- exhDF$num_wins
  i <- i + 1
}

plot(dat[,1], type="l", col="violet", lwd=3, xlab = "time", ylab = "number of rounds won")
lines(dat[,2], col="yellow", lwd=3)


###############
#Head or Tail

#set.seed(seed) generates random numbers

coin = c("Head", "Tail")
set.seed(100) #to make results reproducible
y = sample(coin, 6, replace = TRUE)
length(y[y=="Tail"])

replicate(100, sample(coin, 6, replace = TRUE ))
a = replicate(100, length(sample(coin, 6, replace = TRUE)[y == "Tail"]))
mean(a)

