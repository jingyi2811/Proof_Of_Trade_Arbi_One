// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import "../MyERC20.sol";
import "../New.sol";

contract PausibleTest is DSTest {
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

    function test1_1() public {
        // Default
        vm.startPrank(owner);
        erc20.approve(address(x), 1);
        x.Deposit(1, 1, '1');
        vm.stopPrank();

        // Pause
        vm.startPrank(owner);
        x.pauseProtocol();
        erc20.approve(address(x), 1);
        vm.expectRevert("Pausable: paused");
        x.Deposit(1, 1, '1');
        vm.stopPrank();

        // UnPause
        vm.startPrank(owner);
        x.unpauseProtocol();
        erc20.approve(address(x), 1);
        x.Deposit(1, 1, '1');
        vm.stopPrank();
    }
}
