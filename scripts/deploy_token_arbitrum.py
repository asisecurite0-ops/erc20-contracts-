import os, json
from web3 import Web3
from dotenv import load_dotenv

load_dotenv()

# Connexion au réseau Arbitrum
w3 = Web3(Web3.HTTPProvider(os.getenv("RPC_URL_ARBITRUM")))
deployer = w3.eth.account.from_key(os.getenv("PRIVATE_KEY"))

with open("MyToken.json") as f:
    contract_data = json.load(f)
abi, bytecode = contract_data["abi"], contract_data["bytecode"]

MyToken = w3.eth.contract(abi=abi, bytecode=bytecode)
tx = MyToken.constructor(
    int(os.getenv("INITIAL_SUPPLY")),
    int(os.getenv("MAX_SUPPLY")),
    os.getenv("TOKEN_NAME"),
    os.getenv("TOKEN_SYMBOL")
).build_transaction({
    "from": deployer.address,
    "nonce": w3.eth.get_transaction_count(deployer.address),
    "gas": 3000000,
    "gasPrice": w3.to_wei("0.1", "gwei")  # Arbitrum gas
})

signed_tx = deployer.sign_transaction(tx)
tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
print("✅ Déploiement Arbitrum en cours, hash:", tx_hash.hex())
