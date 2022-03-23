import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const MultiSig = await ethers.getContractFactory("MultiSig", {

	});


	const [owner, address1] = await ethers.getSigners()
	const arr = [owner.address, address1.address]
	const multiSig = await MultiSig.deploy(arr, 1);
	await multiSig.deployed();
	console.log("signers: ", arr)
	return multiSig;
}

describe.only("MultiSig", function () {
	it("deploy", async function () {
		contracts()
	});
	describe("submit transaction", function () {
		it("can be submitted by a signer", async function () {
			const multiSig = await contracts();
			const [owner, address1] = await ethers.getSigners();
			console.log("users", owner.address, address1.address)
			await multiSig.submitTransaction(address1.address, 10, []);

			await multiSig.confirmTransaction(0, true)

			const confirmed = await multiSig.isConfirmed(owner.address, 0);
			expect(confirmed).to.be.true;
		});
		it("can be submitted by a signer", async function () {
			const multiSig = await contracts();
			const [owner, address1] = await ethers.getSigners();
			console.log("users", owner.address, address1.address)
			await multiSig.submitTransaction(address1.address, 0, []);

			await multiSig.confirmTransaction(0, true)

			const confirmed = await multiSig.isConfirmed(owner.address, 0);
			expect(confirmed).to.be.true;

			await multiSig.executeTransaction(0);
		});
	});
});


function toBigNumberArray(arr: any) {
	return arr.map((i: number) => ethers.BigNumber.from(i));
}
