/**
 *Submitted for verification at Etherscan.io on 2022-03-08
 */

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IERC165 {
  /**
   * @dev Returns true if this contract implements the interface defined by
   * `interfaceId`. See the corresponding
   * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
   * to learn more about how these ids are created.
   *
   * This function call must use less than 30 000 gas.
   */

  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @dev Required interface of an ERC721 compliant contract.
 */

interface IERC721 is IERC165 {
  /**
   * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
   * another (`to`).
   *
   *
   *
   * Requirements:
   * - `from`, `to` cannot be zero.
   * - `tokenId` must be owned by `from`.
   * - `tokenId` must be owned by `from`.
   * - If the caller is not `from`, it must be have been allowed to move this
   * NFT by either {approve} or {setApprovalForAll}.
   */

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

  function createCollectible(
    address from,
    string memory tokenURI,
    address[] memory royalty,
    uint256[] memory royaltyFee
  ) external returns (uint256);

  function mintAndTransfer(
    address from,
    address to,
    address[] memory _royaltyAddress,
    uint256[] memory _royaltyfee,
    string memory _tokenURI,
    bytes memory data
  ) external returns (uint256);
}

interface IERC20 {
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
}

contract TransferProxy {
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  address public owner;

  constructor() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */

  modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }

  /** change the Ownership from current owner to newOwner address
        @param newOwner : newOwner address */

  function transferOwnership(address newOwner) external onlyOwner returns (bool) {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    return true;
  }

  function erc721mint(
    IERC721 token,
    address from,
    string memory tokenURI,
    address[] memory royalty,
    uint256[] memory royaltyFee
  ) external {
    token.createCollectible(from, tokenURI, royalty, royaltyFee);
  }

  function erc721mintBatch(
    IERC721 token,
    address from,
    string memory tokenURI,
    address[] memory royalty,
    uint256[] memory royaltyFee,
    uint256 qty
  ) external {
    for (uint256 i = 0; i < qty; i++) {
      token.createCollectible(from, tokenURI, royalty, royaltyFee);
    }
  }

  function erc721safeTransferFrom(
    IERC721 token,
    address from,
    address to,
    uint256 tokenId
  ) external {
    token.safeTransferFrom(from, to, tokenId);
  }

  function erc721mintAndTransfer(
    IERC721 token,
    address from,
    address to,
    address[] memory _royaltyAddress,
    uint256[] memory _royaltyfee,
    string memory tokenURI,
    bytes calldata data
  ) external {
    token.mintAndTransfer(from, to, _royaltyAddress, _royaltyfee, tokenURI, data);
  }

  function erc721safeTransferFromBatch(
    IERC721 token,
    address from,
    address to,
    uint256 tokenIdInit,
    uint256 qty
  ) external {
    for (uint256 i = 0; i < qty; i++) {
      token.safeTransferFrom(from, to, tokenIdInit);
      tokenIdInit++;
    }
  }

  function erc721mintAndTransferBatch(
    IERC721 token,
    address from,
    address to,
    address[] memory _royaltyAddress,
    uint256[] memory _royaltyfee,
    string memory tokenURI,
    uint256 qty,
    bytes calldata data
  ) external {
    for (uint256 i = 0; i < qty; i++) {
      token.mintAndTransfer(from, to, _royaltyAddress, _royaltyfee, tokenURI, data);
    }
  }

  function erc20safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) external {
    require(token.transferFrom(from, to, value), "failure while transferring");
  }
}
