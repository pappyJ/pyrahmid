## `Trade`





### `onlyOwner()`






### `constructor(uint8 _buyerFee, uint8 _sellerFee, contract TransferProxy _transferProxy)` (public)





### `buyerServiceFee() → uint8` (external)





### `sellerServiceFee() → uint8` (external)





### `setBuyerServiceFee(uint8 _buyerFee) → bool` (external)





### `setSellerServiceFee(uint8 _sellerFee) → bool` (external)





### `transferOwnership(address newOwner) → bool` (external)





### `getSigner(bytes32 hash, struct Trade.Sign sign) → address` (internal)





### `verifySellerSign(address seller, uint256 tokenId, uint256 amount, address paymentAssetAddress, address assetAddress, struct Trade.Sign sign)` (internal)





### `verifyBuyerSign(address buyer, uint256 tokenId, uint256 amount, address paymentAssetAddress, address assetAddress, uint256 qty, struct Trade.Sign sign)` (internal)





### `getFees(struct Trade.Order order) → struct Trade.Fee` (internal)





### `tradeAsset(struct Trade.Order order, struct Trade.Fee fee, address buyer, address seller)` (internal)





### `mint(address nftAddress, enum Trade.BuyingAssetType nftType, string tokenURI, uint256 supply, address[] recipient, uint256[] royaltyFee) → bool` (external)





### `mintAndBuyAsset(struct Trade.Order order, struct Trade.Sign sign) → bool` (external)





### `mintAndExecuteBid(struct Trade.Order order, struct Trade.Sign sign) → bool` (external)





### `buyAsset(struct Trade.Order order, struct Trade.Sign sign) → struct Trade.Fee` (external)





### `executeBid(struct Trade.Order order, struct Trade.Sign sign) → bool` (external)






### `OwnershipTransferred(address previousOwner, address newOwner)`





### `SellerFee(uint8 sellerFee)`





### `BuyerFee(uint8 buyerFee)`





### `BuyAsset(address assetOwner, uint256 tokenId, uint256 quantity, address buyer)`





### `ExecuteBid(address assetOwner, uint256 tokenId, uint256 quantity, address buyer)`





