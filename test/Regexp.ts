import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const RegExp = await ethers.getContractFactory("MockRegExp", {

	});
	const regExp = await RegExp.deploy();
	await regExp.deployed();

	return regExp;
}

describe.only("RegExp", function () {
	it("deploy", async function () {
		contracts()
	});
	describe("match", function () {
		it("can match n", async function () {
			const regExp = await contracts();

			expect(await regExp.MatchRegExp("abcd", "abcd")).to.be.true;
		});
		it("can match *", async function () {
			const regExp = await contracts();

			expect(await regExp.MatchRegExp("a*d", "aaaad")).to.be.true;
		});
		it("can match wildcard", async function () {
			const regExp = await contracts();

			expect(await regExp.MatchRegExp("a.*d", "aaaaaaad")).to.be.true;
		});
		it("can detect mismatch", async function () {
			const regExp = await contracts();

			expect(await regExp.MatchRegExp("xxxx", "abcd")).to.be.false;
		});
	});
});

