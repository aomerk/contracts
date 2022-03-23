import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const HuffmanCoding = await ethers.getContractFactory("HuffmanCoding", {

	});
	const huffmanCoding = await HuffmanCoding.deploy();
	await huffmanCoding.deployed();

	return huffmanCoding;
}

describe("HuffmanCoding", function () {
	it("deploy", async function () {
		contracts()
	});
	describe("match", function () {
		it("can match n", async function () {
			const huffmanCoding = await contracts();

			const resp = await huffmanCoding.Encode("abcd")
			console.log(resp)
		});
	});
});

