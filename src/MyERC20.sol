// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20 {
    constructor() ERC20("Name", "SYM") {
        _mint(msg.sender, 1 ether);
    }
}