// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


interface IBAKC {

    function tokenOfOwnerByIndex(address owner,uint256 index) external view returns (uint256);
    
    // Returns the Total NFTs owned by the owner
    function balanceOf(address owner) external view returns (uint256);
}
