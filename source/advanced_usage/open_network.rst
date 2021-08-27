开放网络介绍
============

开放网络集成环境
---------------------

 XuperChain 开放网络是基于百度自研底层技术搭建的区块链基础服务网络，符合中国标准，超级节点遍布全国，区块链网络完全开放，为用户提供区块链快速部署和运行的环境，最低2元钱就用上的区块链服务，让信任链接更加便利。

 XuperChain 开放网络为开发者提供了合约开发、编译、部署、管理的一站式可视化集成环境，下面介绍如何在开放网络上开发部署智能合约。

.. image:: ../images/xuperos-dashboard.png
    :align: center

账户注册
^^^^^^^^^^^^

    1. 在 XuperChain 官网 https://xchain.baidu.com/ 使用百度账号登录，如果没有百度账号请先注册。
    #. 进入 XuperChain 开放网络控制台，第一次登录的用户，平台会为用户创建区块链账户，请按照创建账户指引文档完成安全码设置，并记录自己的助记词和私钥。

.. image:: ../images/xuperos-create-account.png
    :align: center
	
创建合约账户
^^^^^^^^^^^^^^^^

    1. 在工作台，选择「开放网络 —> 合约管理」，点击「创建合约账户」
    #. 进入创建合约账户页，输入安全码后点击「确认创建」，系统自动生成账户名称后，即创建完毕 
	
.. image:: ../images/xuperos-no-account.png
    :align: center
	
	
合约开发和部署
^^^^^^^^^^^^^^^^

    1. 在工作台，选择「开放网络 —> 合约管理」，点击「创建智能合约」

    #. 进入新页面，按要求填写基本信息、编辑合约代码，编译成功后点击「安装」，即可进入合约安装(部署)流程。 合约代码编译有两种方式：
	
       + 模板合约；选择模板后，只需在模板代码中填写相关参数即可（参考模板详情完成参数填写）
       + 自定义合约；在编辑器内完成C++语言的合约编辑即可

.. image:: ../images/xuperos-create-contract.png
    :align: center

3. 进入安装流程，用户需按合约代码完成预执行操作。点击「开始验证」，执行通过会进入安装确认页

        + 模板合约；系统会提供模板的函数，只需填写参数即可（可参考模板详情）
        + 自定义合约；根据页面操作说明，完成函数、参数填写 

.. image:: ../images/xuperos-install-contract.png
    :align: center

4. 进入确认安装页，页面显示安装合约预计消耗的余额。点击「安装合约」将合约上链，上链过程需要等待10S左右。安装完成后，在合约管理列表中可看到合约状态变更为‘安装成功’，即该合约已完成安装。


合约调用
^^^^^^^^^^^^

开放网络上的部署的合约，除了可以在页面上调用还支持使用 SDK 调用。目前开放网络支持通过Go和Javascript、Java SDK调用智能合约，建议使用 Go SDK 或者 JavaScript SDK，Java SDK 目前功能较少。

    - Go SDK：https://github.com/xuperchain/xuper-sdk-go
    - Javascript SDK：https://github.com/xuperchain/xuper-sdk-js
    - Java SDK：https://github.com/xuperchain/xuper-java-sdk

使用 SDK 连接开放网络
-----------------------

下载 SDK 请参考 `Go SDK <https://github.com/xuperchain/xuper-sdk-go>`_ ， `Java SDK <https://github.com/xuperchain/xuper-sdk-js>`_ ， `JS SDK <https://github.com/xuperchain/xuper-java-sdk>`_ 建议使用最新版本。

使用 SDK 连接开放网络整体流程都是一样的：

1. 下载私钥；
   
2. 使用 SDK 加载私钥；
   
3. 修改配置文件连接开放网络；
   
4. 使用 SDK 连接开放网络节点。

下载个人私钥
^^^^^^^^^^^^^^^^^
在开放网络上创建账户后，会为用户生成加密的私钥，使用时需要使用密码解密后才可使用。 

