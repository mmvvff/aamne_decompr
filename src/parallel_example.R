#setup parallel backend to use many processors
cores = detectCores()
cl <- makeCluster(cores[1]-1)
registerDoParallel(cl)

aamne <- foreach(i=vctr_allyears) %dopar% {
  aamne_i <- data.frame(year=i)
}
#stop cluster
stopCluster(cl)
