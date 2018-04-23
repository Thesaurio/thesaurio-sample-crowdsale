pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

import "thesaurio-solidity/contracts/FiatCompatible.sol";
import "thesaurio-solidity/contracts/KycCompatible.sol";
import "thesaurio-solidity/contracts/ThesaurioInfoCompatible.sol";
import "thesaurio-solidity/contracts/lib/MoneyOperations.sol";

/**
 * @title SampleCrowdsaleToken
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in a crowdsale contract.
 */
contract SampleCrowdsaleToken is MintableToken {
  string public constant name = "Sample Crowdsale Token"; // solium-disable-line uppercase
  string public constant symbol = "SCT"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase
}

/**
 * @title SampleCrowdsale
 * @dev This is an example of a fully fledged crowdsale.
 * The way to add new features to a base crowdsale is by multiple inheritance.
 * In this example we are providing following extensions:
 * MintedCrowdsale - creates supply on the fly
 * FiatCompatible - can interact with fiat prices contract of Thesaurio
 * KycCompatible - can interact with kyc registry contract of Thesaurio
 * ThesaurioInfoCompatible - can provide Thesaurio information about its current status
 *
 * In this example, we will use the rate attribute as being EUR cents and not a basic rate
 *
 * After adding multiple features it's good practice to run integration tests
 * to ensure that subcontracts works together as intended.
 */
contract SampleCrowdsale is MintedCrowdsale, FiatCompatible, KycCompatible, ThesaurioInfoCompatible {
  using MoneyOperations for uint256;

  uint256 constant minContrib = 0.1 ether;
  uint256 constant maxContrib = 100 ether;

  constructor(
    uint256 _rate,
    address _wallet,
    MintableToken _token,
    address _priceRegistry,
    address _kycRegistry
  ) public
    Crowdsale(_rate, _wallet, _token)
    FiatCompatible(_priceRegistry)
    KycCompatible(_kycRegistry) {}

  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    require(_beneficiary != address(0));
    require(_weiAmount != 0 && _weiAmount >= minContrib && _weiAmount <= maxContrib);
    require(kycRegistry.isAddressCleared(_beneficiary));
  }

  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.ethdiv(fiatPrices.eurPrice().mul(rate));
  }

  function distributionInfo() public view returns (
    uint256 minimumContribution,
    uint256 maximumContribution,
    uint256 currentTokenPrice,
    uint256 remainingSupply
  ) {
    minimumContribution = minContrib;
    maximumContribution = maxContrib;
    currentTokenPrice = fiatPrices.eurPrice().mul(rate);
    remainingSupply = 0; // Ignored parameter, no cap
  }
}
