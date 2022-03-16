import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const ERC1155 = await ethers.getContractFactory("MockERC1155");
	const erc1155 = await ERC1155.deploy();
	await erc1155.deployed();

	return erc1155;
}

describe.only("ERC1115", function () {
	it("deploy", async function () {
		contracts()
	});

	it("can mint single", async function () {
		const erc1155 = await contracts();
		const [owner, user] = await ethers.getSigners();
		await erc1155.mint(owner.address, 1, 10, []);

		expect(await erc1155.balanceOf(owner.address, 1)).to.eq(10);
		expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);

		// try to mint by a zero address
		await expect(erc1155.mint(ethers.constants.AddressZero, 1, 10, [])).to.be.revertedWith("422");
	});
	it("can mint in batches", async function () {
		const erc1155 = await contracts();
		const [owner, user] = await ethers.getSigners();

		const ids = toBigNumberArray([1, 2, 3]);
		const amounts = toBigNumberArray([10, 10, 10]);

		await erc1155.batchMint(owner.address, ids, amounts, []);

		// must ids and amount be arrays of the same length
		await expect(erc1155.batchMint(owner.address, ids, [], [])).to.be.reverted;
		// to can't be the zero address
		await expect(erc1155.batchMint("0x", ids, amounts, [])).to.be.reverted;

		expect(await erc1155.balanceOf(owner.address, 1)).to.eq(10);
		expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);
	});
	it("can burn", async function () {
		const erc1155 = await contracts();
		const [owner, user] = await ethers.getSigners();
		await erc1155.mint(owner.address, 1, 10, []);

		expect(await erc1155.balanceOf(owner.address, 1)).to.eq(10);
		expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);

		await erc1155.burn(owner.address, 1, 5);

		expect(await erc1155.balanceOf(owner.address, 1)).to.eq(5);
	});
	it("can burn in batches", async function () {
		const erc1155 = await contracts();
		const [owner, user] = await ethers.getSigners();

		const ids = toBigNumberArray([1, 2, 3]);
		const amounts = toBigNumberArray([10, 10, 10]);

		await erc1155.batchMint(owner.address, ids, amounts, []);

		await erc1155.batchBurn(owner.address, ids.slice(0, 1), amounts.slice(0, 1));

		expect(await erc1155.balanceOf(owner.address, 1)).to.eq(0);
		expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);

	});
	it("can get correct balance", async function () {

	});
	it("can get correct balance in batches", async function () {

	});
	it("can set approval", async function () {
		const erc1155 = await contracts();
		const [owner, user, user1] = await ethers.getSigners();

		const ids = toBigNumberArray([1, 2, 3]);
		const amounts = toBigNumberArray([10, 10, 10]);

		await erc1155.batchMint(owner.address, ids, amounts, []);

		await erc1155.setApprovalForAll(user.address, true);

		await erc1155.connect(user).safeBatchTransferFrom(owner.address, user1.address, ids, amounts, []);

		expect(await erc1155.balanceOf(owner.address, 1)).to.eq(0);
		expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);
		expect(await erc1155.balanceOf(user1.address, 1)).to.eq(10);
	});
	it("can transfer safely", async function () {
		const erc1155 = await contracts();
		const [owner, user, user2] = await ethers.getSigners();

		const ids = 1;
		const amounts = 10;

		await erc1155.mint(owner.address, ids, amounts, []);

		expect(await erc1155.balanceOf(owner.address, 1)).to.eq(10);
		expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);

		await erc1155.setApprovalForAll(owner.address, true);
		await erc1155.setApprovalForAll(user.address, true);

		await erc1155.safeTransferFrom(owner.address, user.address, ids, amounts, []);

		expect(await erc1155.balanceOf(owner.address, 1)).to.eq(0);
		expect(await erc1155.balanceOf(user.address, 1)).to.eq(10);

	});
	it("can transfer safely in batches", async function () {
		const erc1155 = await contracts();
		const [owner, user, user2] = await ethers.getSigners();

		const ids = toBigNumberArray([1, 2, 3]);
		const amounts = toBigNumberArray([10, 10, 10]);

		await erc1155.batchMint(owner.address, ids, amounts, []);

		expect(await erc1155.balanceOf(owner.address, 1)).to.eq(10);
		expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);

		await erc1155.safeBatchTransferFrom(owner.address, user.address, ids, amounts, []);

		expect(await erc1155.balanceOf(owner.address, 1)).to.eq(0);
		expect(await erc1155.balanceOf(user.address, 1)).to.eq(10);

		await expect(erc1155.safeBatchTransferFrom(owner.address, user.address, ids, amounts, [])).
			to.be.reverted;

	});
});

function toBigNumberArray(arr: any) {
	return arr.map((i: number) => ethers.BigNumber.from(i));
}

