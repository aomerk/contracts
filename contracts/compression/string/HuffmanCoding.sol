// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.0;

struct Node {
    uint256 left;
    uint256 right;
    uint8 value;
    uint8 char;
}

function sliceHeap(
    Node[] memory nodes,
    uint256 start,
    uint256 end
) pure returns (Node[] memory) {
    Node[] memory result = new Node[](end - start + 1);
    for (uint256 i = start; i < end; i++) {
        result[i - start] = nodes[i];
    }

    return result;
}

function addToHeap(Node[] memory nodes, Node memory node)
    pure
    returns (Node[] memory)
{
    uint256 length = nodes.length + 1;

    Node[] memory result = new Node[](length);
    for (uint256 i = 0; i < length - 1; i++) {
        result[i] = nodes[i];
    }
    result[length - 1] = node;

    return result;
}

uint8 constant MAX_CHAR = (2**8) - 1;

function createMinHead(uint8[] memory characters, uint8[] memory frequencies)
    public
    pure
    returns (Node[] memory)
{
    Node[] memory heap = new Node[](characters.length);

    for (uint256 i = 0; i < characters.length; i++) {
        Node memory node;
        node.char = characters[i];
        node.value = frequencies[i];
        heap[i] = node;
    }

    Node memory rootNode = Node(0, 0, 0, 0);
    heap = _sort(heap);

    while (heap.length > 1) {
        // extract first min
        Node memory node1 = heap[0];
        heap = sliceHeap(heap, 1, heap.length);

        // extract second min
        Node memory node2 = heap[0];
        heap = sliceHeap(heap, 1, heap.length);

        // create new node
        Node memory newNode = Node(0, 0, node1.value + node2.value, 0);
        newNode.left = node1.left;
        newNode.right = node2.right;

        // insert new node into heap
        rootNode = newNode;

        heap = addToHeap(heap, newNode);
        heap = _sort(heap);
    }

    return heap;
}

function extractAlphabet(uint8[] memory input)
    public
    pure
    returns (uint8[] memory)
{
    uint8[] memory alphabet = new uint8[](MAX_CHAR);
    uint256 i = 0;

    for (uint256 j = 0; j < input.length; j++) {
        if (input[j] < MAX_CHAR) {
            alphabet[input[j]] = 1;
        }
    }

    for (uint256 j = 0; j < MAX_CHAR; j++) {
        if (alphabet[j] == 1) {
            i++;
        }
    }

    uint8[] memory result = new uint8[](i);
    i = 0;
    for (uint256 j = 0; j < MAX_CHAR; j++) {
        if (alphabet[j] == 1) {
            result[i] = input[i];
            i++;
        }
    }
    return result;
}

function extractFrequencies(uint8[] memory input)
    public
    pure
    returns (uint8[] memory)
{
    uint8[] memory _frequencies = new uint8[](256);
    uint256 uniqueValueCount;

    for (uint256 i = 0; i < input.length; i++) {
        if (input[i] == 0) {
            uniqueValueCount++;
        }

        _frequencies[input[i]]++;
    }

    uint8[] memory result = new uint8[](uniqueValueCount);

    for (uint256 i = 0; i < _frequencies.length; i++) {
        if (_frequencies[i] != 0) {
            result[uniqueValueCount] = _frequencies[i];
        }
    }

    return result;
}

function _sort(Node[] memory data) pure returns (Node[] memory) {
    _quickSort(data, int256(0), int256(data.length - 1));
    return data;
}

function _quickSort(
    Node[] memory arr,
    int256 left,
    int256 right
) pure {
    int256 i = left;
    int256 j = right;
    if (i == j) return;

    Node memory pivot = arr[uint256(left + (right - left) / 2)];

    while (i <= j) {
        while (arr[uint256(i)].value < pivot.value) i++;
        while (pivot.value < arr[uint256(j)].value) j--;
        if (i <= j) {
            (arr[uint256(i)], arr[uint256(j)]) = (
                arr[uint256(j)],
                arr[uint256(i)]
            );
            i++;
            j--;
        }
    }
    if (left < j) _quickSort(arr, left, j);
    if (i < right) _quickSort(arr, i, right);
}

contract HuffmanCoding {
    function Encode(string memory input) public pure returns (string memory) {}
}
