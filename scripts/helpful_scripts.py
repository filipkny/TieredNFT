from brownie import (
    accounts,
    network,
    config,
    Contract
)

from web3 import Web3

FORKED_LOCAL_ENVIRONMENTS = [ "mainnet-fork" ]

LOCAL_BLOCKCHAIN_ENVIRONMENTS = [
    "development",
    "ganache-local-new"
]
DECIMALS = 8
INITIAL_VALUE = 200000000000



def get_account(index=None, id=None):
    # accounts[0]
    # accounts.add("env")
    # accounts.load("id")
    if index:
        return accounts[index]
    if id:
        return accounts.load(id,password="test")
    if (
            network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
            or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    return accounts.add(config["wallets"]["from_key"])

