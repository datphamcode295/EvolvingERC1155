const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  
  // Deployment parameters
  // const uri0 = "ipfs://bafkreihh5n5c3bcskyg5usr3tdwurcui4j34dypijry3qpgzpk5sqozbpy"; // URI for basic NFTs
  // const uri1 = "ipfs://bafybeihz6stadiejs4rfaoqguuy7hjttxvjjtln6cytm542ryq2zc4fqpy"; // URI for evolved NFTs

  console.log("Deploying contract with account:", deployer.address);

  // Deploy contract
  const EvolvingERC1155 = await hre.ethers.getContractFactory("EvolvingERC1155");
  const contract = await EvolvingERC1155.deploy();

  // Wait for deployment transaction to be mined
  await contract.waitForDeployment();
  
  // Get deployed contract address
  const deployedAddress = await contract.getAddress();

  console.log("EvolvingERC1155 deployed to:", deployedAddress);
  console.log("Owner:", deployer.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });