
# https://shikokuchuo.net/posts/15-nanonext-exchange/

# NOT conda install pythclient
# NOT py_install('pythclient')
# conda env list
# conda activate /Users/jbg/Library/r-miniconda
# pip install pynng

## R ----
Sys.getenv('RETICULATE_PYTHON')
reticulate::py_discover_config()
reticulate::py_discover_config(
  required_module = 'pynng', 
  use_environment = '/Users/jbg/Library/r-miniconda/envs/r-reticulate/bin/python')

pacman::p_load(reticulate) # , tidyverse)
py_install('pynng')
reticulate::repl_python()

import numpy as np
import pynng
socket = pynng.Pair0(listen="ipc:///tmp/nanonext")

## R
pacman::p_load(nanonext) 
n <- nano("pair", dial = "ipc:///tmp/nanonext")
n$send(c(1.1, 2.2, 3.3, 4.4, 5.5), mode = "raw")
