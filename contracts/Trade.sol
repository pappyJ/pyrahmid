/**
 *Submitted for verification at BscScan.com on 2022-03-08
 */

// SPDX-License-Identifier:UNLICENSED
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
  function royaltyFee(uint256 tokenId) external view returns (address[] memory, uint256[] memory);

  function getCreator(uint256 tokenId) external view returns (address);

  function contractOwner() external view returns (address owner);

  /**
   * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
   * another (`to`).
   *
   *
   *
   * Requirements:
   * - `from`, `to` cannot be zero.
   * - `tokenId` must be owned by `from`.
   * - If the caller is not `from`, it must be have been allowed to move this
   * NFT by either {approve} or {setApprovalForAll}.
   */

  function safeTransferFrom(address from, address to, uint256 tokenId) external;

  function createCollectible(
    address from,
    string memory tokenURI,
    address[] memory royalty,
    uint256[] memory _royaltyFee
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

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */

interface IERC20 {
  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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
    require(owner == msg.sender, 'Ownable: caller is not the owner');
    _;
  }

  /** change the Ownership from current owner to newOwner address
        @param newOwner : newOwner address */

  function transferOwnership(address newOwner) external onlyOwner returns (bool) {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    return true;
  }

  function erc721mint(IERC721 token, address from, string memory tokenURI, address[] memory royalty, uint256[] memory royaltyFee) external {
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

  function erc721safeTransferFrom(IERC721 token, address from, address to, uint256 tokenId) external {
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

  function erc721safeTransferFromBatch(IERC721 token, address from, address to, uint256 tokenIdInit, uint256 qty) external {
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

  function erc20safeTransferFrom(IERC20 token, address from, address to, uint256 value) external {
    require(token.transferFrom(from, to, value), 'failure while transferring');
  }
}

contract Trade {
  enum BuyingAssetType {
    SINGLE,
    MULTI,
    LazySINGLE,
    LazyMULTI
  }

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event SellerFee(uint8 sellerFee);
  event BuyerFee(uint8 buyerFee);
  event BuyAsset(address indexed assetOwner, uint256 indexed tokenId, uint256 quantity, address indexed buyer);
  event ExecuteBid(address indexed assetOwner, uint256 indexed tokenId, uint256 quantity, address indexed buyer);

  uint8 private buyerFeePermille;
  uint8 private sellerFeePermille;
  TransferProxy public transferProxy;
  address public owner;

  struct Fee {
    uint256 platformFee;
    uint256 assetFee;
    address[] royaltyAddress;
    uint256[] royaltyFee;
    uint256 price;
  }

  struct Order {
    address seller;
    address buyer;
    address erc20Address;
    address nftAddress;
    BuyingAssetType nftType;
    uint256 unitPrice;
    uint256 amount;
    uint256 tokenId;
    string tokenURI;
    address[] royaltyAddress;
    uint256[] royaltyfee;
    uint256 qty;
  }

  modifier onlyOwner() {
    require(owner == msg.sender, 'Ownable: caller is not the owner');
    _;
  }

  constructor(uint8 _buyerFee, uint8 _sellerFee, TransferProxy _transferProxy) {
    buyerFeePermille = _buyerFee;
    sellerFeePermille = _sellerFee;
    transferProxy = _transferProxy;
    owner = msg.sender;
  }

  function buyerServiceFee() external view virtual returns (uint8) {
    return buyerFeePermille;
  }

  function sellerServiceFee() external view virtual returns (uint8) {
    return sellerFeePermille;
  }

  function setBuyerServiceFee(uint8 _buyerFee) external onlyOwner returns (bool) {
    buyerFeePermille = _buyerFee;
    emit BuyerFee(buyerFeePermille);
    return true;
  }

  function setSellerServiceFee(uint8 _sellerFee) external onlyOwner returns (bool) {
    sellerFeePermille = _sellerFee;
    emit SellerFee(sellerFeePermille);
    return true;
  }

  function transferOwnership(address newOwner) external onlyOwner returns (bool) {
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    return true;
  }

  //get the encoded hash by packing locally signed asset data
  function getMessageHash(address _signer, uint _amount, address _assetAddress, address _paymentAssetAddress) public pure returns (bytes32) {
    return keccak256(abi.encodePacked(_signer, _amount, _assetAddress, _paymentAssetAddress));
  }

  //injecting ethereum standard signed data signature
  function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
    return keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', _messageHash));
  }

  function verify(
    address _signer,
    uint _amount,
    address _assetAddress,
    address _paymentAssetAddress,
    bytes memory signature
  ) public pure returns (bool) {
    bytes32 messageHash = getMessageHash(_signer, _amount, _assetAddress, _paymentAssetAddress);
    bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

    return recoverSigner(ethSignedMessageHash, signature) == _signer;
  }

  function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address) {
    (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

    return ecrecover(_ethSignedMessageHash, v, r, s);
  }

  function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
    require(sig.length == 65, 'invalid signature length');

    assembly {
      /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

      // first 32 bytes, after the length prefix
      r := mload(add(sig, 32))
      // second 32 bytes
      s := mload(add(sig, 64))
      // final byte (first byte of the next 32 bytes)
      v := byte(0, mload(add(sig, 96)))
    }

    // implicitly return (r, s, v)
  }

  function getFees(Order memory order) internal view returns (Fee memory) {
    uint256 platformFee;
    uint256 fee;
    address[] memory royaltyAddress;
    uint256[] memory royaltyPermille;
    uint256 assetFee;
    uint256 price = (order.amount * 1000) / (1000 + buyerFeePermille);
    uint256 buyerFee = order.amount - price;
    uint256 sellerFee = (price * sellerFeePermille) / 1000;
    platformFee = buyerFee + sellerFee;

    if (order.nftType == BuyingAssetType.SINGLE || order.nftType == BuyingAssetType.MULTI) {
      (royaltyAddress, royaltyPermille) = ((IERC721(order.nftAddress).royaltyFee(order.tokenId)));
    }

    if (order.nftType == BuyingAssetType.LazySINGLE || order.nftType == BuyingAssetType.LazyMULTI) {
      royaltyAddress = order.royaltyAddress;
      royaltyPermille = order.royaltyfee;
    }

    uint256[] memory royaltyFee = new uint256[](royaltyAddress.length);

    for (uint256 i = 0; i < royaltyAddress.length; i++) {
      fee += (price * royaltyPermille[i]) / 1000;
      royaltyFee[i] = (price * royaltyPermille[i]) / 1000;
    }

    assetFee = price - fee - sellerFee;
    return Fee(platformFee, assetFee, royaltyAddress, royaltyFee, price);
  }

  function tradeAsset(Order calldata order, Fee memory fee, address buyer, address seller) internal virtual {
    if (order.nftType == BuyingAssetType.SINGLE) {
      transferProxy.erc721safeTransferFrom(IERC721(order.nftAddress), seller, buyer, order.tokenId);
    }
    if (order.nftType == BuyingAssetType.MULTI) {
      transferProxy.erc721safeTransferFromBatch(IERC721(order.nftAddress), seller, buyer, order.tokenId, order.qty);
    }
    if (order.nftType == BuyingAssetType.LazySINGLE) {
      transferProxy.erc721mintAndTransfer(
        IERC721(order.nftAddress),
        order.seller,
        order.buyer,
        order.royaltyAddress,
        order.royaltyfee,
        order.tokenURI,
        ''
      );
    }
    if (order.nftType == BuyingAssetType.LazyMULTI) {
      transferProxy.erc721mintAndTransferBatch(
        IERC721(order.nftAddress),
        order.seller,
        order.buyer,
        order.royaltyAddress,
        order.royaltyfee,
        order.tokenURI,
        order.qty,
        ''
      );
    }
    if (fee.platformFee > 0) {
      transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, owner, fee.platformFee);
    }
    for (uint256 i = 0; i < fee.royaltyAddress.length; i++) {
      if (fee.royaltyFee[i] > 0) {
        transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, fee.royaltyAddress[i], fee.royaltyFee[i]);
      }
    }
    transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, seller, fee.assetFee);
  }

  function mint(
    address nftAddress,
    BuyingAssetType nftType,
    string memory tokenURI,
    address[] memory recipient,
    uint256[] memory royaltyFee,
    uint256 qty
  ) external returns (bool) {
    if (nftType == BuyingAssetType.SINGLE) {
      transferProxy.erc721mint(IERC721(nftAddress), msg.sender, tokenURI, recipient, royaltyFee);
    } else if (nftType == BuyingAssetType.MULTI) {
      transferProxy.erc721mintBatch(IERC721(nftAddress), msg.sender, tokenURI, recipient, royaltyFee, qty);
    }
    return true;
  }

  function mintAndBuyAsset(Order calldata order, bytes memory signature) external returns (bool) {
    Fee memory fee = getFees(order);
    require((fee.price >= order.unitPrice * order.qty), 'Paid invalid amount');
    verify(order.seller, order.unitPrice, order.nftAddress, order.erc20Address, signature);

    address buyer = msg.sender;
    tradeAsset(order, fee, buyer, order.seller);
    emit BuyAsset(order.seller, order.tokenId, order.qty, msg.sender);
    return true;
  }

  function mintAndExecuteBid(Order calldata order, bytes memory signature) external returns (bool) {
    Fee memory fee = getFees(order);
    require((fee.price >= order.unitPrice * order.qty), 'Paid invalid amount');
    verify(order.buyer, order.unitPrice, order.nftAddress, order.erc20Address, signature);
    address seller = msg.sender;
    tradeAsset(order, fee, order.buyer, seller);
    emit ExecuteBid(order.seller, order.tokenId, order.qty, msg.sender);
    return true;
  }

  function buyAsset(Order calldata order, bytes memory signature) external returns (Fee memory) {
    Fee memory fee = getFees(order);
    require((fee.price >= order.unitPrice * order.qty), 'Paid invalid amount');

    verify(order.seller, order.unitPrice, order.nftAddress, order.erc20Address, signature);

    address buyer = msg.sender;
    tradeAsset(order, fee, buyer, order.seller);
    emit BuyAsset(order.seller, order.tokenId, order.qty, msg.sender);
    return fee;
  }

  function executeBid(Order calldata order, bytes memory signature) external returns (bool) {
    Fee memory fee = getFees(order);
    verify(order.buyer, order.unitPrice, order.nftAddress, order.erc20Address, signature);
    address seller = msg.sender;
    tradeAsset(order, fee, order.buyer, seller);
    emit ExecuteBid(msg.sender, order.tokenId, order.qty, order.buyer);
    return true;
  }
}
