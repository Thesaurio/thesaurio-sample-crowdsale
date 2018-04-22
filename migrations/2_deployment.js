// Artifacts
const SampleCrowdsaleToken = artifacts.require('./SampleCrowdsaleToken.sol')
const SampleCrowdsale = artifacts.require('./SampleCrowdsale.sol')

module.exports = function(deployer) {
  let token, crowdsale

  deployer.then(async function() {
    token = await SampleCrowdsaleToken.new()
    console.log("Token address :", token.address)

    crowdsale = await SampleCrowdsale.new(
      100,
      process.env.DESTINATION_WALLET,
      token.address,
      process.env.PRICES_CONTRACT,
      process.env.KYC_REGISTRY_CONTRACT
    )
    console.log("Crowdsale address :", crowdsale.address)

    await token.transferOwnership(crowdsale.address)
    console.log("Ownership of token transferred to crowdsale to enable minting")
  })
}
