Go SDK 使用说明
=======================================

下载
----------
Go SDK 代码可以在github上下载 `Go SDK <https://github.com/xuperchain/xuper-sdk-go>`_，查看详细的 `文档 <https://github.com/xuperchain/xuper-sdk-go/blob/master/README.md>`_

安装
----------
- go get github.com/xuperchain/xuper-sdk-go/v2

使用 Go SDK
--------------

建立连接
^^^^^^^^^^^^^^^^
使用Go SDK和链上数据进行交互，首先需要使用SDK创建一个Client，与节点建立连接。

.. code-block:: go

    // 创建客户端
    xclient, err := xuper.New("127.0.0.1:37101")

账户
^^^^^^^^^^^^^^^^
向链上发起交易前需要建立自己的账户，可以使用SDK创建账户。创建账户时注意保存好助记词或者私钥文件。XuperChain账户助记词中文助记词以及英文助记词

.. code-block:: go

    // 创建账户 CreateAccount(strength uint8, language int)
    //- `strength`：1弱（12个助记词），2中（18个助记词），3强（24个助记词）。
    //- `language`：1中文，2英文。
    acc, err := account.CreateAccount(2, 1)

    // 创建账户并存储到文件中
    acc, err = account.CreateAndSaveAccountToFile("./keys", "123", 1, 1)


如果已有账户，恢复账户即可。

.. code-block:: go

    // 通过助记词恢复账户。xuperChain支持中文助记词
    acc, err = account.RetrieveAccount("玉 脸 驱 协 介 跨 尔 籍 杆 伏 愈 即", 1)

    // 通过私钥文件恢复账户
    acc, err = account.GetAccountFromFile("keys/", "123")

新创建的账户余额为0，可以使用其他有余额的账户向该账户转账。对于有了余额的账户，就可以进行转账操作

.. code-block:: go

    // 普通转账，acc为有余额的账户
    tx, err := xclient.Transfer(acc, to.Address, "10")

    // 查询普通账户余额
    xclient.QueryBalance(to.Address)


合约操作
^^^^^^^^^^^^^^^^
当账户有了余额后，就可以进行转账。如果要进行合约部署、调用等操作，还需要合约账户。合约账号是XuperChain中用于智能合约管理的单元，有普通账户发起交易，在链上生成的一串16位数字的账户，并且由XC开头，以@xuper结尾。执行合约相关操作时，需要用到合约账户

.. code-block:: go

    //创建合约账户
    contractAccount := "XC1234567890123456@xuper"
    tx, err := xchainClient.CreateContractAccount(account, contractAccount)
    
    // 转账给合约账户
    tx, err := xclient.Transfer(acc, contractAccount, "10")
    
    // 查询合约账户余额
    fmt.Println(xclient.QueryBalance(contractAccount) 

当合约账户有了余额后，就可以进行合约相关操作。XuperChain支持 Wasm 合约，EVM 合约，Native 合约.合约编写，编译相关内容这里不再赘述，这里我们使用Go SDK来部署一个Wasm合约

.. code-block:: go

    // 设置合约账户
    err = account.SetContractAccount(contractAccount)

    // 读取Wasm 合约文件
    code, err := ioutil.ReadFile(wasmCodePath)

    // 构造合约初始化参数
    args := map[string]string{
		"creator": "test",
		"key":     "test",
	}

    //部署Wasm 合约,contractName为合约名。链上的合约名不能重复
    tx, err := xuperClient.DeployWasmContract(account, contractName, code, args)

    // 调用Wasm 合约，“increase"为调用合约中的某个具体方法
    tx, err = xuperClient.InvokeWasmContract(account, contractName, "increase", args)

    // 查询Wasm，需要在合约中有查询接口。该方法不需要消耗手续费
    tx, err = xuperClient.QueryWasmContract(account, contractName, "get", args)

如此，合约部署相关的工作就已经完成了。如果需要部署其他合约，请参考 `Go SDK example <https://github.com/xuperchain/xuper-sdk-go/blob/2.0.0/example/contract/contract.go>`_

其他链上查询
^^^^^^^^^^^^^^^^
除了合约相关操作外，Go SDK还支持链上信息查询，比如区块查询，交易查询，链上状态查询等。

.. code-block:: go

    // 查询链上状态
    bcStatus, err := client.QueryBlockChainStatus("xuper")

    // 根据高度查询区块
    blockResult, _ := xclient.QueryBlockByHeight(8)
    // 根据区块ID查询区块
    blockID := "8edfaefd04fa986bfede5a04160b5c200fe63726a4bfed45367da9bf701c70e8"
    blockResult, _ := xclient.QueryBlockByID(blockID)

    // 根据交易ID查询交易
    txID := "c3af3abde7f800dd8782ce8a7559e5bdd7fe712c9efd56d9aeb7f9d2be253730"
    tx, err := client.QueryTxByID(txID)

以上为常用接口使用方法，如果还需要进行其他接口相关查询，请参考 `Go SDK <https://github.com/xuperchain/xuper-sdk-go/blob/2.0.0/xuper/xuperclient.go>`_





