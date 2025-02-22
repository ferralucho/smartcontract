# https://ethdocs.org/en/latest/contracts-and-transactions/accessing-contracts-and-transactions.html
# https://goethereumbook.org/smart-contract-deploy/
# https://documenter.getpostman.com/view/4117254/ethereum-json-rpc/RVu7CT5J#dd57ef90-f990-037e-5512-4929e7280d7c
#
# The environment has three accounts all using this same passkey (123).
# Geth is started with address 0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd and is used as the coinbase address.
# The coinbase address is the account to pay mining rewards to.
# The coinbase address is give a LOT of money to start.
#
# These are examples of what you can do in the attach JS environment.
# 	eth.getBalance("0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd") or eth.getBalance(eth.coinbase)
# 	eth.getBalance("0x8e113078adf6888b7ba84967f299f29aece24c55")
# 	eth.getBalance("0x0070742ff6003c3e809e78d524f0fe5dcc5ba7f7")
#   eth.sendTransaction({from:eth.coinbase, to:"0x8e113078adf6888b7ba84967f299f29aece24c55", value: web3.toWei(0.05, "ether")})
#   eth.sendTransaction({from:eth.coinbase, to:"0x0070742ff6003c3e809e78d524f0fe5dcc5ba7f7", value: web3.toWei(0.05, "ether")})
#   eth.blockNumber
#   eth.getBlockByNumber(8)
#   eth.getTransaction("0xaea41e7c13a7ea627169c74ade4d5ea86664ff1f740cd90e499f3f842656d4ad")
#
# These are examples of what you can do in the HTTP-RPC environment.
# https://documenter.getpostman.com/view/4117254/ethereum-json-rpc/RVu7CT5J
# curl -H 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_coinbase", "id":1}' localhost:8545
# curl -H 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_getBalance", "params": ["0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd", "latest"], "id":1}' localhost:8545
#
# check this out https://etherscan.io/gastracker
# If you want something to go through soon, have a base fee (~30) and the priority fee or tip of 1 gwei
# Priority fee doesn't do much i've noticed and is always around 1-3 gwei. I've been setting that base fee higher.
#
#  Unit	                Wei Value	 Wei
#  wei	                1 wei        1
#  Kwei (babbage)	    1e3 wei	     1,000
#  Mwei (lovelace)	    1e6 wei	     1,000,000
#  Gwei (shannon)	    1e9 wei	     1,000,000,000
#  microether (szabo)	1e12 wei	 1,000,000,000,000
#  milliether (finney)	1e15 wei	 1,000,000,000,000,000
#  ether	            1e18 wei	 1,000,000,000,000,000,000
#
# Goerli Testnet Faucet
# https://goerlifaucet.com/
# Endpoint: https://rpc.goerli.mudit.blog/
#
# Visibility Quantifiers
# external − External functions are meant to be called by other contracts. They cannot be used for internal call.
# public   − Public functions/variables can be used both externally and internally. For public state variable, Solidity automatically creates a getter function.
# internal − Internal functions/variables can only be used internally or by derived contracts.
# private  − Private functions/variables can only be used internally and not even by derived contracts.
#
# Variable Location Options
# Storage  - It is where all state variables are stored. Because state can be altered in a contract (for example, within a function), storage variables must be mutable. However, their location is persistent, and they are stored on the blockchain.
# Memory   - Reserved for variables that are defined within the scope of a function. They only persist while a function is called, and thus are temporary variables that cannot be accessed outside this scope (ie anywhere else in your contract besides within that function). However, they are mutable within that function.
# Calldata - Is an immutable, temporary location where function arguments are stored, and behaves mostly like memory.
#

# ==============================================================================
# Source the Etherscan key to the environment. You will need to get your own
# key after registering on the site. https://docs.etherscan.io/
# This source command needs to be run manually.
etherscan:
	source etherscan.env

# ==============================================================================
# These commands build, deploy, and run the basic smart contract.

# This will compile the smart contract and produce the binary code. Then with the
# abi and binary code, a Go source code file can be generated for Go API access.
basic-build:
	solc --abi app/basic/contract/src/store.sol -o app/basic/contract/abi --overwrite
	solc --bin app/basic/contract/src/store.sol -o app/basic/contract/abi --overwrite
	abigen --bin=app/basic/contract/abi/Store.bin --abi=app/basic/contract/abi/Store.abi --pkg=store --out=app/basic/contract/go/store.go

