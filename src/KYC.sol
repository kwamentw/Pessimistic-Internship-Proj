// SPDX-License-Identifier: MIT
// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

pragma solidity ^0.8.0;

import '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import {SignatureChecker} from '@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol';
import '@openzeppelin/contracts-upgradeable/utils/structs/BitMapsUpgradeable.sol';

contract Token is Initializable, ERC721Upgradeable, AccessControlUpgradeable, UUPSUpgradeable {
    using BitMapsUpgradeable for BitMapsUpgradeable.BitMap;
    using ECDSAUpgradeable for bytes32;
    using SignatureChecker for address;

    struct SignatureData {
        address signer;
        address account;
        uint256 nonce;
        bytes signature;
    }
    uint256 chainId;

    bytes32 public constant PROVIDER_ROLE = keccak256('PROVIDER_ROLE');

    mapping(address => uint256) public nonces;

    function initialize(uint256 _chainId) initializer public {
        __ERC721_init('Token Name', 'TOKEN');
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PROVIDER_ROLE, msg.sender);
        chainId = _chainId;
    }

    function _authorizeUpgrade(address newImplementation) internal override {}

    function mintTo(
        SignatureData calldata signatureData,
        uint256 tokenId
    ) external
      signerVerification(tokenId, signatureData) {
       require(balanceOf(signatureData.account) == 0, 'The token has already been minted!');

       _mint(signatureData.account, tokenId);

       nonces[signatureData.account]++;
    }


    function burn(
        uint256 tokenId,
        SignatureData calldata signatureData
    ) external signerVerification(tokenId, signatureData) {
        require(balanceOf(signatureData.account) > 0, 'Nothing to burn');
        _burn(tokenId);
        nonces[signatureData.account] += 1;
        require(balanceOf(signatureData.account) == 0, 'The token has not been burnt!');
    }

    modifier signerVerification(
      uint256 tokenId,
      SignatureData calldata signature
    ) {
        require(nonces[signature.signer] == signature.nonce, 'Invalid Nonce');
        require(hasRole(PROVIDER_ROLE, msg.sender), 'Invalid Provider');

        bytes32 hash = keccak256(
          abi.encodePacked(
            '\x19\x01',
            keccak256(abi.encode(
                signature.signer,
                address(this),
                signature.account,
                tokenId,
                nonces[signature.signer],
                chainId
            ))
          )
        ).toEthSignedMessageHash();

        require(
          signature.signer.isValidSignatureNow(hash, signature.signature),
          'Invalid Signer'
        );
        _;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
        // uint256 amount
    ) internal override {
        require(
          (from == address(0) && to != address(0)) || (from != address(0) && to == address(0)),
          'Only mint or burn transfers are allowed'
        );
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721Upgradeable, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

/**
 * You need to understand the code and write out all possible issues in the following format: Contract.function L25 - description.
 * Token._authorizeUpgrade - Line 46 - No access controls on this function can make anyone upgrade the contract. It needs to have an onlyOwner modifier
 * Token.signerVerification - line 73 - nonce validation doesn't offer any protection since require check will always evaluate to true that it 0==0, so it will always pass
 * Token.mintTo - line 47 - Before minting there's no check to make sure the tokenId already exists and has an owner
 * Token.mintTo - line 47 - Because of the require check in the function Account can only be minted one TokenId at a time // feels more like a design decision
 * Token.burn - line 59 - Before burning there's no check to validate whether the TokenId exists before burning it 
 */
