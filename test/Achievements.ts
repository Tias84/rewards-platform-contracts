import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Achievements", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployAchievementsContract() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const Achievements = await ethers.getContractFactory("Achievements");
    const achievements = await Achievements.deploy();

    return { achievements, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { achievements, owner } = await deployAchievementsContract();
      const MINTER_ROLE = ethers.keccak256(ethers.toUtf8Bytes("MINTER_ROLE"));

      expect(await achievements.hasRole(MINTER_ROLE, owner.address)).to.equal(
        true
      );
    });

    it("URI should be set", async function () {
      const { achievements, owner } = await deployAchievementsContract();
      const uri = await achievements.uri(0);

      console.log("uri :>> ", uri);
    });

    it("Should mint the right tokens", async function () {
      const { achievements, owner } = await deployAchievementsContract();
      const totalSupply = await achievements["totalSupply()"]();

      const avvalerID = 0;
      const trailblazerID = 1;
      const AVVALER_TOKENS = await achievements["totalSupply(uint256)"](
        avvalerID
      );
      const TRAILBLAZER_TOKENS = await achievements["totalSupply(uint256)"](
        trailblazerID
      );

      expect(await achievements.balanceOf(owner.address, avvalerID)).to.equal(
        10
      );
      expect(
        await achievements.balanceOf(owner.address, trailblazerID)
      ).to.equal(0);
      expect(totalSupply).to.equal(AVVALER_TOKENS + TRAILBLAZER_TOKENS);
      expect(AVVALER_TOKENS).to.equal(10);
      expect(TRAILBLAZER_TOKENS).to.equal(0);
    });
  });
});
