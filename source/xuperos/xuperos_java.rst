Java SDK 接入指南
=====================

下载私钥
>>>>>>>>

在开放网络上创建账户后，会为用户生成加密的私钥，使用时需要使用密码解密后才可使用。

登录到开放网络后，通过控制台可以下载个人账户的私钥文件

   .. image:: ../images/xuperos-private-key-dl.png
    :align: center

引入SDK
>>>>>>>

.. code-block:: Xml
    :linenos:

    <dependency>
        <groupId>com.baidu.xuper</groupId>
        <artifactId>xuper-java-sdk</artifactId>
        <version>0.3.0</version>
    </dependency>

加载私钥
>>>>>>>>>>>>

.. code-block:: Java
    :linenos:

    Account account = Account.getAccountFromFile("yourPrivateKeyFile", "yourPassword");

修改配置文件
>>>>>>>>>>>>>>>
连接开放网络时需要指定 Java SDK 需要使用的配置文件。

配置文件中的内容如下（在 Java sdk 的 /src/main/java/com/baidu/xuper/conf 目录下已经有此文件模板），连接开放网络必须开启背书服务，进行如下配置：

.. code-block:: Yaml
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

连接开放网络
>>>>>>>>>>

.. code-block:: Java
    :linenos:

    Config.setConfigPath("./conf/sdk.yaml");
    XuperClient client = new XuperClient("39.156.69.83:37100");

部署合约
>>>>>>>

.. note::
    - 开放网络目前仅支持部署EVM合约与c++ wasm合约。
    - 本文测试采用EVM counter 合约作为示例，合约内容见：`Counter <https://github.com/xuperchain/contract-example-evm/blob/main/counter/Counter.sol>`_

.. code-block:: Java
    :linenos:

    Account account = Account.getAccountFromFile("开放网络私钥目录","安全码");
    Config.setConfigPath("./conf/sdk.yaml");

    // 开放网络工作台注册的合约账户
    String contractAccount = "";
    account.setContractAccount(contractAccount);

    XuperClient client = new XuperClient("39.156.69.83:37100");
    try {
      // 合约编译文件
      byte[] abi = Files.readAllBytes(Paths.get("./build/Counter.abi"));
      byte[] bin = Files.readAllBytes(Paths.get("./build/Counter.bin"));

      Map<String,String> params = new HashMap<>();
      params.put("creator", contractAccount);

      Transaction tx = client.deployEVMContract(account,bin,abi,"Counter", params);
      System.out.println(tx.getContractResponse().getBodyStr());

    } catch (IOException e) {
      e.printStackTrace();
    }

调用合约
>>>>>>>

.. note::
  - 如果合约方法修改了链上数据，如Counter合约的increase方法，请使用 **invokeEVMContract()**
  - 如果合约方法仅做查询，如Counter合约的get方法，请使用 **queryEVMContract()**

.. code-block:: Java
    :linenos:

      Account account = Account.getAccountFromFile("开放网络私钥目录","安全码");
      Config.setConfigPath("./conf/sdk.yaml");

      String contractAccount = "";
      //// 在调用合约时，如果 SetContractAccount，那么此次调用的发起者为合约账户。即：msg.sender 为合约账户转换后的EVM地址。
      account.setContractAccount(contractAccount);

      String contractName = "Counter";
      String contractMethod = "increase";

      XuperClient client = new XuperClient("39.156.69.83:37100");

      Map<String,String> params = new HashMap<>();
      params.put("key", "xuperos");

      // 开放网络不允许转账，所以在调用合约时 amount 参数要给0
      Transaction tx = client.invokeEVMContract(account,contractName, contractMethod, params, BigInteger.ZERO);

      System.out.println(tx.getContractResponse().getBodyStr());


具体接口文档参考 `Java SDK 使用文档 <../development_manuals/xuper-sdk-java.html>`_  。
