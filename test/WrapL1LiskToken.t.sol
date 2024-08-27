// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {Test} from "../lib/forge-std/src/Test.sol";
import {Wrap_L1LiskToken} from "../src/L1/WrapL1LiskToken.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract WrapL1LiskTokenTest is Test {
    Wrap_L1LiskToken token;
    address owner = address(1);
    address burner = address(2);
    address user = address(3);

    function setUp() public {
        vm.startPrank(owner);
        token = new Wrap_L1LiskToken();
        vm.stopPrank();
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 300_000_000 * 10 ** 18);
        assertEq(token.balanceOf(owner), 300_000_000 * 10 ** 18);
    }

    function testOwnerCanAddBurner() public {
        vm.prank(owner);
        token.addBurner(burner);
        assertTrue(token.isBurner(burner));
    }

    function testNonOwnerCannotAddBurner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        token.addBurner(burner);
    }

    function testOwnerCanRemoveBurner() public {
        vm.prank(owner);
        token.addBurner(burner);
        assertTrue(token.isBurner(burner));

        vm.prank(owner);
        token.renounceBurner(burner);
        assertFalse(token.isBurner(burner));
    }

    function testBurnerCanBurnTokens() external {
        vm.prank(owner);
        token.addBurner(burner);

        vm.startPrank(burner);
        token.burn(1_000 * 10 ** 18);
        assertEq(token.balanceOf(owner), 299_999_000 * 10 ** 18);
        vm.stopPrank();
    }

    function testNonBurnerCannotBurnTokens() public {
        vm.expectRevert(
            "AccessControl: account is missing role 0x3c7a05c3dce2b8e27a1eb8dbcc844b91f9f7e1d2e6f8f8a7e25d123b10987cc3"
        );
        token.burn(1_000 * 10 ** 18);
    }

    function testBurnerCanBurnTokensFrom() public {
        vm.prank(owner);
        token.addBurner(burner);

        vm.prank(owner);
        token.approve(burner, 2_000 * 10 ** 18);

        vm.startPrank(burner);
        token.burnFrom(owner, 1_000 * 10 ** 18);
        assertEq(token.balanceOf(owner), 299_999_000 * 10 ** 18);
        vm.stopPrank();
    }

    function testNonBurnerCannotBurnTokensFrom() public {
        vm.prank(owner);
        token.approve(user, 2_000 * 10 ** 18);

        vm.expectRevert(
            "AccessControl: account is missing role 0x3c7a05c3dce2b8e27a1eb8dbcc844b91f9f7e1d2e6f8f8a7e25d123b10987cc3"
        );
        vm.prank(user);
        token.burnFrom(owner, 1_000 * 10 ** 18);
    }
}
