# Devery Crowdsale Contract 

## Requirements
* 100 Million tokens 
* Presale 5% bonus 
* 20ETH max contributions for 24hrs, afterwards cap is removed - we can change this number
* PICOPS users get a bonus of 150EVE  - we can change this number
* The contract will open when date starts, this date can be in the past. 
* Rejects funding at 10 million USD cap set with USD price per ETH
* Owner must call crowdsale contract to close. 1 week lockup from end of sale whether it fills or not.  
* Unsold tokens are not generated.

<br />

<hr />

## Deployment And Execution

### Deploy BTTS Token Contract

* Use BTTSTokenFactory deployed on Mainnet at address 0x{xxxx}
* Execute `bttsTokenFactory.deployBTTSTokenContract(symbol, name, decimals, initialSupply, mintable, transferable)` where
  * `symbol` = `EVE`
  * `name` = `Devery`
  * `decimals` = `18`
  * `initialSupply` = `0`
  * `mintable` = `true`
  * `transferable` = `false`

<br />

### Deploy Devery Crowdsale Contract

* Deploy `DeveryCrowdsale.DeveryCrowdsale`

<br />

### Link Contracts

* Execute `deveryCrowdsale.setBTTSToken(bttsTokenAddress)`
* Execute `bttsToken.setMinter(deveryCrowdsaleAddress)`

<br />

### Generate Tokens For Presale Accounts

# Execute `deveryCrowdsale.generateTokensForPresaleAccounts([account1, account2, ..., accountn])` so all presale accounts have their tokens generated

<br />

### Contribution Period

* First 12 hours restricted to PICOPS registered addresses and have a maximum cap
* Remaining period does not need accounts to be PICOPS registered, and don't have a maximum cap

<br />

### Finalisation

* Execute `deveryCrowdsale.finalise()`
