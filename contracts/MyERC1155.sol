// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract EvolvingERC1155 is ERC1155, Ownable {
    using ECDSA for bytes32;

    // Token IDs
    uint256 public constant BASIC_NFT = 0;
    uint256 public constant EVOLVED_NFT = 1;

    // Mapping to track if a signature has been used
    mapping(bytes => bool) public usedSignatures;

    constructor() ERC1155("https://ipfs.io/ipfs/bafybeig7kbahfknc5hldgkfhwktao5l4xm3ppphodatxhy2obfh27nyefe/{id}.json") Ownable(msg.sender) {
        // Mint initial supply of basic NFTs
        _mint(msg.sender, BASIC_NFT, 2, "");
        _mint(msg.sender, EVOLVED_NFT, 1, "");
    }

    // Override uri function to return different URIs based on token ID
    function uri(uint256 tokenId) public pure override returns (string memory) {
        return string(abi.encodePacked(
            "https://ipfs.io/ipfs/bafybeig7kbahfknc5hldgkfhwktao5l4xm3ppphodatxhy2obfh27nyefe/",
            Strings.toString(tokenId),
            ".json"
        ));
    }

    function contractURI() public pure returns (string memory) {
        return "https://ipfs.io/ipfs/bafybeig7kbahfknc5hldgkfhwktao5l4xm3ppphodatxhy2obfh27nyefe/collection.json";
    }

    // Function to generate message hash for claiming NFT
    function getMessageHash(address user, uint256 index) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, index));
    }

    // Updated claimNFT function with index parameter
    function claimNFT(uint256 index, bytes memory signature) public {
        require(!usedSignatures[signature], "Signature already used");
        
        // Create message hash including index
        bytes32 messageHash = getMessageHash(msg.sender, index);
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        
        // Verify signature
        address signer = ECDSA.recover(ethSignedMessageHash, signature);
        require(signer == owner(), "Invalid signature");
        
        // Mark signature as used
        usedSignatures[signature] = true;
        
        // Mint basic NFT (ID 0)
        _mint(msg.sender, BASIC_NFT, 1, "");
    }

    // Function to evolve two basic NFTs into one evolved NFT
    function evolveNFTs() public {
        // Check if user has at least 2 basic NFTs
        require(balanceOf(msg.sender, BASIC_NFT) >= 2, "Insufficient basic NFTs");
        
        // Burn two basic NFTs
        _burn(msg.sender, BASIC_NFT, 2);
        
        // Mint one evolved NFT
        _mint(msg.sender, EVOLVED_NFT, 1, "");
    }

    // Function to check if a signature has been used
    function isSignatureUsed(bytes memory signature) public view returns (bool) {
        return usedSignatures[signature];
    }

    // Function to get user's NFT balances
    function getUserBalances(address user) public view returns (uint256, uint256) {
        return (
            balanceOf(user, BASIC_NFT),
            balanceOf(user, EVOLVED_NFT)
        );
    }
}