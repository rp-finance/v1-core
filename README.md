# v1-core

This repository comprises the fundamental smart contracts for the __Reserved Protocol V1__.

## Licensing

The primary license for __Reserved Protocol V1__ Core is the Massachusetts Institute of Technology License (MIT), see [`LICENSE`](./LICENSE). 

## Code Structure

```
$ root_directory
├── .gitignore
├── LICENSE
├── README.md
└── contracts
│   ├── console
│       ├── Console.sol
│       └── ConsoleProxy.sol
│   └── token
│       ├── RPC
│           ├── RpcProxy.sol
│           └── RpcToken.sol
│       └── USRC
│           ├── UsrcProxy.sol
│           └── UsrcToken.sol

```

> `contracts` folder houses all smart contract files, with two subfolders named `console` and `token`. 

* `console` folder houses smart contract files responsible for overseeing administrative functionalities.
* `token` folder encompasses smart contract files that govern the operational aspects of tokens such as `RPC`, `USRC`, and others. 
   - The proxy smart contract files for update purpose within this folder are consistently suffixed with the term `Proxy`.
   - The ERC-20 smart contract files for token manipulate purpose within this folder are consistently suffixed with the term `Token`.

## External References

* [@openzeppelin/contracts/access/Ownable.sol](https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable)
* [@openzeppelin/contracts/token/ERC20/IERC20.sol](https://docs.openzeppelin.com/contracts/4.x/api/token/erc20#IERC20)
* [@openzeppelin/contracts/utils/Strings.sol](https://docs.openzeppelin.com/contracts/4.x/api/utils#Strings)
* [@openzeppelin/contracts/security/ReentrancyGuard.sol](https://docs.openzeppelin.com/contracts/4.x/api/security#ReentrancyGuard)



