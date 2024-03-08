import { ethers, run, network } from "hardhat";

async function main() {
  const achievements = await ethers.deployContract("Achievements");

  await achievements.waitForDeployment();

  console.log(`Achievements deployed to ${achievements.target}`);

  if (network.name !== "hardhat") {
    console.log(`Verifying contract on Etherscan...`);

    setTimeout(async () => {
      // In this case we run the verify task and pass the contract address and constructor arguments
      // The verify task will then use etherscan to verify the contract
      await run("verify:verify", {
        address: achievements.target,
      });

      console.log("Achievements deployed and verified!");
    }, 15_000);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
