
合约账号
========

访问控制列表（ACL）
-------------------

如果把合约账号当作一家股份制公司，那么ACL便是公司股东投票的机制，ACL可以规定合约账号背后各“股东”账号的权重，只有当“股东”签名的权重之和大于设定阈值时操作才会有效地进行。

 XuperChain 中ACL配置格式如下：

.. code-block:: python
    :linenos:

    {
        "pm": {
            "rule": 1,              # rule=1表示签名阈值策略，rule=2表示AKSet签名策略
            "acceptValue": 0.6      # acceptValue为签名需达到的阈值
        },
        "aksWeight": {              # aksWeight里规定了每个地址对应账号签名的权重
            "AK1": 0.3,
            "AK2": 0.3
        }
    }

了解了访问控制列表的概念，下面我们就来演示一下如何创建一个合约账号

合约账号创建
------------

Xchain的客户端工具提供了新建账号的功能，基本用法如下：

.. code-block:: bash
    :linenos:

    xchain-cli account new --desc account.des

这里的 account.des 就是创建账号所需要的配置了，内容如下：

.. code-block:: python
    :linenos:

    {
        "module_name": "xkernel",
        "method_name": "NewAccount",
        "args" : {
            "account_name": "1111111111111111",  # 说明：账号名称是16位数字组成的字符串
            # acl 中的内容注意转义
            "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 0.6},\"aksWeight\": {\"AK1\": 0.3,\"AK2\": 0.3}}"
        }
    }

命令运行后就会调用xchain的系统合约功能 ``NewAccount`` 创建一个名为 ``XC1111111111111111@xuper`` （如果链名字为xuper）的账号

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/acctnew.gif
        :alt: 新建合约账号
        :align: center

        新建合约账号

除了上述方法，我们还提供了一个比较简易的方式来创建合约账号，命令如下：

.. code-block:: bash
    :linenos:

    xchain-cli account new --account 1111111111111111 # 16位数字组成的字符串

上述命令也会创建一个名为 ``XC1111111111111111@xuper`` 的账号，由于我们没有制定ACL的具体内容，其ACL被赋值为默认状态，即背后有权限的账号只有当前节点上默认账号一个（地址默认位于 data/keys/address）

.. note::
    创建合约账号的操作需要提供手续费，需要按照命令行运行结果给出的数值，添加一个不小于它的费用（使用 --fee 参数）

合约账号基本操作
----------------

查询账号ACL
^^^^^^^^^^^

XuperChain的客户端工具提供了ACL查询功能，只需如下命令

.. code-block:: bash
    :linenos:

    xchain-cli acl query --account XC1111111111111111@xuper # account参数为合约账号名称

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/queryacl.gif
        :alt: 查询合约账号ACL
        :align: center

        查询合约账号ACL

查询账号余额
^^^^^^^^^^^^

合约账号查询余额和普通账号类似，只是命令行的参数有些许变化

.. code-block:: bash
    :linenos:

    ./xchain-cli account balance XC1111111111111111@xuper -H 127.0.0.1:37101

使用此命令即可查询`XC1111111111111111@xuper`的余额

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/contracct.gif
        :alt: 查询合约账号
        :align: center

        查询合约账号余额

修改账号ACL
^^^^^^^^^^^

修改ACL的配置和创建账号的配置类似

.. code-block:: python
    :linenos:

    {
        "module_name": "xkernel",
        "method_name": "SetAccountAcl",  # 这里的方法有了变更
        "args" : {
            "account_name": "XC1111111111111111@xuper", #account_name在此处一定要写成XC.....@xuper的形式
            # acl字段为要修改成的新ACL
            "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 0.6},\"aksWeight\": {\"AK3\": 0.3,\"AK4\": 0.3}}"
        }
    }

修改ACL的操作，需要符合当前ACL中设置的规则，即需要具有足够权重的账号签名。

需要新建文件添加需要签名的地址，默认acl文件路径是：./data/acl/addrs 。
./data/acl/addrs 示例：
XC9999999999999999@xuper/9LArZSMrrRorV7T6h5T32PVUrmdcYLbug
XC9999999999999999@xuper/gLAdZSMtkforV7T6h5TA14VUrfdcYLbuy

我们首先生成一个多重签名的交易

.. code-block:: bash
    :linenos:

    ./xchain-cli multisig gen --desc acl_new.json --from XC1111111111111111@xuper

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/modifyacl1.gif
        :alt: 生成多重签名交易
        :align: center

        成多重签名交易

这样就会生成一个默认为`tx.out`的文件，之后使用原ACL中的账号对其进行签名

.. code-block:: bash
    :linenos:

    ./xchain-cli multisig sign --keys data/account/AK1 --output AK1.sign
    ./xchain-cli multisig sign --keys data/account/AK2 --output AK2.sign

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/modifyacl2.gif
        :alt: 签名交易
        :align: center

        签名交易

最后把生成的`tx.out`发出去

.. code-block:: bash
    :linenos:

    ./xchain-cli multisig send --tx tx.out AK1.sign,AK2.sign AK1.sign,AK2.sign

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/modifyacl3.gif
        :alt: 发送交易
        :align: center

        发送交易

至此便完成了ACL的修改

.. note:
    生成交易等操作中，会出现需要手续费的情况，需要按要求添加 --fee 参数

.. note:
    使用“简易”方式创建的合约账号，修改ACL生成交易时，需要添加节点账号的地址路径 --multiAddrs data/keys/address
