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

    function test2_2() public {
        // Owner can update important address
        vm.startPrank(owner);
        x.setUsdt(address(0x04));
        x.setByBitAddress(address(0x05));
        x.setSignerAddress(address(0x06));
        vm.stopPrank();

        assert(x._usdt() == IERC20(address(0x04)));
        assert(x._byBitAddress() == address(0x05));
        assert(x._signerAddress() == address(0x06));
    }

    function test2_3() public {
        // Non owner cannot update important address
        vm.startPrank(address(0x10));
        vm.expectRevert();
        x.setUsdt(address(0x04));
        vm.stopPrank();

        vm.startPrank(address(0x10));
        vm.expectRevert();
        x.setByBitAddress(address(0x05));
        vm.stopPrank();

        vm.startPrank(address(0x10));
        vm.expectRevert();
        x.setSignerAddress(address(0x05));
        vm.stopPrank();
    }
}
