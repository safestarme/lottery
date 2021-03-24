pragma solidity ^0.6.0;
// SPDX-License-Identifier: Unlicensed

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Lottery {
    using SafeMath for uint256;
    
    uint256[] private luckyNum;
    uint256 private participantsNum;
    uint256 private winnersNum;
    uint256 private ticket =  0;
    address private _owner;
    bool private lotteryLive = true;
    
    uint256 private ticketsLimit = 99;
    uint256 private ticketPrice = 1000000000000000; // 0.001
    
    constructor() public{
        _owner = msg.sender;
    }
    
    modifier _ownerOnly() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    event ReturnValue(address indexed _from, uint256 _value, uint256 ticket);
    
    function buyTicket() external payable {
        require(lotteryLive == true, "Lottery stoped");
        require(msg.value == ticketPrice, "Wrong amount");
        require(ticket <= ticketsLimit, "No more tickets left");
        
        ticket++;
        emit ReturnValue(msg.sender, msg.value, ticket);
    }
    
    function sendPrize(address payable recipient, uint256 amount) external _ownerOnly {
        recipient.transfer(amount);
    }

    function drawLuckyNumbers(uint256 _participants, uint256 _winners) external _ownerOnly {
        participantsNum = _participants;
        winnersNum = _winners;
        
        uint256 bStamp = block.timestamp;
        uint256 bNumber = block.number;
        uint256 bDifficulty = block.difficulty;
        
        delete luckyNum;

        uint256 seed = bStamp.add(bDifficulty).add(bNumber).add(_participants).add(_winners);
        uint256 randomN = uint256(keccak256(abi.encodePacked(seed)));
    
        while(luckyNum.length < _winners){
            uint256 digit=randomN % _participants + 1;
            bool found=false;
            
            for (uint256 k=0; k<luckyNum.length; k++) {
                if(luckyNum[k] == digit){
                    found=true;
                    break;
                }
            }
            
            if(found == false){luckyNum.push(digit);}
            
            randomN /= 25;
        }
    }
    
    function stopLottery() external _ownerOnly {
        lotteryLive = false;
    }
    
    function luckyNumbers() public view returns(uint256[] memory) {
        return luckyNum;
    }
    
    function participants() public view returns(uint256) {
        return ticket;
    }
    
    function winners() public view returns(uint256) {
        return winnersNum;
    }
    
    function priceOfTicket() public view returns(uint256) {
        return ticketPrice;
    }
    
    function maxTickets() public view returns(uint256) {
        return ticketsLimit + 1;
    }
}