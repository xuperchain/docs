Js SDK 接入指南
=====================

JS SDK 连接开放网络与 Go SDK 有些许不同之处，主要在配置文件，JS SDK 不需要配置文件，只需要在创建客户端时指定参数即可。

下载私钥
>>>>>>>>

在开放网络上创建账户后，会为用户生成加密的私钥，使用时需要使用密码解密后才可使用。

登录到开放网络后，通过控制台可以下载个人账户的私钥文件

   .. image:: ../images/xuperos-private-key-dl.png
    :align: center

引入SDK
>>>>>>>

.. code-block:: bash
    :linenos:

      npm install --save @xuperchain/xuper-sdk

加载私钥
>>>>>>>

.. code-block:: JavaScript
    :linenos:

    const {default:XuperSDK,Endorsement} = require("@xuperchain/xuper-sdk")

    const xsdk = XuperSDK.getInstance()

    // 其中最后一个参数 true 代表缓存起来，之后 sdk 发送交易默认使用本次 import 的账户。
    const acc = xsdk.import("你的密码", "你的私钥文件内容", true);


连接开放网络
>>>>>>>>>>

.. code-block:: JavaScript
    :linenos:

    const {default:XuperSDK,Endorsement} = require("@xuperchain/xuper-sdk")

    // 连接开放网络可选择 grpc 与 http方式，本文采用http方式
    // grpc 地址: 39.156.69.83:37100
    const node = 'https://xuper.baidu.com/nodeapi'; // node
    const chain = 'xuper'; // chain

    // 背书服务插件，连接开放网络必须加载背书服务插件
    // 如果node 采用grpc方式，背书服务插件的 server 应与node保持一致
    const params = {
        server: "https://xuper.baidu.com/nodeapi",
        fee: "400", // 服务费
        endorseServiceCheckAddr: "jknGxa6eyum1JrATWvSJKW3thJ9GKHA9n",
        endorseServiceFeeAddr: "aB2hpHnTBDxko3UoP2BpBZRujwhdcAFoT"
    }
    const plugins = [
        Endorsement({
            transfer: params,
            makeTransaction: params
        })
    ];
    const xsdk = XuperSDK.getInstance({
        node,
        chain,
        env:{
            node:{
                disableGRPC:true // 如使用http方式连接开放网络，需要禁用grpc
            }
        },
        plugins
    });

此时你的 SDK client 便连接到了开放网络，可以进行部署、调用合约了

合约部署
>>>>>>>

.. note::
    - 开放网络目前仅支持部署EVM合约与c++ wasm合约。
    - 本文测试采用EVM counter 合约作为示例，合约内容见：`Counter <https://github.com/xuperchain/contract-example-evm/blob/main/counter/Counter.sol>`_


