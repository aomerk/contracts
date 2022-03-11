import { expect } from "chai";
import { ethers } from "hardhat";

describe("ERC721", function () {
	it("deploy", async function () {
		const ERC721 = await ethers.getContractFactory("ExampleERC721");
		const erc721 = await ERC721.deploy();
		await erc721.deployed();
	});
	it("balanceOf", async function () {
		const ERC721 = await ethers.getContractFactory("ExampleERC721");
		const erc721 = await ERC721.deploy();
		await erc721.deployed();

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.balanceOf(owner.address);
		await erc721.balanceOf(userAddress1.address);
		await erc721.balanceOf(userAddress2.address);
	});
	it("mint", async function () {
		const ERC721 = await ethers.getContractFactory("ExampleERC721");
		const erc721 = await ERC721.deploy();
		await erc721.deployed();

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.createToken(1);
	});
});
