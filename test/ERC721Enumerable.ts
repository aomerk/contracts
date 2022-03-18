import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const ERC721 = await ethers.getContractFactory("MockERC721Enumerable");
	const erc721 = await ERC721.deploy("x");
	await erc721.deployed();

	return erc721;
}
describe("ERC721Enumerable", function () {
	it("deploy", async function () {
		contracts()
	});
	it("balanceOf", async function () {
		const erc721 = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.balanceOf(owner.address);
		await erc721.balanceOf(userAddress1.address);
		await erc721.balanceOf(userAddress2.address);
	});
	it("totalSupply", async function () {
		const erc721 = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.mint(owner.address, 1);
		await erc721.mint(owner.address, 2);
		await erc721.mint(owner.address, 3);
		await erc721.burn(1);

		expect(await erc721.totalSupply()).to.eq(2);
	});
	it("tokenOfOwnerByIndex", async function () {
		const erc721 = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.mint(owner.address, 1);
		await erc721.mint(owner.address, 2);
		await erc721.mint(owner.address, 3);
		await erc721.mint(owner.address, 4);
		await erc721.burn(4);
		expect(await erc721.tokenOfOwnerByIndex(owner.address, 1)).to.eq(2);
	});

	it("tokenByIndex", async function () {
		const erc721 = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.mint(owner.address, 1);
		await erc721.mint(owner.address, 2);
		await erc721.mint(owner.address, 3);
		await erc721.mint(owner.address, 4);
		await erc721.burn(4);
		expect(await erc721.tokenByIndex(2)).to.eq(3);
	});
});
