import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const ERC721 = await ethers.getContractFactory("MockERC721");
	const erc721 = await ERC721.deploy("x");
	await erc721.deployed();

	return erc721;
}
describe.only("ERC721", function () {
	it("deploy", async function () {
		contracts()
	});
)};
