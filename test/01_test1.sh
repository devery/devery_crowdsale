#!/bin/bash
# ----------------------------------------------------------------------------------------------
# Testing the smart contract
#
# Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
# ----------------------------------------------------------------------------------------------

MODE=${1:-test}

GETHATTACHPOINT=`grep ^IPCFILE= settings.txt | sed "s/^.*=//"`
PASSWORD=`grep ^PASSWORD= settings.txt | sed "s/^.*=//"`

SOURCEDIR=`grep ^SOURCEDIR= settings.txt | sed "s/^.*=//"`

PRESALEWHITELISTSOL=`grep ^PRESALEWHITELISTSOL= settings.txt | sed "s/^.*=//"`
PRESALEWHITELISTJS=`grep ^PRESALEWHITELISTJS= settings.txt | sed "s/^.*=//"`
PICOPSCERTIFIERSOL=`grep ^PICOPSCERTIFIERSOL= settings.txt | sed "s/^.*=//"`
PICOPSCERTIFIERJS=`grep ^PICOPSCERTIFIERJS= settings.txt | sed "s/^.*=//"`
PRESALETOKENSOL=`grep ^PRESALETOKENSOL= settings.txt | sed "s/^.*=//"`
PRESALETOKENJS=`grep ^PRESALETOKENJS= settings.txt | sed "s/^.*=//"`

PRESALEDEPLOYMENTDATA=`grep ^PRESALEDEPLOYMENTDATA= settings.txt | sed "s/^.*=//"`

INCLUDEJS=`grep ^INCLUDEJS= settings.txt | sed "s/^.*=//"`
TEST1OUTPUT=`grep ^TEST1OUTPUT= settings.txt | sed "s/^.*=//"`
TEST1RESULTS=`grep ^TEST1RESULTS= settings.txt | sed "s/^.*=//"`

CURRENTTIME=`date +%s`
CURRENTTIMES=`date -r $CURRENTTIME -u`

START_DATE=`echo "$CURRENTTIME+45" | bc`
START_DATE_S=`date -r $START_DATE -u`

printf "MODE                  = '$MODE'\n" | tee $TEST1OUTPUT
printf "GETHATTACHPOINT       = '$GETHATTACHPOINT'\n" | tee -a $TEST1OUTPUT
printf "PASSWORD              = '$PASSWORD'\n" | tee -a $TEST1OUTPUT
printf "SOURCEDIR             = '$SOURCEDIR'\n" | tee -a $TEST1OUTPUT
printf "PRESALEWHITELISTSOL   = '$PRESALEWHITELISTSOL'\n" | tee -a $TEST1OUTPUT
printf "PRESALEWHITELISTJS    = '$PRESALEWHITELISTJS'\n" | tee -a $TEST1OUTPUT
printf "PICOPSCERTIFIERSOL    = '$PICOPSCERTIFIERSOL'\n" | tee -a $TEST1OUTPUT
printf "PICOPSCERTIFIERJS     = '$PICOPSCERTIFIERJS'\n" | tee -a $TEST1OUTPUT
printf "PRESALETOKENSOL       = '$PRESALETOKENSOL'\n" | tee -a $TEST1OUTPUT
printf "PRESALETOKENJS        = '$PRESALETOKENJS'\n" | tee -a $TEST1OUTPUT
printf "PRESALEDEPLOYMENTDATA = '$PRESALEDEPLOYMENTDATA'\n" | tee -a $TEST1OUTPUT
printf "INCLUDEJS             = '$INCLUDEJS'\n" | tee -a $TEST1OUTPUT
printf "TEST1OUTPUT           = '$TEST1OUTPUT'\n" | tee -a $TEST1OUTPUT
printf "TEST1RESULTS          = '$TEST1RESULTS'\n" | tee -a $TEST1OUTPUT
printf "CURRENTTIME           = '$CURRENTTIME' '$CURRENTTIMES'\n" | tee -a $TEST1OUTPUT
printf "START_DATE            = '$START_DATE' '$START_DATE_S'\n" | tee -a $TEST1OUTPUT

