"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;

var abiDecoder = _interopRequireWildcard(require("../lib/abi-decoder"));

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) { var desc = Object.defineProperty && Object.getOwnPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : {}; if (desc.get || desc.set) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } } newObj.default = obj; return newObj; } }

function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

window.web3 = new window.Web3(new window.Web3.providers.HttpProvider("http://localhost:8545"));

class Marketplace {
  constructor() {}

  init(contractMeta, contractAddress, fromAddress, toAddress) {
    console.log("Initializing Marketplace contract", arguments); //web3.setProvider(new web3.providers.HttpProvider("https://ropsten.infura.io/XXXXXX"))

    this.contractMeta = contractMeta;
    this.contractAddress = contractAddress;
    this.fromAddress = fromAddress;
    this.toAddress = toAddress;
    this.nonce = 0;
    this.contract = new web3.eth.Contract(this.contractMeta.abi, this.contractAddress);
  }

  createProduct({
    name,
    version,
    category,
    files,
    checksum,
    permissions
  }) {
    var _this = this,
        _arguments = arguments;

    return _asyncToGenerator(function* () {
      console.log('Calling Marketplace.createProduct: ', _arguments);
      return yield new Promise(resolve => {
        _this.contract.methods.submitAppForReview(name, web3.utils.asciiToHex(version), category, files, checksum, permissions).send({
          from: _this.fromAddress,
          gas: 3000000
        }).on('receipt', receipt => {
          resolve(receipt.events.AppSubmitted.returnValues.id);
        });
      });
    })();
  }

  updateProduct({
    id,
    name,
    version,
    category,
    files,
    checksum,
    permissions
  }) {
    var _this2 = this,
        _arguments2 = arguments;

    return _asyncToGenerator(function* () {
      console.log('Calling Marketplace.updateProduct: ', _arguments2);
      return yield new Promise(resolve => {
        _this2.contract.methods.submitVersionForReview(id, web3.utils.asciiToHex(version), files, checksum, permissions).send({
          from: _this2.fromAddress,
          gas: 3000000
        }).on('receipt', receipt => {
          resolve(receipt.events.VersionSubmitted.returnValues.app_id);
        });
      });
    })();
  }

  voteForApp(id, version, vote) {
    var _this3 = this,
        _arguments3 = arguments;

    return _asyncToGenerator(function* () {
      console.log('Calling Marketplace.voteForApp with arguments: ', _arguments3);
      return yield new Promise(resolve => {
        _this3.contract.methods.voteForApp(id, web3.utils.asciiToHex(version), vote).send({
          from: _this3.fromAddress,
          gas: 3000000
        }).on('receipt', receipt => {
          resolve();
        });
      });
    })();
  }

  updateAppVotes(id, version) {
    var _this4 = this,
        _arguments4 = arguments;

    return _asyncToGenerator(function* () {
      console.log('Calling Marketplace.updateAppVotes with arguments: ', _arguments4);
      return yield new Promise(resolve => {
        _this4.contract.methods.updateAppVotes(id, web3.utils.asciiToHex(version)).send({
          from: _this4.fromAddress,
          gas: 3000000
        }).on('receipt', receipt => {
          resolve();
        });
      });
    })();
  }

  listApps(page, offset) {
    var _this5 = this,
        _arguments5 = arguments;

    return _asyncToGenerator(function* () {
      console.log('Calling Marketplace.listApps with arguments: ', _arguments5);
      return yield new Promise(resolve => {
        const data = _this5.contract.methods.listApps(page, offset).call({
          from: _this5.fromAddress,
          gas: 3000000
        }, (err, res) => {
          if (err) throw err;
          resolve(res);
        });
      });
    })();
  }

  getApp(id) {
    var _this6 = this,
        _arguments6 = arguments;

    return _asyncToGenerator(function* () {
      console.log('Calling Marketplace.getApp with arguments: ', _arguments6);
      return yield new Promise(resolve => {
        const data = _this6.contract.methods.getLatestVersion(id).call({
          from: _this6.fromAddress,
          gas: 3000000
        }, (err, res) => {
          if (err) throw err;
          resolve(res);
        });
      });
    })();
  }

  getBalance() {
    return 0;
  }

}

var _default = new Marketplace();

exports.default = _default;