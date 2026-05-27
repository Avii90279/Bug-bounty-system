// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BugBountyBadge is ERC721, Ownable {
    uint256 private _tokenIdCounter;
    mapping(uint256 => string) private _tokenURIs;

    event BadgeMinted(address indexed to, uint256 indexed tokenId, string metadataURI);

    constructor() ERC721("BugBounty Badge", "BBB") Ownable(msg.sender) {}

    function mintBadge(address to, string calldata metadataURI) external onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter++;
        _safeMint(to, tokenId);
        _tokenURIs[tokenId] = metadataURI;
        emit BadgeMinted(to, tokenId, metadataURI);
        return tokenId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _tokenURIs[tokenId];
    }
}
