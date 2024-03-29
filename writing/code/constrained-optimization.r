#optim function minimizes 'f'; c vector are starting values; lower is the
#constraint; I choose a null gradient because it was easiest to get up and running
#note that here the beta parameter is hard coded in as equal to 1
rm(list = ls())
#ap5 = .17
#a0 = ap5 + .5
#anp5 = ap5 + 1

ap5 = 1.27
a0 = 1.27
anp5 = 1.27

h <- function(WB,al) {

sy=1
sz=1
  
f <- function(B,WB,al) {
  Bp5 <- B[1]
  B0 <- B[2]
  Bnp5 <- B[3]
  -WB*((1/(1+exp(al - B0 + a0)))*(1/(1+exp((al - .5 - Bnp5 + anp5)/sy))) + (1/(1+exp(al - B0 + a0)))*(1/(1+exp((al + .5 - Bp5 + ap5)/sz))) + (1/(1+exp((al + .5 - Bp5 + ap5)/sz)))*(1/(1+exp((al - .5 - Bnp5 + anp5)/sy))) - 2*(1/(1+exp(al - B0 + a0)))*(1/(1+exp((al - .5 - Bnp5 + anp5)/sy)))*(1/(1+exp((al + .5 - Bp5 + ap5)/sz)))) + B0 + Bp5 + Bnp5
}   

o <- optim(c(1,1,1,WB,al),function(B) f(B,WB,al),gr=NULL,method = "L-BFGS-B", lower = c(0,0,0), control = list(maxit=100000))
#o <- constrOptim(c(0.01,0.01,0.01,WB,al),function(B) f(B,WB,al),gr=NULL,method = "Nelder-Mead", ui = rbind(c(1,0,0),c(0,1,0),c(0,0,1)),ci=c(0,0,0))

X = round(- al -a0 + o$par[2], digits = 2)       #B0   these are shorthand variables for the exponents
Y = round(.5 - al -anp5 + o$par[3], digits = 2)    #Bnp5  in the logistic CDFs; I don't use them in the function
Z = round(-.5 - al - ap5 + o$par[1], digits=2)   #Bp5 but I've pasted in values here to check

pos <- c(Z,X,Y)
bribes <- c(o$par,-o$value)
#note I haven't fixed the win probability to include a's bribes
win <- c(((1/(1+exp(-X)))*(1/(1+exp(-Y/sy))) + (1/(1+exp(-X)))*(1/(1+exp(-Z/sz))) + (1/(1+exp(-Z/sz)))*(1/(1+exp(-Y/sy))) - 2*(1/(1+exp(-X)))*(1/(1+exp(-Y/sy)))*(1/(1+exp(-Z/sz)))))
out <- list("solns" = o$par[1:3], "pos" = pos, "objMax" = -o$value, "a" = al, "wb" = WB, "winProb" = win)
return(out)
}

# Create a dataframe of parameter values
wb_vector <- 5:20 
a_vector <- seq(0.0, 0.0, 0.0)
params <- expand.grid("wb" = wb_vector, "a" = a_vector)

# Use "Map" to evaluate the "h" function at each pair of parameter values
results <- Map(h, al = params$a, WB = params$wb)

# Extract positions and bind to the parameter values
# WOULD LIKE TO HAVE BOTH SOLUTIONS AND POSITIONS IN OUTPUT VECTOR BUT DON'T KNOW HOW
solns <- lapply(seq_along(results), function(x) results[[x]]$solns)
netpos <- lapply(seq_along(results), function(x) results[[x]]$pos)
val <- lapply(seq_along(results), function(x) results[[x]]$objMax)
winProb <- lapply(seq_along(results), function(x) results[[x]]$winProb)
solns <- do.call("rbind", solns)
netpos <- do.call("rbind", netpos)
val <- do.call("rbind", val)
winProb <- do.call("rbind", winProb)
colnames(solns) <- c("foe", "middle", "friend")
colnames(netpos) <- c("Z", "X", "Y")
colnames(val) <- c("value")
colnames(winProb) <- c("winProb")
solns <- cbind(params, solns,netpos,val,winProb)
View(solns)