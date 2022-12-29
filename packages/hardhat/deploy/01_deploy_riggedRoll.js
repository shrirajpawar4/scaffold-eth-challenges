const { ethers } = require("hardhat");

const localChainId = "31337";

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  const diceGame = await ethers.getContract("DiceGame", deployer);

  
  await deploy("RiggedRoll", {
   from: deployer,
   args: [diceGame.address],
   log: true,
  });


  const riggedRoll = await ethers.getContract("RiggedRoll", deployer);

  const ownershipTransaction = await riggedRoll.transferOwnership("0xF230BfdD22b022a4F7d9521Dc1b5C2115D0AeE01");
  

};

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

module.exports.tags = ["RiggedRoll"];

// 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512