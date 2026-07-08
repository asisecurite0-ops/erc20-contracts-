🚀 Deployment Guide – ERC20 Token Multi‑Chain

📖 Description
This project provides an advanced ERC20 Token with:

Whitelist / Blacklist (single and batch)

Pause / Unpause of the contract

Mint / Burn

Export and import of CSV lists

Python scripts to interact with the contract

The project is multi‑network: Ethereum, Polygon, Arbitrum.
You can deploy on the network of your choice using the provided scripts.

⚙️ Installation
bash
git clone https://github.com/youraccount/erc20-project.git
cd erc20-project
pip install -r requirements.txt
🔑 Configuration
Copy the .env.example file to .env and fill in your values:

bash
cp .env.example .env
Main variables:

PRIVATE_KEY: deployer’s private key

RPC_URL_ETH, RPC_URL_POLYGON, RPC_URL_ARBITRUM: RPC endpoints for networks

INITIAL_SUPPLY, MAX_SUPPLY, TOKEN_NAME, TOKEN_SYMBOL

🚀 Deployment
Available scripts:

Ethereum: python deploy_token_eth.py

Polygon: python deploy_token_polygon.py

Arbitrum: python deploy_token_arbitrum.py

Example:

bash
python deploy_token_polygon.py
🛠️ Interaction
Use interact_token.py to:

Read a balance

Transfer tokens

Mint / Burn

Manage whitelist / blacklist

Export / import CSV

📂 Example CSV
csv
Type,Address
Whitelist,0x1234...
Blacklist,0x5678...

📜 License
MIT License

📞 Contact
Project developed by Asi.
For support or partnership: asisecurite0@gmail.com