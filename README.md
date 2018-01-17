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

* Execute `deveryCrowdsale.generateTokensForPresaleAccounts([account1, account2, ..., accountn])` so all presale accounts have their tokens generated

<br />

### Contribution Period

* First 12 hours restricted to PICOPS registered addresses and have a maximum cap
* Remaining period does not need accounts to be PICOPS registered, and don't have a maximum cap

<br />

### Finalisation

* Execute `deveryCrowdsale.finalise()`

<br />

### Vesting

The crowdsale contract will automatically deploy a vesting contract. To verify the source on EtherScan, you will have to provide the
additional parameter data of 0x{24 zeros}{crowdsale contract address}.

These vesting entries are non-revocable. For revocable vesting entries, allocate the proportion to a wallet address with 1 day and after 1 day
withdraw the tokens to the wallet address and manually process the token vesting.

There are three functions to allocate the vesting schedule:

* `addEntryInDays(address holder, uint proportion, uint periods)`
* `addEntryInMonths(address holder, uint proportion, uint periods)`
* `addEntryInYears(address holder, uint proportion, uint periods)`

The holder will be able to call the `withdraw()` function to withdraw any vested tokens.

<br />

<hr />

## Code Review

* [ ] [code-review/DeveryCrowdsale.md](code-review/DeveryCrowdsale.md)
  * [ ] contract ERC20Interface
  * [ ] contract BTTSTokenInterface is ERC20Interface
  * [ ] contract PICOPSCertifier
  * [ ] library SafeMath
  * [ ] contract Owned
  * [ ] contract DeveryVesting
  * [ ] contract DeveryCrowdsale is Owned

<br />

<br />

(c) BokkyPooBah / Bok Consulting Pty Ltd for Devery - Jan 17 2018. The MIT Licence.