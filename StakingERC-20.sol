// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Staking is Ownable {
    // The token being staked (must follow ERC20 standard)
    IERC20 public stakingToken;
    
    // The reward rate per block (used to calculate staking rewards)
    uint256 public rewardRatePerBlock;

    // Struct to hold information about each staker
    struct Staker {
        uint256 amountStaked;    // Total amount of tokens staked by the user
        uint256 rewardDebt;      // Reward amount the user has already earned but not yet claimed
        uint256 lastBlockStaked; // Block number when the user last updated their stake
    }

    // Mapping from user address to their staking information
    mapping(address => Staker) public stakers;
    
    // Total amount of tokens staked in the contract
    uint256 public totalStaked;

    // Events to log staking, withdrawal, and rewards claiming actions
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 reward);

    // Constructor to initialize the staking token and reward rate
    constructor(IERC20 _stakingToken, uint256 _rewardRatePerBlock) {
        stakingToken = _stakingToken;
        rewardRatePerBlock = _rewardRatePerBlock;
    }

    // Function to compare two strings using keccak256 hashing
    function compareStrings(string memory string1, string memory string2) public pure returns (bool) {
        return keccak256(abi.encodePacked(string1)) == keccak256(abi.encodePacked(string2));
    }

    // Function for users to stake tokens in the contract
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        Staker storage staker = stakers[msg.sender];

        // If the user has already staked before, calculate and update their pending rewards
        if (staker.amountStaked > 0) {
            uint256 pendingReward = _pendingReward(msg.sender);
            staker.rewardDebt += pendingReward;
        }

        // Transfer the staking tokens from the user's wallet to the contract
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        
        // Update the user's staking information
        staker.amountStaked += _amount;
        staker.lastBlockStaked = block.number;
        totalStaked += _amount;

        emit Staked(msg.sender, _amount);
    }

    // Function for users to withdraw their staked tokens from the contract
    function withdraw(uint256 _amount) external {
        Staker storage staker = stakers[msg.sender];
        require(staker.amountStaked >= _amount, "Not enough staked tokens");

        // Calculate the pending rewards before the withdrawal
        uint256 pendingReward = _pendingReward(msg.sender);
        staker.rewardDebt += pendingReward;

        // Update the staking amount and transfer the tokens back to the user
        staker.amountStaked -= _amount;
        stakingToken.transfer(msg.sender, _amount);
        totalStaked -= _amount;

        emit Withdrawn(msg.sender, _amount);
    }

    // Function for users to claim their staking rewards
    function claimRewards() external {
        Staker storage staker = stakers[msg.sender];
        uint256 pendingReward = _pendingReward(msg.sender);
        uint256 totalReward = pendingReward + staker.rewardDebt;

        require(totalReward > 0, "No rewards to claim");

        // Reset the user's reward debt and update the last staking block
        staker.rewardDebt = 0;
        staker.lastBlockStaked = block.number;

        // Transfer the rewards to the user
        stakingToken.transfer(msg.sender, totalReward);

        emit RewardsClaimed(msg.sender, totalReward);
    }

    // Internal function to calculate the pending rewards for a user
    function _pendingReward(address _staker) internal view returns (uint256) {
        Staker storage staker = stakers[_staker];
        uint256 blocksStaked = block.number - staker.lastBlockStaked;
        return staker.amountStaked * rewardRatePerBlock * blocksStaked / 1e18;
    }

    // Function for the contract owner to set a new reward rate
    function setRewardRate(uint256 _newRate) external onlyOwner {
        rewardRatePerBlock = _newRate;
    }
}