# This will deploy the smart contract to the locally running Ethereum environment.
basic-deploy: basic-build
	go run app/basic/cmd/deploy/main.go

# This will execute a simple program to test access to the smart contract API.
basic-write:
	go run app/basic/cmd/write/main.go

# This will execute a simple program to test access to the smart contract API.
basic-read:
	go run app/basic/cmd/read/main.go


# ==============================================================================
# These commands build, deploy, and run the simplecoin smart contract.

scoin-build:
	solc --abi app/simplecoin/contract/src/simplecoin.sol -o app/simplecoin/contract/abi --overwrite
	solc --bin app/simplecoin/contract/src/simplecoin.sol -o app/simplecoin/contract/abi --overwrite
	abigen --bin=app/simplecoin/contract/abi/SimpleCoin.bin --abi=app/simplecoin/contract/abi/SimpleCoin.abi --pkg=scoin --out=app/simplecoin/contract/go/scoin.go

scoin-deploy: scoin-build
	go run app/simplecoin/cmd/deploy/main.go

scoin-transfer:
	go run app/simplecoin/cmd/transfer/main.go

scoin-trancheck:
	go run app/simplecoin/cmd/trancheck/main.go


# ==============================================================================
# These commands build, deploy, and run the crowdsale smart contract.

crowd-build:
	solc --abi app/crowdsale/contract/src/crowdsale.sol -o app/crowdsale/contract/abi --overwrite
	solc --bin app/crowdsale/contract/src/crowdsale.sol -o app/crowdsale/contract/abi --overwrite
	abigen --bin=app/crowdsale/contract/abi/CrowdSale.bin --abi=app/crowdsale/contract/abi/CrowdSale.abi --pkg=crowd --out=app/crowdsale/contract/go/crowdsale.go

crowd-deploy: crowd-build
	go run app/crowdsale/cmd/deploy/main.go

crowd-invest:
	go run app/crowdsale/cmd/invest/main.go


# ==============================================================================
# These commands start the Ethereum node and provide examples of attaching
# directly with potential commands to try, and creating a new account if necessary.

# This is start Ethereum in developer mode. Only when a transaction is pending will
# Ethereum mine a block. It provides a minimal environment for development.
geth-up:
	geth --dev --ipcpath zarf/ethereum/geth.ipc --http --allow-insecure-unlock --rpc.allow-unprotected-txs --mine --miner.threads 1 --verbosity 5 --datadir "zarf/ethereum/" --unlock 0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd --password zarf/ethereum/password

# This will signal Ethereum to shutdown.
geth-down:
	kill -INT $(shell ps | grep "geth " | grep -v grep | sed -n 1,1p | cut -c1-5)

# This will remove the local blockchain and let you start new.
geth-reset:
	rm -rf zarf/ethereum/geth/

# This is a JS console environment for making geth related API calls.
geth-attach:
	geth attach --datadir zarf/ethereum/

# This will add a new account to the keystore. The account will have a zero
# balance until you give it some money.
geth-new-account:
	geth --datadir zarf/ethereum/ account new

# This will deposit 1 ETH into the two extra accounts from the coinbase account.
# Do this if you delete the geth folder and start over or if the accounts need money.
geth-deposit:
	curl -H 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_sendTransaction", "params": [{"from":"0x8e113078adf6888b7ba84967f299f29aece24c55", "to":"0x0070742ff6003c3e809e78d524f0fe5dcc5ba7f7", "value":"0x1000000000000000000"}], "id":1}' localhost:8545
	curl -H 'Content-Type: application/json' --data '{"jsonrpc":"2.0","method":"eth_sendTransaction", "params": [{"from":"0x6327A38415C53FFb36c11db55Ea74cc9cB4976Fd", "to":"0x0070742ff6003c3e809e78d524f0fe5dcc5ba7f7", "value":"0x1000000000000000000"}], "id":1}' localhost:8545


# ==============================================================================
# These commands provide Go related support.

# This will tidy up the Go dependencies.
tidy:
	go mod tidy
	go mod vendor


# ==============================================================================
# These commands install geth, abigen, and solc using Homebrew.

# https://geth.ethereum.org/docs/install-and-build/installing-geth
install-geth:
	brew update
	brew tap ethereum/ethereum
	brew install ethereum

# https://docs.soliditylang.org/en/v0.8.11/installing-solidity.html
install-solc:
	brew update
	brew tap ethereum/ethereum
	brew install solidity
