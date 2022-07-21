
# https://github.com/pyth-network/pyth-client-py
# example "pyth-client" Websocket API

# NOT conda install pythclient
# NOT py_install('pythclient')
# conda activate /Users/jbg/Library/r-miniconda
# pip install pythclient

## R ----
pacman::p_load(reticulate) # , tidyverse)
reticulate::repl_python()

# pythclient <- import('pythclient')

## python ----
from pythclient.pythclient import PythClient
from pythclient.pythaccounts import PythPriceAccount
# NOTE: This library requires Python 3.7 or greater due to 
from __future__ import annotations

solana_network="devnet"
first_mapping_account_key = get_key(solana_network, "mapping")
program_key=get_key(solana_network, "program")
PythClient(
  first_mapping_account_key=first_mapping_account_key,
  program_key = program_key # if use_program else None,
).refresh_all_prices() 
products = PythClient(
  first_mapping_account_key=first_mapping_account_key,
  program_key = program_key # if use_program else None,
).get_products()
for p in products:
    print(p.attrs)
    prices = await p.get_prices()
    for _, pr in prices.items():
        print(
            pr.price_type,
            pr.aggregate_price,
            "p/m",
            pr.aggregate_price_confidence_interval,
        )




async with PythClient(
  first_mapping_account_key=first_mapping_account_key,
  program_key = program_key # if use_program else None,
) as c
: await c.refresh_all_prices()
products = await c.get_products()
  for p in products:
      print(p.attrs)
      prices = await p.get_prices()
      for _, pr in prices.items():
          print(
              pr.price_type,
              pr.aggregate_price,
              "p/m",
              pr.aggregate_price_confidence_interval,
          )

