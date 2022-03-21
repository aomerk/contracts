import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const RegExp = await ethers.getContractFactory("MockRegExp", {

	});
	const regExp = await RegExp.deploy();
	await regExp.deployed();

	return regExp;
}

describe("RegExp", function () {
	it("deploy", async function () {
		contracts()
	});
	describe.only("match", function () {
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
		it("can match single", async function () {
			const regExp = await contracts();

			expect(await regExp.MatchRegExp("a.*d", "ad")).to.be.true;
		});

		it("a.*db", async function () {
			const regExp = await contracts();

			expect(await regExp.MatchRegExp("a.*db", "adb")).to.be.true;
		});
		it("can match eol", async function () {
			const regExp = await contracts();

			expect(await regExp.MatchRegExp("ad$", "adx")).to.be.false;
		});
		it("can detect mismatch", async function () {
			const regExp = await contracts();

			expect(await regExp.MatchRegExp("xxxx", "abcd")).to.be.false;
		});
		it("can detect http", async function () {
			const regExp = await contracts();

			expect(await regExp.MatchRegExp('^(\\w|\\d)+\.(com|net|org)',
				"c2r.com/hey/there")).to.be.true;
			expect(await regExp.MatchRegExp('^http://(\\w|\\d)+\.(com|net|org)',
				"http://c2r.com/hey/there")).to.be.true;
		});

		it("can alternate", async function () {
			const regExp = await contracts();

			expect(await regExp.MatchRegExp("gay", "gay")).to.be.true;
			expect(await regExp.MatchRegExp("g(a|e)y", "gay")).to.be.true;
			expect(await regExp.MatchRegExp("gr(a|e)y", "grey")).to.be.true;
			expect(await regExp.MatchRegExp("gr(a|e)y", "groy")).to.be.false;
		});
	});
});

