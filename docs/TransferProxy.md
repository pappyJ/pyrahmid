## `TransferProxy`





### `onlyOwner()`



Throws if called by any account other than the owner.


### `transferOwnership(address newOwner) → bool` (external)

change the Ownership from current owner to newOwner address
        @param newOwner : newOwner address



### `erc1155mint(contract IERC1155 token, address from, string tokenURI, address[] royalty, uint256[] royaltyFee, uint256 supply)` (external)





### `erc1155safeTransferFrom(contract IERC1155 token, address from, address to, uint256 tokenId, uint256 value, bytes data)` (external)





### `erc1155mintAndTransfer(contract IERC1155 token, address from, address to, address[] _royaltyAddress, uint256[] _royaltyfee, uint256 supply, string tokenURI, uint256 qty, bytes data)` (external)





### `erc20safeTransferFrom(contract IERC20 token, address from, address to, uint256 value)` (external)






### `OwnershipTransferred(address previousOwner, address newOwner)`





