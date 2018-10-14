pragma solidity ^0.4.24;

library BytesUtils {

    uint private constant BYTES_HEADER_SIZE = 32; // Can't actually use constants within in-line assembly but figured it'd be good to define anyways

    function toBytes32(bytes _bytes) external pure returns (bytes32 retBytes32) {
        if (_bytes.length == 0) {
            return bytes32(0);
        }

        bytes memory inBytes = _bytes;

        assembly {
            retBytes32 := mload(add(inBytes, /* BYTES_HEADER_SIZE */ 32))
        }
    }
}
