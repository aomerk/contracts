# keser-contracts

library for modern, well-tested and gas optimized smart contract development. Although security practices are heavily considered, first aim of this library is gas optimization. See benchmarks of related contracts for more information.

This software is not audited and provided **as is** and **as provided**. Any PRs and audits are welcomed.



# Benchmarks

## ERC1155
Highlights:
- Way cheaper to deploy the contract. (18% cheaper than solmate, 47% cheaper than openzeppelin)
- Cheaper batch operations (2.15% than solmate, 3.16% than openzeppelin)

|                         | keser   | solmate | % iof improvement | openzeppelin | % of improvement |
| ----------------------- | ------- | ------- | ----------------- | ------------ | ---------------- |
| batchBurn               | 54865   | 55946   | 1.97%             | 56889        | 3.69%            |
| batchMint               | 363087  | 374319  | 3.09%             | 378173       | 4.15%            |
| burn                    | 29848   | 29933   | 0.28%             | 30548        | 2.35%            |
| mint                    | 47743   | 47914   | 0.36%             | 48418        | 1.41%            |
| safeBatchTransferFrom   | 661675  | 670847  | 1.39%             | 672577       | 1.65%            |
| safeTransferFrom        | 52009   | 52440   | 0.83%             | 53020        | 1.94%            |
| setApprovalForAll       | 46143   | 46057   | \-0.19%           | 46158        | 0.03%            |
| MockDeployment          | 1122875 | 1321823 | 17.72%            | 1646238      | 46.61%           |
| Total (exc. Deployment) |         |         | 1.11%             |              | 2.18%            |
| Total                   |         |         | 3.18%             |              | 7.73%            |

See [ERC1155 Implementation](./contracts/token/ERC1155) for more details

