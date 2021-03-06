import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const ERC20 = await ethers.getContractFactory("MockERC20");
	const erc20 = await ERC20.deploy("xaaaaaveee", "ss", 8);
	await erc20.deployed();

	return erc20;
}
const MaxUint256 = (/*#__PURE__*/ethers.BigNumber.from("0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"));
describe.only("ERC20", function () {
	it("deploy", async function () {
		await contracts()
	});
	it("mint", async function () {
		const erc20 = await contracts();
		const [owner, user] = await ethers.getSigners();
		await erc20.mint(owner.address, 120)

		expect(await erc20.totalSupply()).to.equal(120);

		const balance = await erc20.balanceOf(owner.address)
		expect(balance.toNumber()).to.equal(120)
	});
	it("burn", async function () {
		const erc20 = await contracts();
		const [owner, user] = await ethers.getSigners();
		await erc20.mint(owner.address, 120)

		let balance = await erc20.balanceOf(owner.address)
		expect(balance.toNumber()).to.equal(120)

		await erc20.burn(owner.address, 10)

		balance = await erc20.balanceOf(owner.address)
		expect(balance.toNumber()).to.equal(110)
	});
	describe("transfer", async function () {
		it("can ", async function () {
			const erc20 = await contracts();
			const [owner, user] = await ethers.getSigners();
			await erc20.mint(owner.address, 120)

			let balance = await erc20.balanceOf(owner.address)
			expect(balance.toNumber()).to.equal(120)

			await erc20.transfer(user.address, 10);

			balance = await erc20.balanceOf(owner.address)
			let userBalance = await erc20.balanceOf(user.address)

			expect(balance.toNumber()).to.equal(110);
			expect(userBalance.toNumber()).to.equal(10);
		});
		it("caller doesn't own must revert", async function () {
			const erc20 = await contracts();
			const [owner, user] = await ethers.getSigners();
			await erc20.mint(owner.address, 120)

			let balance = await erc20.balanceOf(owner.address)
			expect(balance.toNumber()).to.equal(120)

			await expect(
				erc20.connect(user).transfer(user.address, 10)
			).to.be.reverted;
			balance = await erc20.balanceOf(owner.address)
			let userBalance = await erc20.balanceOf(user.address)

			expect(balance.toNumber()).to.equal(120);
			expect(userBalance.toNumber()).to.equal(0);
		});
	});
	describe("transferFrom", async function () {
		it("reverts on unauth ", async function () {
			const erc20 = await contracts();
			const [owner, user] = await ethers.getSigners();

			await erc20.mint(owner.address, 120)

			await expect(erc20.connect(user).transferFrom(owner.address, user.address, 10)).to.be.reverted;

			let balance = await erc20.balanceOf(owner.address)
			let userBalance = await erc20.balanceOf(user.address)

			expect(balance.toNumber()).to.equal(120);
			expect(userBalance.toNumber()).to.equal(0);
		});
		it("allows transfer on behalf of ", async function () {
			const erc20 = await contracts();
			const [owner, user] = await ethers.getSigners();

			await erc20.mint(owner.address, 120)
			await erc20.approve(user.address, 10);

			await erc20.connect(user).transferFrom(owner.address, user.address, 10)

			let balance = await erc20.balanceOf(owner.address)
			let userBalance = await erc20.balanceOf(user.address)

			expect(balance.toNumber()).to.equal(110);
			expect(userBalance.toNumber()).to.equal(10);
		});
		it("from == sender, not approved must revert", async function () {
			const erc20 = await contracts();
			const [owner, user] = await ethers.getSigners();

			await erc20.mint(owner.address, 120)

			await erc20.approve(user.address, 10);

			await expect(erc20.connect(owner).
				transferFrom(owner.address, user.address, 10)).to.be.reverted;

			let balance = await erc20.balanceOf(owner.address)
			let userBalance = await erc20.balanceOf(user.address)

			expect(balance.toNumber()).to.equal(120);
			expect(userBalance.toNumber()).to.equal(0);
		});
		it("from == sender,	approved", async function () {
			const erc20 = await contracts();
			const [owner, user] = await ethers.getSigners();

			await erc20.mint(owner.address, 120)
			await erc20.approve(owner.address, 10);

			await erc20.connect(owner).transferFrom(owner.address, user.address, 10)

			let balance = await erc20.balanceOf(owner.address)
			let userBalance = await erc20.balanceOf(user.address)

			expect(balance.toNumber()).to.equal(110);
			expect(userBalance.toNumber()).to.equal(10);
		});
		it("from != sender,	not approved must revert", async function () {
			const erc20 = await contracts();
			const [owner, user] = await ethers.getSigners();

			await erc20.mint(owner.address, 120)

			await expect(
				erc20.connect(user).transferFrom(owner.address, user.address, 10)
			).to.be.reverted;

			let balance = await erc20.balanceOf(owner.address)
			let userBalance = await erc20.balanceOf(user.address)

			expect(balance.toNumber()).to.equal(120);
			expect(userBalance.toNumber()).to.equal(0);
		});
		it("from != sender,	approved", async function () {
			const erc20 = await contracts();
			const [owner, user] = await ethers.getSigners();

			await erc20.mint(owner.address, 120)
			await erc20.approve(user.address, 10);

			await erc20.connect(user).transferFrom(owner.address, user.address, 10)

			let balance = await erc20.balanceOf(owner.address)
			let userBalance = await erc20.balanceOf(user.address)

			expect(balance.toNumber()).to.equal(110);
			expect(userBalance.toNumber()).to.equal(10);
		});
		it("from != sender,	approved but spends too much must revert", async function () {
			const erc20 = await contracts();
			const [owner, user] = await ethers.getSigners();

			await erc20.mint(owner.address, 120)
			await erc20.approve(user.address, 10);

			await expect(
				erc20.connect(user).transferFrom(owner.address, user.address, 20)
			).to.be.reverted;

			let balance = await erc20.balanceOf(owner.address)
			let userBalance = await erc20.balanceOf(user.address)

			expect(balance.toNumber()).to.equal(120);
			expect(userBalance.toNumber()).to.equal(0);
		});
	});
	it("approve", async function () {
		const erc20 = await contracts();
		const [owner, user] = await ethers.getSigners();
		await erc20.mint(owner.address, 120)

		await erc20.approve(user.address, 10);
		let balance = await erc20.balanceOf(owner.address)

		expect(balance.toNumber()).to.equal(120)

		await erc20.connect(user).transferFrom(owner.address, user.address, 10);

		balance = await erc20.balanceOf(owner.address)
		let userBalance = await erc20.balanceOf(user.address)

		expect(balance.toNumber()).to.equal(110);
		expect(userBalance.toNumber()).to.equal(10);
	});
	// it("permit", async function () {
	// 	const erc20 = await contracts();

	// 	const [owner, user] = await ethers.getSigners();

	// 	let deadline = (await ethers.provider.getBlock('latest')).timestamp;
	// 	deadline += 2;


	// 	const value = '1000000000000000000';
	// 	let spender = user.address;

	// 	const result = await signERC2612Permit(provider, erc20.address, defaultSender, spender, value);

	// 	await erc20.connect(owner).permit(defaultSender, spender, value, result.deadline, result.v, result.r, result.s);
	// });
});


