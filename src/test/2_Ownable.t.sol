// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import "../MyERC20.sol";
import "../New.sol";

contract OwnableTest is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    Utilities internal utils;

    Proof_of_Trade_Arbi_One x;
    MyERC20 erc20;
    address owner;

    function setUp() public {
       x = new Proof_of_Trade_Arbi_One();
       erc20 = new MyERC20();

       x.setUsdt(address(erc20));
       x.setByBitAddress(address(0x01));
       x.setSignerAddress(address(0x02));
       owner = x.owner();
    }

    function test2_1() public {
        // Transfer ownership
        vm.startPrank(owner);
        x.transferOwnership(address(0x03));
        vm.stopPrank();

        // Expect revert
        vm.startPrank(owner);
        vm.expectRevert();
        x.transferOwnership(address(0x03));
        vm.stopPrank();

        // Transfer back ownership
        vm.startPrank(address(0x03));
        x.transferOwnership(owner);
        vm.stopPrank();

        assert(x.owner() == owner);
    }
}
