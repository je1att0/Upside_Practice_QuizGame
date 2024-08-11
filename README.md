# 문제 1: QuizGame 컨트랙트 구현하기

## 1.1. 전역 변수 및 함수 개요

```solidity
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

```

### 전역 변수

- `Quiz_item` : 퀴즈의 정보를 저장하는 구조체로, 퀴즈의 ID, 질문, 정답, 최소 베팅 금액, 최대 베팅 금액을 포함한다.
- `quizzes` : 퀴즈 항목들을 저장하는 배열로, 각각의 `Quiz_item`을 포함한다.
- `bets` : 각 주소가 특정 퀴즈에 대해 베팅한 금액을 추적하는 `mapping` 배열이다.
- `vault_balance` : 퀴즈에서 틀린 베팅 금액이 모이는 금고의 잔액을 나타내며, 딜러가 소유한 금액과 같은 개념이다.
- `owner` : 컨트랙트를 생성한 계정으로, 컨트랙트의 관리자인 역할을 한다. 오직 소유자만이 새로운 퀴즈를 추가할 수 있다.

### 함수 개요

- `constructor()` : 컨트랙트 생성자 함수로, 컨트랙트를 소유자를 설정하고, 초기 퀴즈를 추가한다.
- `onlyOwner` : 오직 컨트랙트 소유자만 호출할 수 있도록 제한하는 `modifier`이다.
- `addQuiz(Quiz_item memory q)` : 새로운 퀴즈를 추가하고, 해당 퀴즈에 대한 베팅 정보를 초기화한다.
- `getAnswer(uint quizId)` : 특정 퀴즈의 정답을 반환한다.
- `getQuiz(uint quizId)` : 특정 퀴즈의 정보를 반환하되, 정답은 숨긴다.
- `getQuizNum()` : 전체 퀴즈의 개수를 반환한다.
- `betToPlay(uint quizId)` : 특정 퀴즈에 대해 베팅하고, 베팅 금액을 기록한다.
- `solveQuiz(uint quizId, string memory ans)` : 퀴즈의 정답을 제출하고, 맞추면 `true`, 틀리면 `false`를 반환한다.
- `claim()` : 베팅에 성공한 경우, 당첨금을 청구할 수 있다.
- `fallback()` : 이더를 받을 수 있는 fallback 함수이다.

## 3.2. `constructor()`

- 컨트랙트를 생성할 때 호출되며, 컨트랙트 소유자를 설정한다.
- 초기 퀴즈를 생성하고 추가한다. 이 초기 퀴즈는 "1+1=?"와 같은 질문과 "2"라는 정답을 가진다.
- 퀴즈의 최소 베팅 금액은 1 이더, 최대 베팅 금액은 2 이더로 설정된다.

## 3.3. `onlyOwner`

- 오직 컨트랙트 소유자만이 호출할 수 있는 함수로 제한하며, 소유자가 아닌 경우 호출이 실패한다.

## 3.4. `addQuiz(Quiz_item memory q)`

- 새로운 퀴즈를 추가한다.
- 퀴즈 배열 `quizzes`에 새로운 퀴즈를 push하고, 해당 퀴즈에 대한 베팅 정보를 초기화하기 위해 `bets` 배열에 빈 `mapping`을 추가한다.

## 3.5. `getAnswer(uint quizId)`

- 특정 퀴즈의 정답을 반환한다.
- 퀴즈 ID를 기반으로 `quizzes` 배열에서 해당 퀴즈를 검색하여 정답을 반환한다.

## 3.6. `getQuiz(uint quizId)`

- 특정 퀴즈의 정보를 반환하되, 정답은 빈 문자열로 숨긴다.
- 퀴즈 ID를 기반으로 `quizzes` 배열에서 해당 퀴즈를 검색하여 질문과 베팅 정보를 포함한 퀴즈 정보를 반환한다.

## 3.7. `getQuizNum()`

- 전체 퀴즈의 개수를 반환한다.
- `quizzes` 배열의 길이를 반환하여 퀴즈의 총 개수를 알 수 있다.

## 3.8. `betToPlay(uint quizId)`

- 특정 퀴즈에 대해 베팅을 하고, 베팅 금액을 기록한다.
- 제출된 베팅 금액이 퀴즈의 최소 및 최대 베팅 금액 사이에 있는지 확인한다.
- 베팅 금액이 유효하면, 해당 주소의 베팅 금액을 `bets` 배열에 기록한다.

## 3.9. `solveQuiz(uint quizId, string memory ans)`

- 퀴즈의 정답을 제출하고, 제출한 답이 정답과 일치하는지 확인한다.
- 정답이 맞으면 `true`를 반환하고, 틀리면 `false`를 반환한다.
- 정답이 틀린 경우, 해당 주소의 베팅 금액이 금고 잔액(`vault_balance`)에 추가된다.

## 3.10. `claim()`

- 베팅에 성공한 경우, 당첨금을 청구할 수 있다.
- 베팅 금액의 두 배를 반환하며, 해당 주소의 베팅 기록은 초기화된다.

## 3.11. `fallback()`

- 컨트랙트가 이더를 받을 수 있도록 하는 fallback 함수이다.
