// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract tokenMock is ERC20{
    constructor()ERC20("TOKEN","TK20"){}

    function mint(address account, uint256 amount) external{
        _mint(account,amount);
    }

    function burn(address account, uint256 amount) external {
        _burn(account,amount);
    }
}