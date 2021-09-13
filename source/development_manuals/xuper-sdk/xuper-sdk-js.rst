JS SDK 使用说明
====================

下载
----------
JS SDK 代码可在github上下载：`JS SDK <https://github.com/xuperchain/xuper-sdk-js>`_，可以查看详细的 `接口文档 <https://xuperchain.github.io/xuper-sdk-js/classes/xupersdk.html>`_


安装
----------
- npm install --save @xuperchain/xuper-sdk

使用 SDK
----------
接下来你可以使用 JS SDK 进行合约的部署以及合约的调用等操作。首先你需要使用 SDK 与节点创建一个 client。

.. code-block:: js
    :linenos:

    import XuperSDK from '@xuperchain/xuper-sdk';
      const node = '127.0.0.1:37101'; // node
      const chain = 'xuper'; // chain
      const xsdk = XuperSDK.getInstance({
        node,
        chain
    });

默认 JS sdk 会与节点之间使用 gRPC，你可以选择使用 http 方式：

.. code-block:: js
    :linenos:

    const xsdk = XuperSDK.getInstance({
      const node = '127.0.0.1:37101'; // node
      const chain = 'xuper'; // chain
      env: {
        node: {
            disableGRPC: true // disable gRPC
        }
      }
    });

账户
----------
你可以使用 SDK 创建一个账户，同时记录下对应的助记词，或者保存好私钥文件：

.. code-block:: js
    :linenos:

    const acc = xsdk.create();
    console.log(acc.mnemonic);
    console.log(acc.address);

默认创建的助记词长度为12，并且为中文，你可以修改参数来指定其他长度或者英文：

.. code-block:: js
    :linenos:

    const acc = xsdk.create(Language.English, Strength.Middle);
    console.log(acc.mnemonic);
    console.log(acc.address);

创建账户之后你同样可以通过助记词来恢复账户，恢复账户时助记词难度级别、语言需要和创建时保持一直：

.. code-block:: js
    :linenos:

    const acc = xsdk.retrieve('fork remind carry tennis flavor draw island decrease salute hamster cool parrot circle twist width humor genre mammal', Language.English);
    console.log(acc.mnemonic);
    console.log(acc.address);

如果你的账户私钥是从开放网络下载的，那么会有对应的密码，你可以将私钥文件内容读取出来，然后用密码加载账户：

.. code-block:: js
    :linenos:

    // 其中最后一个参数 true 代表缓存起来，之后 sdk 发送交易默认使用本次 import 的账户。
    const acc = xsdk.import("你的密码", "你的私钥文件内容", true);

除此之外，SDK 还支持导出账户、检查地址和助记词以等，更多功能可以参考 `接口文档 <https://xuperchain.github.io/xuper-sdk-js/classes/xupersdk.html#create>`_

合约
----------
有了账户之后，便可以向链上发送交易（前提是账户有足够的余额），接下来便可以进行部署、调用合约的完整流程。

合约账户
^^^^^^^^^^^^^^
部署合约之前，首先需要创建一个合约账户（形如：XC8888888888888888@xuper），同时转账给合约账户：

.. code-block:: js
    :linenos:

    var num = new Number(8888888888888888);
    const demo = await xsdk.createContractAccount(num);
    await xsdk.postTransaction(demo.transaction);

    // 转账给合约账户
    const tx = await xsdk.transfer({
            to: 'XC8888888888888888@xuper',
            amount: '1000000000',
            fee: '1000'
        });
    await xsdk.postTransaction(tx);

部署合约
^^^^^^^^^^^^^^
有了合约账户后便可以部署合约，合约的编写、编译等这里不再赘述。你可以使用 SDK 来部署你的合约：
    
