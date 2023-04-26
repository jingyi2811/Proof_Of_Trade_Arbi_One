// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import "../MyERC20.sol";
import "../New.sol";

contract DepositTest is DSTest {
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

    function test3_0() public {
        assert(erc20.balanceOf(owner) == 1 ether);
        assert(erc20.balanceOf(address(x)) == 0);
        assert(erc20.balanceOf(x._byBitAddress()) == 0);

        vm.startPrank(owner);
        erc20.approve(address(x), 1);
        x.deposit(1, 1, '1');
        vm.stopPrank();

        assert(erc20.balanceOf(owner) == (1 ether - 1));
        assert(erc20.balanceOf(address(x)) == 0);
        assert(erc20.balanceOf(x._byBitAddress()) == 1);
    }

    function test3_1() public {
        // Deposit with amount 0
        vm.startPrank(owner);
        erc20.approve(address(x), 1);
        vm.expectRevert(bytes("Invalid amount"));
        x.deposit(0, 1, '1');
        vm.stopPrank();
    }

    function test3_2() public {
        // Deposit with invalid trade type
        vm.startPrank(owner);
        erc20.approve(address(x), 1);
        vm.expectRevert(bytes("Invalid Trade Type"));
        x.deposit(1, 3, '1');
        vm.stopPrank();
    }

    function test3_3() public {
        // Deposit with insufficient allowance
        vm.startPrank(owner);
        vm.expectRevert(bytes("ERC20: insufficient allowance"));
        x.deposit(1, 1, '1');
        vm.stopPrank();
    }

    function test3_4() public {
        // Deposit with amount 0
        vm.startPrank(owner);
        erc20.approve(address(x), 2 ether);
        vm.expectRevert(bytes("ERC20: transfer amount exceeds balance"));
        x.deposit(2 ether, 1, '1');
        vm.stopPrank();
    }
}
