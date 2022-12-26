// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ISpiritTribes.sol";

contract SpiritToken is ERC20, Ownable {
    /// @notice price of SpiritToken
    uint256 public constant tokenPrice = 0.001 ether;

    /// @notice Owning 1 full token is equivalent to owning (10^18) tokens when you account for the decimal places.
    uint256 public constant tokensPerNft = 10 * 10**18;

    /// @notice the max total supply is 10000 for Crypto Dev Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;

    /// @notice Spirit Tribes NFT contract instance
    ISpiritTribes spiritTribes;

    /// @notice mapping to track which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _spiritTribesContract) ERC20("Spirit Token", "SPIRIT") {
        spiritTribes = ISpiritTribes(_spiritTribesContract);
    }

    /**
     * @dev Mints `amount` number of CryptoDevTokens
     * Requirements:
     * - `msg.value` should be equal or greater than the tokenPrice * amount
     */
    function mint(uint256 amount) public payable {
        /// @notice the value of ether that should be equal or greater than tokenPrice * amount;
        uint256 priceToPay = tokenPrice * amount;
        require(msg.value >= priceToPay, "Ether sent is incorrect");
        // total tokens + amount <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        require(
            totalSupply() + amountWithDecimals <= maxTotalSupply,
            "Exceed maximum total supply!"
        );
        // call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }

    /**
     * @dev Mints tokens based on the number of NFT's held by the sender
     * Requirements:
     * balance of Crypto Dev NFT's owned by the sender should be greater than 0
     * Tokens should have not been claimed for all the NFTs owned by the sender
     */
    function claim() public {
        address sender = msg.sender;
        /// @notice number of NFTs/tokens held by sender
        uint256 balance = spiritTribes.balanceOf(sender);
        require(balance > 0, "You don't own any Spirit Tribe NFTs");

        /// @notice amount keeps track of how many tokens are to be claimed
        uint256 amount = 0;
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = spiritTribes.tokenOfOwnerByIndex(sender, i);
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        /// @notice reverts if all tokens have been claimed
        require(amount > 0, "You've claimed all your tokens!");
        _mint(sender, amount * tokensPerNft);
    }

    /**
     * @dev withdraws all ETH sent to this contract
     * Requirements:
     * wallet connected must be owner's address
     */
    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "Contract balance is empty!");

        address _owner = owner();
        (bool success, ) = _owner.call{value: amount}("");
        require(success, "Withdraw failed!");
    }

    /// @notice function to receive ether. msg.data is empty
    receive() external payable {}

    /// @notice function to receive ether. msg.data is not empty
    fallback() external payable {}
}
