// This code snippet is provided by Pessimistic company.
// To apply for the internship opportunity at Pessimistic company,
// please fill out the form by visiting the following link: https://forms.gle/SUTcGi8X86yNoFnG7

// Caution: This code is intended for educational purposes only
// and should not be used in production environments.

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Airdrop {
    using MerkleProof for bytes32[];
    using SafeERC20 for IERC20;

    bytes32 private _merkleTreeRoot;

    IERC20 private _erc20;

    //@solution mapping (address user => bool claimed) hasClaimed;

    event Claim(address indexed who, uint256 amount);

    constructor(IERC20 erc20, bytes32 merkleTreeRoot) {
        _erc20 = erc20;
        _merkleTreeRoot = merkleTreeRoot;
    }

    function claim(uint256 amount, bytes32[] calldata proof) external {
        //@solution require(!hasClaimed[msg.sender], "Caller has already claimed");
        require(_erc20.balanceOf(msg.sender) == 0);
        require(proof.verify(_merkleTreeRoot, keccak256(abi.encode(msg.sender))), "User was not found");
        
        _erc20.safeTransfer(msg.sender, amount);
        //@solution hasClaimed[msg.sender]=true;

        emit Claim(msg.sender, amount);
    }

    // solution #1
    /**
     * balanceOf(msg.sender) == 0 is not a very effective check, this check can be bypassed by;
     * caller can claim the airdrop and then send it to another account bypassing the check
     * This contract does not protect against double claiming 
     * in this the solution will be;
     * to create a mapping to store the address of all those who have claimed
     * and have a check on the mapping in the claim function
     * to see whether the address calling has already claimed 
     */
}