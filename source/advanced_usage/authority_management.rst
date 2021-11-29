权限管理
========

合约访问控制列表ACL
-------------------

ACL（Access Control List）是XuperChain提供的重要的权限管理方法，其主要对于合约方法的读写做控制，包括系统合约和用户合约。

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

了解了访问控制列表的概念，下面我们会进一步详细介绍ACL的细节。

合约账号创建
^^^^^^^^^^^^

XuperChain的客户端工具提供了新建账号的功能，基本用法如下：

.. code-block:: bash
    :linenos:

    xchain-cli account new --desc account.des

这里的 account.des 就是创建账号所需要的配置了，内容如下：

.. code-block:: python
    :linenos:

    {
        "module_name": "xkernel",
        "method_name": "NewAccount",
        "contract_name": "$acl",
        "args" : {
            "account_name": "1111111111111111",  # 说明：账号名称是16位数字组成的字符串
            # acl 中的内容注意转义
            "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 0.6},\"aksWeight\": {\"AK1\": 0.3,\"AK2\": 0.3}}"
        }
    }

命令运行后就会调用xchain的系统合约功能 ``NewAccount`` 创建一个名为 ``XC1111111111111111@xuper`` （如果链名字为xuper）的账号

除了上述方法，我们还提供了一个比较简易的方式来创建合约账号，命令如下：

.. code-block:: bash
    :linenos:

    xchain-cli account new --account 1111111111111111 # 16位数字组成的字符串

上述命令也会创建一个名为 ``XC1111111111111111@xuper`` 的账号，由于我们没有制定ACL的具体内容，其ACL被赋值为默认状态，即背后有权限的账号只有当前节点上默认账号一个（地址默认位于 data/keys/address）。

.. Important::
    创建合约账号的操作需要提供手续费，需要按照命令行运行结果给出的数值，添加一个不小于它的费用（使用 --fee 参数）。

合约账号基本操作
^^^^^^^^^^^^^^^^

**1. 查询账号ACL**

XuperChain的客户端工具提供了ACL查询功能，只需如下命令。

.. code-block:: bash
    :linenos:

    ./bin/xchain-cli acl query --account XC1111111111111111@xuper # account参数为合约账号名称

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/queryacl.gif
        :alt: 查询合约账号ACL
        :align: center

        查询合约账号ACL

**2. 查询账号余额**

合约账号查询余额和普通账号类似，只是命令行的参数有些许变化。

.. code-block:: bash
    :linenos:

    ./bin/xchain-cli account balance XC1111111111111111@xuper -H 127.0.0.1:37101

使用此命令即可查询 ``XC1111111111111111@xuper`` 的余额。

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/contracct.gif
        :alt: 查询合约账号
        :align: center

        查询合约账号余额

**3. 修改账号ACL**

修改ACL的配置和创建账号的配置类似。

.. code-block:: python
    :linenos:

    {
        "module_name": "xkernel",
        "method_name": "SetAccountAcl",  # 这里的方法有了变更
        "contract_name": "$acl",
        "args" : {
            "account_name": "XC1111111111111111@xuper", #account_name在此处一定要写成XC.....@xuper的形式
            # acl字段为要修改成的新ACL
            "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 0.6},\"aksWeight\": {\"AK3\": 0.3,\"AK4\": 0.3}}"
        }
    }

修改ACL的操作，需要符合当前ACL中设置的规则，即需要具有足够权重的账号签名。

需要新建文件添加需要签名的地址，默认acl文件路径是：./data/acl/addrs 。
./data/acl/addrs 示例(这里为原ACL地址，即AK1,AK2)：
XC9999999999999999@xuper/9LArZSMrrRorV7T6h5T32PVUrmdcYLbug
XC9999999999999999@xuper/gLAdZSMtkforV7T6h5TA14VUrfdcYLbuy

我们首先生成一个多重签名的交易。

.. code-block:: bash
    :linenos:

    ./bin/xchain-cli multisig gen --desc acl_new.json --from XC1111111111111111@xuper

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/modifyacl1.gif
        :alt: 生成多重签名交易
        :align: center

        成多重签名交易

这样就会生成一个默认为 ``tx.out`` 的文件，之后使用原ACL中的账号对其进行签名。

.. code-block:: bash
    :linenos:

    ./bin/xchain-cli multisig sign --keys data/account/AK1 --output AK1.sign
    ./bin/xchain-cli multisig sign --keys data/account/AK2 --output AK2.sign

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/modifyacl2.gif
        :alt: 签名交易
        :align: center

        签名交易

最后把生成的 ``tx.out`` 发出去。

.. code-block:: bash
    :linenos:

    ./bin/xchain-cli multisig send --tx tx.out AK1.sign,AK2.sign AK1.sign,AK2.sign

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/modifyacl3.gif
        :alt: 发送交易
        :align: center

        发送交易

至此便完成了ACL的修改。

.. Important::
    生成交易等操作中，会出现需要手续费的情况，需要按要求添加 --fee 参数。

.. Important::
    使用“简易”方式创建的合约账号，修改ACL生成交易时，需要添加节点账号的地址路径 --multiAddrs data/keys/address。


平行链群组
----------

平行链群组提供的是对某一条平行链的读权限和操作该权限的写权限的控制。平行链和群组是彼此相辅相成的概念，在创建平行链时，会根据输入创建该平行链的群组合约，用户后续可通过系统合约对群组进行修改。

.. Important::
    XuperChain需要与Xuper-Front联合使用才可以控制平行链的权限，该方案面向的是联盟链场景。单独的XuperChain进程，通过调用系统合约只能对主链群组相关Key进行修改，并不影响XuperChain节点的使用。具体可见 `平行链、群组和CA中心 <../advanced_usage/parallel_chain.html#xuperchain>`_ 。


平行链群组的创建
^^^^^^^^^^^^^^^^

平行链群组的创建只能在平行链创建时发生。若在平行链参数中指定 ``group`` 参数，则平行链群组根据该参数创建，否则走默认模式，即平行链群组默认归合约发起节点拥有。

.. code-block:: bash
    :linenos:
    
    // 平行链参数形式
    {
        "name":$Blockchain_Name, // 平行链名称
        "data":$Genesis_Configuration，// 平行链创世块配置
        "group":$Group_Configuration // 平行链群组配置，若缺省则为默认配置
    }  

群组合约的参数如下。

.. code-block:: bash
    :linenos:

    // 平行链群组参数形式
    {
        "name": $Blockchain_Name, // 平行链群组名称必须与平行链名称相同
        "admin": [$Admin_Addresses], // 管理者列表，管理者拥有写该群组合约的权限
        "identities": [$Identities_Address] // 查询者列表，查询者仅拥有读该群组合约的权限，若同时也为管理者，则也有写权限
    }


平行链群组的修改
^^^^^^^^^^^^^^^^^
有平行链群组管理员身份的XuperChain节点和账户才可以对该平行链群组做修改。

.. code-block:: bash
    :linenos:

    // group参数在-a后面键入，下面是更改hello链的例子
    ./bin/xchain-cli xkernel invoke '$parachain' --method editGroup -a '{ "name":"hello","admin":"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY;SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co;iYjtLcW6SVCiousAb5DFKWtWroahhEj4u"}' --fee 1000



平行链群组的查看
^^^^^^^^^^^^^^^^
仅有平行链管理员身份或者平行链查询者身份的节点和账户才可以对该平行链群组做查询。

.. code-block:: bash
    :linenos:

    // 下面是查看hello链群组信息的例子
    ./bin/xchain-cli xkernel query '$parachain' --method getGroup -a '{"name":"hello"}'

