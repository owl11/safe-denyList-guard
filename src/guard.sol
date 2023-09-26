// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import {BaseGuard, Enum} from "safe-contracts/contracts/base/GuardManager.sol";
import {BadActors} from "./BadERC20.sol";

contract customeGuard is BaseGuard {
    error AddressBlacklisted();
    event LogAddress(bytes4 indexed funcSig, address indexed to);
    bytes4 private constant ERC20_INTERFACE_ID = 0x36372b07;
    bytes4 private constant ERC721_INTERFACE_ID = 0x80ac58cd;

    bytes4 private constant transfer_ID = 0xa9059cbb;
    bytes4 private constant transferFrom_ID = 0x23b872dd;
    bytes4 private constant approve_ID = 0x095ea7b3;

    BadActors public baddies;

    constructor(address _baddies) {
        baddies = BadActors(_baddies);
    }

    //TODO: implement a mechanism to seamlessly swap owners, by adding an admin, and their recovery method, this should ensure the owner remains in the safe if their account was compromised
    function checkTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address msgSender
    ) external override {
        // Check if the transaction is a token transfer
        address address_to;
        bytes4 _funcSig;
        (address_to, _funcSig) = FlaggedERCMethods(data);
        if (baddies.isBlacklisted(address_to)) {
            // The address is blacklisted; take appropriate action here, e.g., revert the transaction
            emit LogAddress(_funcSig, address_to);
            revert AddressBlacklisted();
        } else {
            // For other cases, you can check the `to` address directly
            address_to = to;
            if (baddies.isBlacklisted(address_to)) {
                // The address is blacklisted; take appropriate action here, e.g., revert the transaction
                revert AddressBlacklisted();
            }
        }
    }

    //not used here, could potentially be used if an admin module was added on top, which allows an admin to sign transactions without the need for all signers
    function checkModuleTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        address module
    ) external returns (bytes32 moduleTxHash) {}

    function checkAfterExecution(
        bytes32 txHash,
        bool success
    ) external override {
        // Handle after-execution checks if needed
    }

    //We summarize both erc 20 and erc721 methods into one checker function, since they share a lot of methods, re-using the same function for both types is possiable
    //TODO: Make it more modular, allow it to have extra methods that safe owners wish to blacklist, or even flip it upside down and allow only allowed methods, reverting on unrecognized methods
    function FlaggedERCMethods(
        bytes memory data
    ) public pure returns (address, bytes4) {
        bytes4 funcSig;
        address to;

        assembly {
            // Shift right by 224 bits to retain only the first 4 bytes
            funcSig := shr(224, mload(add(data, 0x20)))
            switch funcSig
            case 0x095ea7b3 {
                // Method ID for 'approve'
                to := mload(add(data, 0x30)) // located 48th bit
                to := shr(96, to)
            }
            case 0x23b872dd {
                // Method ID for 'transferFrom'
                to := mload(add(data, 0x50)) // located at the 80th bit
                to := shr(96, to)
            }
            case 0xa9059cbb {
                // Method ID for 'transfer'
                to := mload(add(data, 0x30)) // located 48th bit
                to := shr(96, to)
            }
            case 0x39509351 {
                // Method ID for 'increaseAllowance'
                to := mload(add(data, 0x30)) // located 48th bit
                to := shr(96, to)
            }
            case 0xd505accf {
                // Method ID for 'permit'
                to := mload(add(data, 0x50)) // located at the 80th bit
                to := shr(96, to)
            }
            case 0x42842e0e {
                // Method ID for 'safeTransferFrom(address,address,uint256)'
                to := mload(add(data, 0x50)) // located at the 80th bit
                to := shr(96, to)
            }
            case 0xb88d4fde {
                // Method ID for 'safeTransferFrom(address,address,uint256,bytes)'
                to := mload(add(data, 0x50)) // located at the 80th bit
                to := shr(96, to)
            }
            case 0xa22cb465 {
                // Method ID for 'setApprovalForAll(address,bool)'
                to := mload(add(data, 0x30)) // located 48th bit
                to := shr(96, to)
            }
            default {
                // Handle the default case if the function signature doesn't match any of the cases
            }
        }

        return (to, funcSig);
    }
}
