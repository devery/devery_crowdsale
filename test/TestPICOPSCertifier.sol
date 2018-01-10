pragma solidity ^0.4.18;

contract TestPICOPSCertifier {
    function certified(address addr) public view returns (bool) {
        return (addr == 0xa44a08d3F6933c69212114bb66E2Df1813651844 || addr == 0xa77A2b9D4B1c010A22A7c565Dc418cef683DbceC);
    }
}