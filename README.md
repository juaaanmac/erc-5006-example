# ERC-5006 Implementation Example

ERC-5006 is an extension of ERC-1155. It proposes an additional role (user) which can be granted to addresses that represent a user of the assets rather than an owner.

Try running some of the following commands:

### Compile
```shell
forge build
```

### Run tests
```shell
forge test
```
### Deploy and verify
```shell
forge create --rpc-url <your_rpc_url> --constructor-args <uri> --private-key <your_private_key> --etherscan-api-key <your_etherscan_api_key> --verify src/RYC.sol:RYC
```

**Sample contract deployed and verified on [Polygon Mumbai](https://mumbai.polygonscan.com/address/0x8d7cf2f420863ef8cb2edb700985e4023c463308).**