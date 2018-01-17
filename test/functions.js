// Jan 11 2018 13:07 AEST
var ethPriceUSD = 1310.74;
var defaultGasPrice = web3.toWei(50, "gwei");

// -----------------------------------------------------------------------------
// Accounts
// -----------------------------------------------------------------------------
var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Contract Owner");
addAccount(eth.accounts[2], "Account #2 - Wallet");
addAccount(eth.accounts[3], "Account #3 - Devery Whitelisted");
addAccount(eth.accounts[4], "Account #4 - PICOPS Certified");
addAccount(eth.accounts[5], "Account #5 - Devery Whitelisted");
addAccount(eth.accounts[6], "Account #6 - Not whitelisted or certified");
addAccount(eth.accounts[7], "Account #7 - PICOPS Certified");
addAccount(eth.accounts[8], "Account #8");
addAccount(eth.accounts[9], "Account #9");
addAccount(eth.accounts[10], "Account #10 - Reserve Wallet");
addAccount(eth.accounts[11], "Account #11 - Team Member 1");
addAccount(eth.accounts[12], "Account #12 - Team Member 2");
addAccount(eth.accounts[13], "Account #13 - Team Member 3");


var minerAccount = eth.accounts[0];
var contractOwnerAccount = eth.accounts[1];
var wallet = eth.accounts[2];
var account3 = eth.accounts[3];
var account4 = eth.accounts[4];
var account5 = eth.accounts[5];
var account6 = eth.accounts[6];
var account7 = eth.accounts[7];
var account8 = eth.accounts[8];
var account9 = eth.accounts[9];
var reserveWallet = eth.accounts[10];
var teamMember1Wallet = eth.accounts[11];
var teamMember2Wallet = eth.accounts[12];
var teamMember3Wallet = eth.accounts[13];


var baseBlock = eth.blockNumber;

function unlockAccounts(password) {
  for (var i = 0; i < eth.accounts.length && i < accounts.length; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}


// -----------------------------------------------------------------------------
// Token Contract
// -----------------------------------------------------------------------------
var tokenContractAddress = null;
var tokenContractAbi = null;

function addTokenContractAddressAndAbi(address, tokenAbi) {
  tokenContractAddress = address;
  tokenContractAbi = tokenAbi;
}


// -----------------------------------------------------------------------------
// Account ETH and token balances
// -----------------------------------------------------------------------------
function printBalances() {
  var token = tokenContractAddress == null || tokenContractAbi == null ? null : web3.eth.contract(tokenContractAbi).at(tokenContractAddress);
  var decimals = token == null ? 18 : token.decimals();
  var i = 0;
  var totalTokenBalance = new BigNumber(0);
  console.log("RESULT:  # Account                                             EtherBalanceChange                          Token Name");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  accounts.forEach(function(e) {
    var etherBalanceBaseBlock = eth.getBalance(e, baseBlock);
    var etherBalance = web3.fromWei(eth.getBalance(e).minus(etherBalanceBaseBlock), "ether");
    var tokenBalance = token == null ? new BigNumber(0) : token.balanceOf(e).shift(-decimals);
    totalTokenBalance = totalTokenBalance.add(tokenBalance);
    console.log("RESULT: " + pad2(i) + " " + e  + " " + pad(etherBalance) + " " + padToken(tokenBalance, decimals) + " " + accountNames[e]);
    i++;
  });
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT:                                                                           " + padToken(totalTokenBalance, decimals) + " Total Token Balances");
  console.log("RESULT: -- ------------------------------------------ --------------------------- ------------------------------ ---------------------------");
  console.log("RESULT: ");
}

function pad2(s) {
  var o = s.toFixed(0);
  while (o.length < 2) {
    o = " " + o;
  }
  return o;
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function padToken(s, decimals) {
  var o = s.toFixed(decimals);
  var l = parseInt(decimals)+12;
  while (o.length < l) {
    o = " " + o;
  }
  return o;
}


// -----------------------------------------------------------------------------
// Transaction status
// -----------------------------------------------------------------------------
function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  var gasPrice = tx.gasPrice;
  var gasCostETH = tx.gasPrice.mul(txReceipt.gasUsed).div(1e18);
  var gasCostUSD = gasCostETH.mul(ethPriceUSD);
  var block = eth.getBlock(txReceipt.blockNumber);
  console.log("RESULT: " + name + " status=" + txReceipt.status + (txReceipt.status == 0 ? " Failure" : " Success") + " gas=" + tx.gas +
    " gasUsed=" + txReceipt.gasUsed + " costETH=" + gasCostETH + " costUSD=" + gasCostUSD +
    " @ ETH/USD=" + ethPriceUSD + " gasPrice=" + web3.fromWei(gasPrice, "gwei") + " gwei block=" + 
    txReceipt.blockNumber + " txIx=" + tx.transactionIndex + " txId=" + txId +
    " @ " + block.timestamp + " " + new Date(block.timestamp * 1000).toUTCString());
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

function failIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 0) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfTxStatusError(tx, msg) {
  var status = eth.getTransactionReceipt(tx).status;
  if (status == 1) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function gasEqualsGasUsed(tx) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  return (gas == gasUsed);
}

function failIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    console.log("RESULT: PASS " + msg);
    return 1;
  }
}