.. code-block:: JavaScript
  :linenos:

  const {default:XuperSDK,Endorsement} = require("@xuperchain/xuper-sdk")

  const node = 'https://xuper.baidu.com/nodeapi';
  const chain = 'xuper';
  const params = {
      server: "https://xuper.baidu.com/nodeapi",
      fee: "400",
      endorseServiceCheckAddr: "jknGxa6eyum1JrATWvSJKW3thJ9GKHA9n",
      endorseServiceFeeAddr: "aB2hpHnTBDxko3UoP2BpBZRujwhdcAFoT"
  }
  const plugins = [
      Endorsement({
          transfer: params,
          makeTransaction: params
      })
  ];
  const xsdk = XuperSDK.getInstance({
      node,
      chain,
      env:{
          node:{
              disableGRPC:true
          }
      },
      plugins
  });

  const acc = xsdk.import("安全码","开放网络私钥内容",true)

  const contractAccount = "开放网络工作台注册的合约账户"

  // evm 合约的 abi 以及 bin。这里只是示例，你可以编写自己的合约，然后编译出 abi 和 bin。
  const abi = "[{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"constant":true,"inputs":[{"internalType":"string","name":"key","type":"string"}],"name":"get","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getOwner","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"string","name":"key","type":"string"}],"name":"increase","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"internalType":"string","name":"a","type":"string"},{"internalType":"string","name":"b","type":"string"}],"name":"join","outputs":[{"internalType":"string","name":"c","type":"string"},{"internalType":"string","name":"d","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]";
  const bin = "608060405234801561001057600080fd5b50336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506106ef806100606000396000f3fe60806040526004361061003f5760003560e01c806329803b2114610044578063693ec85e14610288578063893d20e814610364578063ae896c87146103bb575b600080fd5b34801561005057600080fd5b506101a16004803603604081101561006757600080fd5b810190808035906020019064010000000081111561008457600080fd5b82018360208201111561009657600080fd5b803590602001918460018302840111640100000000831117156100b857600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505091929192908035906020019064010000000081111561011b57600080fd5b82018360208201111561012d57600080fd5b8035906020019184600183028401116401000000008311171561014f57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290505050610476565b604051808060200180602001838103835285818151815260200191508051906020019080838360005b838110156101e55780820151818401526020810190506101ca565b50505050905090810190601f1680156102125780820380516001836020036101000a031916815260200191505b50838103825284818151815260200191508051906020019080838360005b8381101561024b578082015181840152602081019050610230565b50505050905090810190601f1680156102785780820380516001836020036101000a031916815260200191505b5094505050505060405180910390f35b34801561029457600080fd5b5061034e600480360360208110156102ab57600080fd5b81019080803590602001906401000000008111156102c857600080fd5b8201836020820111156102da57600080fd5b803590602001918460018302840111640100000000831117156102fc57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050919291929050505061049d565b6040518082815260200191505060405180910390f35b34801561037057600080fd5b50610379610510565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b610474600480360360208110156103d157600080fd5b81019080803590602001906401000000008111156103ee57600080fd5b82018360208201111561040057600080fd5b8035906020019184600183028401116401000000008311171561042257600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290505050610539565b005b606080836002908051906020019061048f929190610615565b508284915091509250929050565b60006001826040518082805190602001908083835b602083106104d557805182526020820191506020810190506020830392506104b2565b6001836020036101000a0380198251168184511680821785525050505050509050019150509081526020016040518091039020549050919050565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b600180826040518082805190602001908083835b60208310610570578051825260208201915060208101905060208303925061054d565b6001836020036101000a038019825116818451168082178552505050505050905001915050908152602001604051809103902054016001826040518082805190602001908083835b602083106105db57805182526020820191506020810190506020830392506105b8565b6001836020036101000a03801982511681845116808217855250505050505090500191505090815260200160405180910390208190555050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061065657805160ff1916838001178555610684565b82800160010185558215610684579182015b82811115610683578251825591602001919060010190610668565b5b5090506106919190610695565b5090565b6106b791905b808211156106b357600081600090555060010161069b565b5090565b9056fea265627a7a72315820cf953dc1839436e254d5a3c4c228d708600f054f50da1950ddc1960647386ef364736f6c63430005110032";


  // 在部署其他合约时请使用 xsdk.deployContract()
  const start = async () => {
      try {
          const demo = await xsdk.deploySolidityContract(
            contractAccount,            // 合约账户
            'counter',                  // 合约名字
            bin,                        // evm 合约 bin
            abi,                        // evm 合约 abi
            "evm",
            {
               "creator": contractAccount      // 合约有初始化参数
            },
            acc
          );
          const res = await xsdk.postTransaction(demo.transaction);
          console.log(demo)
      }
      catch (e){
          console.log(e)
      }

  };


  start()


合约调用
>>>>>>>

.. note::
  - EVM合约，请使用 **xsdk.invokeSolidityContarct()**
  - 其他合约，请使用 **xsdk.invokeContract()**


.. code-block:: JavaScript
  :linenos:

  const {default:XuperSDK,Endorsement} = require("@xuperchain/xuper-sdk")

  const node = 'https://xuper.baidu.com/nodeapi';
  const chain = 'xuper';
  const params = {
      server: "https://xuper.baidu.com/nodeapi",
      fee: "400",
      endorseServiceCheckAddr: "jknGxa6eyum1JrATWvSJKW3thJ9GKHA9n",
      endorseServiceFeeAddr: "aB2hpHnTBDxko3UoP2BpBZRujwhdcAFoT"
  }
  const plugins = [
      Endorsement({
          transfer: params,
          makeTransaction: params
      })
  ];
  const xsdk = XuperSDK.getInstance({
      node,
      chain,
      env:{
          node:{
              disableGRPC:true
          }
      },
      plugins
  });

  const acc = xsdk.import("安全码","开放网络私钥内容",true)
  const contractName = "Counter"
  const contractMethod = "increase"

  const start = async () => {
      try {
          const demo = await xsdk.invokeSolidityContarct(
            contractName,                  // 合约名字
            contractMethod,               // 合约方法
            "evm",
            {
               "key": "xuperos"      // 合约参数
            },
            "0",
            acc
          );
          const res = await xsdk.postTransaction(demo.transaction);
          console.log(demo)
      }
      catch (e){
          console.log(e)
      }

  };


  start()

具体接口文档参考 `JS SDK 使用文档 <../development_manuals/xuper-sdk-js.html>`_  。
