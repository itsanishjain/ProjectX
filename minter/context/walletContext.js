import { useState, useEffect, useRef, createContext } from "react";
import Web3Modal from "web3modal";
import { providers } from "ethers";



export const WalletContext = createContext();

export const WalletContextProvider = ({ children }) => {
    const [walletConnected, setWalletConnected] = useState(false);
    const [address, setAddress] = useState("");
    const [isWalletConnected, setIsWalletConnected] = useState(false);

    const web3ModalRef = useRef();

    useEffect(() => {
        web3ModalRef.current = new Web3Modal({
            network: "rinkeby",
            providerOptions: {},
            disableInjectedProvider: false,
        });
        connectWallet();
    }, [walletConnected]);

    const getSignerOrProvider = async (needSigner = true) => {
        const provider = await web3ModalRef.current.connect();
        const web3Provider = new providers.Web3Provider(provider);
        const { chainId } = await web3Provider.getNetwork();
        if (chainId !== 4) {
            alert("USE RINKEBY NETWORK");
            throw new Error("Change network to Rinkeby");
        }

        if (needSigner) {
            const signer = web3Provider.getSigner();
            const signerAccount = await signer.getAddress();
            setAddress(signerAccount);
            return signer;
        } else {
            return provider;
        }
    };

    const connectWallet = async () => {
        try {
            await getSignerOrProvider();
            setWalletConnected(true);
            setIsWalletConnected(true);
        } catch (err) {
            console.error(err);
        }
    };

    const contextValue = {
        wallet: {
            isWalletConnected,
            address,
            getSignerOrProvider,
            connectWallet,
        }
    };


    return (
        <WalletContext.Provider value={contextValue}>
            {children}
        </WalletContext.Provider>
    );

}