import { Network, provider, wallet } from "../provider";
import addressInfo from "../addressInfo";
import { ethers } from "ethers";

// NFT μλ Ή λμ
const getter = "0xf2616B64972Df1CfDD5301cc95dc3c07979CdA81";

export const callYUSingleMint = async () => {
    const network = process.env.NETWORK as Network;
    const { myLittleEagleAddr, myLittleEagleABI } = addressInfo[network];
    const myLittleEagleContract = new ethers.Contract(myLittleEagleAddr, myLittleEagleABI, provider);

    console.log(`π¦μ°μΈλνκ΅π¦ NFT λ―Όν(1κ° μ£Όμμ 1κ° λ―Όν): to => ${getter}π`);
    await (
        await myLittleEagleContract.connect(wallet).singleMint(getter, {
            gasLimit: 10000000,
        })
    ).wait();

    console.log("λ―Όνμ΄ μλ£λμμ΅λλ€ :D");
    console.log(`μ΄ λ°νλ νμΈ: ${await myLittleEagleContract.totalSupply()}`);
};

callYUSingleMint();
