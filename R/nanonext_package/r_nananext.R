
# https://shikokuchuo.net/nanonext/
# install.packages("nanonext")

# object-oriented interface 
# nano() to encapsulates a Socket and Dialer/Listener. 
# Methods such as $send() or $recv() 
library(nanonext)
nano1 <- nano("req", listen = "inproc://nanonext")
nano2 <- nano("rep", dial = "inproc://nanonext")

nano1$send("hello world!")
nano2$recv()

# functional interface is the Socket
# create socket optionally dial/listen at address. 
#  actions such as send() or recv().
socket1 <- socket("push", listen = "tcp://127.0.0.1:5556")
socket2 <- socket("pull", dial = "tcp://127.0.0.1:5556")
send(socket1, "hello world!")
recv(socket2)
send(socket1, "hello world!")
recv(socket2)

# https://docs.solana.com/developing/clients/jsonrpc-api
# RPC HTTP Endpoint#
# Default port: 8899 
# eg. http://localhost:8899, http://192.168.1.88:8899
# RPC PubSub WebSocket Endpoint#
# Default port: 8900 
# eg. ws://localhost:8900, http://192.168.1.88:8900



# ----
n <- nano("pair", dial = "ipc:///tmp/nanonext.socket")
n$send(c(1.1, 2.2, 3.3, 4.4, 5.5), mode = "raw")



# Receive in R, specifying the receive mode as ‘double’:
n$recv(mode = "double")



# Async and Concurrency
# send_aio() and recv_aio() return immediately 
#  perform their operations async. 
#  results can be called using call_aio() when required.
s1 <- socket("pair", listen = "inproc://nano")
s2 <- socket("pair", dial = "inproc://nano")
# ‘sendAio’- calling result causes it to be stored in AIO 
# as $result. An exit code of 0 denotes a successful send.
res <- send_aio(s1, data.frame(a = 1, b = 2))
res
call_aio(res)
res
res$result

# ‘recvAio’ - causes it to be stored in the AIO as $raw 
# (if kept) and $data.

msg <- recv_aio(s2)
msg
call_aio(msg)
msg
msg$data
msg$raw

call_aio(msg)$data

close(s1)
close(s2)


# remote procedure calls RPC and Distributed Computing
# writing large amounts of data to disk in a separate ‘server’ process running concurrently

# Server: reply() wait for message and apply function rnorm()
# before sending back the result
rep <- socket("rep", listen = "tcp://127.0.0.1:6546")
ctxp <- context(rep)
reply(ctxp, execute = rnorm, send_mode = "raw") 


# Client: request() async send and receive request and 
# returns immediately with a recvAio object.
library(nanonext)
req <- socket("req", dial = "tcp://127.0.0.1:6546")
ctxq <- context(req)
aio <- request(ctxq, data = 1e8, recv_mode = "double", keep.raw = FALSE)



# https://shikokuchuo.net/nanonext/#publisher-subscriber-model
pub <- socket("pub", listen = "inproc://nanobroadcast")
sub <- socket("sub", dial = "inproc://nanobroadcast")

sub |> subscribe(topic = "examples")
#> subscribed topic: examples
pub |> send(c("examples", "this is an example"), mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)
#> [1] "examples"           "this is an example"

pub |> send(c("other", "this other topic will not be received"), mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)
#> 8 : Try again

# specify NULL to subscribe to ALL topics
sub |> subscribe(topic = NULL)
#> subscribed topic: ALL
pub |> send(c("newTopic", "this is a new topic"), mode = "raw", echo = FALSE)
sub |> recv("character", keep.raw = FALSE)
#> [1] "newTopic"            "this is a new topic"

sub |> unsubscribe(topic = NULL)
#> unsubscribed topic: ALL
pub |> send(c("newTopic", "this topic will now not be received"), mode = "raw", echo = FALSE)
sub |> recv("character", keep.raw = FALSE)
#> 8 : Try again

# however the topics explicitly subscribed to are still received
pub |> send(c("examples", "this example will still be received"), mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)
#> [1] "examples"                            "this example will still be received"

close(pub)
close(sub)

# https://shikokuchuo.net/nanonext/#ncurl-minimalist-http-client
ncurl("http://httpbin.org/headers")
