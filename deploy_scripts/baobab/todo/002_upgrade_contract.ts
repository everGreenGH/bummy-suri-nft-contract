import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { deployments, getNamedAccounts } = hre;
    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    const KoreaUnivNFT = await deploy("MyLittleTiger", {
        from: deployer,
        proxy: true,
        log: true,
        autoMine: true,
    });

    console.log("๐ฏ ๊ณ ๋ ค๋ํ๊ต NFT ์ปจํธ๋ํธ ์๊ทธ๋ ์ด๋ ์๋ฃ :D ๐ฏ");
    console.log("์ปจํธ๋ํธ ์ฃผ์: ", KoreaUnivNFT.address);

    const YonseiUnivNFT = await deploy("MyLittleEagle", {
        from: deployer,
        proxy: true,
        log: true,
        autoMine: true,
    });

    console.log("๐ฆ ์ฐ์ธ๋ํ๊ต NFT ์ปจํธ๋ํธ ์๊ทธ๋ ์ด๋ ์๋ฃ :D ๐ฆ");
    console.log("์ปจํธ๋ํธ ์ฃผ์: ", YonseiUnivNFT.address);
};

export default func;

func.tags = ["upgrade_contract"];
