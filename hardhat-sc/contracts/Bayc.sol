// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract Bayc {
    function ownerOf(uint256 tokenId) public view virtual returns (address);
}