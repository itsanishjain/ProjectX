import Layout from "../src/components/Layout";
import "../styles/globals.css";

import { WalletContextProvider } from "../context/walletContext";

function MyApp({ Component, pageProps }) {
  return (
    <WalletContextProvider>
      <Layout>
        <Component {...pageProps} />
      </Layout>
    </WalletContextProvider>
  );
}

export default MyApp;
