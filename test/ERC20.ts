import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const ERC20 = await ethers.getContractFactory("MockERC20");
	const erc20 = await ERC20.deploy("xaaaaaveee", "ss", 8);
	await erc20.deployed();

	return erc20;
}
describe.only("ERC20", function () {
	it("deploy", async function () {
		await contracts()
	});
	it("mint", async function () {
		const erc20 = await contracts();
		const [owner, user] = await ethers.getSigners();
		await erc20.mint(owner.address, 120)

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
	it("transfer", async function () {
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
});
