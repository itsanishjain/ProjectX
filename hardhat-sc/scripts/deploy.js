const { ethers } = require("hardhat");

BAYC_CONTRACT_ADDRESS = "0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D"
MAYC_CONTRACT_ADDRESS = "0x60E4d786628Fea6478F785A6d7e704777c86a7c6"
BAKC_CONTRACT_ADDRESS = "0xba30E5F9Bb24caa003E9f2f0497Ad287FDF95623"


async function main() {
  const NftpresTokenContract = await ethers.getContractFactory("NftpresToken");

  const deployedNftpresTokenContract = await NftpresTokenContract.deploy(BAYC_RINKEBY_CONTRACT_ADDRESS,MAYC_CONTRACT_ADDRESS,BAKC_CONTRACT_ADDRESS);

  console.log("Contract Address:", deployedNftpresTokenContract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
