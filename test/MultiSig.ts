import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const MultiSig = await ethers.getContractFactory("MultiSig");
	const multiSig = await MultiSig.deploy();
	await multiSig.deployed();

	return multiSig;
}
describe("MultiSig", function () {
	it("deploy", async function () {
		contracts();
	});
});
