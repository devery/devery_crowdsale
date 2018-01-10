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
addAccount(eth.accounts[10], "Account #10");
addAccount(eth.accounts[11], "Account #11");


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
var owner1 = eth.accounts[10];
var owner2 = eth.accounts[11];

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
    console.log("RESULT: token.wallet=" + contract.wallet());
    console.log("RESULT: token.START_DATE=" + contract.START_DATE() + " " + new Date(contract.START_DATE() * 1000).toUTCString());
    console.log("RESULT: token.closed=" + contract.closed());
    console.log("RESULT: token.ethMinContribution=" + contract.ethMinContribution() + " " + contract.ethMinContribution().shift(-18) + " ETH");
    console.log("RESULT: token.usdCap=" + contract.usdCap());
    console.log("RESULT: token.usdPerKEther=" + contract.usdPerKEther());
    console.log("RESULT: token.ethCap=" + contract.ethCap() + " " + contract.ethCap().shift(-18) + " ETH");
    console.log("RESULT: token.contributedEth=" + contract.contributedEth() + " " + contract.contributedEth().shift(-18) + " ETH");
    console.log("RESULT: token.contributedUsd=" + contract.contributedUsd());
    console.log("RESULT: token.whitelist=" + contract.whitelist());
    console.log("RESULT: token.picopsCertifier=" + contract.picopsCertifier());
    console.log("RESULT: token.addressCanContribute(0xa44a08d3f6933c69212114bb66e2df1813651844) (WL)=" + contract.addressCanContribute("0xa44a08d3f6933c69212114bb66e2df1813651844"));
    console.log("RESULT: token.addressCanContribute(0xa55a151eb00fded1634d27d1127b4be4627079ea) (PICOPS)=" + contract.addressCanContribute("0xa55a151eb00fded1634d27d1127b4be4627079ea"));
    console.log("RESULT: token.addressCanContribute(0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9) (not registered)=" + contract.addressCanContribute("0xa66a85ede0cbe03694aa9d9de0bb19c99ff55bd9"));

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

    var walletUpdatedEvents = contract.WalletUpdated({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    walletUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: WalletUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    walletUpdatedEvents.stopWatching();

    var ethMinContributionUpdatedEvents = contract.EthMinContributionUpdated({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    ethMinContributionUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: EthMinContributionUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ethMinContributionUpdatedEvents.stopWatching();

    var usdCapUpdatedEvents = contract.UsdCapUpdated({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    usdCapUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: UsdCapUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    usdCapUpdatedEvents.stopWatching();

    var usdPerKEtherUpdatedEvents = contract.UsdPerKEtherUpdated({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    usdPerKEtherUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: UsdPerKEtherUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    usdPerKEtherUpdatedEvents.stopWatching();

    var whitelistUpdatedEvents = contract.WhitelistUpdated({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    whitelistUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: WhitelistUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    whitelistUpdatedEvents.stopWatching();

    var picopsCertifierUpdatedEvents = contract.PICOPSCertifierUpdated({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    picopsCertifierUpdatedEvents.watch(function (error, result) {
      console.log("RESULT: PICOPSCertifierUpdated " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    picopsCertifierUpdatedEvents.stopWatching();

    var contributedEvents = contract.Contributed({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    contributedEvents.watch(function (error, result) {
      console.log("RESULT: Contributed " + i++ + " #" + result.blockNumber + " addr=" + result.args.addr + 
        " ethAmount=" + result.args.ethAmount + " " + result.args.ethAmount.shift(-18) + " ETH" +
        " ethRefund=" + result.args.ethRefund + " " + result.args.ethRefund.shift(-18) + " ETH" +
        " usdAmount=" + result.args.usdAmount + " USD" +
        " contributedEth=" + result.args.contributedEth + " " + result.args.contributedEth.shift(-18) + " ETH" +
        " contributedUsd=" + result.args.contributedUsd + " USD");
    });
    contributedEvents.stopWatching();

    var approvalEvents = contract.Approval({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    approvalEvents.watch(function (error, result) {
      console.log("RESULT: Approval " + i++ + " #" + result.blockNumber + " owner=" + result.args.owner + " spender=" + result.args.spender +
        " value=" + result.args.value.shift(-decimals));
    });
    approvalEvents.stopWatching();

    var transferEvents = contract.Transfer({}, { fromBlock: tokenFromBlock, toBlock: latestBlock });
    i = 0;
    transferEvents.watch(function (error, result) {
      console.log("RESULT: Transfer " + i++ + " #" + result.blockNumber + ": from=" + result.args.from + " to=" + result.args.to +
        " value=" + result.args.value.shift(-decimals));
    });
    transferEvents.stopWatching();

    tokenFromBlock = latestBlock + 1;
  }
}


// -----------------------------------------------------------------------------
// Whitelist Contract
// -----------------------------------------------------------------------------
var whitelistContractAddress = null;
var whitelistContractAbi = null;

function addWhitelistContractAddressAndAbi(address, whitelistAbi) {
  whitelistContractAddress = address;
  whitelistContractAbi = whitelistAbi;
}

var whitelistFromBlock = 0;
function printWhitelistContractDetails() {
  console.log("RESULT: whitelistContractAddress=" + whitelistContractAddress);
  if (whitelistContractAddress != null && whitelistContractAbi != null) {
    var contract = eth.contract(whitelistContractAbi).at(whitelistContractAddress);
    console.log("RESULT: whitelist.owner=" + contract.owner());
    console.log("RESULT: whitelist.newOwner=" + contract.newOwner());
    console.log("RESULT: whitelist.sealed=" + contract.sealed());

    var latestBlock = eth.blockNumber;
    var i;

    var ownershipTransferredEvents = contract.OwnershipTransferred({}, { fromBlock: whitelistFromBlock, toBlock: latestBlock });
    i = 0;
    ownershipTransferredEvents.watch(function (error, result) {
      console.log("RESULT: OwnershipTransferred " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    ownershipTransferredEvents.stopWatching();

    var adminAddedEvents = contract.AdminAdded({}, { fromBlock: whitelistFromBlock, toBlock: latestBlock });
    i = 0;
    adminAddedEvents.watch(function (error, result) {
      console.log("RESULT: AdminAdded " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    adminAddedEvents.stopWatching();

    var adminRemovedEvents = contract.AdminRemoved({}, { fromBlock: whitelistFromBlock, toBlock: latestBlock });
    i = 0;
    adminRemovedEvents.watch(function (error, result) {
      console.log("RESULT: AdminRemoved " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    adminRemovedEvents.stopWatching();

    var whitelistedEvents = contract.Whitelisted({}, { fromBlock: whitelistFromBlock, toBlock: latestBlock });
    i = 0;
    whitelistedEvents.watch(function (error, result) {
      console.log("RESULT: Whitelisted " + i++ + " #" + result.blockNumber + " " + JSON.stringify(result.args));
    });
    whitelistedEvents.stopWatching();

    whitelistFromBlock = latestBlock + 1;
  }
}

