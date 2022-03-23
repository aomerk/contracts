# keser-contracts

library for modern, well-tested and gas optimized smart contract development. Although security practices are heavily considered, first aim of this library is gas optimization. See benchmarks of related contracts for more information.

This software is not audited and provided **as is** and **as provided**. Any PRs and audits are welcomed.

# Implementations
- Tokens
  - [ERC721](./contracts/token/ERC721/)
  - [ERC721Enumerable](./contracts/token/ERC721/)
  - [ERC20](./contracts/token/ERC20/)
  - [ERC1155](./contracts/token/ERC1155/)
- [Multi-Sig wallet](./contracts/multisig/)
- [RegExp Engine](./contracts/std/regexp)
- [String Utilities](./contracts/std/String.sol)
- Data Structures / Algorithms
  - [Binary Search](./contracts/data-structures/SortedArray.sol)
  - [Sorted Array](./contracts/data-structures/SortedArray.sol)
  - [Linked List](./contracts/data-structures/LinkedList/)
  - [QuickSort](./contracts/data-structures/QuickSort.sol)
# Benchmarks

## ERC721
Highlights:
- Way cheaper for end users to interact. (61% than solmate, 70% than openzeppelin)
- Bit more costly to deploy and mint (-7% for minting)
- written mostly in assembly

| erc721                  | keser   | solmate | % of improvement | openzeppelin | % of improvement |
| ----------------------- | ------- | ------- | ---------------- | ------------ | ---------------- |
| approve                 | 46494   | 48357   | 4.01%            | 48789        | 4.94%            |
| burn                    | 26333   | 28916   | 9.81%            | 30824        | 17.05%           |
| mint                    | 74016   | 68532   | \-7.41%          | 68636        | \-7.27%          |
| safeTransferFrom        | 35532   | 57236   | 61.08%           | 60467        | 70.18%           |
| transferFrom            | 33665   | 54498   | 61.88%           | 57587        | 71.06%           |
| MockDeployment          | 1174223 | 999125  | \-14.91%         | 1213540      | 3.35%            |
| Total (exc. Deployment) |         |         | 25.87%           |              | 31.19%           |
| Total                   |         |         | 19.08%           |              | 26.55%           |

See [ERC721 Implementation](./contracts/token/ERC721) for more details

---
## ERC1155
Highlights:
- Way cheaper to deploy the contract. (18% cheaper than solmate, 47% cheaper than openzeppelin)
- Cheaper batch operations (2.15% than solmate, 3.16% than openzeppelin)

|                         | keser   | solmate | % of improvement | openzeppelin | % of improvement |
| ----------------------- | ------- | ------- | ---------------- | ------------ | ---------------- |
| batchBurn               | 54865   | 55946   | 1.97%            | 56889        | 3.69%            |
| batchMint               | 363087  | 374319  | 3.09%            | 378173       | 4.15%            |
| burn                    | 29848   | 29933   | 0.28%            | 30548        | 2.35%            |
| mint                    | 47743   | 47914   | 0.36%            | 48418        | 1.41%            |
| safeBatchTransferFrom   | 661675  | 670847  | 1.39%            | 672577       | 1.65%            |
| safeTransferFrom        | 52009   | 52440   | 0.83%            | 53020        | 1.94%            |
| setApprovalForAll       | 46143   | 46057   | \-0.19%          | 46158        | 0.03%            |
| MockDeployment          | 1122875 | 1321823 | 17.72%           | 1646238      | 46.61%           |
| Total (exc. Deployment) |         |         | 1.11%            |              | 2.18%            |
| Total                   |         |         | 3.18%            |              | 7.73%            |

See [ERC1155 Implementation](./contracts/token/ERC1155) for more details

## ERC20
Highlights:
- I don't think there is a single more gas left to save.
- Although, erc20 is widely used in mainnet and every single dime counts. **0.78%** cheaper to call `transfer`


| erc20                   | keser  | solmate | % of improvement | openzeppelin | % of improvement |
| ----------------------- | ------ | ------- | ---------------- | ------------ | ---------------- |
| approve                 | 46032  | 46117   | 0.18%            | 46197        | 0.36%            |
| burn                    | 33891  | 34037   | 0.43%            | 34160        | 0.79%            |
| mint                    | 68163  | 68197   | 0.05%            | 68311        | 0.22%            |
| transfer                | 51122  | 51248   | 0.25%            | 51520        | 0.78%            |
| transferFrom            | 51946  | 52341   | 0.76%            | 54552        | 5.02%            |
| MockDeployment          | 738053 | 782147  | 5.97%            | 743374       | 0.72%            |
| Total (exc. Deployment) |        |         | 0.33%            |              | 1.43%            |
| Total                   |        |         | 1.27%            |              | 1.31%            |

See [ERC20 Implementation](./contracts/token/ERC20) for more details

