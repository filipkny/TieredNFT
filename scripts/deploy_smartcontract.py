import web3
from brownie import config, network, TieredNFT

from scripts.helpful_scripts import get_account, LOCAL_BLOCKCHAIN_ENVIRONMENTS

def main():
    deploy_tiered_nft()

def deploy_tiered_nft():
    account = get_account()
    print(f"Owner account {account}")
    lottery =  TieredNFT.deploy(
        "TieredNFT",
        "TNFT",
        {"from" : account},
        publish_source=network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS
    )

    print("Deployed lottery")
    return lottery
