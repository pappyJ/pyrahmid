// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Pyrahmid.sol";

pragma solidity ^0.8.4;

contract PyrahmidAssetFactory is Context {
  address public Owner;

  event AssetCreated(address tokenAddress);

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  address[] private assets;

  modifier onlyOwner() {
    require(Owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  function transferOwnership(address newOwner) external onlyOwner returns (bool) {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(Owner, newOwner);
    Owner = newOwner;
    return true;
  }

  function createAsset(string memory _name, string memory _symbol, address _transferProxy) external onlyOwner returns (address) {
    address _admin = msg.sender;

    PYRAHMID asset = new PYRAHMID(_name, _symbol, _transferProxy);

    PYRAHMID(asset).transferOwnership(_admin);

    assets.push(address(asset));

    emit AssetCreated(address(asset));

    return address(asset);
  }

  /* Returns all created Asset conracts */
  function fetchAssets() public view returns (address[] memory) {
    uint256 totalItemCount = assets.length;
    uint256 currentIndex = 0;

    address[] memory assetsItems = new address[](totalItemCount);

    for (uint256 i = 0; i < totalItemCount; i++) {
      assetsItems[currentIndex] = assets[currentIndex];
      currentIndex += 1;
    }

    return assetsItems;
  }

  function fetchAssetByIndex(uint256 index) public view returns (address) {
    return assets[index];
  }

  //Use this in case Coins are sent to the contract by mistake
  function rescueETH(uint256 weiAmount) external onlyOwner {
    require(address(this).balance >= weiAmount, "insufficient Token balance");
    payable(msg.sender).transfer(weiAmount);
  }

  function rescueAnyERC20Tokens(address _tokenAddr, address _to, uint256 _amount) public onlyOwner {
    IERC20(_tokenAddr).transfer(_to, _amount);
  }

  receive() external payable {}
}
