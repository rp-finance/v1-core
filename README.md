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

> `contracts` folder houses all smart contract files, with two subfolders named `console` and `token`. The proxy smart contract files within this folder are consistently suffixed with the term `proxy`.

* `console` folder houses smart contract files responsible for overseeing administrative functionalities.
* `token` folder encompasses smart contract files that govern the operational aspects of tokens such as `RPC`, `USRC`, and others.

