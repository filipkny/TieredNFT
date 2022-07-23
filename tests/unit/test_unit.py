import brownie
import pytest
from brownie import network, accounts
from web3 import Web3

from scripts.deploy_smartcontract import deploy_tiered_nft
from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account

@pytest.fixture
def smartcontract():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip()

    return deploy_tiered_nft()

@pytest.fixture
def owner_account():
    return get_account()

def test_deploy_smartcontract(smartcontract, owner_account):
    assert smartcontract.balanceOf(accounts[0]) == 0

def test_mint(smartcontract, owner_account):
    smartcontract.flipSaleState(
        {"from": owner_account}
    )

    smartcontract.mint({"from": accounts[0], "value": Web3.toWei(0.42, "ether")})

    assert smartcontract.balanceOf(accounts[0]) == 1
    assert smartcontract.tierTotalSupply(0) == 1 # We minted tier 0
    assert smartcontract.tierTotalSupply(1) == 0 # We didnt mint tier 1
    assert smartcontract.tierTotalSupply(2) == 0 # We didnt mint tier 2
    assert smartcontract.ownerOf(0) == accounts[0]

def test_mint_several(smartcontract, owner_account):
    smartcontract.flipSaleState(
        {"from": owner_account}
    )

    smartcontract.mint({"from": accounts[0], "value": Web3.toWei(0.42, "ether")})
    smartcontract.mint({"from": accounts[0], "value": Web3.toWei(0.6, "ether")})
    smartcontract.mint({"from": accounts[1], "value": Web3.toWei(0.6, "ether")})
    smartcontract.mint({"from": accounts[1], "value": Web3.toWei(0.9, "ether")})

    assert smartcontract.balanceOf(accounts[0]) == 2
    assert smartcontract.balanceOf(accounts[1]) == 2
    assert smartcontract.tierTotalSupply(0) == 1 # We minted tier 0
    assert smartcontract.tierTotalSupply(1) == 2 # We didnt mint tier 1
    assert smartcontract.tierTotalSupply(2) == 1 # We didnt mint tier 2
    assert smartcontract.ownerOf(0) == accounts[0]
    assert smartcontract.ownerOf(300) == accounts[0]
    assert smartcontract.ownerOf(301) == accounts[1]
    assert smartcontract.ownerOf(400) == accounts[1]

def test_fail_mint_not_enough_eth(smartcontract, owner_account):
    smartcontract.flipSaleState()

    with brownie.reverts("Not enough ETH to mint cheapest tier"):
        smartcontract.mint({"from": accounts[0], "value": Web3.toWei(0.1, "ether")})

def test_fail_exceeded_mints_per_address(smartcontract, owner_account):
    smartcontract.flipSaleState()

    smartcontract.mint({"from": accounts[0], "value": Web3.toWei(0.42, "ether")})
    smartcontract.mint({"from": accounts[0], "value": Web3.toWei(0.42, "ether")})
    smartcontract.mint({"from": accounts[0], "value": Web3.toWei(0.42, "ether")})

    with brownie.reverts("Max number of mints per address reached"):
        smartcontract.mint({"from": accounts[0], "value": Web3.toWei(0.42, "ether")})

def test_fail_mint_exceeded_max_supply(smartcontract, owner_account):
    smartcontract.flipSaleState()

    for i in range(20):
        smartcontract.mint({"from": accounts[i], "value": Web3.toWei(0.9, "ether")})

    smartcontract.mint({"from": accounts[0], "value": Web3.toWei(0.42, "ether")})

    with brownie.reverts("Exceeded max limit of allowed token mints"):
        smartcontract.mint({"from": accounts[0], "value": Web3.toWei(0.9, "ether")})

def test_withdraw(smartcontract, owner_account):
    starting_balance = owner_account.balance()
    smartcontract.flipSaleState()
    smartcontract.mint({"from": accounts[1], "value": Web3.toWei(0.42, "ether")})
    smartcontract.withdraw({"from" : owner_account})

    assert owner_account.balance() > starting_balance;

def test_too_much_money_paid(smartcontract, owner_account):
    smartcontract.flipSaleState(
        {"from": owner_account}
    )

    with brownie.reverts("Wrong amount of ETH provided. Please send of the following amounts: 420000000000000000, 600000000000000000, 900000000000000000 gwei"):
        smartcontract.mint({"from": accounts[0], "value": Web3.toWei(2, "ether")})
    