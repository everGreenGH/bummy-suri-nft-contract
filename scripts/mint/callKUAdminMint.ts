import { Network, provider, wallet } from "../provider";
import addressInfo from "../addressInfo";
import { ethers, BigNumber } from "ethers";

// NFT μλ Ή λμ
const getter = "0xf2616B64972Df1CfDD5301cc95dc3c07979CdA81";
const mintNum = BigNumber.from(2);

export const callKUAdminMint = async () => {
    const network = process.env.NETWORK as Network;
    const { myLittleTigerAddr, myLittleTigerABI } = addressInfo[network];
    const MyLittleTiger = new ethers.Contract(myLittleTigerAddr, myLittleTigerABI, provider);

    console.log(`πκ³ λ €λνκ΅π NFT λ―Όν(κ΄λ¦¬μ λ―Όν): to => ${getter}π`);
    await (
        await MyLittleTiger.connect(wallet).adminMint(getter, mintNum, {
            gasLimit: 10000000,
        })
    ).wait();

    console.log(`μ΄ ${mintNum}κ°μ NFTμ λν κ΄λ¦¬μ λ―Όνμ΄ μλ£λμμ΅λλ€ :D`);
    console.log(`μ΄ λ°νλ νμΈ: ${await MyLittleTiger.totalSupply()}`);
};

callKUAdminMint();
