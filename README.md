# keser-contracts

library for modern, well-tested and gas optimized smart contract development. Although security practices are heavily considered, first aim of this library is gas optimization. See benchmarks of related contracts for more information.

This software is not audited and provided **as is** and **as provided**. Any PRs and audits are welcomed.



# benchmarks

## ERC1155


|	Method 					| keser (avg) 		|	solmate(avg) 	|	openzeppelin(avg)	|
| ------ 					| ----------- 		| ------------- 	|	----------------	|
|	batchBurn	  			|	24926			|   28503(+14.3%) 	|	28776	(+15.4)		|
|	batchMint				|	75657			|	98473(+30.2%	|	98773	(+30.5)		|
|	burn 					|	30234			|   29933(-0.8%)	|	30548	(+1%)		|
|	mint 					|	47923			|   47914(-0.02%)  	|	48418	(+1%)		|
|	safeBatchTransferFrom 	|	81704			|   104115(+27.4%)	|	104422	(+27.8)		|
|	safeTransferFrom 		|	50856			|   51311(+0.9%)	|	51869	(+2%)		|
|	setApprovalForAll 		|	46143			|   46057(-0.2%)	|	46158	(-0.03%)	|
|	MockDeployment 			|	1214552			|   1301654   		|	1654094				|

See tokens/ERC1155/benchmarks for more details
