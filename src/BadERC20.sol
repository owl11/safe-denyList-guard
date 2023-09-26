// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//this is not an ERC20, and does not follow the spec of a basic ERC20, It only utilizes some of the functions to keep track of holders and is only burnable by the owner
contract BadActors {
    mapping(address => uint256) public balanceOf;
    mapping(address => bytes32[]) private maliciousTransactions;
    address public immutable AUTH_ROLE;
    uint8 public immutable decimals;

    uint256 public totalSupply;
    event MaliciousActivityRecorded(
        address indexed maliciousAddress,
        bytes32 indexed transactionHash
    );

    event Transfer(
        address indexed owner_,
        address indexed recipient_,
        uint256 amount_
    );
    error Auth();

    constructor() {
        totalSupply = 0;
        decimals = 0;
        AUTH_ROLE = msg.sender;
    }

    modifier authorized() {
        if (!isAuthorized(msg.sender)) {
            revert Auth();
        }
        _;
    }

    // Function to check if an account is authorized to record malicious activities
    function isAuthorized(address account) internal view returns (bool) {
        address auth = AUTH_ROLE;
        if (account == auth) {
            return true;
        } else {
            return false;
        }
    }

    function isBlacklisted(address targetUser) public view returns (bool) {
        return balanceOf[targetUser] > 0;
    }

    // Function to record a malicious activity
    function recordMaliciousActivity(
        address maliciousAddress,
        bytes32 transactionHash
    ) external authorized {
        // Store the transaction hash without any prefix
        maliciousTransactions[maliciousAddress].push(transactionHash);

        // Emit an event to log the recorded activity
        emit MaliciousActivityRecorded(maliciousAddress, transactionHash);
    }

    // Function to get the recorded malicious transactions for an address
    function getMaliciousTransactions(
        address maliciousAddress
    ) external view returns (bytes32[] memory) {
        return maliciousTransactions[maliciousAddress];
    }

    function mint(address recipient_) public authorized {
        _mint(recipient_, 1);
    }

    function burn(address recipient_) public authorized {
        _burn(recipient_, 1);
    }

    function _burn(address owner_, uint256 amount_) internal {
        balanceOf[owner_] -= amount_;

        // Cannot underflow because a user's balance will never be larger than the total supply.
        unchecked {
            totalSupply -= amount_;
        }

        emit Transfer(owner_, address(0), amount_);
    }

    function _mint(address recipient_, uint256 amount_) internal {
        totalSupply += amount_;

        // Cannot overflow because totalSupply would first overflow in the statement above.
        unchecked {
            balanceOf[recipient_] += amount_;
        }

        emit Transfer(address(0), recipient_, amount_);
    }
}
