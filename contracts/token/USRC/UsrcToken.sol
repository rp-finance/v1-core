// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IConsole {
    function getMinter() view external returns(address);
    function getBurner() view external returns(address);
    function getMintTimeLock() view external returns(uint);
    function getMintCancelTimeLock() view external returns(uint);
    function isBlock(address _address) view external returns(bool);
    // function parseInt(string memory _a) external pure returns (uint _parsedInt);
}
struct MintRequest {
    address _address;
    uint _refId;
    uint _amount;
    uint _proposedMintTime;
}

contract UsrcToken is ERC20, Ownable, ReentrancyGuard{
    IConsole console;

    uint public lastMintedTime;
    uint public lastBurnedTime;
    uint public lastTransferredTime;
    uint public requestId;
    uint public lastMintedRequestId;
    mapping (uint => MintRequest) public mintRequests;
    string private _name;
    string private _symbol;

    event MintRequestEvent (uint indexed refId, uint indexed requestId, uint timestamp);
    event MintCancelEvent (uint indexed refId, uint indexed requestId, uint timestamp);
    event MintEvent (uint indexed refId, uint indexed requestId, uint timestamp);
    event TransferEvent (uint indexed refId, uint indexed amount, uint timestamp);
    event BurnEvent (uint indexed refId, uint indexed amount, uint timestamp);


    constructor() ERC20("USRC", "USRC") {
    }
    // Create Mint Request
    function proposeMint(uint refId, address _address, uint amount) external nonReentrant {
        require(_address != address(0), "[RP-113]-invalid address");
        require(msg.sender == console.getMinter(), "[RP-211]-only minter can operate mint request");
        verifyAmount(amount);
        unchecked {
            // Time Lock: should be 1 days for Live
            uint proposedMintTime = block.timestamp + console.getMintTimeLock();
            MintRequest memory mintRequest = MintRequest(_address, refId, amount, proposedMintTime);
            ++requestId;
            mintRequests[requestId] = mintRequest;  
            emit MintRequestEvent(refId, requestId, block.timestamp);
        }
    }

    // Cancel MintRequest
    function cancelMint(uint id) external nonReentrant {
        require(msg.sender == console.getMinter(), "[RP-211]-only minter can operate mint request");
        MintRequest memory mintRequest = mintRequests[id];
        require(mintRequest._proposedMintTime > 0, "[RP-212]-mint request does not exist");
        // Time Lock: should be 1 hours for Live
        require(block.timestamp <= mintRequest._proposedMintTime - console.getMintCancelTimeLock(), "[RP-214]-failed to cancel mint request");
        unchecked {
            uint refId = mintRequest._refId;
            delete mintRequests[id];
            emit MintCancelEvent(refId, id, block.timestamp);
        }
    }
    // Execute Mint Request by requestId
    function mint(uint id) external nonReentrant {
        MintRequest memory mintRequest = mintRequests[id];
        require(mintRequest._proposedMintTime > 0, "[RP-212]-mint request does not exist");
        require(block.timestamp >= mintRequest._proposedMintTime, "[RP-213]-still waiting for cool down");
        // Execute Mint
        _mint(address(console.getMinter()), mintRequest._amount);
        unchecked {
            uint refId = mintRequest._refId;
            lastMintedTime = block.timestamp;
            lastMintedRequestId = id;
            delete mintRequests[id];
            emit MintEvent(refId, requestId, lastMintedTime);
        }
    } 
    // Execute Transfer
    function transfer(address to, uint amount) public virtual override nonReentrant returns (bool) {
        require(to != address(0), "[RP-113]-invalid address");
        require(msg.sender != console.getBurner(), "[RP-215]-burner is not allowed for token transfer");
        verifyAmount(amount);
        // Execute Transfer
        _transfer(address(msg.sender), to, amount);
        unchecked {
            lastTransferredTime = block.timestamp;
        }
        return true;
    }

    function transferTo(uint refId, address to, uint amount) external nonReentrant returns (bool) {
        require(to != address(0), "[RP-113]-invalid address");
        require(refId > 0, "[RP-216]-refId is required");
        require(msg.sender != console.getBurner(), "[RP-215]-burner is not allowed for token transfer");
        verifyAmount(amount);
        // Execute Transfer
        _transfer(address(msg.sender), to, amount);
        unchecked {
            lastTransferredTime = block.timestamp;
            emit TransferEvent(refId, amount, lastTransferredTime);
        }
        return true;
    }

    // Execute Transfer From
    function transferFrom(address from, address to, uint amount) public virtual override nonReentrant returns (bool) {
        require(from != address(0) || to != address(0), "[RP-113]-invalid address");
        require(msg.sender != console.getBurner() && from != console.getBurner(), "[RP-215]-burner is not allowed for token transfer");
        verifyAmount(amount);
        // Execute Transfer
        _transfer(from, to, amount);
        unchecked {
            lastTransferredTime = block.timestamp;
        }
        return true;
    }

    function transferFromWithRefId(uint refId, address from, address to, uint amount) external nonReentrant returns (bool) {
        require(from != address(0) || to != address(0), "[RP-113]-invalid address");
        require(refId > 0, "[RP-216]-refId is required");
        require(msg.sender != console.getBurner() && from != console.getBurner(), "[RP-215]-burner is not allowed for token transfer");
        verifyAmount(amount);
        // Execute Transfer
        _transfer(from, to, amount);
        unchecked {
            lastTransferredTime = block.timestamp;
            emit TransferEvent(refId, amount, lastTransferredTime);
        }
        return true;
    }

    // Execute Burn
    function burn(uint refId, uint amount) external nonReentrant {
        require(msg.sender == console.getBurner(),"[RP-217]-only burner can burn tokens");
        require(refId > 0, "[RP-216]-refId is required");
        verifyAmount(amount);
        _burn(address(msg.sender), amount);
        unchecked {
            lastBurnedTime = block.timestamp;
            emit BurnEvent(refId, amount, lastBurnedTime);
        }
    }

    function verifyAmount(uint amount) internal pure {
        require(amount > 0, "[RP-111]-amount should be greater than 0");
        require(amount <= 1e38, "[RP-112]-max amount is 1e38 token");
    }

    function setConsole(address _console) external onlyOwner {
        console = IConsole(_console);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view override  {
        require(!console.isBlock(from) && !console.isBlock(to), "[RP-311]-not allowed");
        require(amount > 0, "[RP-111]-amount should be greater than 0");
    }
    
    // Initialize Ownership, Name & Symbol
    function initialize(string calldata name_, string calldata symbol_) public {
        _transferOwnership(msg.sender);
        unchecked {
            _name = name_;
            _symbol = symbol_;
        }
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

}