# Make copy of SOL file and modify start and end times ---
# `cp modifiedContracts/SnipCoin.sol .`
`cp $SOURCEDIR/$PRESALEWHITELISTSOL .`
`cp $SOURCEDIR/$PICOPSCERTIFIERSOL .`
`cp $SOURCEDIR/$PRESALETOKENSOL .`

# --- Modify parameters ---
`perl -pi -e "s/START_DATE \= 1513303200;.*$/START_DATE \= $START_DATE; \/\/ $START_DATE_S/" $PRESALETOKENSOL`

DIFFS1=`diff $SOURCEDIR/$PRESALEWHITELISTSOL $PRESALEWHITELISTSOL`
echo "--- Differences $SOURCEDIR/$PRESALEWHITELISTSOL $PRESALEWHITELISTSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $SOURCEDIR/$PICOPSCERTIFIERSOL $PICOPSCERTIFIERSOL`
echo "--- Differences $SOURCEDIR/$PICOPSCERTIFIERSOL $PICOPSCERTIFIERSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

DIFFS1=`diff $SOURCEDIR/$PRESALETOKENSOL $PRESALETOKENSOL`
echo "--- Differences $SOURCEDIR/$PRESALETOKENSOL $PRESALETOKENSOL ---" | tee -a $TEST1OUTPUT
echo "$DIFFS1" | tee -a $TEST1OUTPUT

solc_0.4.18 --version | tee -a $TEST1OUTPUT

echo "var whitelistOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $PRESALEWHITELISTSOL`;" > $PRESALEWHITELISTJS
echo "var picopsCertifierOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $PICOPSCERTIFIERSOL`;" > $PICOPSCERTIFIERJS
echo "var tokenOutput=`solc_0.4.18 --optimize --pretty-json --combined-json abi,bin,interface $PRESALETOKENSOL`;" > $PRESALETOKENJS


geth --verbosity 3 attach $GETHATTACHPOINT << EOF | tee -a $TEST1OUTPUT
loadScript("$PRESALEWHITELISTJS");
loadScript("$PICOPSCERTIFIERJS");
loadScript("$PRESALETOKENJS");
loadScript("presaleFunctions.js");

var whitelistAbi = JSON.parse(whitelistOutput.contracts["$PRESALEWHITELISTSOL:DeveryPresaleWhitelist"].abi);
var whitelistBin = "0x" + whitelistOutput.contracts["$PRESALEWHITELISTSOL:DeveryPresaleWhitelist"].bin;
var picopsCertifierAbi = JSON.parse(picopsCertifierOutput.contracts["$PICOPSCERTIFIERSOL:TestPICOPSCertifier"].abi);
var picopsCertifierBin = "0x" + picopsCertifierOutput.contracts["$PICOPSCERTIFIERSOL:TestPICOPSCertifier"].bin;
var tokenAbi = JSON.parse(tokenOutput.contracts["$PRESALETOKENSOL:DeveryPresale"].abi);
var tokenBin = "0x" + tokenOutput.contracts["$PRESALETOKENSOL:DeveryPresale"].bin;

console.log("DATA: whitelistAbi=" + JSON.stringify(whitelistAbi));
console.log("DATA: whitelistBin=" + JSON.stringify(whitelistBin));
console.log("DATA: picopsCertifierAbi=" + JSON.stringify(picopsCertifierAbi));
console.log("DATA: picopsCertifierBin=" + JSON.stringify(picopsCertifierBin));
console.log("DATA: tokenAbi=" + JSON.stringify(tokenAbi));
console.log("DATA: tokenBin=" + JSON.stringify(tokenBin));


