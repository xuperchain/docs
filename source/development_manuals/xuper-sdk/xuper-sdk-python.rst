Python SDK 使用说明
==========================

下载
^^^^^^^
Python SDK 代码可以在github上下载 `Python SDK <https://github.com/xuperchain/xuper-python-sdk>`_


使用
^^^^^^^
创建客户端，假设你的节点地址为 127.0.0.1:37101：

.. code-block:: python

    pysdk = xuper.XuperSDK("http://127.0.0.1:37101", "xuper")

向链上发交易前需要有自己的账户，我们可以从私钥文件中恢复账户。

.. code-block:: python

    pysdk.readkeys("./data/keys")


恢复账户后，我们可以创建合约账户，从何进行部署合约、调用合约

.. code-block:: python 

    // 给合约账户转账
    pysdk.transfer(new_account_name, 10000000, desc="start funds")
    // 设置合约账户
    pysdk.set_account(new_account_name)
    contract_name = 'counter'+str(random.randint(100,1000000))
    // 部署合约
    print("deploying......")
    rsps = pysdk.deploy(new_account_name, contract_name, open('./data/wasm/counter.wasm','rb').read(), {'creator':b'baidu'})
    print(rsps)

部署合约后可以调用合约方法：

.. code-block:: python

    rsps = pysdk.invoke(contract_name, "increase", {"key":b"counter"})

也可以通过预执行查看执行的结果

.. code-block:: python

    rsps = pysdk.preexec(contract_name, "get", {"key":b"counter"})
    print(rsps.decode())


Python 合约还支持 evm 合约以及其他查询接口请参考 `Python SDK 接口 <https://github.com/xuperchain/xuper-python-sdk/blob/master/xuper/client.py>`_

