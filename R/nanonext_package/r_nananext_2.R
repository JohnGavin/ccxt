
# https://shikokuchuo.net/posts/17-nanonext-concurrency/
# - concurrency framework that can be used for building distributed applications
# - successor to ZeroMQ
# - actions out of order - receive before we send

# https://github.com/r-lib/lintr
# https://blog.r-hub.io/2022/03/21/code-style/
# 
# loading the package and creating sockets
library(nanonext)
s1 <- socket("pair", listen = "inproc://nano")
s2 <- socket("pair", dial = "inproc://nano")

# an async receive is requested, but no messages are waiting (yet to be sent)
msg <- s2 |> recv_aio()
# send_aio() and recv_aio() functions return immediately 
# with an ‘Aio’ object, but perform their operations async. 
msg
msg$data

# https://api.devnet.solana.com


# An ‘Aio’ object returns an ‘unresolved’ logical NA value 
# whilst its asynchronous operation is ongoing. 
# This is an actual NA value, and Shiny will, for example, 
# recognise it as being ‘non-truthy’.
s2 |> recv_aio()
s2 |> send_aio("asdfs3 ")
library(magrittr)
s2 |> recv_aio() %>% `[[`('data')

# perform a send, and ‘Aio’ resolves immediately, once sent
res <- s1 |> send_aio(data.frame(a = 1, b = 2))
# message sent => 'recvAio' automatically resolves
msg$data
msg$raw
# still ‘just’ messaging?

# actions which depend on resolution of the Aio (completion of the async operation), both before and after. This means there is no need to ever wait (block) for an Aio to resolve
msg <- recv_aio(s2)

# unresolved() queries for resolution itself so no need to use it again within the while loop
while (unresolved(msg)) {
  # do real stuff here not just the toy actions below
  cat("unresolved")
  send_aio(s1, "resolved")
  Sys.sleep(0.1)  
}
# resolution of the Aio exits the while loop - now do the stuff which depends on its value
msg$data

# to access the resolved value directly (waiting if required)
call_aio(msg)$data

## NNG’s ‘scalability protocols ----
# communications patterns built on top of raw bytestream connections
# socket of a certain type will always interact with another in a prescribed way. No matter the platform, and no matter the language binding
# most classic pattern for NNG is the req/rep (request/reply). 
# This is a guaranteed communications pattern that will not drop messages, retrying under the hood if messages cannot be delivered for whatever reason. 
# This can be utilised to implement ‘traditional’ RPC (remote prodecure calls), 
#   computationally-expensive calculations or 
#   I/O-bound operations such as writing large amounts of data to disk 
#   in a separate ‘server’ process running concurrently.

# This code block is run in a separate R process to knit this document

library(nanonext)
rep <- socket("rep", listen = "tcp://127.0.0.1:6546")
ctxp <- context(rep)
reply(ctxp, execute = rnorm, send_mode = "raw") 
# Client process: request() performs an async send and receive
#  request and returns immediately with an Aio object.

library(nanonext)
req <- socket("req", dial = "tcp://127.0.0.1:6546")
ctxq <- context(req)
aio <- request(ctxq, data = 1e8, recv_mode = "double", keep.raw = FALSE)









 