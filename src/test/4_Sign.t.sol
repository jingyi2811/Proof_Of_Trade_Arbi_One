// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import "../MyERC20.sol";
import "../New.sol";

contract SignTest is DSTest {
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
       x.setSignerAddress(vm.addr(1)); // Set signer to address which has private key = 1
       owner = x.owner();

       vm.prank(x.owner());
       erc20.transfer(address(x), 2);
       vm.stopPrank();
    }

    function test4_0() public {
        address alice = vm.addr(1); // Set alice as signer

        string memory timestamp = Strings.toString(block.timestamp);
        uint amount = 1;
        address msgSender = address(0x11);

        bytes32 message = keccak256(abi.encode(timestamp, amount, msgSender)); // Construct message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, message); // Sign by alice

        address signer = ecrecover(message, v, r, s);
        assertEq(alice, signer);
        assertEq(message, x.getMessage(timestamp, amount, msgSender)); // Check getMessage function

        bytes memory signature = abi.encodePacked(r, s, v); // recover signature

        vm.startPrank(msgSender);
        x.claim(timestamp, signature, amount);
        vm.stopPrank();

        // Try to claim again
        vm.startPrank(msgSender);
        vm.expectRevert(bytes("Key Already Claimed"));
        x.claim(timestamp, signature, amount);
        vm.stopPrank();

        // Pause protocol and claim again
        vm.startPrank(x.owner());
        x.pauseProtocol();
        vm.expectRevert(bytes("Pausable: paused"));
        x.claim(timestamp, signature, amount);
        vm.stopPrank();
    }

    function test4_1() public {

        // Test invalid amount

        address alice = vm.addr(1); // Set alice as signer

        string memory timestamp = Strings.toString(block.timestamp);
        uint amount = 0;
        address msgSender = address(0x11);

        bytes32 message = keccak256(abi.encode(timestamp, amount, msgSender)); // Construct message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, message); // Sign by alice

        address signer = ecrecover(message, v, r, s);
        assertEq(alice, signer);
        assertEq(message, x.getMessage(timestamp, amount, msgSender)); // Check getMessage function

        bytes memory signature = abi.encodePacked(r, s, v); // recover signature

        vm.startPrank(msgSender);
        vm.expectRevert(bytes("Invalid amount"));
        x.claim(timestamp, signature, amount);
        vm.stopPrank();
    }

    function test4_2() public {

        // Test invalid signature

        address alice = vm.addr(1); // Set alice as signer

        string memory timestamp = Strings.toString(block.timestamp);
        uint amount = 1;
        address msgSender = address(0x11);

        bytes32 message = keccak256(abi.encode(timestamp, amount, msgSender)); // Construct message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, message); // Sign by alice

        address signer = ecrecover(message, v, r, s);
        assertEq(alice, signer);
        assertEq(message, x.getMessage(timestamp, amount, msgSender)); // Check getMessage function

        bytes memory signature = abi.encodePacked(r, s, v); // recover signature with wrong order

        vm.startPrank(msgSender);
        vm.expectRevert(bytes("Invalid Signature"));
        x.claim(timestamp, signature, 2);
        vm.stopPrank();
    }

    function test4_3() public {
        // What happened if no balance

        address alice = vm.addr(1); // Set alice as signer

        string memory timestamp = Strings.toString(block.timestamp);
        uint amount = 3;
        address msgSender = address(0x11);

        bytes32 message = keccak256(abi.encode(timestamp, amount, msgSender)); // Construct message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, message); // Sign by alice

        address signer = ecrecover(message, v, r, s);
        assertEq(alice, signer);
        assertEq(message, x.getMessage(timestamp, amount, msgSender)); // Check getMessage function

        bytes memory signature = abi.encodePacked(r, s, v); // recover signature

        vm.startPrank(msgSender);
        vm.expectRevert(bytes("ERC20: transfer amount exceeds balance"));
        x.claim(timestamp, signature, amount);
        vm.stopPrank();
    }

    function test4_4() public {
        // What happened if timestamp value contribute to amount?

        address alice = vm.addr(1); // Set alice as signer

        string memory timestamp = "1234";
        uint amount = 3;
        address msgSender = address(0x11);

        bytes32 message = keccak256(abi.encode(timestamp, amount, msgSender)); // Construct message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, message); // Sign by alice

        address signer = ecrecover(message, v, r, s);
        assertEq(alice, signer);
        assertEq(message, x.getMessage(timestamp, amount, msgSender)); // Check getMessage function

        bytes memory signature = abi.encodePacked(r, s, v); // recover signature

        vm.startPrank(msgSender);
        vm.expectRevert(bytes("Invalid Signature"));
        x.claim("123", signature, 43);
        vm.stopPrank();
    }
}
