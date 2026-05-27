import { BrowserProvider } from "ethers";
import api from "./api";

declare global {
  interface Window {
    ethereum?: {
      request: (args: { method: string; params?: unknown[] }) => Promise<unknown>;
      isMetaMask?: boolean;
    };
  }
}

export async function connectWallet(_userId?: number) {
  if (!window.ethereum) throw new Error("No Web3 wallet detected. Install MetaMask.");

  const provider = new BrowserProvider(window.ethereum);
  await provider.send("eth_requestAccounts", []);
  const signer = await provider.getSigner();
  const address = await signer.getAddress();

  const { data: walletInfo } = await api.get("/blockchain/wallet");
  const message = walletInfo.message as string;
  const signature = await signer.signMessage(message);

  await api.post("/blockchain/connect_wallet", {
    address,
    message,
    signature,
    chain_id: (await provider.getNetwork()).chainId.toString()
  });

  return address;
}

export async function mintNftBadge(badgeId: number) {
  const { data } = await api.post("/blockchain/mint_badge", { badge_id: badgeId });
  return data;
}
