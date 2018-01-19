#!/bin/sh

# geth attach << EOF
geth attach << EOF | grep "JSONSUMMARY:" | sed "s/JSONSUMMARY: //" > tmp.json
loadScript("deveryCrowdsale.js");
// loadScript("whiteList.js");

function generateSummaryJSON() {
  console.log("JSONSUMMARY: {");
  var whiteList = null
  // if (whiteListAddress != null && whiteListAbi != null) {
  //   whiteList = eth.contract(whiteListAbi).at(whiteListAddress);
  // }
  if (crowdsaleContractAddress != null && crowdsaleContractAbi != null) {
    var crowdsale = eth.contract(crowdsaleContractAbi).at(crowdsaleContractAddress);
    var token = eth.contract(tokenContractAbi).at(tokenContractAddress);
    var blockNumber = eth.blockNumber;
    var timestamp = eth.getBlock(blockNumber).timestamp;
    console.log("JSONSUMMARY:   \"blockNumber\": " + blockNumber + ",");
    console.log("JSONSUMMARY:   \"blockTimestamp\": " + timestamp + ",");
    console.log("JSONSUMMARY:   \"blockTimestampString\": \"" + new Date(timestamp * 1000).toString() + "\",");
    console.log("JSONSUMMARY:   \"blockTimestampUTCString\": \"" + new Date(timestamp * 1000).toUTCString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleContractAddress\": \"" + crowdsaleContractAddress + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleContractOwnerAddress\": \"" + crowdsale.owner() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleContractNewOwnerAddress\": \"" + crowdsale.newOwner() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleBTTSToken\": \"" + crowdsale.bttsToken() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleTokenDecimals\": \"" + crowdsale.TOKEN_DECIMALS() + "\",");
    console.log("JSONSUMMARY:   \"crowdsalePresaleToken\": \"" + crowdsale.presaleToken() + "\",");
    console.log("JSONSUMMARY:   \"crowdsalePresaleEthAmountsProcessed\": \"" + crowdsale.presaleEthAmountsProcessed().shift(-18) + "\",");
    console.log("JSONSUMMARY:   \"crowdsalePresaleProcessed\": \"" + crowdsale.presaleProcessed() + "\",");
    console.log("JSONSUMMARY:   \"crowdsalePresaleBonusPercent\": \"" + crowdsale.PRESALE_BONUS_PERCENT() + "\",");
    console.log("JSONSUMMARY:   \"crowdsalePerAccountAdditionalTokens\": \"" + crowdsale.PER_ACCOUNT_ADDITIONAL_TOKENS().shift(-18) + "\",");
    console.log("JSONSUMMARY:   \"crowdsalePicopsCertifier\": \"" + crowdsale.picopsCertifier() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleWalletAddress\": \"" + crowdsale.wallet() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleReserveWalletAddress\": \"" + crowdsale.reserveWallet() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleVestingTeamWalletAddress\": \"" + crowdsale.vestingTeamWallet() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleVestingTeamPercentEve\": \"" + crowdsale.TEAM_PERCENT_EVE() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleVestingReservePercentEve\": \"" + crowdsale.RESERVE_PERCENT_EVE() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleVestingTargetEve\": \"" + crowdsale.TARGET_EVE().shift(-18) + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleVestingPresalePlusCrowdsaleEve\": \"" + crowdsale.PRESALEPLUSCROWDSALE_EVE().shift(-18) + "\",");
    var startDate = crowdsale.startDate();
    console.log("JSONSUMMARY:   \"crowdsaleStartDate\": " + startDate + ",");
    console.log("JSONSUMMARY:   \"crowdsaleStartDateString\": \"" + new Date(startDate * 1000).toString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleStartDateUTCString\": \"" + new Date(startDate * 1000).toUTCString() + "\",");
    var firstPeriodEndDate = crowdsale.firstPeriodEndDate();
    console.log("JSONSUMMARY:   \"crowdsaleFirstPeriodEndDate\": " + firstPeriodEndDate + ",");
    console.log("JSONSUMMARY:   \"crowdsaleFirstPeriodEndDateString\": \"" + new Date(firstPeriodEndDate * 1000).toString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleFirstPeriodEndDateUTCString\": \"" + new Date(firstPeriodEndDate * 1000).toUTCString() + "\",");
    var endDate = crowdsale.endDate();
    console.log("JSONSUMMARY:   \"crowdsaleEndDate\": " + endDate + ",");
    console.log("JSONSUMMARY:   \"crowdsaleEndDateString\": \"" + new Date(endDate * 1000).toString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleEndDateUTCString\": \"" + new Date(endDate * 1000).toUTCString() + "\",");
    console.log("JSONSUMMARY:   \"crowdsaleUsdPerEther\": " + crowdsale.usdPerKEther().shift(-3) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleCapUsd\": " + crowdsale.CAP_USD() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleCapEth\": " + crowdsale.capEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsalePresaleEth\": " + crowdsale.presaleEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleCrowdsaleEth\": " + crowdsale.crowdsaleEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleMinContributionEth\": " + crowdsale.MIN_CONTRIBUTION_ETH().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleContributedEth\": " + crowdsale.contributedEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleContributionUsd\": " + crowdsale.contributedUsd() + ",");
    console.log("JSONSUMMARY:   \"crowdsaleGeneratedEve\": " + crowdsale.generatedEve().shift(-18) + ",");
    var oneEther = web3.toWei(1, "ether");
    console.log("JSONSUMMARY:   \"crowdsaleEvePerEth\": " + crowdsale.evePerEth().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleEvePerEthWithFivePercentBonus\": " + crowdsale.eveFromEth(oneEther, 5).shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleUsdPerEve\": " + crowdsale.usdPerEve().shift(-18) + ",");
    console.log("JSONSUMMARY:   \"crowdsaleFinalised\": " + crowdsale.finalised() + ",");
    
    console.log("JSONSUMMARY:   \"tokenContractAddress\": \"" + tokenContractAddress + "\",");
    console.log("JSONSUMMARY:   \"tokenContractOwnerAddress\": \"" + token.owner() + "\",");
    console.log("JSONSUMMARY:   \"tokenContractNewOwnerAddress\": \"" + token.newOwner() + "\",");
    console.log("JSONSUMMARY:   \"tokenSymbol\": \"" + token.symbol() + "\",");
    console.log("JSONSUMMARY:   \"tokenName\": \"" + token.name() + "\",");
    console.log("JSONSUMMARY:   \"tokenDecimals\": \"" + token.decimals() + "\",");
    console.log("JSONSUMMARY:   \"tokenTotalSupply\": \"" + token.totalSupply().shift(-18) + "\",");
    console.log("JSONSUMMARY:   \"tokenTransferable\": \"" + token.transferable() + "\",");
    console.log("JSONSUMMARY:   \"tokenMintable\": \"" + token.mintable() + "\",");

    var separator = "";
    // var toBlock = parseInt(fromBlock) + 1000;
    var contributedEvents = crowdsale.Contributed({}, { fromBlock: fromBlock, toBlock: toBlock }).get();
    console.log("JSONSUMMARY:   \"numberOfContributions\": " + contributedEvents.length + ",");
    console.log("JSONSUMMARY:   \"contributions\": [");
    var accounts = {};
    for (var i = 0; i < contributedEvents.length; i++) {
      // var e = contributedEvents[contributedEvents.length - 1 - i];
      var e = contributedEvents[i];
      var separator;
      if (i == contributedEvents.length - 1) {
        separator = "";
      } else {
        separator = ",";
      }
      accounts[e.args.addr] = accounts[e.args.addr] + 1;
      var ts = eth.getBlock(e.blockNumber).timestamp;
      console.log("JSONSUMMARY:     {");
      console.log("JSONSUMMARY:       \"address\": \"" + e.args.addr + "\",");
      console.log("JSONSUMMARY:       \"transactionHash\": \"" + e.transactionHash + "\",");
      console.log("JSONSUMMARY:       \"href\": \"https://etherscan.io/tx/" + e.transactionHash + "\",");
      console.log("JSONSUMMARY:       \"blockNumber\": " + e.blockNumber + ",");
      console.log("JSONSUMMARY:       \"transactionIndex\": " + e.transactionIndex + ",");
      console.log("JSONSUMMARY:       \"timestamp\": " + ts + ",");
      console.log("JSONSUMMARY:       \"timestampString\": \"" + new Date(ts * 1000).toString() + "\",");
      console.log("JSONSUMMARY:       \"timestampUTCString\": \"" + new Date(ts * 1000).toUTCString() + "\",");
      console.log("JSONSUMMARY:       \"ethAmount\": " + e.args.ethAmount.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"ethRefund\": " + e.args.ethRefund.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"accountEthAmount\": " + e.args.accountEthAmount.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"usdAmount\": " + e.args.usdAmount + ",");
      console.log("JSONSUMMARY:       \"bonusPercent\": " + e.args.bonusPercent + ",");
      console.log("JSONSUMMARY:       \"eveAmount\": " + e.args.eveAmount.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"contributedEth\": " + e.args.contributedEth.shift(-18) + ",");
      console.log("JSONSUMMARY:       \"contributedUsd\": " + e.args.contributedUsd + ",");
      console.log("JSONSUMMARY:       \"generatedEve\": " + e.args.generatedEve.shift(-18));
      console.log("JSONSUMMARY:     }" + separator);
    }
    console.log("JSONSUMMARY:   ],");
    var accountKeys = Object.keys(accounts);
    accountKeys.sort();
    console.log("JSONSUMMARY:   \"numberOfAccounts\": " + accountKeys.length + ",");
    console.log("JSONSUMMARY:   \"balances\": [");
    for (var i = 0; i < accountKeys.length; i++) {
      var separator;
      if (i == accountKeys.length - 1) {
        separator = "";
      } else {
        separator = ",";
      }
      console.log("JSONSUMMARY:       {");
      console.log("JSONSUMMARY:         \"account\": \"" + accountKeys[i] + "\",");
      console.log("JSONSUMMARY:         \"balance\": " + token.balanceOf(accountKeys[i]).shift(-18) + "");
      console.log("JSONSUMMARY:       }" + separator);
    }
    console.log("JSONSUMMARY:   ]");
  }
  console.log("JSONSUMMARY: }");
}

generateSummaryJSON();
EOF

mv tmp.json DeveryCrowdsaleSummary.json
