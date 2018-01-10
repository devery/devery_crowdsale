pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// 'EVE' 'Devery EVE' token contract
//
// Deployed to : {TBA}
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
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// BokkyPooBah's Token Teleportation Service Interface v1.00
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017. The MIT Licence.
// ----------------------------------------------------------------------------
contract BTTSTokenInterface is ERC20Interface {
    uint public constant bttsVersion = 100;

    bytes public constant signingPrefix = "\x19Ethereum Signed Message:\n32";
    bytes4 public constant signedTransferSig = "\x75\x32\xea\xac";
    bytes4 public constant signedApproveSig = "\xe9\xaf\xa7\xa1";
    bytes4 public constant signedTransferFromSig = "\x34\x4b\xcc\x7d";
    bytes4 public constant signedApproveAndCallSig = "\xf1\x6f\x9b\x53";

    event OwnershipTransferred(address indexed from, address indexed to);
    event MinterUpdated(address from, address to);
    event Mint(address indexed tokenOwner, uint tokens, bool lockAccount);
    event MintingDisabled();
    event TransfersEnabled();
    event AccountUnlocked(address indexed tokenOwner);

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success);

    // ------------------------------------------------------------------------
    // signed{X} functions
    // ------------------------------------------------------------------------
    function signedTransferHash(address tokenOwner, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferCheck(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedTransfer(address tokenOwner, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedApproveHash(address tokenOwner, address spender, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveCheck(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedApprove(address tokenOwner, address spender, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedTransferFromHash(address spender, address from, address to, uint tokens, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedTransferFromCheck(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedTransferFrom(address spender, address from, address to, uint tokens, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function signedApproveAndCallHash(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce) public view returns (bytes32 hash);
    function signedApproveAndCallCheck(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public view returns (CheckResult result);
    function signedApproveAndCall(address tokenOwner, address spender, uint tokens, bytes _data, uint fee, uint nonce, bytes sig, address feeAccount) public returns (bool success);

    function mint(address tokenOwner, uint tokens, bool lockAccount) public returns (bool success);
    function unlockAccount(address tokenOwner) public;
    function disableMinting() public;
    function enableTransfers() public;

    // ------------------------------------------------------------------------
    // signed{X}Check return status
    // ------------------------------------------------------------------------
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
contract PICOPSCertifier {
    function certified(address) public constant returns (bool);
}


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function Owned() public {
        owner = msg.sender;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// Devery Vesting Contract
// ----------------------------------------------------------------------------
contract DeveryVesting {
    using SafeMath for uint;

    // ERC20Interface public token;
    DeveryCrowdsale public crowdsale;
    uint public totalProportion;
    uint public totalTokens;
    uint public constant PERIOD_LENGTH = 30 days;
    uint public startDate;

    struct Entry {
        uint proportion;
        uint periods;
        uint withdrawn;
    }
    mapping (address => Entry) public entries;

    event NewEntry(address indexed holder, uint proportion, uint periods);

    function DeveryVesting(address _crowdsale) public {
        crowdsale = DeveryCrowdsale(_crowdsale);
    }

    function addEntry(address holder, uint256 proportion, uint256 periods) public {
        require(msg.sender == crowdsale.owner());
        require(holder != address(0));
        require(proportion > 0);
        require(periods > 0);
        require(entries[holder].proportion == 0);
        entries[holder] = Entry({
            proportion: proportion,
            periods: periods,
            withdrawn: 0
        });
        totalProportion = totalProportion.add(proportion);
        NewEntry(holder, proportion, periods);
    }

    function vested(address holder, uint time) public constant returns (uint) {
        if (startDate == 0 || time <= startDate) {
            return 0;
        }
        Entry memory entry = entries[holder];
        if (time > startDate + entry.periods * PERIOD_LENGTH) {
            return totalTokens * entry.proportion / totalProportion;
        }
        uint periods = (time - startDate) / PERIOD_LENGTH;
        uint tokens = totalTokens * periods / entry.periods;
        return tokens;
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

    ERC20Interface public presaleToken = ERC20Interface(0xe6ada9beed6e24be4c0259383db61b52bfca85f3);
    uint public presaleEthAmountsProcessed;
    bool public presaleProcessed;
    // TEST uint public constant PRESALE_BONUS_PERCENT = 5;
    uint public constant PRESALE_BONUS_PERCENT = 0;

    // TEST uint public constant PER_ACCOUNT_ADDITIONAL_TOKENS = 150 * 10**uint(TOKEN_DECIMALS);
    uint public constant PER_ACCOUNT_ADDITIONAL_TOKENS = 0;
    mapping(address => bool) bonusTokensAllocate;

    PICOPSCertifier public picopsCertifier = PICOPSCertifier(0x1e2f058c43ac8965938f6e9ca286685a3e63f24e);

    address public wallet = 0xa22AB8A9D641CE77e06D98b7D7065d324D3d6976;
    address public teamWallet = 0xAAAA9De1E6C564446EBCA0fd102D8Bd92093c756;
    address public reserveWallet = 0xaBBa43E7594E3B76afB157989e93c6621497FD4b;
    DeveryVesting public vestingTeamWallet;
    uint public constant TEAM_PERCENT_EVE = 15;
    uint public constant RESERVE_PERCENT_EVE = 25;

    // Start 18 Jan 2018 16:00 UTC => "Fri, 19 Jan 2018 03:00:00 AEDT"
    // new Date(1516291200 * 1000).toUTCString() => "Thu, 18 Jan 2018 16:00:00 UTC"
    uint public startDate = 1515946516; // Sun 14 Jan 2018 16:15:16 UTC
    uint public firstPeriodEndDate = startDate + 12 hours;
    uint public endDate = startDate + 14 days;

    // ETH/USD 11 Jan 2018 22:34 AEDT => 1182.75 from CMC
    uint public usdPerKEther = 1182750;
    uint public constant USD_CENT_PER_6_EVE = 100;
    uint public constant CAP_USD = 10000000;
    uint public constant MIN_CONTRIBUTION_ETH = 0.01 ether;

    uint public contributedEth;
    uint public contributedUsd;
    uint public generatedEve;

    mapping(address => uint) public accountEthAmount;

    bool public finalised;

    event BTTSTokenUpdated(address indexed oldBTTSToken, address indexed newBTTSToken);
    event PICOPSCertifierUpdated(address indexed oldPICOPSCertifier, address indexed newPICOPSCertifier);
    event WalletUpdated(address indexed oldWallet, address indexed newWallet);
    event TeamWalletUpdated(address indexed oldTeamWallet, address indexed newTeamWallet);
    event ReserveWalletUpdated(address indexed oldReserveWallet, address indexed newReserveWallet);
    event StartDateUpdated(uint oldStartDate, uint newStartDate);
    event FirstPeriodEndDateUpdated(uint oldFirstPeriodEndDate, uint newFirstPeriodEndDate);
    event EndDateUpdated(uint oldEndDate, uint newEndDate);
    event UsdPerKEtherUpdated(uint oldUsdPerKEther, uint newUsdPerKEther);

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
    function setTeamWallet(address _teamWallet) public onlyOwner {
        TeamWalletUpdated(teamWallet, _teamWallet);
        teamWallet = _teamWallet;
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

    function capEth() public view returns (uint) {
        return CAP_USD * 10**uint(3 + 18) / usdPerKEther;
    }
    function eveFromEth(uint ethAmount, uint bonusPercent) public view returns (uint) {
        return usdPerKEther * ethAmount * (100 + bonusPercent) * 6 / 10**uint(3 + 2 - 2) / USD_CENT_PER_6_EVE;
    }
    function evePerEth() public view returns (uint) {
        return eveFromEth(10**18, 0);
    }

    event Contributed(address indexed addr, uint ethAmount, uint ethRefund, uint accountEthAmount, uint usdAmount, uint bonusPercent,
        uint eveAmount, uint contributedEth, uint contributedUsd, uint generatedEve);

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
        // require((now >= START_DATE && now <= endDate) || (msg.sender == owner && msg.value == MIN_CONTRIBUTION_ETH));
        require(contributedEth < capEth());
        require(msg.value >= MIN_CONTRIBUTION_ETH);
        uint ethAmount = msg.value;
        uint ethRefund = 0;
        if (contributedEth.add(ethAmount) > capEth()) {
            ethAmount = capEth().sub(contributedEth);
            ethRefund = msg.value.sub(ethAmount);
        }
        uint usdAmount = ethAmount.mul(usdPerKEther).div(10**uint(3 + 18));
        uint eveAmount = eveFromEth(ethAmount, 0);
        generatedEve = generatedEve.add(eveAmount);
        if (!bonusTokensAllocate[msg.sender]) {
            eveAmount = eveAmount.add(PER_ACCOUNT_ADDITIONAL_TOKENS);
            bonusTokensAllocate[msg.sender] = true;
        }
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
        // bttsToken.mint(teamWallet, amountTeam, false);
        bttsToken.mint(address(vestingTeamWallet), amountTeam, false);
        bttsToken.mint(reserveWallet, amountReserve, false);
        bttsToken.disableMinting();
        vestingTeamWallet.finalise();
        finalised = true;
    }
}