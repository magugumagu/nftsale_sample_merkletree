// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";
import "@nomiclabs/hardhat-etherscan";
const main = async () => {
  const nftContractFactory = await ethers.getContractFactory('TESTNFT');
  const nftContract = await nftContractFactory.deploy(
      "TEST NFT",
      "TEST",
      "https://ipfs.io/ipfs/QmeRWEBMTSdt1dTJK4c2wdoGLD8suuHSUM8un2qabBfZDn",
      "https://ipfs.io/ipfs/QmeRWEBMTSdt1dTJK4c2wdoGLD8suuHSUM8un2qabBfZDn/notRevealed.json"
  );
  //
  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);

  // Call the function.
  let txn = await nftContract.setPresale(false)
  // Wait for it to be mined.
  await txn.wait()
  console.log("start publicsale")
  let sendeth=160000000000000000
  txn = await nftContract.publicMint(1,{value:sendeth})
  await txn.wait()
  // Wait for it to be mined.
  console.log("mint success")
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();

//0x510C204E369199EF86644210DAd0537aE324255b