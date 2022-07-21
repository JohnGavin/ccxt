pacman::p_load(tsmp, bench, tidyverse)
# vignette(package = 'bench')

# TODO: https://franzbischoff.rbind.io/posts/100-time-series-part-2/ ----



# from where? ---- 
url <- readr::read_csv("https://raw.githubusercontent.com/matrix-profile-foundation/mpf-datasets/05efe885cff4b2266067ad62c4f6fa2b537ad2a2/real/italianpowerdemand.csv", col_names = FALSE)
dataset <- as.numeric(url$X1)
dataset %>% str()

sample <- head(dataset, 1000)
w_size <- 50
bench::mark(stomp = 
  stomp(sample, window_size = w_size, verbose = 2))


# changing n_workers to 4 will use 4 threads to compute
results <- bench::press(
  d_size = c(5000, 10000, 15000, 20000, 25000)  ,
  w_size = c(100, 300, 500, 700, 900)[1] ,
  {
    data <- head(dataset, d_size[1])
    
    bench::mark(
      stamp = stamp(data, window_size = w_size, verbose = 2),
      stomp = stomp(data, window_size = w_size, verbose = 2),
      scrimp = scrimp(data, window_size = w_size, verbose = 2),
      mpx = mpx(data, window_size = w_size, verbose = 2),
      check = FALSE,
      min_iterations = 3
    )
  })

save(results, file = "bench.rda")
