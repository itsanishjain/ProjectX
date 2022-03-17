import React, { useContext, useState } from "react";
import { WalletContext } from "../context/walletContext";
import { BAYC_CONTRACT_ABI, BAYC_CONTRACT_ADDRESS } from "../src/Address_ABI.js/bayc";
import { NFTPRES_CONTRACT_ABI, NFTPRES_CONTRACT_ADDRESS } from "../src/Address_ABI.js/nftpresToken";
import { Contract, utils } from "ethers";

import { toast, ToastContainer } from "react-toastify";
import "react-toastify/dist/ReactToastify.css";

import Button from '../src/components/Button'
import Loader from '../src/components/Loader'

export default function Home() {
  const { wallet } = useContext(WalletContext);
  const [loading, setLoading] = useState(false);
  const [mintloading, setMintLoading] = useState(false);


  const checkErrorTypeAndNotify = (error) => {
    if (error.message.includes("reverted")) {
      toast.error(error.error.message);
    } else if (
      error.message.includes(
        "MetaMask Tx Signature: User denied transaction signature."
      )
    ) {
      toast.error("Transaction cancelled");
    } else {
      toast.error(error.message);
    }
  };

  const mintBAYCNFT = async () => {

    try {
      const signer = await wallet.getSignerOrProvider();

      const baycContract = new Contract(BAYC_CONTRACT_ADDRESS, BAYC_CONTRACT_ABI, signer);
      const value = 0.08 * 1;
      setLoading(true);
      const mint = await baycContract.mintApe(1, {
        value: utils.parseEther(value.toString())
      });
      console.log(mint);
      await mint.wait();
    }
    catch (error) {
      console.log(error);
      alert("ERROR IN MINTING")
    }
    setLoading(false);

  }

  const mintNftpresToken = async () => {

    try {
      const signer = await wallet.getSignerOrProvider();

      const nftpresContract = new Contract(NFTPRES_CONTRACT_ADDRESS, NFTPRES_CONTRACT_ABI, signer);
      setMintLoading(true);
      const value = 0.005 * 1;
      const tx = await nftpresContract.mint(1, {
        value: utils.parseEther(value.toString())
      });
      console.log(tx);
      await tx.wait();
    }
    catch (error) {
      console.log(error);
      checkErrorTypeAndNotify(error)

    }
    setMintLoading(false);

  }




  console.log("WALLET", wallet)
  return (
    <>
      <ToastContainer />
      <div className=" h-screen p-12 bg-gradient-to-b from-yellow-500 to-yellow-200   ">
        <div className="space-x-4 mt-4 text-center">



          {/* <Button text={!wallet.isWalletConnected ? "Connect Wallet" : "Connected"} /> */}

          {
            !loading ? <Button text="Mint BAYC" onClick={mintBAYCNFT} /> : <Loader />
          }


          {
            !mintloading ? <Button text="Mint NFTPRES TOKEN" onClick={mintNftpresToken} /> : <Loader />
          }

        </div>
      </div>
    </>
  );
}
