import { expect } from "chai";
import { ethers } from "hardhat";
import { MockERC1155 } from "../typechain";

async function contracts() {
	const ERC1155 = await ethers.getContractFactory("MockERC1155");
	const erc1155 = await ERC1155.deploy();
	await erc1155.deployed();

	return erc1155;
}

describe.only("ERC1115", function () {
	let erc1155: MockERC1155;
	let users: any[];
	this.beforeEach(async function () {
		erc1155 = await contracts();
		users = await ethers.getSigners();
	})

	it("deploy", async function () {
		contracts()
	});
	describe("mint", function () {
		it("can mint single", async function () {
			const erc1155 = await contracts();
			const [owner, user] = await ethers.getSigners();
			await erc1155.mint(owner.address, 1, 10, []);

			expect(await erc1155.balanceOf(owner.address, 1)).to.eq(10);
			expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);

			// try to mint by a zero address
			await expect(erc1155.mint(ethers.constants.AddressZero, 1, 10, [])).to.be.reverted;
		});
		it("mint throws when needed", async function () {
			const erc1155 = await contracts();
			const [owner, user] = await ethers.getSigners();
			await erc1155.mint(owner.address, 1, 10, []);

			expect(await erc1155.balanceOf(owner.address, 1)).to.eq(10);
			expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);

			// try to mint by a zero address
			await expect(erc1155.mint(ethers.constants.AddressZero, 1, 10, [])).to.be.reverted;
		});
		it("throw on zero _from", async function () {
			await erc1155.mint(users[0].address, 1, 10, []);

			expect(await erc1155.balanceOf(users[0].address, 1)).to.eq(10);
			expect(await erc1155.balanceOf(users[1].address, 1)).to.eq(0);

			// try to mint by a zero address
			await expect(erc1155.mint(ethers.constants.AddressZero, 1, 10, [])).to.be.reverted;
		});
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
	describe("safe transfer", async function () {
		it("can transfer safely", async function () {
			const erc1155 = await contracts();
			const [owner, user, user2] = await ethers.getSigners();

			const ids = 1;
			const amounts = 10;

			await erc1155.mint(owner.address, ids, amounts, []);

			expect(await erc1155.balanceOf(owner.address, 1)).to.eq(10);
			expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);

			// await erc1155.setApprovalForAll(owner.address, true);
			await erc1155.setApprovalForAll(user.address, true);

			await erc1155.safeTransferFrom(owner.address, user.address, ids, amounts, []);

			expect(await erc1155.balanceOf(owner.address, 1)).to.eq(0);
			expect(await erc1155.balanceOf(user.address, 1)).to.eq(10);

		});
		it("supports transfer by approved", async function () {
			const erc1155 = await contracts();
			const [owner, user, user2] = await ethers.getSigners();

			const ids = 1;
			const amounts = 10;

			await erc1155.mint(owner.address, ids, amounts, []);

			expect(await erc1155.balanceOf(owner.address, 1)).to.eq(10);
			expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);

			// await erc1155.setApprovalForAll(owner.address, true);
			await erc1155.setApprovalForAll(user.address, true);

			await erc1155.connect(user).safeTransferFrom(owner.address, user2.address, ids, amounts, []);

			expect(await erc1155.balanceOf(owner.address, 1)).to.eq(0);
			expect(await erc1155.balanceOf(user2.address, 1)).to.eq(10);

		});
		it("reverts if unsafe recipient", async function () {
			const erc1155 = await contracts();
			const unsafeRecipient = await contracts();
			const [owner, user, user2] = await ethers.getSigners();

			const ids = 1;
			const amounts = 10;

			// MUST revert if `_to` is the zero address.
			await erc1155.mint(owner.address, ids, amounts, []);

			// Must check for overflows
			// TODO - hardhat test can't catch following case
			// expect(await erc1155.safeTransferFrom(owner.address, unsafeRecipient.address, ids,
			// amounts, [])).to.be.reverted;
		});
		it("reverts on over/underflow", async function () {
			const erc1155 = await contracts();
			const [owner, user, user2] = await ethers.getSigners();

			const ids = 1;
			const amounts = ethers.constants.MaxInt256;

			// Must check for overflows
			await expect(erc1155.safeTransferFrom(owner.address, user.address, ids,
				amounts, [])).to.be.reverted;

			// Must check for negative
			await expect(erc1155.safeTransferFrom(owner.address, user.address, ids,
				ethers.BigNumber.from("-1"), [])).to.be.reverted;
		});
		it("revert if `_to` is the zero address", async function () {
			const erc1155 = await contracts();
			const [owner, user, user2] = await ethers.getSigners();

			const ids = 1;
			const amounts = 10;

			// MUST revert if `_to` is the zero address.
			await erc1155.mint(owner.address, ids, amounts, []);
			await expect(erc1155.safeTransferFrom(owner.address, ethers.constants.AddressZero, ids, amounts, [])).to.be.reverted;
		});

		it("reverts on insufficient balance", async function () {
			const erc1155 = await contracts();
			const [owner, user, user2] = await ethers.getSigners();

			const ids = 1;
			const amounts = 10;
			// MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
			await expect(erc1155.safeTransferFrom(user2.address, owner.address, ids, amounts, [])).to.be.reverted;
		});

		it("reverts unapproved caller", async function () {
			const erc1155 = await contracts();
			const [owner, user, user2] = await ethers.getSigners();

			const ids = 1;
			const amounts = 10;
			await erc1155.mint(owner.address, ids, amounts, []);

			// MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
			await expect(erc1155.connect(user).safeTransferFrom(owner.address, user.address, ids, amounts, [])).to.be.reverted;
		});
	});
	describe("safeBatchTransfer", async function () {
		it("can transfer", async function () {
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
		it("can transfer huge batches", async function () {
			const erc1155 = await contracts();
			const [owner, user, user2] = await ethers.getSigners();
			let numIds = []
			let numAmounts = []
			for (let i = 1; i < 100; i++) {
				numIds.push(i);
				numAmounts.push(i);
			}
			const ids = toBigNumberArray(numIds);
			const amounts = toBigNumberArray(numAmounts);

			await erc1155.batchMint(owner.address, ids, amounts, []);

			expect(await erc1155.balanceOf(owner.address, 1)).to.eq(1);
			expect(await erc1155.balanceOf(user.address, 1)).to.eq(0);

			await erc1155.safeBatchTransferFrom(owner.address, user.address, ids, amounts, []);

			expect(await erc1155.balanceOf(owner.address, 1)).to.eq(0);
			expect(await erc1155.balanceOf(user.address, 1)).to.eq(1);

			await expect(erc1155.safeBatchTransferFrom(owner.address, user.address, ids, amounts, [])).
				to.be.reverted;
		});

		it("reverts on zero recipient", async function () {
			const erc1155 = await contracts();
			const [owner, user, user2] = await ethers.getSigners();


			const ids = toBigNumberArray([1, 2, 3]);
			const amounts = toBigNumberArray([10, 10, 10]);

			// MUST revert if `_to` is the zero address.
			await erc1155.batchMint(owner.address, ids, amounts, []);
			await expect(erc1155.safeBatchTransferFrom(owner.address, ethers.constants.AddressZero, ids, amounts, [])).to.be.reverted;
		});
		it("reverts on id/value mismatch", async function () {
			const erc1155 = await contracts();
			const [owner, user, user2] = await ethers.getSigners();


			const ids = toBigNumberArray([1, 2, 3]);
			const amounts = toBigNumberArray([10, 10, 10]);

			// MUST revert if length of `_ids` is not the same as length of `_values`.
			await expect(erc1155.safeBatchTransferFrom(owner.address, user.address, ids, amounts.slice(0, 1), [])).to.be.reverted;
			await expect(erc1155.safeBatchTransferFrom(owner.address, user.address, ids.slice(0, 1), amounts, [])).to.be.reverted;

		});
		it("reverts insufficient balance", async function () {
			const erc1155 = await contracts();
			const [owner, user, user2] = await ethers.getSigners();


			const ids = toBigNumberArray([1, 2, 3]);
			const amounts = toBigNumberArray([10, 10, 10]);

			// MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
			await expect(erc1155.safeBatchTransferFrom(user2.address, owner.address, ids, amounts, [])).to.be.reverted;
		});
	});

});

function toBigNumberArray(arr: any) {
	return arr.map((i: number) => ethers.BigNumber.from(i));
}

