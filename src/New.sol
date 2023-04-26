// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Proof_of_Trade_Arbi_One is Ownable, Pausable {

    // Using

    using SafeERC20 for IERC20;
    using ECDSA for bytes32;

    // Global variables

    IERC20 public _usdt = IERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    address public _byBitAddress = 0x11668139AC2569b7bA34ee43Ccb13f3CEb55b098;
    address private _signerAddress = 0x960A4406d23Cb0cced0584B769bde13de60F27c5;

    mapping(bytes32 => bool) public _swapKey;

    // Events

    event UserDeposit(address indexed msgSender, string indexed id, uint indexed amount);
    event UserTradeType(string indexed id, uint indexed amount, uint indexed tradeType);
    event RewardClaimed(address indexed msgSender, uint indexed amount, bytes32 indexed message, string timestamp, bytes signature);

    // Admin functions

    function setUsdt(address usdt_) external onlyOwner {
        _usdt = IERC20(usdt_);
    }

    function setByBitAddress(address byBitAddress_) external onlyOwner {
        _byBitAddress = byBitAddress_;
    }

    function setSignerAddress(address signerAddress_) external onlyOwner {
        _signerAddress = signerAddress_;
    }

    // External functions

    function Deposit(
        uint amount_,
        uint tradeType_,
        string memory id_
    ) external whenNotPaused {
        require(amount_ > 0, "Invalid amount");
        require(tradeType_ == 1 || tradeType_ == 2, "Invalid Trade Type");
        _usdt.safeTransferFrom(msg.sender, address(this), amount_);
        _usdt.safeTransfer(_byBitAddress, amount_);
        emit UserDeposit(msg.sender, id_, amount_);
        emit UserTradeType(id_, amount_, tradeType_);
    }

    function Claim(
        string calldata timestamp_,
        bytes calldata signature_,
        uint amount_
    ) external whenNotPaused {
        require(amount_ > 0, "Invalid amount");
        bytes32 message =  keccak256(abi.encode(timestamp_, amount_, msg.sender));
        require(!_swapKey[message], "Key Already Claimed");
        require(isValidData(timestamp_, amount_, msg.sender, signature_), "Invalid Signature");
        _swapKey[message] = true;
        _usdt.safeTransfer(msg.sender, amount_);
        emit RewardClaimed(msg.sender, amount_, message, timestamp_, signature_);
    }

    function isValidData(
        string calldata timestamp_,
        uint amount_,
        address msgSender,
        bytes memory sig_
    ) public view returns (bool) {
        bytes32 message =  keccak256(abi.encode(timestamp_, amount_, msgSender));
        return message
        .toEthSignedMessageHash()
        .recover(sig_) == _signerAddress;
    }
}