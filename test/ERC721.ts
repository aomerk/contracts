import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const ERC721 = await ethers.getContractFactory("MockERC721");
	const erc721 = await ERC721.deploy("x");
	await erc721.deployed();

	return erc721;
}
describe("ERC721", function () {
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
	it("transferFrom", async function () {
		const erc721 = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.mint(owner.address, 1);
		await erc721.transferFrom(owner.address, userAddress1.address, 1);
	});
	it("safeTransferFrom", async function () {
		const erc721 = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.mint(owner.address, 1);
		await erc721["safeTransferFrom(address,address,uint256)"](owner.address, userAddress1.address, 1);
	});
	it("approve", async function () {
		const erc721 = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.mint(owner.address, 1);
		await erc721.transferFrom(owner.address, userAddress1.address, 1);
		await erc721.connect(userAddress1).approve(owner.address, 1);
	});
	it("burn", async function () {
		const erc721 = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.mint(owner.address, 1);
		await erc721.burn(1);
		expect(await erc721.burn(1)).to.be.reverted("ERR_TOKEN_NOT_EXISTS");

		expect(await erc721.balanceOf(owner.address)).to.eq(0);
	});
	it("mint", async function () {
		const erc721 = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await erc721.mint(owner.address, 1);
	});
	it("mint and burn bunch of stuff", async function () {
		const erc721 = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();
		let items = 200;
		for (let tokenId = 0; tokenId < items; tokenId++) {
			await erc721.mint(owner.address, tokenId);
			await erc721.burn(tokenId);
		}
	});
});
