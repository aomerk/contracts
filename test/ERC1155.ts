import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const ERC1155 = await ethers.getContractFactory("MockERC1115");
	const erc1155 = await ERC1155.deploy();
	await erc1155.deployed();

	return erc1155;
}

describe.only("ERC1115", function () {
	it("deploy", async function () {
		contracts()
	});

	it("can mint single", async function () {
	});
	it("can mint in batches", async function () {
	});
	it("can burn", async function () {

	});
	it("can burn in batches", async function () {

	});
	it("can get correct balance", async function () {

	});
	it("can get correct balance in batches", async function () {

	});
	it("can set approval", async function () {

	});
	it("can check for approval", async function () {

	});
	it("can transfer safely", async function () {

	});
	it("can transfer safely in batches", async function () {

	});
});

function toBigNumberArray(arr: any) {
	return arr.map((i: number) => ethers.BigNumber.from(i));
}

