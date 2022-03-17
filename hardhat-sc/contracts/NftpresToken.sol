// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./IBAYC.sol";
import "./IMAYC.sol";
import "./IBAKC.sol";

contract NftpresToken is Ownable, ERC20 {
    uint256 public constant tokenPrice = 0.5 ether;

    uint256 public constant maxTotalSupply = 2222 * 10**18;

    mapping(address => uint) public userMintedToken;

    IBAYC IBAYCNFT;
    IMAYC IMAYCNFT;
    IBAKC IBAKCNFT;

    constructor(address BAYC_CONTRACT_ADDRESS,address MAYC_CONTRACT_ADDRESS,address BAKC_CONTRACT_ADDRESS) ERC20("NftpresToken", "NPT") {
        IBAYCNFT = IBAYC(BAYC_CONTRACT_ADDRESS);
        IMAYCNFT = IMAYC(MAYC_CONTRACT_ADDRESS);
        IBAKCNFT = IBAKC(BAKC_CONTRACT_ADDRESS);
    }

    function mint(uint256 amount) public payable {
        
        address sender = msg.sender;
        uint256 balanceBAYC = IBAYCNFT.balanceOf(sender);
        uint256 balanceMAYC = IMAYCNFT.balanceOf(sender);
        uint256 balanceBAKC = IBAKCNFT.balanceOf(sender);

        require(amount <= 2, "You can mint atmost 2 tokens");

        require(userMintedToken[sender] == 2, "You have already minted your token");
  
        require(balanceBAYC > 0 || balanceMAYC > 0 || balanceBAKC > 0 , "You dont own any BAYC/MAYC/BAKC NFT's");


        uint256 _requiredAmount = amount * tokenPrice;

        uint256 amountWithDecimals = amount * 10**18;

        require(
            msg.value >= _requiredAmount,
            "You don't have enough ether to mint tokens"
        );

         require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max total supply available"
        );

        _mint(msg.sender, amountWithDecimals);

        userMintedToken[msg.sender]+=1;
    }

    //  A Withdraw function

    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
    
    fallback() external payable {}

}
