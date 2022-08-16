// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract TESTNFT is ERC721Enumerable, Ownable {
  using Strings for uint256;
    
  string public baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public publicCost = 0.000005 ether;
  uint256 public presaleCost = 0.00004 ether;
  uint256 public maxSupply = 300;
  uint256 public maxMintAmount = 1;
  uint256 public nftPerAddressLimit = 1;
  bytes32 public merkleRoot;
  bool public paused = false;
  bool public revealed = false;
  bool public presale = true;
  mapping(address => uint256) private whiteListClaimed;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function publicMint(uint256 _mintAmount) public payable {
      require(!paused,"the sale is not available");
      require(tx.origin==msg.sender, "Trying to mint from a contract");
      uint256 supply = totalSupply();
      uint256 cost =publicCost * _mintAmount;
      require(!presale,"Publicsale is not available while Presale is active");
      require(_mintAmount > 0, "need to mint at least 1 NFT");
      require(_mintAmount <= maxMintAmount,"max mint amount per transaction exceeded");
      require(supply + _mintAmount <= maxSupply,"max supply limit exceeded");
      require(msg.value >= cost * _mintAmount,"insufficient funds");

      for (uint i=1; i<= _mintAmount; i++) {
          _safeMint(msg.sender,supply + i);
      }
  }
  function presaleMint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable{
      require(!paused,"the sale is not available");
      require(presale,"Presale is not active.");

      bytes32 leaf=keccak256(abi.encodePacked(msg.sender));
      require(MerkleProof.verify(_merkleProof,merkleRoot,leaf),"Invali Merle Proof");

      uint256 supply =totalSupply();
      uint256 cost=presaleCost * _mintAmount;
      require(_mintAmount > 0,"need to mint at least 1 NFT");
      require(_mintAmount <= maxMintAmount,"max mint amount per transaction exceeded");
      require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");
      require(whiteListClaimed[msg.sender]+ _mintAmount <= nftPerAddressLimit, "max NFT per address exceeded");  
      require(msg.value >= cost, "insufficient funds");
      for (uint i=1; i<= _mintAmount; i++) {
          _safeMint(msg.sender, supply + i);
          whiteListClaimed[msg.sender]++;
      }
  }


  function walletOfOwner(address _owner) public view returns (uint256[] memory){
      uint256 ownerTokenCount=balanceOf(_owner);
      uint256[] memory tokenIds=new uint256[](ownerTokenCount);
      for (uint256 i; i<ownerTokenCount; i++) {
          tokenIds[i] =tokenOfOwnerByIndex(_owner,i);
      }
      return tokenIds;
  }
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
      require(_exists(tokenId), "ERC721Metadeta: URI query for nonexistment token");
      if (revealed == false) {
          return notRevealedUri;
      }
      string memory currentBaseURI =_baseURI();
      return bytes(currentBaseURI).length > 0
          ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
          : "";
  }
  
  function ownerMint(address _address, uint256 count) public onlyOwner {
    uint256 supply =totalSupply();

    for (uint256 i= 1;i <= count; i++) {
        _safeMint(msg.sender, supply+i);
        safeTransferFrom(msg.sender, _address, supply+i);
    }
  }
  
  function reveal() public onlyOwner {
      revealed =true;
  }

  function is_revealed() public view returns (bool){
      return revealed;
  }
  
  function setPresale(bool _state) public onlyOwner {
      presale = _state;
  }

  function is_presaleActive() public view returns (bool) {
      return presale;
    }
  
  function setNftPerAddressLimit(uint256 _limit) public onlyOwner {
      nftPerAddressLimit = _limit;
  }

  function getpublicCost() public view returns (uint256) {
      return publicCost;
  }

  function getpresaleCost() public view returns (uint256) {
      return presaleCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
      maxMintAmount = _newmaxMintAmount;
  }
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
      baseURI = _newBaseURI;
  }

  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
      notRevealedUri = _notRevealedURI;
  }

  function setBaseExtenstion(string memory _newBaseExtension) public onlyOwner {
      baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
      paused =_state;
  }

  function is_paused() public view returns (bool) {
      return paused;
  }
  

  function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
    merkleRoot=_merkleRoot;
  }

  function withdraw() external onlyOwner {
    uint256 balance =address(this).balance;
    payable(msg.sender).transfer(balance);
  }

}