.. code-block:: js
    :linenos:
    
    // evm 合约的 abi 以及 bin。这里只是示例，你可以编写自己的合约，然后编译出 abi 和 bin。
    const abi = "[{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"constant":true,"inputs":[{"internalType":"string","name":"key","type":"string"}],"name":"get","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getOwner","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"string","name":"key","type":"string"}],"name":"increase","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"internalType":"string","name":"a","type":"string"},{"internalType":"string","name":"b","type":"string"}],"name":"join","outputs":[{"internalType":"string","name":"c","type":"string"},{"internalType":"string","name":"d","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]";
    const bin = "608060405234801561001057600080fd5b50336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506106ef806100606000396000f3fe60806040526004361061003f5760003560e01c806329803b2114610044578063693ec85e14610288578063893d20e814610364578063ae896c87146103bb575b600080fd5b34801561005057600080fd5b506101a16004803603604081101561006757600080fd5b810190808035906020019064010000000081111561008457600080fd5b82018360208201111561009657600080fd5b803590602001918460018302840111640100000000831117156100b857600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505091929192908035906020019064010000000081111561011b57600080fd5b82018360208201111561012d57600080fd5b8035906020019184600183028401116401000000008311171561014f57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290505050610476565b604051808060200180602001838103835285818151815260200191508051906020019080838360005b838110156101e55780820151818401526020810190506101ca565b50505050905090810190601f1680156102125780820380516001836020036101000a031916815260200191505b50838103825284818151815260200191508051906020019080838360005b8381101561024b578082015181840152602081019050610230565b50505050905090810190601f1680156102785780820380516001836020036101000a031916815260200191505b5094505050505060405180910390f35b34801561029457600080fd5b5061034e600480360360208110156102ab57600080fd5b81019080803590602001906401000000008111156102c857600080fd5b8201836020820111156102da57600080fd5b803590602001918460018302840111640100000000831117156102fc57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f82011690508083019250505050505050919291929050505061049d565b6040518082815260200191505060405180910390f35b34801561037057600080fd5b50610379610510565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b610474600480360360208110156103d157600080fd5b81019080803590602001906401000000008111156103ee57600080fd5b82018360208201111561040057600080fd5b8035906020019184600183028401116401000000008311171561042257600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f820116905080830192505050505050509192919290505050610539565b005b606080836002908051906020019061048f929190610615565b508284915091509250929050565b60006001826040518082805190602001908083835b602083106104d557805182526020820191506020810190506020830392506104b2565b6001836020036101000a0380198251168184511680821785525050505050509050019150509081526020016040518091039020549050919050565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b600180826040518082805190602001908083835b60208310610570578051825260208201915060208101905060208303925061054d565b6001836020036101000a038019825116818451168082178552505050505050905001915050908152602001604051809103902054016001826040518082805190602001908083835b602083106105db57805182526020820191506020810190506020830392506105b8565b6001836020036101000a03801982511681845116808217855250505050505090500191505090815260200160405180910390208190555050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061065657805160ff1916838001178555610684565b82800160010185558215610684579182015b82811115610683578251825591602001919060010190610668565b5b5090506106919190610695565b5090565b6106b791905b808211156106b357600081600090555060010161069b565b5090565b9056fea265627a7a72315820cf953dc1839436e254d5a3c4c228d708600f054f50da1950ddc1960647386ef364736f6c63430005110032";
    
    const demo = await xsdk.deploySolidityContract(
        'XC8888888888888888@xuper', // 合约账户
        'counter',                  // 合约名字
        bin,                        // evm 合约 bin
        abi, "evm"                 // evm 合约 abi
        //{
        //    "creator": "bob"      // 如果合约有初始化参数可以写在这里
        //}
    );
    await xsdk.postTransaction(demo.transaction);


调用合约
^^^^^^^^^^^^^^
合约部署成功后，你可以调用这个合约，调用合约时需要指定合约名字、方法以及参数：
    
.. code-block:: js
    :linenos:
    
    // evm 合约的 abi 以及 bin。这里只是示例，你可以编写自己的合约，然后编译出 abi 和 bin。
    const demo = await xsdk.invokeSolidityContarct(
            "counter",         // 合约名字
            "increase",        // 合约方法
            "evm",             // 合约模块，本合约为 evm 合约
            {
                "key": "hello" // 参数
            }
            //"100"            // 调用合约同时转账给合约的金额，方法具有 payable 关键字才可使用
        );
    await xsdk.postTransaction(demo.transaction);
    
查询合约
^^^^^^^^^^^^^^
合约中同样有查询接口，你可以调用这些接口查询数据，同时不消耗手续费，执行合约后，只要不将 transaction 再 post 到链上即可：
    
.. code-block:: js
    :linenos:
    
    // 执行合约即可。
    const demo = await xsdk.invokeSolidityContarct(
            "counter",         // 合约名字
            "get",             // 合约方法
            "evm",             // 合约模块，本合约为 evm 合约
            {
                "key": "hello" // 参数
            }
        );


转账
^^^^^^^
除了合约相关操作，你还可以进行转账：
    
.. code-block:: js
    :linenos:
    
    const tx = await xsdk.transfer({
            to: 'dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN',
            amount: '100',
            fee: '100'
        });
    await xsdk.postTransaction(tx);

转账后还可以查询某个地址的余额：

.. code-block:: js
    :linenos:
    
    // 查询自己的余额
    const result = await xsdk.getBalance();
    console.log(result);

    // 查询指定地址的余额
    const result = await xsdk.getBalance('dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN');
    console.log(result);


查询链上信息
^^^^^^^^^^^^^^^^^
SDK 还支持链上的查询接口，例如查询区块，查询交易，链上的状态等：
    
.. code-block:: js
    :linenos:
    
    // 查询链上状态
    const status = await xsdk.checkStatus();

    // 根据高度查询区块
    const result = await xsdk.getBlockByHeight('8');

    // 根据交易 ID 查询交易
    const result = await xsdk.queryTransaction('242de4ae4b09d25e2103a29725fb2f865538669780e5759be61d17e2c2e4afec');


上面为部署 EVM 合约、转账以及查询接口示例，wasm 以及 native 合约部署、升级、调用等其他接口接口请参考 `接口文档 <https://xuperchain.github.io/xuper-sdk-js/classes/xupersdk.html>`_