function passIfGasEqualsGasUsed(tx, msg) {
  var gas = eth.getTransaction(tx).gas;
  var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
  if (gas == gasUsed) {
    console.log("RESULT: PASS " + msg);
    return 1;
  } else {
    console.log("RESULT: FAIL " + msg);
    return 0;
  }
}

function failIfGasEqualsGasUsedOrContractAddressNull(contractAddress, tx, msg) {
  if (contractAddress == null) {
    console.log("RESULT: FAIL " + msg);
    return 0;
  } else {
    var gas = eth.getTransaction(tx).gas;
    var gasUsed = eth.getTransactionReceipt(tx).gasUsed;
    if (gas == gasUsed) {
      console.log("RESULT: FAIL " + msg);
      return 0;
    } else {
      console.log("RESULT: PASS " + msg);
      return 1;
    }
  }
}


//-----------------------------------------------------------------------------
//Wait until some unixTime + additional seconds
//-----------------------------------------------------------------------------
function waitUntil(message, unixTime, addSeconds) {
  var t = parseInt(unixTime) + parseInt(addSeconds) + parseInt(1);
  var time = new Date(t * 1000);
  console.log("RESULT: Waiting until '" + message + "' at " + unixTime + "+" + addSeconds + "s =" + time + " now=" + new Date());
  while ((new Date()).getTime() <= time.getTime()) {
  }
  console.log("RESULT: Waited until '" + message + "' at at " + unixTime + "+" + addSeconds + "s =" + time + " now=" + new Date());
  console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
//Wait until some block
//-----------------------------------------------------------------------------
function waitUntilBlock(message, block, addBlocks) {
  var b = parseInt(block) + parseInt(addBlocks);
  console.log("RESULT: Waiting until '" + message + "' #" + block + "+" + addBlocks + " = #" + b + " currentBlock=" + eth.blockNumber);
  while (eth.blockNumber <= b) {
  }
  console.log("RESULT: Waited until '" + message + "' #" + block + "+" + addBlocks + " = #" + b + " currentBlock=" + eth.blockNumber);
  console.log("RESULT: ");
}


//-----------------------------------------------------------------------------
// Token Contract
//-----------------------------------------------------------------------------
var tokenFromBlock = 0;
function printTokenContractDetails() {
  console.log("RESULT: tokenContractAddress=" + tokenContractAddress);
  if (tokenContractAddress != null && tokenContractAbi != null) {
    var contract = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var decimals = contract.decimals();
    console.log("RESULT: token.owner=" + contract.owner());
    console.log("RESULT: token.newOwner=" + contract.newOwner());
    console.log("RESULT: token.symbol=" + contract.symbol());
    console.log("RESULT: token.name=" + contract.name());
    console.log("RESULT: token.decimals=" + decimals);
    console.log("RESULT: token.totalSupply=" + contract.totalSupply().shift(-decimals));
    console.log("RESULT: token.transferable=" + contract.transferable());
    console.log("RESULT: token.mintable=" + contract.mintable());

    var latestBlock = eth.blockNumber;
    var i;

    var ownershipTransferredEvents = contract.OwnershipTransferred({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    ownershipTransferredEvents.watch(function (error, result) {
      console.log("RESULT: OwnershipTransferred " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ownershipTransferredEvents.stopWatching();

    var mintingDisabledEvents = contract.MintingDisabled({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    mintingDisabledEvents.watch(function (error, result) {
      console.log("RESULT: MintingDisabled " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    mintingDisabledEvents.stopWatching();

    var transfersEnabledEvents = contract.TransfersEnabled({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transfersEnabledEvents.watch(function (error, result) {
      console.log("RESULT: TransfersEnabled " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    transfersEnabledEvents.stopWatching();

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " tokenOwner=" + result.args.tokenOwner + " spender=" + result.args.spender +
        " tokens=" + result.args.tokens.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": from=" + result.args.from + " to=" + result.args.to +
        " tokens=" + result.args.tokens.shift(-decimals));
    });
    transferEvents.stopWatching();

    tokenFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// Crowdsale Contract
// -----------------------------------------------------------------------------
var crowdsaleContractAddress = null;
var crowdsaleContractAbi = null;

function addCrowdsaleContractAddressAndAbi(address, crowdsaleAbi) {
  crowdsaleContractAddress = address;
  crowdsaleContractAbi = crowdsaleAbi;
}

var crowdsaleFromBlock = 0;
function printCrowdsaleContractDetails() {
  console.log("RESULT: crowdsaleContractAddress=" + crowdsaleContractAddress);
  if (crowdsaleContractAddress != null && crowdsaleContractAbi != null) {
    var contract = eth.contract(crowdsaleContractAbi).at(crowdsaleContractAddress);
    console.log("RESULT: crowdsale.owner=" + contract.owner());
    console.log("RESULT: crowdsale.newOwner=" + contract.newOwner());
    console.log("RESULT: crowdsale.bttsToken=" + contract.bttsToken());
    console.log("RESULT: crowdsale.TOKEN_DECIMALS=" + contract.TOKEN_DECIMALS());
    console.log("RESULT: crowdsale.presaleToken=" + contract.presaleToken());
    console.log("RESULT: crowdsale.presaleEthAmountsProcessed=" + contract.presaleEthAmountsProcessed() + " " + contract.presaleEthAmountsProcessed().shift(-18));
    console.log("RESULT: crowdsale.presaleProcessed=" + contract.presaleProcessed());
    console.log("RESULT: crowdsale.PRESALE_BONUS_PERCENT=" + contract.PRESALE_BONUS_PERCENT());
    console.log("RESULT: crowdsale.PER_ACCOUNT_ADDITIONAL_TOKENS=" + contract.PER_ACCOUNT_ADDITIONAL_TOKENS() + " " + contract.PER_ACCOUNT_ADDITIONAL_TOKENS().shift(-18) + " EVE");
    console.log("RESULT: crowdsale.picopsCertifier=" + contract.picopsCertifier());
    console.log("RESULT: crowdsale.wallet=" + contract.wallet());
    // console.log("RESULT: crowdsale.teamWallet=" + contract.teamWallet());
    console.log("RESULT: crowdsale.reserveWallet=" + contract.reserveWallet());
    console.log("RESULT: crowdsale.vestingTeamWallet=" + contract.vestingTeamWallet());
    console.log("RESULT: crowdsale.TEAM_PERCENT_EVE=" + contract.TEAM_PERCENT_EVE());
    console.log("RESULT: crowdsale.RESERVE_PERCENT_EVE=" + contract.RESERVE_PERCENT_EVE());
    console.log("RESULT: crowdsale.TARGET_EVE=" + contract.TARGET_EVE() + " " + contract.TARGET_EVE().shift(-18) + " EVE");
    console.log("RESULT: crowdsale.PRESALEPLUSCROWDSALE_EVE=" + contract.PRESALEPLUSCROWDSALE_EVE() + " " + contract.PRESALEPLUSCROWDSALE_EVE().shift(-18) + " EVE");

    console.log("RESULT: crowdsale.startDate=" + contract.startDate() + " " + new Date(contract.startDate() * 1000).toUTCString());
    console.log("RESULT: crowdsale.firstPeriodEndDate=" + contract.firstPeriodEndDate() + " " + new Date(contract.firstPeriodEndDate() * 1000).toUTCString());
    console.log("RESULT: crowdsale.endDate=" + contract.endDate() + " " + new Date(contract.endDate() * 1000).toUTCString());
    console.log("RESULT: crowdsale.usdPerKEther=" + contract.usdPerKEther() + " = " + contract.usdPerKEther().shift(-3) + " USD per ETH");
    console.log("RESULT: crowdsale.CAP_USD=" + contract.CAP_USD());
    console.log("RESULT: crowdsale.capEth=" + contract.capEth() + " " + contract.capEth().shift(-18) + " ETH");
    console.log("RESULT: crowdsale.presaleEth=" + contract.presaleEth() + " " + contract.presaleEth().shift(-18) + " ETH");
    console.log("RESULT: crowdsale.crowdsaleEth=" + contract.crowdsaleEth() + " " + contract.crowdsaleEth().shift(-18) + " ETH");
    console.log("RESULT: crowdsale.MIN_CONTRIBUTION_ETH=" + contract.MIN_CONTRIBUTION_ETH() + " " + contract.MIN_CONTRIBUTION_ETH().shift(-18) + " ETH");
    console.log("RESULT: crowdsale.contributedEth=" + contract.contributedEth() + " " + contract.contributedEth().shift(-18) + " ETH");
    console.log("RESULT: crowdsale.contributedUsd=" + contract.contributedUsd());
    console.log("RESULT: crowdsale.generatedEve=" + contract.generatedEve() + " " + contract.generatedEve().shift(-18) + " EVE");
    var oneEther = web3.toWei(1, "ether");
    console.log("RESULT: crowdsale.eveFromEth(1 ether, 5%)=" + contract.eveFromEth(oneEther, 5) + " " + contract.eveFromEth(oneEther, 5).shift(-18) + " EVE");
    console.log("RESULT: crowdsale.evePerEth()=" + contract.evePerEth() + " " + contract.evePerEth().shift(-18) + " EVE");
    console.log("RESULT: crowdsale.usdPerEve()=" + contract.usdPerEve() + " " + contract.usdPerEve().shift(-18) + " USD");
    console.log("RESULT: crowdsale.finalised=" + contract.finalised());

    var latestBlock = eth.blockNumber;
    var i;

    var ownershipTransferredEvents = contract.OwnershipTransferred({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    ownershipTransferredEvents.watch(function (error, result) {
      console.log("RESULT: OwnershipTransferred " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ownershipTransferredEvents.stopWatching();

    var bttsTokenUpdatedEvents = contract.BTTSTokenUpdated({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    bttsTokenUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: BTTSTokenUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    bttsTokenUpdatedEvents.stopWatching();

    var picopsCertifierUpdatedEvents = contract.PICOPSCertifierUpdated({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    picopsCertifierUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: PICOPSCertifierUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    picopsCertifierUpdatedEvents.stopWatching();

    var walletUpdatedEvents = contract.WalletUpdated({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    walletUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: WalletUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    walletUpdatedEvents.stopWatching();

    // var teamWalletUpdatedEvents = contract.TeamWalletUpdated({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    // i = 0;
    // teamWalletUpdatedEvents.watch(function (error, result) {
    //   console.log("RESULT: TeamWalletUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    // });
    // teamWalletUpdatedEvents.stopWatching();

    var reserveWalletUpdatedEvents = contract.ReserveWalletUpdated({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    reserveWalletUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: ReserveWalletUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    reserveWalletUpdatedEvents.stopWatching();

    var startDateUpdatedEvents = contract.StartDateUpdated({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    startDateUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: StartDateUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    startDateUpdatedEvents.stopWatching();

    var firstPeriodEndDateUpdatedEvents = contract.FirstPeriodEndDateUpdated({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    firstPeriodEndDateUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: FirstPeriodEndDateUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    firstPeriodEndDateUpdatedEvents.stopWatching();

    var endDateUpdatedEvents = contract.EndDateUpdated({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    endDateUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: EndDateUpdated " + i++ + " #" + result.blockNumber +
        " oldEndDate=" + result.args.oldEndDate + " " + new Date(result.args.oldEndDate * 1000).toUTCString() +
        " newEndDate=" + result.args.newEndDate + " " + new Date(result.args.newEndDate * 1000).toUTCString());
    });
    endDateUpdatedEvents.stopWatching();

    var usdPerKEtherUpdatedEvents = contract.UsdPerKEtherUpdated({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    usdPerKEtherUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: UsdPerKEtherUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    usdPerKEtherUpdatedEvents.stopWatching();

    var firstPeriodCapUpdatedEvents = contract.FirstPeriodCapUpdated({}, { fromBlock: crowdsaleFromBlock, toBlock: latestBlock });
    i = 0;
    firstPeriodCapUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: FirstPeriodCapUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    firstPeriodCapUpdatedEvents.stopWatching();

    var contributedEvents = contract.Contributed({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    contributedEvents.watch(function (error, result) {
      console.log("RESULT: Contributed " + i++ + " #" + result.blockNumber + " addr=" + result.args.addr + 
        " ethAmount=" + result.args.ethAmount.shift(-18) + " ETH" +
        " ethRefund=" + result.args.ethRefund.shift(-18) + " ETH" +
        " accountEthAmount=" + result.args.accountEthAmount.shift(-18) + " ETH" +
        " usdAmount=" + result.args.usdAmount + " USD" +
        " bonusPercent=" + result.args.bonusPercent + "%" +
        " eveAmount=" + result.args.eveAmount.shift(-18) +
        " contributedEth=" + result.args.contributedEth.shift(-18) + " ETH" +
        " contributedUsd=" + result.args.contributedUsd + " USD" +
        " generatedEve=" + result.args.generatedEve.shift(-18));
    });
    contributedEvents.stopWatching();

    crowdsaleFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// Vesting Contract
// -----------------------------------------------------------------------------
var vestingContractAddress = null;
var vestingContractAbi = null;

function addVestingContractAddressAndAbi(address, vestingAbi) {
  vestingContractAddress = address;
  vestingContractAbi = vestingAbi;
}

var vestingFromBlock = 0;
function printVestingContractDetails() {
  console.log("RESULT: vestingContractAddress=" + vestingContractAddress);
  if (vestingContractAddress != null && vestingContractAbi != null) {
    var contract = eth.contract(vestingContractAbi).at(vestingContractAddress);
    console.log("RESULT: vesting.crowdsale=" + contract.crowdsale());
    console.log("RESULT: vesting.totalProportion=" + contract.totalProportion());
    console.log("RESULT: vesting.totalTokens=" + contract.totalTokens().shift(-18) + " EVE");
    console.log("RESULT: vesting.startDate=" + contract.startDate() + " " + new Date(contract.startDate() * 1000).toUTCString());
    console.log("RESULT: vesting.entries(" + teamMember1Wallet + ")=" + JSON.stringify(vesting.entries(teamMember1Wallet)));
    console.log("RESULT: vesting.entries(" + teamMember2Wallet + ")=" + JSON.stringify(vesting.entries(teamMember2Wallet)));
    console.log("RESULT: vesting.entries(" + teamMember3Wallet + ")=" + JSON.stringify(vesting.entries(teamMember3Wallet)));
    var tokenShare1 = vesting.tokenShare(teamMember1Wallet);
    var withdrawable1 = vesting.withdrawable(teamMember1Wallet);
    var withdrawn1 = vesting.withdrawn(teamMember1Wallet);
    console.log("RESULT: vesting.tokenShare(" + teamMember1Wallet + ")=" + tokenShare1.shift(-18) +
        " EVE, withdrawable=" + withdrawable1.shift(-18) +
        " EVE, withdrawn=" + withdrawn1.shift(-18) + " EVE");
    var tokenShare2 = vesting.tokenShare(teamMember2Wallet);
    var withdrawable2 = vesting.withdrawable(teamMember2Wallet);
    var withdrawn2 = vesting.withdrawn(teamMember2Wallet);
    console.log("RESULT: vesting.tokenShare(" + teamMember2Wallet + ")=" + tokenShare2.shift(-18) +
        " EVE, withdrawable=" + withdrawable2.shift(-18) +
        " EVE, withdrawn=" + withdrawn2.shift(-18) + " EVE");
    var tokenShare3 = vesting.tokenShare(teamMember3Wallet);
    var withdrawable3 = vesting.withdrawable(teamMember3Wallet);
    var withdrawn3 = vesting.withdrawn(teamMember3Wallet);
    console.log("RESULT: vesting.tokenShare(" + teamMember3Wallet + ")=" + tokenShare3.shift(-18) +
        " EVE, withdrawable=" + withdrawable3.shift(-18) +
        " EVE, withdrawn=" + withdrawn3.shift(-18) + " EVE");
    var totalTokenShare = tokenShare1.add(tokenShare2).add(tokenShare3);
    console.log("RESULT: vesting.totalTokenShare=" + totalTokenShare.shift(-18) + " EVE");

    var latestBlock = eth.blockNumber;
    var i;

    var newEntryEvents = contract.NewEntry({}, { fromBlock: vestingFromBlock, toBlock: latestBlock });
    i = 0;
    newEntryEvents.watch(function (error, result) {
      console.log("RESULT: NewEntry " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    newEntryEvents.stopWatching();

    var withdrawnEvents = contract.Withdrawn({}, { fromBlock: vestingFromBlock, toBlock: latestBlock });
    i = 0;
    withdrawnEvents.watch(function (error, result) {
      console.log("RESULT: Withdrawn " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    withdrawnEvents.stopWatching();

    vestingFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// TokenFactory Contract
// -----------------------------------------------------------------------------
var tokenFactoryContractAddress = null;
var tokenFactoryContractAbi = null;

function addTokenFactoryContractAddressAndAbi(address, tokenFactoryAbi) {
  tokenFactoryContractAddress = address;
  tokenFactoryContractAbi = tokenFactoryAbi;
}

var tokenFactoryFromBlock = 0;

function getBTTSFactoryTokenListing() {
  var addresses = [];
  console.log("RESULT: tokenFactoryContractAddress=" + tokenFactoryContractAddress);
  if (tokenFactoryContractAddress != null && tokenFactoryContractAbi != null) {
    var contract = eth.contract(tokenFactoryContractAbi).at(tokenFactoryContractAddress);

    var latestBlock = eth.blockNumber;
    var i;

    var bttsTokenListingEvents = contract.BTTSTokenListing({}, { fromBlock: tokenFactoryFromBlock, toBlock: latestBlock });
    i = 0;
    bttsTokenListingEvents.watch(function (error, result) {
      console.log("RESULT: get BTTSTokenListing " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
      addresses.push(result.args.bttsTokenAddress);
    });
    bttsTokenListingEvents.stopWatching();
  }
  return addresses;
}

function printTokenFactoryContractDetails() {
  console.log("RESULT: tokenFactoryContractAddress=" + tokenFactoryContractAddress);
  if (tokenFactoryContractAddress != null && tokenFactoryContractAbi != null) {
    var contract = eth.contract(tokenFactoryContractAbi).at(tokenFactoryContractAddress);
    console.log("RESULT: tokenFactory.owner=" + contract.owner());
    console.log("RESULT: tokenFactory.newOwner=" + contract.newOwner());

    var latestBlock = eth.blockNumber;
    var i;

    var ownershipTransferredEvents = contract.OwnershipTransferred({}, { fromBlock: tokenFactoryFromBlock, toBlock: latestBlock });
    i = 0;
    ownershipTransferredEvents.watch(function (error, result) {
      console.log("RESULT: OwnershipTransferred " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ownershipTransferredEvents.stopWatching();

    var bttsTokenListingEvents = contract.BTTSTokenListing({}, { fromBlock: tokenFactoryFromBlock, toBlock: latestBlock });
    i = 0;
    bttsTokenListingEvents.watch(function (error, result) {
      console.log("RESULT: BTTSTokenListing " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    bttsTokenListingEvents.stopWatching();

    tokenFactoryFromBlock = latestBlock + 1;
  }
}
