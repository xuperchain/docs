
XuperChain 监管机制
==============

监管机制概述
------------

 XuperChain 是一个具备政府监管能力的区块链系统。在设计上我们需要充分考虑监管和安全问题，做到安全可控。基于此我们 XuperChain 底层设计了一个监管合约的机制，通过该机制， XuperChain 具备了对链上用户的实名、交易的安全检查等监管能力。

 XuperChain 在初始化时候，可以通过创世块配置的方式，配置这条链是否需要支持监管类型。对于配置了监管合约的链，这个链上所有的事务发起，无论是转账还是合约调用，系统会默认插入监管合约的执行，执行结果体现在读写集中，执行过程不消耗用户资源，执行结果所有节点可验证。

目前 XuperChain 支持的监管合约主要有以下几个：

- 实名制合约: identity
- DApp封禁合约: banned
- 合规性检查合约: complianceCheck
- 交易封禁合约: forbidden

**下面将会以实名合约为例对监管合约的使用步骤进行说明**

监管机制使用说明
----------------

创世块配置
^^^^^^^^^^

创世块配置新增 ``reserved_contracts`` 配置，内容如下：

.. code-block:: python
    :linenos:

    "reserved_contracts": [
        {
            "module_name": "wasm",
            "contract_name": "identity",
            "method_name": "verify",
            "args":{}
        }
    ]

这个配置中配置了 ``identity`` 监管合约。

搭建网络
^^^^^^^^

搭建网络的方式与以前的方式没有区别，用户可以依据需求选择搭建单节点网络还是多节点网络。

搭建网络参见如下链接： 
`单节点网络搭建 <quickstart.html#xchain>`_
`多节点网络搭建 <../advanced_usage/multi-nodes.html>`_ 

部署Reserved合约
^^^^^^^^^^^^^^^^

**1. 编译实名合约** 

实名合约代码路径如下：`core/contractsdk/cpp/reserved/identity.cc <https://github.com/xuperchain/xuperchain/blob/master/core/contractsdk/cpp/reserved/identity.cc>`_ 

实名合约实名的对象是一个具体的ak。

.. code-block:: bash
    :linenos:

    cd ./contractsdk/cpp
    cp reserved/identity.cc example 
    ./build.sh

编译好的产出为 ./build 文件夹下的identity.wasm文件。

**2. 创建合约账户**

在XuperChain中所有的合约都是部署在具体的某个账户下的，所以，为了部署实名合约，我们需要首先创建一个合约账户，注意，这里账户的拥有者可以修改其内合约Method的ACL权限管理策略，通过这种机制实现对谁可以添加实名状态和删除实名状态的控制。 
这里是由 XuperChain 的 `多节点网络搭建 <../advanced_usage/multi-nodes.html>`_ 支持的。

.. code-block:: bash
    :linenos:

    # 快速创建合约方式：
    ./xchain-cli account new --account 1111111111111111

**3. 部署实名合约**

部署合约需要消耗资源，所以先给上述合约账户转移一笔资源，然后在合约内部署上面的合约：

.. code-block:: bash
    :linenos:

    # 1  转移资源
    ./xchain-cli transfer --to XC1111111111111111@xuper --amount 100000
    # 2 部署实名合约
    # 通过 -a 的creator参数，可以初始化被实名的ak。
    ./xchain-cli wasm deploy --account XC1111111111111111@xuper --cname identity -H localhost:37101 identity.wasm -a '{"creator":"addr1"}'

.. note:: 上述实名合约初始化的被实名的address需要和实名合约添加实名信息保持相同，否则会由于初始实名的ak和添加实名权控不一致而导致系统无法添加新的实名状态。

Reserved合约调用
^^^^^^^^^^^^^^^^

实名合约部署完成后，就可以进行实名合约信息的添加和删除了

**1. 添加实名信息**

合约调用json文件如下:

.. code-block:: python
    :linenos:

    {
        "module_name": "wasm",
        "contract_name": "identity",
        "method_name": "register_aks",
        "args":{
            "aks":"ak1,ak2"
        }
    }

具体步骤如下：

.. code-block:: bash
    :linenos:

    # 1: 生成原始交易
    ./xchain-cli multisig gen --desc identity_add.json --host localhost:37101 --fee 1000 --output tx_add.out
    # 2: 本地签名
    ./xchain-cli multisig sign --output tx_add_my.sign --tx tx_add.out
    # 3: 交易发送
    ./xchain-cli multisig send tx_add_my.sign --host localhost:37101 --tx tx_add.out

**2. 删除实名信息**

合约调用json文件如下:

.. code-block:: python
    :linenos:

    {
        "module_name": "wasm",
        "contract_name": "identity",
        "method_name": "unregister_aks",
        "args":{
            "aks":"ak1,ak2"
        }
    }

具体步骤如下：

.. code-block:: bash
    :linenos:

    # 1: 生成原始交易
    ./xchain-cli multisig gen --desc identity_del.json --host localhost:37101 --fee 1000 --output tx_del.out
    # 2: 本地签名
    ./xchain-cli multisig sign --output tx_del_my.sign --tx tx_del.out
    # 3: 交易发送
    ./xchain-cli multisig send tx_del_my.sign tx_del_compliance_sign.out --host localhost:37101 --tx tx_del.out

**3. 实名信息验证**

当用户向网络发起事务请求时，网络会验证交易中的 ``initiator`` 和 ``auth_require`` 字段是否都经过实名，如果都经过实名，则通过，否则，失败。