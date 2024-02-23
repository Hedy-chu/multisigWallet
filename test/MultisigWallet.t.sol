// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MultisigWallet} from "../src/MultisigWallet.sol";
import {Counter} from "../src/Counter.sol";

contract MultisigWalletTest is Test {
    MultisigWallet public multisigWallet;
    Counter public counter;
    address hedy = makeAddr("hedy");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address kaka = makeAddr("kaka");
    address geyi = makeAddr("geyi");
    address[] owners;

    function setUp() public {
        deal(alice, 10 ether);
        owners.push(hedy);
        owners.push(alice);
        owners.push(bob);
        owners.push(kaka);
        multisigWallet = new MultisigWallet(owners, 2);
        counter = new Counter();
        assertEqUint(multisigWallet.numOfConfirmed(), 2);
    }

    function testCreat() public {
        vm.startPrank(hedy);
        {
            bytes memory data = abi.encodeWithSignature(
                "setNumber(uint256)",
                100
            );
            uint length = multisigWallet.creatTranscation(
                address(counter),
                0,
                data
            );
            console.log(length);
            assertEq(length, 1);
        }
        vm.stopPrank();
    }

    function testConfirm(address user, uint txIndex) public {
        vm.startPrank(user);
        {
            multisigWallet.confirmTranscation(txIndex);
        }
    }

    function testExecute(address user, uint txIndex) public {
        vm.startPrank(user);
        {
            multisigWallet.excuteTranscation(txIndex);
        }
    }

    function testTotal() public {
        testCreat();
        testConfirm(address(alice), 0);
        // testConfirm(address(alice),1); // 验证交易是否存在
        assertTrue(multisigWallet.isConfirm(0, (address(alice))));
        // testConfirm(address(alice)); 验证重复confirm
        testExecute(address(alice), 0);
        console.log(counter.number());
        assertEq(counter.number(), 100);
        // testExecute(address(alice)); 验证重复execute
    }
}
