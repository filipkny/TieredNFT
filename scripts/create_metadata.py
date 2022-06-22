import json

import requests
from brownie import TieredNFT, network
from pathlib import Path
from scripts.deploy_smartcontract import deploy_tiered_nft

hashes = [
    "QmPzEyUfWSPz1EiZMasVQ14VcmrmyNAgfCk4TM1ZpYWRit",
    "QmTWeu3r8r5d21VkZyWVGJXPfUZivsfigEBUbMramHwwBG",
    "QmcWikGwdF829mrs8E2LFFpooWoJ4rwYr4WNQ154VnRm2G"]

def main():
    deploy_tiered_nft()
    smartcontract_showcase = TieredNFT[-1]
    num_tiers = 3
    num_tokens_per_tier = [smartcontract_showcase.tierMaxSupply(i) for i in range(num_tiers)]

    # reading the data from the file
    if Path('./nfts/uploaded_nfts.txt').exists():
        with open('./nfts/uploaded_nfts.txt') as f:
            data = f.read()

        uploaded_nfts = json.loads(data)
        print("Loaded uploaded nfts")
    else:
        print("No uploaded nfts found")
        uploaded_nfts = {}


    token_id = 0
    for tier, num_tokens in enumerate(num_tokens_per_tier):
        for _ in range(num_tokens):
            metadata_filename = f"./images/metadata/{token_id}.json"

            if Path(metadata_filename).exists():
                print(f"{metadata_filename} already exists! Skipping")
            else:
                print(f"Creating {metadata_filename}")
                image_filename = f"./images/pictures/question_mark{tier}.png"
                metadata = {
                    "name" : "#{}".format(token_id),
                    "description" : "Question mark #{}".format(token_id),
                    "image" : upload_to_ipfs(image_filename),
                    "attributes" :[]
                }

                with open(metadata_filename,"w") as file:
                    json.dump(metadata, file)

                metadata_uri = upload_to_ipfs(metadata_filename)
                uploaded_nfts[token_id] = metadata_uri

            token_id += 1

    # with open("./images/uploaded_nfts.txt", "w") as f:
    #     json.dump(uploaded_nfts, f)

def upload_to_ipfs(filepath):
    with Path(filepath).open("rb") as fp:
        img_binary = fp.read()
        ipfs_url = "http://127.0.0.1:5001"
        endpoint = "/api/v0/add"
        response = requests.post(ipfs_url+endpoint,files={"file": img_binary})
        ipfs_hash = response.json()["Hash"]
        filename = filepath.split("/")[-1:][0]
        img_uri = f"https://ipfs.io/ipfs/{ipfs_hash}?filename={filename}"
        print(img_uri)
        return img_uri
