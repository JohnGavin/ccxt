# https://github.com/farach/huggingfaceR

library(reticulate)
virtualenv_create('huggingfaceR')
Sys.getenv('RETICULATE_PYTHON')
# "/usr/local/opt/python@3.9/bin/python3.9"
Sys.setenv(RETICULATE_PYTHON="/Users/jbg/Library/r-miniconda/envs/huggingfaceR/bin/python")
Sys.getenv('RETICULATE_PYTHON')
# "/Users/jbg/Library/r-miniconda/envs/huggingfaceR/bin/python"
library(keras)

Sys.getenv('RETICULATE_PYTHON')
# "/Users/jbg/Library/r-miniconda/envs/huggingfaceR/bin/python"

library(huggingfaceR)

Sys.getenv('RETICULATE_PYTHON')
# "/Users/jbg/Library/r-miniconda/envs/huggingfaceR/bin/python"
distilBERT <- hf_load_model("distilbert-base-uncased-finetuned-sst-2-english")

# creating virtual environment '/NA'
