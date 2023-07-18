// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
pragma abicoder v2;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IConsole {
    function setMinter(address _minter) external;
    function getMinter() view external returns(address);
    function setBurner(address _burner) external;
    function getBurner() view external returns(address);
    function setOperator(address _operator) external;

    function setMintTimeLock(uint timeLock) external;
    function getMintTimeLock() view external returns(uint);
    function setMintCancelTimeLock(uint timeLock) external;
    function getMintCancelTimeLock() view external returns(uint);
    // function parseInt(string memory _a) external pure returns (uint _parsedInt);

    function addBlockAddresses(AddressList calldata addressList) external;
    function removeBlockAddresses(AddressList calldata addressList) external;
    function addAllowAddresses(AddressList calldata addressList) external;
    function removeAllowAddresses(AddressList calldata addressList) external;
    function isBlock(address _address) view external returns(bool);
    function isAllow(address _address) view external returns(bool);
}

struct AddressList {
    address[] addresses;
}

contract Console is IConsole, Ownable {
    address public minter;
    address public burner;
    address public operator;

    mapping(address=>uint256) blockAddresses;
    mapping(address=>uint256) allowAddresses;
    // Time Lock: should be 1 days for Live
    uint public mintTimeLock = 1 minutes;
    uint public mintTimeLockLastChangedTime = block.timestamp;
    // Time Lock: should be 1 hours for Live
    uint public mintCancelTimeLock = 30 seconds;

    // Initialize Ownership
    function initialize() public {
        _transferOwnership(msg.sender);
    }

    function verifyTimeLock() internal view {
        require(msg.sender == operator, "[RP-312]-only operator can manipulate the data");
        require(block.timestamp >= mintTimeLockLastChangedTime + mintTimeLock, "[RP-314]-failed to modify mintTimeLock");

    }

    function setMintCancelTimeLock(uint timeLock) external {
        verifyTimeLock();
        // require(msg.sender == operator, "only operator can manipulate the data");
        // require(block.timestamp >= mintTimeLockLastChangedTime + mintTimeLock, "failed to modify mintTimeLock");
        unchecked {
            mintCancelTimeLock = timeLock;
            mintTimeLockLastChangedTime = block.timestamp;
        }
    }

    function getMintCancelTimeLock() view external returns(uint) {
        return mintCancelTimeLock;
    }

    function setMintTimeLock(uint timeLock) external {
        verifyTimeLock();
        // require(msg.sender == operator, "only operator can manipulate the data");
        // require(block.timestamp >= mintTimeLockLastChangedTime + mintTimeLock, "failed to modify mintTimeLock");
        unchecked {
            mintTimeLock = timeLock;
        }
    }

    function getMintTimeLock() view external returns(uint) {
        return mintTimeLock;
    }

    function setMinter(address _minter) external onlyOwner{
        require(_minter != address(0), "[RP-113]-invalid address");
        unchecked {
            minter = _minter;
        }
    }

    function getMinter() view external returns(address) {
        return minter;
    }
    
    function setBurner(address _burner) external onlyOwner{
        require(_burner != address(0), "[RP-113]-invalid address");
        unchecked {
            burner = _burner;
        }
    }

    function getBurner() view external returns(address) {
        return burner;
    }

    function setOperator(address _operator) external onlyOwner{
        require(_operator != address(0), "[RP-113]-invalid address");
        unchecked {
            operator = _operator;
        }
    }

    function getSize(AddressList calldata addressList) internal pure returns(uint) {
        uint size = addressList.addresses.length;
        require(size <= 100, "[RP-313]-each bacth cannot exceed 100");
        return size;
    }

    function addBlockAddresses(AddressList calldata addressList) external {
        require(msg.sender == operator,"[RP-312]-only operator can manipulate the data");
        uint size = getSize(addressList);
        for (uint8 i = 0; i < size; i++) {
            unchecked {
                blockAddresses[addressList.addresses[i]] = 1;
            }
        }
    }

    function removeBlockAddresses(AddressList calldata addressList) external {
        require(msg.sender == operator,"[RP-312]-only operator can manipulate the data");
        uint size = getSize(addressList);
        for (uint8 i = 0; i < size; i++) {
            unchecked {
                delete blockAddresses[addressList.addresses[i]];
            }
        }
    }
    function addAllowAddresses(AddressList calldata addressList) external {
        require(msg.sender == operator,"[RP-312]-only operator can manipulate the data");
        uint size = getSize(addressList);
        for (uint8 i = 0; i < size; i++) {
            unchecked {
                allowAddresses[addressList.addresses[i]] = 1;
            }
        }
    }

    function removeAllowAddresses(AddressList calldata addressList) external {
        require(msg.sender == operator,"[RP-312]-only operator can manipulate the data");
        uint size = getSize(addressList);
        for (uint8 i = 0; i < size; i++) {
            unchecked {
                delete allowAddresses[addressList.addresses[i]];
            }
        }
    }
    
    function isBlock(address _address) view external returns(bool){
        return blockAddresses[_address] == 1;
    }
    function isAllow(address _address) view external returns(bool){
        return allowAddresses[_address] == 1;
    }  
}