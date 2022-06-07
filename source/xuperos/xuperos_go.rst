Go SDK 接入指南
=====================

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

      go get github.com/xuperchain/xuper-sdk-go/v2


加载私钥
>>>>>>>>>
下载私钥文件后，私钥文件是加密的，使用时需要使用密码解密才可发送交易。

.. note::
    - 目前开放网络不支持本次生成账户并发送交易，只能在开放网络注册账户后，使用对应的私钥才可以发送交易。
    - 开放网络不允许转账操作。

.. code-block:: go
    :linenos:

    package main

    import (
        "fmt"

        "github.com/xuperchain/xuper-sdk-go/v2/account"
    )

    func accountExample() {
        privateKeyFile := "your private key file path"
        password := "your password"
        yourAccount, err := account.GetAccountFromFile(privateKeyFile, password)
        if err != nil {
            fmt.Println(err)
            return
        }

        fmt.Println(yourAccount.Address)
    }

修改配置文件
>>>>>>>>>>>>
在 Go SDK 中的 conf 目录下有两个配置文件：sdk.yaml 和 sdk.testnet.yaml，一个是连接开放网络使用（sdk.yaml），另外一个连接开放测试网络使用（sdk.testnet.yaml）。

Go SDK 使用配置文件有两种方式：

1. 默认加载 ./conf/sdk.yaml；
2. 指定配置文件。

默认加载是指你的项目引用的 Go SDK 后，在运行目录的 ./conf 目录下，如果存在 sdk.yaml 文件，则 Go SDK 使用此配置文件，没有则用默认配置文件（不支持连接开放网络）。

指定配置文件是指在你的项目中，使用 Go SDK 创建 client 时，可以指定任意的配置文件（yaml 格式），示例代码如下：

.. code-block:: go
    :linenos:

    func clientConfigExample() {
        // 39.156.69.83:37100 为开放网络节点地址。
        // xuper.WithConfigFile("yourSDK.yaml") 设置使用的配置文件。
        xclient, err := xuper.New("39.156.69.83:37100", xuper.WithConfigFile("yourSDK.yaml"))
        if err != nil {
            fmt.Println(err)
            return
        }

        status, err := xclient.QuerySystemStatus()
        if err != nil {
            fmt.Println(err)
            return
        }
        fmt.Println(status)
    }

以上两种方式都可以设置配置文件，配置文件中的内容如下（在 go sdk 的 conf 目录下已经有此文件模板），连接开放网络必须开启背书服务，进行如下配置：

.. code-block:: yaml
    :linenos:

    # endorseService Info
    endorseServiceHost: "39.156.69.83:37100"
    complianceCheck:
    # 是否需要进行合规性背书
    isNeedComplianceCheck: true
    # 是否需要支付合规性背书费用
    isNeedComplianceCheckFee: true
    # 合规性背书费用
    complianceCheckEndorseServiceFee: 400
    # 支付合规性背书费用的收款地址
    complianceCheckEndorseServiceFeeAddr: aB2hpHnTBDxko3UoP2BpBZRujwhdcAFoT
    # 如果通过合规性检查，签发认证签名的地址
    complianceCheckEndorseServiceAddr: jknGxa6eyum1JrATWvSJKW3thJ9GKHA9n
    #创建平行链所需要的最低费用
    minNewChainAmount: "100"
    crypto: "xchain"
    txVersion: 3

此时你的 SDK client 便连接到了开放网络，可以进行部署、调用合约了

部署合约
>>>>>>>

.. note::
    - 开放网络目前仅支持部署EVM合约与c++ wasm合约。
    - 本文测试采用EVM counter 合约作为示例，合约内容见：`Counter <https://github.com/xuperchain/contract-example-evm/blob/main/counter/Counter.sol>`_

.. code-block:: go
    :linenos:

    func main() {

    	client, err := xuper.New("39.156.69.83:37100")
    	if err != nil {
    		fmt.Println(err)
    	}

    	acc, err := account.GetAccountFromFile("开放网络私钥文件路径", "安全码")
    	if err != nil {
    		fmt.Println(err)
    	}

    	// contract account 合约账号使用在工作台注册的合约账号
    	contractAccount := ""
    	err = acc.SetContractAccount(contractAccount)
    	if err != nil {
    		fmt.Println(err)
    	}

    	// 合约编译文件
    	abi , err := ioutil.ReadFile("./build/Counter.abi")
    	bin , err := ioutil.ReadFile("./build/Counter.bin")

    	// 初始化参数
    	args := make(map[string]string)
    	args["creator"] = contractAccount

    	// 发送交易
    	tx, err := client.DeployEVMContract(acc,"Counter",abi,bin,args)
    	if err != nil{
    		fmt.Println(err)
    	}

    	fmt.Printf("%s", tx.ContractResponse)
    }

调用合约
>>>>>>>

.. note::
  - 如果合约方法修改了链上数据，如Counter合约的increase方法，请使用 **InvokeEVMContract()**
  - 如果合约方法仅做查询，如Counter合约的get方法，请使用 **QueryEVMContract()**

.. code-block:: go
    :linenos:

    func main() {

    	client, err := xuper.New("39.156.69.83:37100")
    	if err != nil {
    		fmt.Println(err)
    	}

    	acc, err := account.GetAccountFromFile("开放网络私钥文件路径", "安全码")
    	if err != nil {
    		fmt.Println(err)
    	}

    	// contract account 合约账号使用在工作台注册的合约账号
      // 在调用合约时，如果 SetContractAccount，那么此次调用的发起者为合约账户。即：msg.sender 为合约账户转换后的EVM地址。
    	contractAccount := ""
    	err = acc.SetContractAccount(contractAccount)
    	if err != nil {
    		fmt.Println(err)
    	}

      // 合约名称
      contractName := "Counter"

      //此次要调用的合约方法
      contractMethod := "increase"

    	// 合约方法参数
    	args := make(map[string]string)
    	args["key"] = "xuperos"

    	// 发送交易
    	tx, err := client.InvokeEVMContract(acc,contractName,contractMethod,args)
    	if err != nil{
    		fmt.Println(err)
    	}

    	fmt.Printf("%s", tx.ContractResponse)
    }

具体接口文档参考 `Go SDK 使用文档 <../development_manuals/xuper-sdk-go.html>`_  。
