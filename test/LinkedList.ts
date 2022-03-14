import { expect } from "chai";
import { ethers } from "hardhat";

async function contracts() {
	const LinkedList = await ethers.getContractFactory("LinkedList");
	const linkedList = await LinkedList.deploy();
	await linkedList.deployed();

	return linkedList;
}
describe("Linked List", function () {
	it("deploy", async function () {
		contracts()
	});
	it("insert", async function () {
		let arr = toBigNumberArray(Array.from({ length: 100 }, (_, i) => i + 1))
		const linkedList = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();
		for (let i = 5; i >= 1; i--) {
			await linkedList.addHead(i + 4490);
		}

		// let idx = await linkedList.get(4);
		// console.log("Found item 4 at", idx);
	});
	it("head", async function () {
		const linkedList = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();
		for (let i = 5; i >= 1; i--) {
			await linkedList.addHead(i);
		}
		expect(await linkedList.get(1)).to.be.equal(5);
	});
	it("add head", async function () {
		const linkedList = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		for (let i = 5; i >= 1; i--) {
			await linkedList.addHead(i);
		}

		for (let i = 1; i <= 5; i++) {
			let res = await linkedList.get(i);
		}

	});
	it("add tail", async function () {
		const linkedList = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		for (let i = 5; i >= 1; i--) {
			await linkedList.addTail(i);
		}

		for (let i = 1; i <= 5; i++) {
			let res = await linkedList.get(i);
		}

	});
	it("insert after", async function () {
		const linkedList = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();
		await linkedList.addHead(4);
		await linkedList.insertAfter(1, 12);


		expect(await linkedList.get(2)).to.be.equal(12);
	});
	it("insert after", async function () {
		const linkedList = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();
		await linkedList.addHead(4);
		await linkedList.insertAfter(1, 12);
		await linkedList.insertBefore(2, 21);


		expect(await linkedList.get(3)).to.be.equal(21);
	});

	it("find tail", async function () {
		const linkedList = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();

		await linkedList.addHead(4);
		await linkedList.insertAfter(1, 12);

		const tailId = await linkedList.findTail();

		expect(await linkedList.get(tailId)).to.be.equal(12);
	});
	it("remove item", async function () {
		const linkedList = await contracts()

		const [owner, userAddress1, userAddress2] = await ethers.getSigners();
		await linkedList.addHead(4);
		await linkedList.insertAfter(1, 12);


		await linkedList.remove(2);
		let item2 = await linkedList.get(2);
	});
});

function toBigNumberArray(arr: any) {
	return arr.map((i: number) => ethers.BigNumber.from(i));
}
