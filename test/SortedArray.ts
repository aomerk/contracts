import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts(arr: any) {
	const SortedArray = await ethers.getContractFactory("SortedArray");
	const sortedArray = await SortedArray.deploy(arr);
	await sortedArray.deployed();

	return sortedArray;
}
describe("Sorted Array", function () {
	it("deploy", async function () {
		contracts([])
	});
	it("insert", async function () {
		let arr = toBigNumberArray(Array.from({ length: 100 }, (_, i) => i + 1))
		const sortedArray = await contracts(arr)

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();
		for (let i = 5; i >= 1; i--) {
			await sortedArray.insert(i + 4490);
		}
	});

	it("remove all", async function () {
		let arr = [1, 2, 3, 3, 3, 4, 5, 6]
		let bigArr = toBigNumberArray(arr)
		const sortedArray = await contracts(bigArr)

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await sortedArray.removeValues(3, 0);
		const res = await sortedArray.getLength();

		let data = await sortedArray.getAll()

		expect(res).to.be.equal(arr.length - 3);
	});

	it("find smallest bigger item", async function () {
		const sortedArray = await contracts([])

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		for (let i = 1; i <= 10; i += 2) {
			await sortedArray.insert(i);
		}

		let idx = await sortedArray.findSmallestBiggerIndex(4);
		let value = await sortedArray.get(idx);
	});
	it("find biggest smaller item", async function () {
		const sortedArray = await contracts([])

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		for (let i = 1; i <= 10; i += 2) {
			await sortedArray.insert(i);
		}

		let idx = await sortedArray.findBiggestSmallerIndex(4);
		let value = await sortedArray.get(idx);
	});
	it("get", async function () {
		const sortedArray = await contracts([])

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		for (let i = 5; i >= 1; i--) {
			await sortedArray.insert(i);
		}

		for (let i = 1; i <= 5; i++) {
			let res = await sortedArray.find(i);
		}

	});
});

function toBigNumberArray(arr: any) {
	return arr.map((i: number) => ethers.BigNumber.from(i));
}
