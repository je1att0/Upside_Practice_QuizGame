// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    Quiz_item[] public quizzes;
    mapping(address => uint256)[] public bets;
    uint public vault_balance;
    address public owner;

    constructor () {
        owner = msg.sender;
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function addQuiz(Quiz_item memory q) public onlyOwner{
        quizzes.push(q);
        bets.push();
    }

    function getAnswer(uint quizId) public view returns (string memory){
        Quiz_item memory q = quizzes[quizId-1];
        return q.answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory q = quizzes[quizId-1];
        q.answer = "";
        return q;
    }

    function getQuizNum() public view returns (uint){
        return quizzes.length;
    }
    
    function betToPlay(uint quizId) public payable {
        Quiz_item memory q = quizzes[quizId-1];
        require(msg.value >= q.min_bet && msg.value <= q.max_bet, "Invalid bet amount");
        bets[0][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        Quiz_item memory q = quizzes[quizId-1];
        if (keccak256(abi.encodePacked(ans)) == keccak256(abi.encodePacked(q.answer))) {
            return true;
        }
        else {
            vault_balance += bets[0][msg.sender];
            bets[0][msg.sender] = 0;
            return false;
        }
    }

    function claim() public {
        uint amount = bets[0][msg.sender];
        require(amount > 0, "No balance to claim");
        bets[0][msg.sender] = 0;
        payable(msg.sender).transfer(amount*2);
    }
    
    fallback() external payable {}

}
