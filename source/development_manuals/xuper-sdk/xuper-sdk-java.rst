Java SDK 使用说明
=================================

Java SDK
----------

下载
^^^^^^^
JS SDK 代码可在github上下载： `Java SDK <https://github.com/xuperchain/xuper-java-sdk>`_，可以查看详细的 `文档 <https://github.com/xuperchain/xuper-java-sdk/blob/master/README.md>`_

同时可以使用 maven：

.. code-block:: xml
    :linenos:

    <dependency>
        <groupId>com.baidu.xuper</groupId>
        <artifactId>xuper-java-sdk</artifactId>
        <version>0.2.0</version>
    </dependency>

使用
^^^^^^^
创建客户端，假设你的节点地址为 127.0.0.1:37101：

.. code-block:: java
    :linenos:

    XuperClient client = new XuperClient("127.0.0.1:37101");

向链上发交易前需要创建自己的账户，创建账户后余额为0，你可以使用 xchain-cli 程序向此地址转账：

.. code-block:: java
    :linenos:

    Account account = Account.create(1, 2);
    System.out.println(account.getAddress());
    System.out.println(account.getMnemonic());

当账户有余额后，你可以进行部署合约、调用合约，在这之前你需要先创建合约账户：

.. code-block:: java
    :linenos:

    // 创建合约账户
    client.createContractAccount(account, "1111111111111111");  
    
    // 转账给合约账户
    client.transfer(account, "XC1111111111111111@xuper", BigInteger.valueOf(1000000), "1");

    // 查询余额
    BigInteger result = client.getBalance("XC1111111111111111@xuper");


创建合约账户之后，可以部署合约，本次以部署 wasm 合约为例：

.. code-block:: java
    :linenos:

    // 设置合约账户
    account.setContractAccount("XC1111111111111111@xuper");

    // 构造合约初始化参数
    Map<String, byte[]> args = new HashMap<>();
    args.put("creator", "icexin".getBytes());

    // wasm 合约编译的文件
    String codePath = "./counter.wasm";
    byte[] code = Files.readAllBytes(Paths.get(codePath));
    
    // C++ 编写的合约，runtime 参数使用 "c"，合约名字为 counter
    client.deployWasmContract(account, code, "counter", "c", args);

部署合约后可以调用合约方法：

.. code-block:: java
    :linenos:

    Map<String, byte[]> args = new HashMap<>();
    args.put("key", "icexin".getBytes());
    Transaction tx = client.invokeContract(account, "wasm", "counter", "increase", args);
    System.out.println("txid: " + tx.getTxid());
    System.out.println("response: " + tx.getContractResponse().getBodyStr());
    System.out.println("gas: " + tx.getGasUsed());

Java 合约还支持 evm 合约以及其他查询接口请参考 `Java SDK 接口 <https://github.com/xuperchain/xuper-java-sdk/blob/master/src/main/java/com/baidu/xuper/api/XuperClient.java>`_


