# DeveryCrowdsale

Source file [../contracts/DeveryCrowdsale.sol](../contracts/DeveryCrowdsale.sol).

<br />

<hr />

```javascript
// BK Ok
pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// 'EVE' 'Devery EVE' crowdsale and token contracts
//
// Symbol      : EVE
// Name        : Devery EVE
// Total supply: Minted
// Decimals    : 18
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd for Devery 2018. The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
// BK Ok
contract ERC20Interface {
    // BK Next 6 Ok
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    // BK Next 2 Ok - Events
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// BokkyPooBah's Token Teleportation Service Interface v1.00
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------
// BK Ok
contract BTTSTokenInterface is ERC20Interface {
    // BK Ok
    uint public constant bttsVersion = 100;

    // BK Next 5 Ok
    bytes public constant signingPrefix = "\x19Ethereum Signed Message:\n32";
    bytes4 public constant signedTransferSig = "\x75\x32\xea\xac";
    bytes4 public constant signedApproveSig = "\xe9\xaf\xa7\xa1";
    bytes4 public constant signedTransferFromSig = "\x34\x4b\xcc\x7d";
    bytes4 public constant signedApproveAndCallSig = "\xf1\x6f\x9b\x53";

    // BK Next 6 Ok - Events
    event OwnershipTransferred(address indexed from, address indexed to);
    event MinterUpdated(address from, address to);
    event Mint(address indexed tokenOwner, uint tokens, bool lockAccount);
    event MintingDisabled();
    event TransfersEnabled();
    event AccountUnlocked(address indexed tokenOwner);

    // BK Ok
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success);

    // ------------------------------------------------------------------------
    // signed{X} functions
    // ------------------------------------------------------------------------
    // BK Next 3 Ok
    function signedTransferHash(address tokenOwner, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferCheck(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedTransfer(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    // BK Next 3 Ok
    function signedApproveHash(address tokenOwner, address spender, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveCheck(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedApprove(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    // BK Next 3 Ok
    function signedTransferFromHash(address spender, address from, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferFromCheck(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedTransferFrom(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    // BK Next 3 Ok
    function signedApproveAndCallHash(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveAndCallCheck(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedApproveAndCall(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    // BK Next 4 Ok
    function mint(address tokenOwner, uint tokens, bool lockAccount) public returns (bool success);
    function unlockAccount(address tokenOwner) public;
    function disableMinting() public;
    function enableTransfers() public;

    // ------------------------------------------------------------------------
    // signed{X}Check return status
    // ------------------------------------------------------------------------
    // BK Next block Ok
    enum CheckResult {
        Success,                           // 0 Success
        NotTransferable,                   // 1 Tokens not transferable yet
        AccountLocked,                     // 2 Account locked
        SignerMismatch,                    // 3 Mismatch in signing account
        AlreadyExecuted,                   // 4 Transfer already executed
        InsufficientApprovedTokens,        // 5 Insufficient approved tokens
        InsufficientApprovedTokensForFees, // 6 Insufficient approved tokens for fees
        InsufficientTokens,                // 7 Insufficient tokens
        InsufficientTokensForFees,         // 8 Insufficient tokens for fees
        OverflowError                      // 9 Overflow error
    }
}


// ----------------------------------------------------------------------------
// Parity PICOPS Whitelist Interface
// ----------------------------------------------------------------------------
// BK Ok - Checked against https://etherscan.io/address/0x1e2F058C43ac8965938F6e9CA286685A3E63F24E#code
contract PICOPSCertifier {
    // BK Ok
    function certified(address) public constant returns (bool);
}


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
// BK Ok
library SafeMath {
    // BK Ok
    function add(uint a, uint b) internal pure returns (uint c) {
        // BK Ok
        c = a + b;
        // BK Ok
        require(c >= a);
    }
    // BK Ok
    function sub(uint a, uint b) internal pure returns (uint c) {
        // BK Ok
        require(b <= a);
        // BK Ok
        c = a - b;
    }
    // BK Ok
    function mul(uint a, uint b) internal pure returns (uint c) {
        // BK Ok
        c = a * b;
        // BK Ok
        require(a == 0 || c / a == b);
    }
    // BK Ok
    function div(uint a, uint b) internal pure returns (uint c) {
        // BK Ok
        require(b > 0);
        // BK Ok
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
// BK Ok
contract Owned {
    // BK Ok
    address public owner;
    // BK Ok
    address public newOwner;

    // BK Ok - Event
    event OwnershipTransferred(address indexed _from, address indexed _to);

    // BK Ok - Modifier
    modifier onlyOwner {
        // BK Ok
        require(msg.sender == owner);
        // BK Ok
        _;
    }

    // BK Ok - Constructor
    function Owned() public {
        // BK Ok
        owner = msg.sender;
    }
    // BK Ok - Only owner can execute
    function transferOwnership(address _newOwner) public onlyOwner {
        // BK Ok
        newOwner = _newOwner;
    }
    // BK Ok - Only new owner can execute
    function acceptOwnership() public {
        // BK Ok
        require(msg.sender == newOwner);
        // BK Ok - Log event
        OwnershipTransferred(owner, newOwner);
        // BK Ok
        owner = newOwner;
        // BK Ok
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// Devery Vesting Contract
// ----------------------------------------------------------------------------
// BK Ok
contract DeveryVesting {
    // BK Ok
    using SafeMath for uint;

    // BK Ok - This contract is deployed by the crowdsale contract 
    DeveryCrowdsale public crowdsale;
    // BK Ok
    uint public totalProportion;
    // BK Ok - Set in `finalise()` that is called by `crowdsale.finalise()`
    uint public totalTokens;
    // BK Ok - Set in `finalise()` that is called by `crowdsale.finalise()`
    uint public startDate;

    // BK Next block Ok
    struct Entry {
        uint proportion;
        uint periods;
        uint periodLength;
        uint withdrawn;
    }
    // BK Ok
    mapping (address => Entry) public entries;

    // BK Next 2 Ok - Events
    event NewEntry(address indexed holder, uint proportion, uint periods, uint periodLength);
    event Withdrawn(address indexed holder, uint withdrawn);

    // BK Ok - Constructor, called by tbe crowdsale constructor
    function DeveryVesting(address _crowdsale) public {
        // BK Ok
        crowdsale = DeveryCrowdsale(_crowdsale);
    }

    // BK Ok - Add vesting entry with the period length of 1 day
    function addEntryInDays(address holder, uint proportion, uint periods) public {
        // BK Ok
        addEntry(holder, proportion, periods, 1 days);
    }
    // BK Ok - Add vesting entry with the period length of 30 days
    function addEntryInMonths(address holder, uint proportion, uint periods) public {
        // BK Ok
        addEntry(holder, proportion, periods, 30 days);
    }
    // BK Ok - Add vesting entry with the period length of 365 days
    function addEntryInYears(address holder, uint proportion, uint periods) public {
        // BK Ok
        addEntry(holder, proportion, periods, 365 days);
    }

    // BK NOTE - Internal function; the function calling this function can only be called by the owner of the crowdsale contract
    // BK Ok
    function addEntry(address holder, uint proportion, uint periods, uint periodLength) internal {
        // BK Ok - Only crowdsale contract owner can execute this function
        require(msg.sender == crowdsale.owner());
        // BK Ok - Holder cannot be null
        require(holder != address(0));
        // BK Ok - Proportion must be non-zero
        require(proportion > 0);
        // BK Ok - Periods must be non-zero
        require(periods > 0);
        // BK Ok - Enter cannot already have been created
        require(entries[holder].proportion == 0);
        // BK Next block Ok - Create new entry
        entries[holder] = Entry({
            proportion: proportion,
            periods: periods,
            periodLength: periodLength,
            withdrawn: 0
        });
        // BK Ok - Calculation total proportions
        totalProportion = totalProportion.add(proportion);
        // BK Ok - Log event
        NewEntry(holder, proportion, periods, periodLength);
    }

    // BK Ok - Constant function
    function tokenShare(address holder) public constant returns (uint) {
        // BK Ok
        uint result = 0;
        // BK Ok
        Entry memory entry = entries[holder];
        // BK Ok
        if (entry.proportion > 0 && totalProportion > 0) {
            // BK Ok
            result = totalTokens.mul(entry.proportion).div(totalProportion);
        }
        // BK Ok
        return result;
    }
    // BK Ok - Constant function
    function vested(address holder, uint time) public constant returns (uint) {
        // BK Ok
        uint result = 0;
        // BK Ok - Crowdsale finalised and time after finalised date
        if (startDate > 0 && time > startDate) {
            // BK Ok
            Entry memory entry = entries[holder];
            // BK Ok - Holder account as and entry
            if (entry.proportion > 0 && totalProportion > 0) {
                // BK Ok
                uint _tokenShare = totalTokens.mul(entry.proportion).div(totalProportion);
                // BK Ok - Past the vesting periods
                if (time >= startDate.add(entry.periods.mul(entry.periodLength))) {
                    // BK Ok
                    result = _tokenShare;
                // BK Ok - Within the vesting periods
                } else {
                    // BK Ok
                    uint periods = time.sub(startDate).div(entry.periodLength);
                    // BK Ok
                    result = _tokenShare.mul(periods).div(entry.periods);
                }
            }
        }
        // BK Ok
        return result;
    }
    // BK Ok - Constant function
    function withdrawable(address holder) public constant returns (uint) {
        // BK Ok
        uint result = 0;
        // BK Ok
        Entry memory entry = entries[holder];
        // BK Ok
        if (entry.proportion > 0 && totalProportion > 0) {
            // BK Ok
            uint _vested = vested(holder, now);
            // BK Ok
            result = _vested.sub(entry.withdrawn);
        }
        // BK Ok
        return result;
    }
    // BK Ok
    function withdraw() public {
        // BK Ok
        Entry storage entry = entries[msg.sender];
        // BK Ok
        require(entry.proportion > 0 && totalProportion > 0);
        // BK Ok
        uint _vested = vested(msg.sender, now);
        // BK Ok
        uint _withdrawn = entry.withdrawn;
        require(_vested > _withdrawn);
        uint _withdrawable = _vested.sub(_withdrawn);
        entry.withdrawn = _vested;
        require(crowdsale.bttsToken().transfer(msg.sender, _withdrawable));
        Withdrawn(msg.sender, _withdrawable);
    }
    function withdrawn(address holder) public constant returns (uint) {
        Entry memory entry = entries[holder];
        return entry.withdrawn;
    }

    function finalise() public {
        require(msg.sender == address(crowdsale));
        totalTokens = crowdsale.bttsToken().balanceOf(address(this));
        startDate = now;
    }

}


// ----------------------------------------------------------------------------
// Devery Crowdsale Contract
// ----------------------------------------------------------------------------
contract DeveryCrowdsale is Owned {
    using SafeMath for uint;

    BTTSTokenInterface public bttsToken;
    uint8 public constant TOKEN_DECIMALS = 18;

    ERC20Interface public presaleToken = ERC20Interface(0x8ca1d9C33c338520604044977be69a9AC19d6E54);
    uint public presaleEthAmountsProcessed;
    bool public presaleProcessed;
    uint public constant PRESALE_BONUS_PERCENT = 5;

    uint public constant PER_ACCOUNT_ADDITIONAL_TOKENS = 150 * 10**uint(TOKEN_DECIMALS);
    mapping(address => bool) bonusTokensAllocate;

    PICOPSCertifier public picopsCertifier = PICOPSCertifier(0x1e2F058C43ac8965938F6e9CA286685A3E63F24E);

    address public wallet = 0xC14d7150543Cc2C9220D2aaB6c2Fe14C90A4d409;
    address public reserveWallet = 0xC14d7150543Cc2C9220D2aaB6c2Fe14C90A4d409;
    DeveryVesting public vestingTeamWallet;
    uint public constant TEAM_PERCENT_EVE = 15;
    uint public constant RESERVE_PERCENT_EVE = 25;
    uint public constant TARGET_EVE = 100000000 * 10**uint(TOKEN_DECIMALS);
    uint public constant PRESALEPLUSCROWDSALE_EVE = TARGET_EVE * (100 - TEAM_PERCENT_EVE - RESERVE_PERCENT_EVE) / 100;

    // Start 18 Jan 2018 16:00 UTC => "Fri, 19 Jan 2018 03:00:00 AEDT"
    // new Date(1516291200 * 1000).toUTCString() => "Thu, 18 Jan 2018 16:00:00 UTC"
    uint public startDate = 1516291200;
    uint public firstPeriodEndDate = startDate + 12 hours;
    uint public endDate = startDate + 14 days;

    // ETH/USD 7 day average from CMC - 1180
    uint public usdPerKEther = 1180000;
    uint public constant CAP_USD = 10000000;
    uint public constant MIN_CONTRIBUTION_ETH = 0.01 ether;
    uint public firstPeriodCap = 20 ether;

    uint public contributedEth;
    uint public contributedUsd;
    uint public generatedEve;

    mapping(address => uint) public accountEthAmount;

    bool public finalised;

    event BTTSTokenUpdated(address indexed oldBTTSToken, address indexed newBTTSToken);
    event PICOPSCertifierUpdated(address indexed oldPICOPSCertifier, address indexed newPICOPSCertifier);
    event WalletUpdated(address indexed oldWallet, address indexed newWallet);
    event ReserveWalletUpdated(address indexed oldReserveWallet, address indexed newReserveWallet);
    event StartDateUpdated(uint oldStartDate, uint newStartDate);
    event FirstPeriodEndDateUpdated(uint oldFirstPeriodEndDate, uint newFirstPeriodEndDate);
    event EndDateUpdated(uint oldEndDate, uint newEndDate);
    event UsdPerKEtherUpdated(uint oldUsdPerKEther, uint newUsdPerKEther);
    event FirstPeriodCapUpdated(uint oldFirstPeriodCap, uint newFirstPeriodCap);
    event Contributed(address indexed addr, uint ethAmount, uint ethRefund, uint accountEthAmount, uint usdAmount, uint bonusPercent, uint eveAmount, uint contributedEth, uint contributedUsd, uint generatedEve);

    function DeveryCrowdsale() public {
        vestingTeamWallet = new DeveryVesting(this);
    }

    function setBTTSToken(address _bttsToken) public onlyOwner {
        require(now <= startDate);
        BTTSTokenUpdated(address(bttsToken), _bttsToken);
        bttsToken = BTTSTokenInterface(_bttsToken);
    }
    function setPICOPSCertifier(address _picopsCertifier) public onlyOwner {
        require(now <= startDate);
        PICOPSCertifierUpdated(address(picopsCertifier), _picopsCertifier);
        picopsCertifier = PICOPSCertifier(_picopsCertifier);
    }
    function setWallet(address _wallet) public onlyOwner {
        WalletUpdated(wallet, _wallet);
        wallet = _wallet;
    }
    function setReserveWallet(address _reserveWallet) public onlyOwner {
        ReserveWalletUpdated(reserveWallet, _reserveWallet);
        reserveWallet = _reserveWallet;
    }
    function setStartDate(uint _startDate) public onlyOwner {
        require(_startDate >= now);
        StartDateUpdated(startDate, _startDate);
        startDate = _startDate;
    }
    function setFirstPeriodEndDate(uint _firstPeriodEndDate) public onlyOwner {
        require(_firstPeriodEndDate >= now);
        require(_firstPeriodEndDate >= startDate);
        FirstPeriodEndDateUpdated(firstPeriodEndDate, _firstPeriodEndDate);
        firstPeriodEndDate = _firstPeriodEndDate;
    }
    function setEndDate(uint _endDate) public onlyOwner {
        require(_endDate >= now);
        require(_endDate >= firstPeriodEndDate);
        EndDateUpdated(endDate, _endDate);
        endDate = _endDate;
    }
    function setUsdPerKEther(uint _usdPerKEther) public onlyOwner {
        require(now <= startDate);
        UsdPerKEtherUpdated(usdPerKEther, _usdPerKEther);
        usdPerKEther = _usdPerKEther;
    }
    function setFirstPeriodCap(uint _firstPeriodCap) public onlyOwner {
        require(_firstPeriodCap >= MIN_CONTRIBUTION_ETH);
        FirstPeriodCapUpdated(firstPeriodCap, _firstPeriodCap);
        firstPeriodCap = _firstPeriodCap;
    }

    // capEth       = USD 10,000,000 / 1,180 = 8474.576271186440677966
    // presaleEth   = 4561.764705882353
    // crowdsaleEth = capEth - presaleEth
    //              = 3912.811565304087678
    // totalEve     = 100,000,000
    // presalePlusCrowdsaleEve = 60% x totalEve = 60,000,000
    // evePerEth x presaleEth x 1.05 + evePerEth x crowdsaleEth = presalePlusCrowdsaleEve
    // evePerEth x (presaleEth x 1.05 + crowdsaleEth) = presalePlusCrowdsaleEve
    // evePerEth = presalePlusCrowdsaleEve / (presaleEth x 1.05 + crowdsaleEth)
    //           = 60000000/(4561.764705882353*1.05 + 3912.811565304087678)
    //           = 6894.440198

    function capEth() public view returns (uint) {
        return CAP_USD * 10**uint(3 + 18) / usdPerKEther;
    }
    function presaleEth() public view returns (uint) {
        return presaleToken.totalSupply();
    }
    function crowdsaleEth() public view returns (uint) {
        return capEth().sub(presaleEth());
    }
    function eveFromEth(uint ethAmount, uint bonusPercent) public view returns (uint) {
        uint adjustedEth = presaleEth().mul(100 + PRESALE_BONUS_PERCENT).add(crowdsaleEth().mul(100)).div(100);
        return ethAmount.mul(100 + bonusPercent).mul(PRESALEPLUSCROWDSALE_EVE).div(adjustedEth).div(100);
    }
    function evePerEth() public view returns (uint) {
        return eveFromEth(10**18, 0);
    }
    function usdPerEve() public view returns (uint) {
        uint evePerKEth = eveFromEth(10**(18 + 3), 0);
        return usdPerKEther.mul(10**(18 + 18)).div(evePerKEth);
    }

    function generateTokensForPresaleAccounts(address[] accounts) public onlyOwner {
        require(bttsToken != address(0));
        require(!presaleProcessed);
        for (uint i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            uint ethAmount = presaleToken.balanceOf(account);
            uint eveAmount = bttsToken.balanceOf(account);
            if (eveAmount == 0) {
                presaleEthAmountsProcessed = presaleEthAmountsProcessed.add(ethAmount);
                accountEthAmount[account] = accountEthAmount[account].add(ethAmount);
                eveAmount = eveFromEth(ethAmount, PRESALE_BONUS_PERCENT);
                eveAmount = eveAmount.add(PER_ACCOUNT_ADDITIONAL_TOKENS);
                bonusTokensAllocate[account] = true;
                uint usdAmount = ethAmount.mul(usdPerKEther).div(10**uint(3 + 18));
                contributedEth = contributedEth.add(ethAmount);
                contributedUsd = contributedUsd.add(usdAmount);
                generatedEve = generatedEve.add(eveAmount);
                Contributed(account, ethAmount, 0, ethAmount, usdAmount, PRESALE_BONUS_PERCENT, eveAmount,
                    contributedEth, contributedUsd, generatedEve);
                bttsToken.mint(account, eveAmount, false);
            }
        }
        if (presaleEthAmountsProcessed == presaleToken.totalSupply()) {
            presaleProcessed = true;
        }
    }

    function () public payable {
        require(!finalised);
        uint ethAmount = msg.value;
        if (msg.sender == owner) {
            require(msg.value == MIN_CONTRIBUTION_ETH);
        } else {
            require(now >= startDate && now <= endDate);
            if (now <= firstPeriodEndDate) {
                require(accountEthAmount[msg.sender].add(ethAmount) <= firstPeriodCap);
                require(picopsCertifier.certified(msg.sender));
            }
        }
        require(contributedEth < capEth());
        require(msg.value >= MIN_CONTRIBUTION_ETH);
        uint ethRefund = 0;
        if (contributedEth.add(ethAmount) > capEth()) {
            ethAmount = capEth().sub(contributedEth);
            ethRefund = msg.value.sub(ethAmount);
        }
        uint usdAmount = ethAmount.mul(usdPerKEther).div(10**uint(3 + 18));
        uint eveAmount = eveFromEth(ethAmount, 0);
        if (picopsCertifier.certified(msg.sender) && !bonusTokensAllocate[msg.sender]) {
            eveAmount = eveAmount.add(PER_ACCOUNT_ADDITIONAL_TOKENS);
            bonusTokensAllocate[msg.sender] = true;
        }
        generatedEve = generatedEve.add(eveAmount);
        contributedEth = contributedEth.add(ethAmount);
        contributedUsd = contributedUsd.add(usdAmount);
        accountEthAmount[msg.sender] = accountEthAmount[msg.sender].add(ethAmount);
        bttsToken.mint(msg.sender, eveAmount, false);
        if (ethAmount > 0) {
            wallet.transfer(ethAmount);
        }
        Contributed(msg.sender, ethAmount, ethRefund, accountEthAmount[msg.sender], usdAmount, 0, eveAmount,
            contributedEth, contributedUsd, generatedEve);
        if (ethRefund > 0) {
            msg.sender.transfer(ethRefund);
        }
    }

    function roundUp(uint a) internal pure returns (uint) {
        uint multiple = 10**uint(TOKEN_DECIMALS);
        uint remainder = a % multiple;
        if (remainder > 0) {
            return a.add(multiple).sub(remainder);
        }
    }
    function finalise() public onlyOwner {
        require(!finalised);
        require(now > endDate || contributedEth >= capEth());
        uint total = generatedEve.mul(100).div(uint(100).sub(TEAM_PERCENT_EVE).sub(RESERVE_PERCENT_EVE));
        uint amountTeam = total.mul(TEAM_PERCENT_EVE).div(100);
        uint amountReserve = total.mul(RESERVE_PERCENT_EVE).div(100);
        generatedEve = generatedEve.add(amountTeam).add(amountReserve);
        uint rounded = roundUp(generatedEve);
        if (rounded > generatedEve) {
            uint dust = rounded.sub(generatedEve);
            generatedEve = generatedEve.add(dust);
            amountReserve = amountReserve.add(dust);
        }
        if (generatedEve > TARGET_EVE) {
            uint diff = generatedEve.sub(TARGET_EVE);
            generatedEve = TARGET_EVE;
            amountReserve = amountReserve.sub(diff);
        }
        bttsToken.mint(address(vestingTeamWallet), amountTeam, false);
        bttsToken.mint(reserveWallet, amountReserve, false);
        bttsToken.disableMinting();
        vestingTeamWallet.finalise();
        finalised = true;
    }
}
```