登录到开放网络后，通过控制台可以下载个人账户的私钥文件

   .. image:: ../images/xuperos-private-key-dl.png
    :align: center

使用 Go SDK 连接开放网络
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

加载私钥
>>>>>>>>>
下载私钥文件后，私钥文件是加密的，使用时需要使用密码解密才可发送交易。

.. note::
    目前开放网络不支持本次生成账户并发送交易，只能在开放网络注册账户后，使用对应的私钥才可以发送交易。

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
在 Go SDK 中的 conf 目录下有两个配置文件：sdk.yaml 和 sdk.testnet.yaml，一个是连接开放网络使用，另外一个连接开放测试网络使用。

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

以上两种方式都可以设置配置文件，配置文件中的内容如下（在 go sdk 的 conf 目录下已经有此文件模板，需要修改成如下内容）：

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
    txVersion: 1

此时你的 SDK client 便连接到了开放网络，可以进行部署、调用合约了，具体接口文档参考 `Go SDK 使用文档 <../development_manuals/xuper-sdk-go.html>`_  。

使用 JS SDK 连接开放网络
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
JS SDK 连接开放网络与 Go SDK 有些许不同之处，主要在配置文件，JS SDK 不需要配置文件，只需要在创建客户端时指定参数即可。

加载私钥
>>>>>>>>>
加载私钥时同样需要指定密码，示例如下：

.. code-block:: js
    :linenos:

    // 第一个参数为密钥的密码，第二个参数为下载的私钥文件内容。
    const yourAccount = xsdk.import("yourPassword", "yourPrivateKeyString", true)
    console.log(yourAccount.address)

创建开放网络 client
>>>>>>>>>>>>>>>>>>>>>>

JS SDK 不需要指定配置文件，在创建客户端时，指定需要的参数即可，内容与 Go SDK 中使用的配置文件内容类似，示例如下：

.. code-block:: js
    :linenos:

    const xsdk = XuperSDK.getInstance({
        node: 'https://xuper.baidu.com/nodeapi',
        chain: 'xuper',
        env :{
            node: {
                disableGRPC: true // 代表禁用 grpc，使用 http。
            }
        },
        plugins: [
            Endorsement({
                transfer: {
                    server: "https://xuper.baidu.com/nodeapi", // https 地址
                    fee: "400", // 背书手续费。
                    endorseServiceCheckAddr:"jknGxa6eyum1JrATWvSJKW3thJ9GKHA9n", // 可以看到这里的地址和 Go SDK 中配置文件的对应地址相同。
                    endorseServiceFeeAddr: "aB2hpHnTBDxko3UoP2BpBZRujwhdcAFoT"
                },
                makeTransaction: {
                    server: "https://xuper.baidu.com/nodeapi",
                    fee: "400",
                    endorseServiceCheckAddr: "jknGxa6eyum1JrATWvSJKW3thJ9GKHA9n",
                    endorseServiceFeeAddr: "aB2hpHnTBDxko3UoP2BpBZRujwhdcAFoT"
                }
            })
        ]
    });

创建 client 后便可以发送交易，使用请参考 `JS SDK 使用文档 <../development_manuals/xuper-sdk-js.html>`_  。

使用 Java SDK 连接开放网络
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Java SDK 连接开放网络和 Go SDK 有些类似，主要也是通过配置文件。

加载私钥
>>>>>>>>>>>>
使用 Java SDK 同样需要加载你的私钥文件：

.. code-block:: java
    :linenos:

    Account account = Account.getAccountFromFile("yourPrivateKeyFile", "yourPassword");

设置配置文件
>>>>>>>>>>>>>>>
连接开放网络时同样需要指定 Java SDK 需要使用的配置文件（没错，和 Go SDK 的配置文件相同）。

.. code-block:: java
    :linenos:

    Config.setConfigPath("./conf/sdk.yaml");

此时便可以使用 Java SDK 连接开放网络，详细操作参考 创建 client 后便可以发送交易，使用请参考 `Java SDK 使用文档 <../development_manuals/xuper-sdk-java.html>`_  。
