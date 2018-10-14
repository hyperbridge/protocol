pragma solidity ^0.4.24;

library StringUtils {
    function equals(string _string1, string _string2) external pure returns (bool) {
        bool sameLength = bytes(_string1).length == bytes(_string2).length;
        bool sameHash = keccak256(abi.encodePacked(_string1)) == keccak256(abi.encodePacked(_string2));

        return sameLength && sameHash;
    }
}
