
# https://shikokuchuo.net/nanonext/
# Create socket in Python using the NNG binding ‘pynng’:

import numpy as np
import pynng
socket = pynng.Pair0(listen="ipc:///tmp/nanonext.socket")

# Receive in Python as a NumPy array of ‘floats’, and send back to R:
raw = socket.recv()
array = np.frombuffer(raw)
print(array)
#> [1.1 2.2 3.3 4.4 5.5]
msg = array.tobytes()
socket.send(msg)




