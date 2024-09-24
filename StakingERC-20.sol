// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import OpenZeppelin's IERC20 and Ownable
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Contract for staking ERC20 tokens
contract TokenStaking is Ownable {
    // The ERC20 token being staked
    IERC20 public stakingToken;

    // Mapping of users' staked balances
    mapping(address => uint256) public stakedBalances;

    // Reward rate (for simplicity, 1:1 ratio with staking tokens)
    uint256 public rewardRate = 100; // Set a default reward rate of 100

    // Events
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    // Constructor to initialize the staking token
    constructor(IERC20 _stakingToken) Ownable() {
        stakingToken = _stakingToken; // Set the staking token
    }


    // Stake function: Allows users to stake a specific amount of tokens
    function stake(uint256 _amount) external {
        require(_amount > 0, "Cannot stake 0 tokens");
        
        // Transfer the tokens from the user to the contract
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        
        // Update the user's staked balance
        stakedBalances[msg.sender] += _amount;

        emit Staked(msg.sender, _amount);
    }

    // Withdraw function: Allows users to withdraw their staked tokens
    function withdraw(uint256 _amount) external {
        require(stakedBalances[msg.sender] >= _amount, "Insufficient balance to withdraw");
        
        // Update the user's staked balance
        stakedBalances[msg.sender] -= _amount;
        
        // Transfer the tokens from the contract back to the user
        stakingToken.transfer(msg.sender, _amount);

        emit Withdrawn(msg.sender, _amount);
    }

    // Claim rewards function: Allows users to claim their rewards
    function claimRewards() external {
        uint256 reward = stakedBalances[msg.sender] * rewardRate / 1000; // Example reward calculation
        require(reward > 0, "No rewards to claim");
        
        // Transfer rewards to the user
        stakingToken.transfer(msg.sender, reward);

        emit RewardPaid(msg.sender, reward);
    }

    // Function to adjust the reward rate (only owner can call this)
    function setRewardRate(uint256 _newRate) external onlyOwner {
        rewardRate = _newRate;
    }
}
