// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract GenealogyERC20 is ERC20 {

    struct Person {
        uint256 id;
        string name;
        uint256 birthDate;
        address addedBy;
        uint256 parentId;
        uint256[] children;    // Liste des enfants
        uint256[] siblings;    // Liste des frères et sœurs
        address spouse;        // Adresse du conjoint/mari
    }

    mapping(uint256 => Person) public people;
    mapping(address => uint256) public addressToPersonId;  // Associe les adresses aux personnes
    uint256 public peopleCount;

    event PersonAdded(uint256 id, string name, uint256 parentId, address addedBy);
    event Marriage(uint256 personId1, uint256 personId2);
    event SiblingAdded(uint256 personId1, uint256 personId2);
    event ChildAdded(uint256 parentId, uint256 childId);

    constructor() ERC20("GenealogyToken", "GEN") {
        peopleCount = 0;
    }

    // Ajouter une personne
    function addPerson(string memory _name, uint256 _birthDate, uint256 _parentId) public {
        peopleCount++;
        uint256 newPersonId = peopleCount;

        // Créer une nouvelle personne
        people[newPersonId] = Person({
            id: newPersonId,
            name: _name,
            birthDate: _birthDate,
            addedBy: msg.sender,
            parentId: _parentId,
            children: new uint256 ,
            siblings: new uint256 ,
            spouse: address(0)
        });

        // Associe l'adresse à la personne
        addressToPersonId[msg.sender] = newPersonId;

        // Si un parent est défini, ajouter l'enfant au parent
        if (_parentId != 0) {
            people[_parentId].children.push(newPersonId);
            emit ChildAdded(_parentId, newPersonId);
        }

        // Émettre l'événement de création
        emit PersonAdded(newPersonId, _name, _parentId, msg.sender);
        
        // Mint ERC-20 tokens à l'utilisateur représentant la "personne ajoutée"
        _mint(msg.sender, 1 * 10**18);
    }

    // Ajouter un mariage entre deux personnes
    function marry(uint256 _personId1, uint256 _personId2) public {
        require(people[_personId1].spouse == address(0), "Person already married");
        require(people[_personId2].spouse == address(0), "Person already married");

        people[_personId1].spouse = people[_personId2].addedBy;
        people[_personId2].spouse = people[_personId1].addedBy;

        emit Marriage(_personId1, _personId2);
    }

    // Ajouter un frère ou une sœur
    function addSibling(uint256 _personId1, uint256 _personId2) public {
        people[_personId1].siblings.push(_personId2);
        people[_personId2].siblings.push(_personId1);

        emit SiblingAdded(_personId1, _personId2);
    }

    // Obtenir les informations sur une personne
    function getPerson(uint256 _id) public view returns (Person memory) {
        return people[_id];
    }

    // Obtenir les enfants d'une personne
    function getChildren(uint256 _parentId) public view returns (uint256[] memory) {
        return people[_parentId].children;
    }

    // Obtenir les frères et sœurs d'une personne
    function getSiblings(uint256 _personId) public view returns (uint256[] memory) {
        return people[_personId].siblings;
    }

    // Obtenir le conjoint d'une personne
    function getSpouse(uint256 _personId) public view returns (address) {
        return people[_personId].spouse;
    }
}