unlockAccounts("$PASSWORD");
printBalances();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var whitelistMessage = "Deploy Devery Whitelist Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + whitelistMessage);
var whitelistContract = web3.eth.contract(whitelistAbi);
// console.log(JSON.stringify(whitelistContract));
var whitelistTx = null;
var whitelistAddress = null;
var whitelist = whitelistContract.new({from: contractOwnerAccount, data: whitelistBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        whitelistTx = contract.transactionHash;
      } else {
        whitelistAddress = contract.address;
        addAccount(whitelistAddress, "Devery Whitelist");
        addWhitelistContractAddressAndAbi(whitelistAddress, whitelistAbi);
        console.log("DATA: whitelistAddress=" + whitelistAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(whitelistTx, whitelistMessage);
printTxData("whitelistAddress=" + whitelistAddress, whitelistTx);
printWhitelistContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var whitelistAccounts_Message = "Whitelist Accounts";
// -----------------------------------------------------------------------------
console.log("RESULT: " + whitelistAccounts_Message);
var whitelistAccounts_1Tx = whitelist.multiAdd([account3, account5, contractOwnerAccount], [1, 1, 1], {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(whitelistAccounts_1Tx, whitelistAccounts_Message + " - multiAdd([account3, account5, contractOwnerAccount], [1, 1, 1])");
printTxData("whitelistAccounts_1Tx", whitelistAccounts_1Tx);
printWhitelistContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var picopsCertifierMessage = "Deploy Test PICOPS Certifier Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + picopsCertifierMessage);
var picopsCertifierContract = web3.eth.contract(picopsCertifierAbi);
// console.log(JSON.stringify(picopsCertifierContract));
var picopsCertifierTx = null;
var picopsCertifierAddress = null;
var picopsCertifier = picopsCertifierContract.new({from: contractOwnerAccount, data: picopsCertifierBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        picopsCertifierTx = contract.transactionHash;
      } else {
        picopsCertifierAddress = contract.address;
        addAccount(picopsCertifierAddress, "Test PICOPS Certifier");
        console.log("DATA: picopsCertifierAddress=" + picopsCertifierAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(picopsCertifierTx, picopsCertifierMessage);
printTxData("picopsCertifierAddress=" + picopsCertifierAddress, picopsCertifierTx);
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var tokenMessage = "Deploy Token Contract";
// -----------------------------------------------------------------------------
console.log("RESULT: " + tokenMessage);
var tokenContract = web3.eth.contract(tokenAbi);
// console.log(JSON.stringify(tokenContract));
var tokenTx = null;
var tokenAddress = null;
var token = tokenContract.new({from: contractOwnerAccount, data: tokenBin, gas: 6000000, gasPrice: defaultGasPrice},
  function(e, contract) {
    if (!e) {
      if (!contract.address) {
        tokenTx = contract.transactionHash;
      } else {
        tokenAddress = contract.address;
        addAccount(tokenAddress, "Token '" + token.symbol() + "' '" + token.name() + "'");
        addTokenContractAddressAndAbi(tokenAddress, tokenAbi);
        console.log("DATA: tokenAddress=" + tokenAddress);
      }
    }
  }
);
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(tokenTx, tokenMessage);
printTxData("tokenAddress=" + tokenAddress, tokenTx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var setTokenParameters_Message = "Set Token Contract Parameters";
// -----------------------------------------------------------------------------
console.log("RESULT: " + setTokenParameters_Message);
var setTokenParameters_1Tx = token.setWallet(wallet, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_2Tx = token.setEthMinContribution(web3.toWei(10, "ether"), {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_3Tx = token.setUsdCap(2000000, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_4Tx = token.setUsdPerKEther(730111, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_5Tx = token.setWhitelist(whitelistAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
var setTokenParameters_6Tx = token.setPICOPSCertifier(picopsCertifierAddress, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(setTokenParameters_1Tx, setTokenParameters_Message + " - token.setWallet(wallet)");
failIfTxStatusError(setTokenParameters_2Tx, setTokenParameters_Message + " - token.setEthMinContribution(10 ETH)");
failIfTxStatusError(setTokenParameters_3Tx, setTokenParameters_Message + " - token.setUsdCap(2,200,000)");
failIfTxStatusError(setTokenParameters_4Tx, setTokenParameters_Message + " - token.setUsdPerKEther(444,444)");
failIfTxStatusError(setTokenParameters_5Tx, setTokenParameters_Message + " - token.setWhitelist(whitelistAddress)");
failIfTxStatusError(setTokenParameters_6Tx, setTokenParameters_Message + " - token.setPICOPSCertifier(picopsCertifierAddress)");
printTxData("setTokenParameters_1Tx", setTokenParameters_1Tx);
printTxData("setTokenParameters_2Tx", setTokenParameters_2Tx);
printTxData("setTokenParameters_3Tx", setTokenParameters_3Tx);
printTxData("setTokenParameters_4Tx", setTokenParameters_4Tx);
printTxData("setTokenParameters_5Tx", setTokenParameters_5Tx);
printTxData("setTokenParameters_6Tx", setTokenParameters_6Tx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution0Message = "Send Test Contribution From Owner Account";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution0Message);
var sendContribution0_1Tx = eth.sendTransaction({from: contractOwnerAccount, to: tokenAddress, gas: 400000, value: web3.toWei("0.01", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution0_1Tx, sendContribution0Message + " - ac1 0.01 ETH");
printTxData("sendContribution0_1Tx", sendContribution0_1Tx);
printTokenContractDetails();
console.log("RESULT: ");


waitUntil("START_DATE", token.START_DATE(), 0);

// -----------------------------------------------------------------------------
var sendContribution1Message = "Send Contribution #1";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution1Message);
var sendContribution1_1Tx = eth.sendTransaction({from: account3, to: tokenAddress, gas: 400000, value: web3.toWei("1000", "ether")});
var sendContribution1_2Tx = eth.sendTransaction({from: account6, to: tokenAddress, gas: 400000, value: web3.toWei("800", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution1_1Tx, sendContribution1Message + " - ac3 1,000 ETH");
passIfTxStatusError(sendContribution1_2Tx, sendContribution1Message + " - ac6 800 ETH - Expecting failure as not whitelisted");
printTxData("sendContribution1_1Tx", sendContribution1_1Tx);
printTxData("sendContribution1_2Tx", sendContribution1_2Tx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var increaseCapMessage = "Increase Cap";
// -----------------------------------------------------------------------------
console.log("RESULT: " + increaseCapMessage);
var increaseCapTx = token.setUsdCap(8000000, {from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(increaseCapTx, increaseCapMessage);
printTxData("increaseCapTx", increaseCapTx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var sendContribution2Message = "Send Contribution #2";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution2Message);
var sendContribution2_1Tx = eth.sendTransaction({from: account4, to: tokenAddress, gas: 400000, value: web3.toWei("2000", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution2_1Tx, sendContribution2Message + " - ac4 2,000 ETH");
printTxData("sendContribution2_1Tx", sendContribution2_1Tx);
printTokenContractDetails();
console.log("RESULT: ");


// // -----------------------------------------------------------------------------
// var sendContribution3Message = "Send Contribution #3";
// // -----------------------------------------------------------------------------
// console.log("RESULT: " + sendContribution3Message);
// var sendContribution3_1Tx = eth.sendTransaction({from: account5, to: tokenAddress, gas: 400000, value: web3.toWei("2000", "ether")});
// while (txpool.status.pending > 0) {
// }
// printBalances();
// passIfTxStatusError(sendContribution3_1Tx, sendContribution3Message + " - ac5 2,000 ETH - Expecting failure");
// printTxData("sendContribution3_1Tx", sendContribution3_1Tx);
// printTokenContractDetails();
// console.log("RESULT: ");


// -----------------------------------------------------------------------------
// 4561.764705882353
// 1561.754705882353
var sendContribution4Message = "Send Contribution #4";
// -----------------------------------------------------------------------------
console.log("RESULT: " + sendContribution4Message);
var sendContribution4_1Tx = eth.sendTransaction({from: account5, to: tokenAddress, gas: 400000, value: web3.toWei("1561.754705882353", "ether")});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(sendContribution4_1Tx, sendContribution4Message + " - ac5 1,561.754705882353 ETH");
printTxData("sendContribution4_1Tx", sendContribution4_1Tx);
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var closeMessage = "Close Sale";
// -----------------------------------------------------------------------------
console.log("RESULT: " + closeMessage);
var closeTx = token.closeSale({from: contractOwnerAccount, gas: 100000, gasPrice: defaultGasPrice});
while (txpool.status.pending > 0) {
}
printBalances();
failIfTxStatusError(closeTx, closeMessage);
printTxData("closeTx", closeTx);
printTokenContractDetails();
console.log("RESULT: ");


exit;

// -----------------------------------------------------------------------------
var moveToken1_Message = "Move Tokens After Presale - To Redemption Wallet";
// -----------------------------------------------------------------------------
console.log("RESULT: " + moveToken1_Message);
var moveToken1_1Tx = token.transfer(redemptionWallet, "1000000", {from: account3, gas: 100000});
var moveToken1_2Tx = token.approve(account6,  "30000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var moveToken1_3Tx = token.transferFrom(account4, redemptionWallet, "30000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("moveToken1_1Tx", moveToken1_1Tx);
printTxData("moveToken1_2Tx", moveToken1_2Tx);
printTxData("moveToken1_3Tx", moveToken1_3Tx);
failIfTxStatusError(moveToken1_1Tx, moveToken1_Message + " - transfer 1 token ac3 -> redemptionWallet. CHECK for movement");
failIfTxStatusError(moveToken1_2Tx, moveToken1_Message + " - approve 30 tokens ac4 -> ac6");
failIfTxStatusError(moveToken1_3Tx, moveToken1_Message + " - transferFrom 30 tokens ac4 -> redemptionWallet by ac6. CHECK for movement");
printTokenContractDetails();
console.log("RESULT: ");


// -----------------------------------------------------------------------------
var moveToken2_Message = "Move Tokens After Presale - Not To Redemption Wallet";
// -----------------------------------------------------------------------------
console.log("RESULT: " + moveToken2_Message);
var moveToken2_1Tx = token.transfer(account5, "1000000", {from: account3, gas: 100000});
var moveToken2_2Tx = token.approve(account6,  "30000000", {from: account4, gas: 100000});
while (txpool.status.pending > 0) {
}
var moveToken2_3Tx = token.transferFrom(account4, account7, "30000000", {from: account6, gas: 100000});
while (txpool.status.pending > 0) {
}
printBalances();
printTxData("moveToken2_1Tx", moveToken2_1Tx);
printTxData("moveToken2_2Tx", moveToken2_2Tx);
printTxData("moveToken2_3Tx", moveToken2_3Tx);
passIfTxStatusError(moveToken2_1Tx, moveToken2_Message + " - transfer 1 token ac3 -> ac5. Expecting failure");
failIfTxStatusError(moveToken2_2Tx, moveToken2_Message + " - approve 30 tokens ac4 -> ac6");
passIfTxStatusError(moveToken2_3Tx, moveToken2_Message + " - transferFrom 30 tokens ac4 -> ac7 by ac6. Expecting failure");
printTokenContractDetails();
console.log("RESULT: ");


EOF
grep "DATA: " $TEST1OUTPUT | sed "s/DATA: //" > $PRESALEDEPLOYMENTDATA
cat $PRESALEDEPLOYMENTDATA
grep "RESULT: " $TEST1OUTPUT | sed "s/RESULT: //" > $TEST1RESULTS
cat $TEST1RESULTS
