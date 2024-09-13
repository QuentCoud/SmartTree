// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GenealogyERC20 is ERC20 {

    struct Person {
        uint256 id;
        string name;
        string firstName;
        address parent1;
        address parent2;
        address spouse;
        address[] children;
        address[] siblings;
    }

    mapping(address => Person) public people;


    uint256 public peopleCount;

    constructor() ERC20("SmartTree", "GEN") {
        peopleCount = 0;
    }

    // Ajouter une personne avec ses relations (parents, conjoint, frères et sœurs)
    function addPerson(
        string memory _name,
        string memory _firstName,
        address _parent1,
        address _parent2,
        address _spouse,
        address[] memory _siblings,
        address[] memory _children
    ) public {
        require(people[msg.sender].id == 0, "Person already exists"); // Vérifie si la personne existe déjà

        peopleCount++;

        people[msg.sender] = Person({
            id: peopleCount,
            name: _name,
            firstName: _firstName,
            parent1: _parent1,
            parent2: _parent2,
            spouse: _spouse,
            siblings: _siblings,
            children: _children
        });

        if (_parent1 != address(0)) {
            people[_parent1].children.push(msg.sender);
        }
        if (_parent2 != address(0)) {
            people[_parent2].children.push(msg.sender);
        }

        _mint(msg.sender, 1 * 10**18);
    }

    function getParents(address _person) public view returns (address, address) {
        require(people[_person].id != 0, "Person does not exist");
        return (people[_person].parent1, people[_person].parent2);
    }

    function getChildren(address _person) public view returns (address[] memory) {
        require(people[_person].id != 0, "Person does not exist");
        return people[_person].children;
    }

    

}