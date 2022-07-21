
# https://docs.syndica.io/solana-rpc/how-to-use-solana-rpc-node
# curl https://solana-api.syndica.io/access-token/<YOUR_ACCESS_TOKEN>/rpc \
# -X POST -H "Content-Type: application/json" \
# -d '{"jsonrpc":"2.0","id":1, "method":"getSlot"}'


# RPC HTTP Endpoint#
# Default port: 8899 eg. http://localhost:8899, http://192.168.1.88:8899
# RPC PubSub WebSocket Endpoint#
# Default port: 8900 eg. ws://localhost:8900, http://192.168.1.88:8900

library(nanonext)
logging(level = "info")

pub <- socket("pub", listen = "inproc://nanobroadcast")
sub <- socket("sub", dial = "inproc://nanobroadcast")
sub |> subscribe(topic = "examples")
sub |> recv(mode = "character", keep.raw = FALSE)
pub |> send(c("examples", "this is an example"), mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)
sub |> subscribe(topic = "other")
pub |> send(c("other", "this other topic will not be received"), mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)
# specify NULL to subscribe to ALL topics
sub |> subscribe(topic = NULL)
pub |> send(c("newTopic", "this is a new topic"), mode = "raw", echo = FALSE)
sub |> recv("character", keep.raw = FALSE)
sub |> unsubscribe(topic = NULL)
pub |> send(c("newTopic", "this topic will now not be received"), mode = "raw", echo = FALSE)
sub |> recv("character", keep.raw = FALSE)
# however the topics explicitly subscribed to are still received
pub |> send(c("examples", "this example will still be received"), mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)

sub |> subscribe(topic = "other")
sub |> recv(mode = "character", keep.raw = FALSE)
pub |> send(c("other", "this other topic will not be received"), mode = "raw", echo = FALSE)
sub |> recv(mode = "character", keep.raw = FALSE)

# set logging level back to the default of errors only
logging(level = "error")


# https://shikokuchuo.net/nanonext/index.html
rep <- socket("rep", listen = "tcp://127.0.0.1:6546")
ctxp <- context(rep)
reply(ctxp, execute = rnorm, send_mode = "raw") 


# https://shikokuchuo.net/nanonext/reference/ncurl.html
ncurl("http://httpbin.org/get")
# ncurl("http://localhost:8899")
ncurl("http://httpbin.org/post", "POST", "text/plain", 
  "hello world")



library(nanonext)
nano1 <- nano("req", listen = "inproc://nanonext")
nano2 <- nano("rep", dial = "inproc://nanonext")

nano1$send("hello world!")
nano2$recv()