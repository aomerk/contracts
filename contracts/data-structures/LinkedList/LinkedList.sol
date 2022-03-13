// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.3;

/// @notice implementation of linked list data structure.
/// @dev not cost efficient.
contract LinkedList {
    struct Node {
        uint256 id;
        uint256 next;
        uint256 value;
    }

    mapping(uint256 => Node) public _list;

    uint256 public head;
    uint256 public idCounter;

    constructor() {
        head = 0;
        idCounter = 1;
    }

    /// @notice given an id of a node, returns the value of the node.
    /// @param _id if not exists, returns 0.
    function get(uint256 _id) public view returns (uint256) {
        return _list[_id].value;
    }

    /// @dev creates and adds a new node to the list as head.
    /// @param _value value of the new node.
    function addHead(uint256 _value) public {
        Node memory newNode = _createNode(_value);

        _link(newNode.id, head);

        head = newNode.id;
    }

    /// @dev creates and adds a new node to the list as tail.
    /// @param _value value of the new node.
    function addTail(uint256 _value) public {
        Node memory newNode = _createNode(_value);

        if (head == 0) {
            head = newNode.id;
        } else {
            _link(_list[findTail()].id, newNode.id);
        }
    }

    /// @dev returns the id of the tail node.
    function findTail() public view returns (uint256) {
        Node memory currNode = _list[head];

        while (currNode.next != 0) {
            currNode = _list[currNode.next];
        }

        return currNode.id;
    }

    /// @dev removes a node from the list. When queried, value returns 0.
    function remove(uint256 _id) public {
        Node memory node = _list[_id];

        if (head == _id) {
            head = node.next;
        } else {
            uint256 prevId = _findPreviousItem(_id);
            _link(prevId, node.next);
        }

        delete _list[_id];
    }

    /// @dev creates a link from prev->next.
    function _link(uint256 _prevId, uint256 _nextId) internal {
        _list[_prevId].next = _nextId;
    }

    /// @dev creates a node with value and inserts before the node with given id.
    /// @param _value value of the new node.
    /// @param _nextId id of the next node.
    function insertBefore(uint256 _nextId, uint256 _value) public {
        Node memory newNode = _createNode(_value);
        _insertBefore(_nextId, newNode.id);
    }

    /// @dev creates a node with value and inserts after the node with given id.
    function insertAfter(uint256 _prevId, uint256 _value) public {
        Node memory newNode = _createNode(_value);
        _insertAfter(_prevId, newNode.id);
    }

    function _insertAfter(uint256 _prevId, uint256 _newId) internal {
        _link(_newId, _list[_prevId].next);
        _link(_prevId, _newId);
    }

    function _insertBefore(uint256 _nextId, uint256 _newId) internal {
        if (_nextId == head) {
            head = _newId;

            return;
        }
        uint256 prevId = _findPreviousItem(_nextId);
        _link(_newId, _nextId);
        _link(prevId, _newId);
    }

    function _findPreviousItem(uint256 _id) internal view returns (uint256) {
        uint256 currentId = head;

        while (currentId != 0) {
            if (_list[currentId].next == _id) {
                return currentId;
            }

            currentId = _list[currentId].next;
        }

        return 0;
    }

    function _createNode(uint256 _value) internal returns (Node memory) {
        Node memory newNode = Node(idCounter, 0, _value);

        _list[idCounter] = newNode;

        idCounter++;

        return newNode;
    }
}
