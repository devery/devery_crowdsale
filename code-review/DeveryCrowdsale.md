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

    // BK Ok - View function
    function tokenShare(address holder) public view returns (uint) {
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
    // BK Ok - View function
    function vested(address holder, uint time) public view returns (uint) {
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
    // BK Ok - View function
    function withdrawable(address holder) public view returns (uint) {
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
        // BK Ok
        require(_vested > _withdrawn);
        // BK Ok
        uint _withdrawable = _vested.sub(_withdrawn);
        // BK Ok
        entry.withdrawn = _vested;
        // BK Ok
        require(crowdsale.bttsToken().transfer(msg.sender, _withdrawable));
        // BK Ok
        Withdrawn(msg.sender, _withdrawable);
    }
    // BK Ok - View function
    function withdrawn(address holder) public view returns (uint) {
        // BK Ok
        Entry memory entry = entries[holder];
        // BK Ok
        return entry.withdrawn;
    }

    // BK Ok
    function finalise() public {
        // BK Ok - Only crowdsale contract can finalise
        require(msg.sender == address(crowdsale));
        // BK Ok - Store original number of tokens allocated in total
        totalTokens = crowdsale.bttsToken().balanceOf(address(this));
        // BK Ok - Vesting starts now
        startDate = now;
    }

}


// ----------------------------------------------------------------------------
// Devery Crowdsale Contract
// ----------------------------------------------------------------------------
// BK Ok
contract DeveryCrowdsale is Owned {
    // BK Ok
    using SafeMath for uint;

    // BK Ok
    BTTSTokenInterface public bttsToken;
    // BK Ok
    uint8 public constant TOKEN_DECIMALS = 18;

    // BK Ok - Confirmed to https://etherscan.io/address/0x8ca1d9C33c338520604044977be69a9AC19d6E54#code
    ERC20Interface public presaleToken = ERC20Interface(0x8ca1d9C33c338520604044977be69a9AC19d6E54);
    // BK Ok
    uint public presaleEthAmountsProcessed;
    // BK Ok
    bool public presaleProcessed;
    // BK Ok
    uint public constant PRESALE_BONUS_PERCENT = 5;

    // BK Ok
    uint public constant PER_ACCOUNT_ADDITIONAL_TOKENS = 150 * 10**uint(TOKEN_DECIMALS);
    // BK Ok
    mapping(address => bool) bonusTokensAllocate;

    // BK Ok - Confirmed to https://etherscan.io/address/0x1e2F058C43ac8965938F6e9CA286685A3E63F24E#code
    PICOPSCertifier public picopsCertifier = PICOPSCertifier(0x1e2F058C43ac8965938F6e9CA286685A3E63F24E);

    // BK Ok - Confirmed to https://etherscan.io/address/0x87410eE93BDa2445339c9372b20BF25e138F858C#code
    address public wallet = 0x87410eE93BDa2445339c9372b20BF25e138F858C;
    // BK Ok - Confirmed to https://etherscan.io/address/0x87410eE93BDa2445339c9372b20BF25e138F858C#code
    address public reserveWallet = 0x87410eE93BDa2445339c9372b20BF25e138F858C;
    // BK Ok
    DeveryVesting public vestingTeamWallet;
    // BK Ok
    uint public constant TEAM_PERCENT_EVE = 15;
    // BK Ok
    uint public constant RESERVE_PERCENT_EVE = 25;
    // BK Ok
    uint public constant TARGET_EVE = 100000000 * 10**uint(TOKEN_DECIMALS);
    // BK Ok
    uint public constant PRESALEPLUSCROWDSALE_EVE = TARGET_EVE * (100 - TEAM_PERCENT_EVE - RESERVE_PERCENT_EVE) / 100;

    // Start 18 Jan 2018 16:00 UTC => "Fri, 19 Jan 2018 03:00:00 AEDT"
    // new Date(1516291200 * 1000).toUTCString() => "Thu, 18 Jan 2018 16:00:00 UTC"
    // BK Ok
    uint public startDate = 1516291200;
    // BK Ok
    uint public firstPeriodEndDate = startDate + 12 hours;
    // BK Ok
    uint public endDate = startDate + 14 days;

    // ETH/USD rate used 1,000
    // BK Ok
    uint public usdPerKEther = 1000000;
    // BK Ok
    uint public constant CAP_USD = 10000000;
    // BK Ok
    uint public constant MIN_CONTRIBUTION_ETH = 0.01 ether;
    // BK Ok
    uint public firstPeriodCap = 20 ether;

    // BK Ok
    uint public contributedEth;
    // BK Ok
    uint public contributedUsd;
    // BK Ok
    uint public generatedEve;

    // BK Ok
    mapping(address => uint) public accountEthAmount;

    // BK Ok
    bool public finalised;

    // BK Next 10 Ok - Events
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

    // BK Ok - Constructor
    function DeveryCrowdsale() public {
        // BK Ok
        vestingTeamWallet = new DeveryVesting(this);
    }

    // BK Ok - Only owner can execute, before start
    function setBTTSToken(address _bttsToken) public onlyOwner {
        // BK Ok
        require(now <= startDate);
        // BK Ok - Log event
        BTTSTokenUpdated(address(bttsToken), _bttsToken);
        // BK Ok
        bttsToken = BTTSTokenInterface(_bttsToken);
    }
    // BK Ok - Only owner can execute, before start
    function setPICOPSCertifier(address _picopsCertifier) public onlyOwner {
        // BK Ok
        require(now <= startDate);
        // BK Ok - Log event
        PICOPSCertifierUpdated(address(picopsCertifier), _picopsCertifier);
        // BK Ok
        picopsCertifier = PICOPSCertifier(_picopsCertifier);
    }
    // BK Ok - Only owner can execute
    function setWallet(address _wallet) public onlyOwner {
        // BK Ok - Log event
        WalletUpdated(wallet, _wallet);
        // BK Ok
        wallet = _wallet;
    }
    // BK Ok - Only owner can execute
    function setReserveWallet(address _reserveWallet) public onlyOwner {
        // BK Ok - Log event
        ReserveWalletUpdated(reserveWallet, _reserveWallet);
        // BK Ok
        reserveWallet = _reserveWallet;
    }
    // BK Ok - Only owner can execute
    function setStartDate(uint _startDate) public onlyOwner {
        // BK Ok
        require(_startDate >= now);
        // BK Ok - Log event
        StartDateUpdated(startDate, _startDate);
        // BK Ok
        startDate = _startDate;
    }
    // BK Ok - Only owner can execute
    function setFirstPeriodEndDate(uint _firstPeriodEndDate) public onlyOwner {
        // BK Ok
        require(_firstPeriodEndDate >= now);
        // BK Ok
        require(_firstPeriodEndDate >= startDate);
        // BK Ok - Log event
        FirstPeriodEndDateUpdated(firstPeriodEndDate, _firstPeriodEndDate);
        // BK Ok
        firstPeriodEndDate = _firstPeriodEndDate;
    }
    // BK Ok - Only owner can execute
    function setEndDate(uint _endDate) public onlyOwner {
        // BK Ok
        require(_endDate >= now);
        // BK Ok
        require(_endDate >= firstPeriodEndDate);
        // BK Ok - Log event
        EndDateUpdated(endDate, _endDate);
        // BK Ok
        endDate = _endDate;
    }
    // BK Ok - Only owner can execute, before start
    function setUsdPerKEther(uint _usdPerKEther) public onlyOwner {
        // BK Ok
        require(now <= startDate);
        // BK Ok - Log event
        UsdPerKEtherUpdated(usdPerKEther, _usdPerKEther);
        // BK Ok
        usdPerKEther = _usdPerKEther;
    }
    // BK Ok - Only owner can execute
    function setFirstPeriodCap(uint _firstPeriodCap) public onlyOwner {
        // BK Ok
        require(_firstPeriodCap >= MIN_CONTRIBUTION_ETH);
        // BK Ok - Log event
        FirstPeriodCapUpdated(firstPeriodCap, _firstPeriodCap);
        // BK Ok
        firstPeriodCap = _firstPeriodCap;
    }

    // usdPerKEther = 1,000,000
    // capEth       = USD 10,000,000 / 1,000 = 10,000
    // presaleEth   = 4,561.764705882353
    // crowdsaleEth = capEth - presaleEth
    //              = 5,438.235294117647
    // totalEve     = 100,000,000
    // presalePlusCrowdsaleEve = 60% x totalEve = 60,000,000
    // evePerEth x presaleEth x 1.05 + evePerEth x crowdsaleEth = presalePlusCrowdsaleEve
    // evePerEth x (presaleEth x 1.05 + crowdsaleEth) = presalePlusCrowdsaleEve
    // evePerEth = presalePlusCrowdsaleEve / (presaleEth x 1.05 + crowdsaleEth)
    //           = 60,000,000/(4,561.764705882353*1.05 + 5,438.235294117647)
    //           = 5,866.19890440108697
    // usdPerEve = 1,000 / 5,866.19890440108697 = 0.170468137254902 

    // BK Ok - View function
    function capEth() public view returns (uint) {
        // BK Ok
        return CAP_USD * 10**uint(3 + 18) / usdPerKEther;
    }
    // BK Ok - View function
    function presaleEth() public view returns (uint) {
        // BK Ok
        return presaleToken.totalSupply();
    }
    // BK Ok - View function
    function crowdsaleEth() public view returns (uint) {
        // BK Ok
        return capEth().sub(presaleEth());
    }
    // BK Ok - View function
    function eveFromEth(uint ethAmount, uint bonusPercent) public view returns (uint) {
        // BK Ok
        uint adjustedEth = presaleEth().mul(100 + PRESALE_BONUS_PERCENT).add(crowdsaleEth().mul(100)).div(100);
        // BK Ok
        return ethAmount.mul(100 + bonusPercent).mul(PRESALEPLUSCROWDSALE_EVE).div(adjustedEth).div(100);
    }
    // BK Ok - View function
    function evePerEth() public view returns (uint) {
        // BK Ok
        return eveFromEth(10**18, 0);
    }
    // BK Ok - View function
    function usdPerEve() public view returns (uint) {
        // BK Ok
        uint evePerKEth = eveFromEth(10**(18 + 3), 0);
        // BK Ok
        return usdPerKEther.mul(10**(18 + 18)).div(evePerKEth);
    }

    // BK Ok - Only owner can execute
    function generateTokensForPresaleAccounts(address[] accounts) public onlyOwner {
        // BK Ok
        require(bttsToken != address(0));
        // BK Ok
        require(!presaleProcessed);
        // BK Ok
        for (uint i = 0; i < accounts.length; i++) {
            // BK Ok
            address account = accounts[i];
            // BK Ok
            uint ethAmount = presaleToken.balanceOf(account);
            // BK Ok
            uint eveAmount = bttsToken.balanceOf(account);
            // BK Ok
            if (eveAmount == 0 && ethAmount != 0) {
                // BK Ok
                presaleEthAmountsProcessed = presaleEthAmountsProcessed.add(ethAmount);
                // BK Ok
                accountEthAmount[account] = accountEthAmount[account].add(ethAmount);
                // BK Ok
                eveAmount = eveFromEth(ethAmount, PRESALE_BONUS_PERCENT);
                // BK Ok
                eveAmount = eveAmount.add(PER_ACCOUNT_ADDITIONAL_TOKENS);
                // BK Ok
                bonusTokensAllocate[account] = true;
                // BK Ok
                uint usdAmount = ethAmount.mul(usdPerKEther).div(10**uint(3 + 18));
                // BK Ok
                contributedEth = contributedEth.add(ethAmount);
                // BK Ok
                contributedUsd = contributedUsd.add(usdAmount);
                // BK Ok
                generatedEve = generatedEve.add(eveAmount);
                // BK Ok - Log event
                Contributed(account, ethAmount, 0, ethAmount, usdAmount, PRESALE_BONUS_PERCENT, eveAmount,
                    contributedEth, contributedUsd, generatedEve);
                // BK Ok
                bttsToken.mint(account, eveAmount, false);
            }
        }
        // BK Ok
        if (presaleEthAmountsProcessed == presaleToken.totalSupply()) {
            // BK Ok
            presaleProcessed = true;
        }
    }

    // BK Ok - Contributors send ETH here, payable
    function () public payable {
        // BK Ok
        require(!finalised);
        // BK Ok
        uint ethAmount = msg.value;
        // BK Ok
        if (msg.sender == owner) {
            // BK Ok
            require(msg.value == MIN_CONTRIBUTION_ETH);
        // BK Ok
        } else {
            // BK Ok
            require(now >= startDate && now <= endDate);
            // BK Ok
            if (now <= firstPeriodEndDate) {
                // BK Ok
                require(accountEthAmount[msg.sender].add(ethAmount) <= firstPeriodCap);
                // BK Ok
                require(picopsCertifier.certified(msg.sender));
            }
        }
        // BK Ok
        require(contributedEth < capEth());
        // BK Ok
        require(msg.value >= MIN_CONTRIBUTION_ETH);
        // BK Ok
        uint ethRefund = 0;
        // BK Ok
        if (contributedEth.add(ethAmount) > capEth()) {
            // BK Ok
            ethAmount = capEth().sub(contributedEth);
            // BK Ok
            ethRefund = msg.value.sub(ethAmount);
        }
        // BK Ok
        uint usdAmount = ethAmount.mul(usdPerKEther).div(10**uint(3 + 18));
        // BK Ok
        uint eveAmount = eveFromEth(ethAmount, 0);
        // BK Ok
        if (picopsCertifier.certified(msg.sender) && !bonusTokensAllocate[msg.sender]) {
            // BK Ok
            eveAmount = eveAmount.add(PER_ACCOUNT_ADDITIONAL_TOKENS);
            // BK Ok
            bonusTokensAllocate[msg.sender] = true;
        }
        // BK Ok
        generatedEve = generatedEve.add(eveAmount);
        // BK Ok
        contributedEth = contributedEth.add(ethAmount);
        // BK Ok
        contributedUsd = contributedUsd.add(usdAmount);
        // BK Ok
        accountEthAmount[msg.sender] = accountEthAmount[msg.sender].add(ethAmount);
        // BK Ok
        bttsToken.mint(msg.sender, eveAmount, false);
        // BK Ok
        if (ethAmount > 0) {
            // BK Ok
            wallet.transfer(ethAmount);
        }
        // BK Ok - Log event
        Contributed(msg.sender, ethAmount, ethRefund, accountEthAmount[msg.sender], usdAmount, 0, eveAmount,
            contributedEth, contributedUsd, generatedEve);
        // BK Ok
        if (ethRefund > 0) {
            // BK Ok
            msg.sender.transfer(ethRefund);
        }
    }

    // BK Ok - Pure function
    function roundUp(uint a) internal pure returns (uint) {
        // BK Ok
        uint multiple = 10**uint(TOKEN_DECIMALS);
        // BK Ok
        uint remainder = a % multiple;
        // BK Ok
        if (remainder > 0) {
            // BK Ok
            return a.add(multiple).sub(remainder);
        }
    }
    // BK Ok - Only owner can execute
    function finalise() public onlyOwner {
        // BK Ok
        require(!finalised);
        // BK Ok
        require(now > endDate || contributedEth >= capEth());
        // BK Ok
        uint total = generatedEve.mul(100).div(uint(100).sub(TEAM_PERCENT_EVE).sub(RESERVE_PERCENT_EVE));
        // BK Ok
        uint amountTeam = total.mul(TEAM_PERCENT_EVE).div(100);
        // BK Ok
        uint amountReserve = total.mul(RESERVE_PERCENT_EVE).div(100);
        // BK Ok
        generatedEve = generatedEve.add(amountTeam).add(amountReserve);
        // BK Ok
        uint rounded = roundUp(generatedEve);
        // BK Ok
        if (rounded > generatedEve) {
            // BK Ok
            uint dust = rounded.sub(generatedEve);
            // BK Ok
            generatedEve = generatedEve.add(dust);
            // BK Ok
            amountReserve = amountReserve.add(dust);
        }
        // BK Ok
        if (generatedEve > TARGET_EVE) {
            // BK Ok
            uint diff = generatedEve.sub(TARGET_EVE);
            // BK Ok
            generatedEve = TARGET_EVE;
            // BK Ok
            amountReserve = amountReserve.sub(diff);
        }
        // BK Ok
        bttsToken.mint(address(vestingTeamWallet), amountTeam, false);
        // BK Ok
        bttsToken.mint(reserveWallet, amountReserve, false);
        // BK Ok
        bttsToken.disableMinting();
        // BK Ok
        vestingTeamWallet.finalise();
        // BK Ok
        finalised = true;
    }
}
```
