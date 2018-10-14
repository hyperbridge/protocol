"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;

var abiDecoder = _interopRequireWildcard(require("../lib/abi-decoder"));

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) { var desc = Object.defineProperty && Object.getOwnPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : {}; if (desc.get || desc.set) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } } newObj.default = obj; return newObj; } }

window.web3 = new window.Web3(new window.Web3.providers.HttpProvider("http://localhost:8545"));

class Token {
  constructor() {}

  init(contractMeta, contractAddress, fromAddress, toAddress) {
    console.log("Initializing Token contract", arguments); //web3.setProvider(new web3.providers.HttpProvider("https://ropsten.infura.io/XXXXXX"))

    this.contractMeta = contractMeta;
    this.contractAddress = contractAddress;
    this.fromAddress = fromAddress;
    this.toAddress = toAddress;
    this.nonce = 0;
    this.contract = new web3.eth.Contract(this.contractMeta.abi, this.contractAddress);
  }

  getBalance() {
    return 0;
  }

}

var _default = new Token();

exports.default = _default;