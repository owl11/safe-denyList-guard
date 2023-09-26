## Safe-DenyList-Guard

**This is a custom guard built for the current safe-contracts architecture**

Components:

- **BadERC20**: Built as a custom ERC20 (but not implementing the entire EIP20 spec), with no name, and 0 decimals(optimize gas usage), it can only minted and burned by the owner, additionally, an optional parameter, the owner can provide a reason as to why a user is blacklisted by adding a Txhash as proof to the malicious transaction committed by the blacklisted actors.

- **Guard**: Inheriting from the most recent safe-contracts, we built out a custom guard that denies any transaction that is going to 'blacklisted' address, through a basic ERC20 Methods' or ERC721's Methods' or a direct transfer (WIP).

## Usage

### Build

```shell
$ forge script script/script.s.sol --private-key $DEPLOYER_PRIVATE_KEY --rpc-url $GOERLI_RPC --broadcast
```

## Notes

**Disclaimer:** These contracts are experimental and are not guaranteed or audited. They are a work in progress, and their functionality may change in future updates.

While we have designed these contracts to be simple and efficient, we cannot provide any guarantees regarding their security or functionality. Please exercise caution and use them at your own risk.

**Future Updates:** We are actively working on potential upgrades and updates to improve these contracts. Keep an eye out for announcements regarding new versions and changes.

Your feedback and contributions are welcome as we continue to enhance and refine these contracts.
