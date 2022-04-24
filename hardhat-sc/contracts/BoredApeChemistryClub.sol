// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BoredApeChemistryClub is ERC1155, Ownable {
    using Strings for uint256;

    address private mutationContract;
    string private baseURI;

    mapping(uint256 => bool) public validSerumTypes;

    event SetBaseURI(string indexed _baseURI);

    constructor(string memory _baseURI) ERC1155(_baseURI) {
        baseURI = _baseURI;
        validSerumTypes[0] = true;
        validSerumTypes[10] = true;
        validSerumTypes[100] = true;
        emit SetBaseURI(_baseURI);
    }

    function mintBatch(uint256[] memory ids, uint256[] memory amounts)
        external
        onlyOwner
    {
        _mintBatch(owner(), ids, amounts, "");
    }

    function setMutationContractAddress(address mutationContractAddress)
        external
        onlyOwner
    {
        mutationContract = mutationContractAddress;
    }

    /* burnerTokenAddress is the user address who is
     trying mutate using serum 
    */

    function burnSerumForAddress(uint256 typeId, address burnTokenAddress)
        external
    {
        require(msg.sender == mutationContract, "Invalid Burner Address");
        _burn(burnTokenAddress, typeId, 1);
    }

    function updateBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
        emit SetBaseURI(_baseURI);
    }

    function uri(uint256 typeId) public view override returns (string memory) {
        require(
            validSerumTypes[typeId],
            "URI requested for invalid Serum type"
        );
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, typeId.toString()))
                : baseURI;
    }
}
