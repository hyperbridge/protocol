"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.call = exports.deployContract = exports.setContractAddress = exports.init = exports.state = void 0;

var truffleContract = _interopRequireWildcard(require("truffle-contract"));

var abiDecoder = _interopRequireWildcard(require("./lib/abi-decoder"));

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) { var desc = Object.defineProperty && Object.getOwnPropertyDescriptor ? Object.getOwnPropertyDescriptor(obj, key) : {}; if (desc.get || desc.set) { Object.defineProperty(newObj, key, desc); } else { newObj[key] = obj[key]; } } } } newObj.default = obj; return newObj; } }

function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

// const provider = new window.Web3.providers.HttpProvider("http://localhost:8545")
// window.web3 = new window.Web3(provider)
let state = {
  fromAddress: null,
  toAddress: null,
  contracts: {
    EternalStorage: {
      contract: null,
      deployed: null,
      meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/EternalStorage.json'),
      address: null
    },
    Token: {
      contract: null,
      deployed: null,
      meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/Token.json'),
      address: null
    },
    TokenDelegate: {
      contract: null,
      deployed: null,
      meta: require(__dirname + '/../../../smart-contracts/ethereum/build/contracts/TokenDelegate.json'),
      address: null
    }
  }
};
exports.state = state;

const buildContract = (meta, options) => {
  const contract = truffleContract(meta);
  contract.setProvider(provider);
  contract.defaults({
    from: options.from,
    gas: options.gas
  });
  contract.setNetwork('*'); // dirty hack for web3@1.0.0 support for localhost testrpc, see https://github.com/trufflesuite/truffle-contract/issues/56#issuecomment-331084530

  if (typeof contract.currentProvider.sendAsync !== 'function') {
    contract.currentProvider.sendAsync = function () {
      return contract.currentProvider.send.apply(contract.currentProvider, arguments);
    };
  }

  return contract;
};

const init = (fromAddress, toAddress) => {
  state.fromAddress = fromAddress;
  state.toAddress = toAddress;
};

exports.init = init;

const setContractAddress =
/*#__PURE__*/
function () {
  var _ref = _asyncToGenerator(function* (contractName, address) {
    console.log('[Token] Setting contract address for: ' + contractName + ' to ' + address);
    return yield new Promise((resolve, reject) => {
      const contract = state.contracts[contractName].contract = buildContract(state.contracts[contractName].meta, {
        from: state.fromAddress,
        gas: 6500000
      });
      contract.at(address).then(deployed => {
        state.contracts[contractName].deployed = deployed;
        state.contracts[contractName].address = deployed.address;
        resolve(deployed);
      }).catch(reject);
    });
  });

  return function setContractAddress(_x, _x2) {
    return _ref.apply(this, arguments);
  };
}();

exports.setContractAddress = setContractAddress;

const deployContract =
/*#__PURE__*/
function () {
  var _ref2 = _asyncToGenerator(function* (contractName, links, params) {
    console.log('[Token] Deploying contract for: ' + contractName);
    const contract = state.contracts[contractName].contract = buildContract(state.contracts[contractName].meta, {
      from: state.fromAddress,
      gas: 6500000
    });

    if (!links) {
      links = [];
    } //let data = meta.bytecode


    for (let i in links) {
      let link = links[i];
      contract.link(link.name, link.address); //data = data.replace(new RegExp('__' + link.name + '_+', 'g'), link.address.replace('0x', ''))
    }

    return yield new Promise(resolve => {
      contract.new(...params).then(deployed => {
        state.contracts[contractName].deployed = deployed;
        resolve(deployed);
      });
    });
  });

  return function deployContract(_x3, _x4, _x5) {
    return _ref2.apply(this, arguments);
  };
}();

exports.deployContract = deployContract;

const call =
/*#__PURE__*/
function () {
  var _ref3 = _asyncToGenerator(function* (contractName, methodName, params) {
    console.log('Calling ' + contractName + '.' + methodName + ' with params: ', params);

    if (contractName === 'test' && methodName === 'test') {} else {
      return yield new Promise(resolve => {
        const data = state.contracts[contractName].deployed.methods[methodName].apply(null, params).call({
          from: state.fromAddress,
          gas: 3000000
        }, (err, res) => {
          if (err) throw err;
          resolve(res);
        });
      });
    }
  });

  return function call(_x6, _x7, _x8) {
    return _ref3.apply(this, arguments);
  };
}();

exports.call = call;