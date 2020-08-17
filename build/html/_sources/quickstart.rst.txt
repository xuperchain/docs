
本章节将指导您获取XuperChain的代码并部署一个基础的可用环境，还会展示一些基本操作

.. _env-deploy:

XuperChain环境部署
------------------

.. _env-prepare:

准备环境
^^^^^^^^

XuperChain主要由Golang开发，需要首先准备编译运行的环境

- 安装go语言编译环境，版本为1.11或更高
    - 下载地址：`golang <https://golang.org/dl/>`_
- 安装git
    - 下载地址：`git <https://git-scm.com/download>`_

.. _env-compiling:

编译XuperChain
^^^^^^^^^^^^^^

- 使用git下载源码到本地

    - git clone https://github.com/xuperchain/xuperchain.git

- 执行命令

.. code-block:: bash
    :linenos:

    cd src/github.com/xuperchain/xuperchain
    make

- 在output目录得到产出xchain和xchain-cli


.. note::
    可能需要配置go语言环境变量（$GOROOT, $PATH）

    GOPATH问题报错（go1.11版本之后无需关注）
        - 在1.11版本之前需要配置。配置成以下形式：
        - export GOPATH=xxx/github.com/xuperchain/xuperchain
        
    GCC版本需要升级到4或5以上


.. _basic-operation:

XuperChain基本操作
------------------

在output下，主要目录有data, logs, conf, plugins等, 二进制文件有xchain，xchain-cli

各目录的功能如下表：

+------------------------+---------------------------------------------------------------+
| 目录名                 | 功能                                                          |
+========================+===============================================================+
| output/                | 节点根目录                                                    |
+------------------------+---------------------------------------------------------------+
| ├─ conf                | xchain.yaml: xchain服务的配置信息（注意端口冲突）             |
|                        | plugins.conf: 插件的配置信息                                  |
+------------------------+---------------------------------------------------------------+
| ├─ data                | 数据的存放目录，创世块信息，以及共识和合约的样例              |
+------------------------+---------------------------------------------------------------+
| │  ···   ├─ blockchain | 账本目录                                                      |
+------------------------+---------------------------------------------------------------+
| │  ···   ├─ keys       | 此节点的地址，具有全局唯一性                                  |
+------------------------+---------------------------------------------------------------+
| │  ···   ├─ netkeys    | 此节点的网络标识ID，具有全局唯一性                            |
+------------------------+---------------------------------------------------------------+
| │  ···   └─ config     | 包括创始的共识，初始的资源数，矿工奖励机制等                  |
+------------------------+---------------------------------------------------------------+
| ├─ logs                | 程序日志目录                                                  |
+------------------------+---------------------------------------------------------------+
| ├─ plugins             | so扩展的存放目录                                              |
+------------------------+---------------------------------------------------------------+
| ├─ xchain              | xchain服务的二进制文件                                        |
+------------------------+---------------------------------------------------------------+
| ├─ xchain-cli          | xchain客户端工具                                              |
+------------------------+---------------------------------------------------------------+
| └─ wasm2c              | wasm工具（智能合约会用到）                                    |
+------------------------+---------------------------------------------------------------+

.. _svr-deploy:

部署xchain服务
^^^^^^^^^^^^^^

.. _create-chain:

创建链
>>>>>>

在启动xchain服务之前，我们首先需要创建一条链（创世区块），xchain客户端工具提供了此功能

.. code-block:: bash
    :linenos:

    # 创建xuper链
    ./xchain-cli createChain

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/createChain.gif
        :alt: 创建链
        :align: center

        创建链

这样我们就使用 config/xuper.json 中的配置创建了一条链（此时 data/blockchain 中会生成 xuper 目录，里面即是我们创建的链的账本等文件）

.. _svr-start:

启动服务
>>>>>>>>

启动服务命令十分简单，还可以配合多种参数使用，详见命令行的 -h 输出

.. code-block:: bash
    :linenos:

    # 启动服务节点
    nohup ./xchain &

.. _svr-status:

确认服务状态
>>>>>>>>>>>>

按照默认配置，xchain服务会监听37101端口，可以使用如下命令查看xchain服务的运行状态

.. code-block:: bash
    :linenos:

    # check服务运行状况
    ./xchain-cli status -H 127.0.0.1:37101

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/status.gif
        :alt: 查看状态
        :align: center

        查看运行状态

.. _basic-usage:

基本功能的使用
^^^^^^^^^^^^^^

.. _create-account:

创建新账号
>>>>>>>>>>

xchain中，账号分为普通账号和“合约账号”，这里先介绍普通账号的创建，命令如下

.. code-block:: bash
    :linenos:

    # 创建普通用户, 包含地址，公钥，私钥
    ./xchain-cli account newkeys --output data/bob
    # 在bob目录下会看到文件address，publickey，privatekey生成
    
.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/newkey.gif
        :alt: 创建账号
        :align: center

        创建账号

.. _balance:

查询资源余额
>>>>>>>>>>>>

对于普通账号，可使用如下命令查询账号资源余额，其中 -H 参数为xchain服务的地址

.. code-block:: bash
    :linenos:

    ./xchain-cli account balance --keys data/keys -H 127.0.0.1:37101

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/balance.gif
        :alt: 查询余额
        :align: center

        查询余额

.. _transfer:

转账
>>>>

转账操作需要提供源账号的私钥目录，也就类似“1.2.4.1”中生成的目录，这里注意到并不需要提供目标账号的任何密钥，只需要提供地址即可

.. code-block:: bash
    :linenos:
    
    # --keys 从此地址 转给 --to地址 --amount 钱
    ./xchain-cli transfer --to czojZcZ6cHSiDVJ4jFoZMB1PjKnfUiuFQ --amount 10 --keys data/keys/ -H 127.0.0.1:37101

命令执行的返回是转账操作的交易id（txid）

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/transfer.gif
        :alt: 普通转账
        :align: center

        普通转账操作

.. _querytx:

查询交易信息
>>>>>>>>>>>>

通过以下命令可以查询交易的信息，包括交易状态、交易的源和目标账号、交易的金额、所在的区块（如果已上链）等内容

.. code-block:: bash
    :linenos:

    # 可查询上一步生成的txid的交易信息
    ./xchain-cli tx query cbbda2606837c950160e99480049e2aec3e60689a280b68a2d253fdd8a6ce931 -H 127.0.0.1:37101

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/querytx.gif
        :alt: 查询交易
        :align: center

        查询交易

.. _queryblock:

查询block信息
>>>>>>>>>>>>>

通过blockid可以查询区块的相关信息，包括区块内打包的交易、所在链的高度、前驱/后继区块的id等内容

.. code-block:: bash
    :linenos:

    # 可查询上一步交易所在的block id信息
    ./xchain-cli block 0354240c8335e10d8b48d76c0584e29ab604cfdb7b421d973f01a2a49bb67fee -H 127.0.0.1:37101

.. only:: html

    .. figure:: https://xchain-xuperunion.bj.bcebos.com/learning/queryblock.gif
        :alt: 查询区块
        :align: center

        查询区块

.. _multisig:

发起多重签名交易
>>>>>>>>>>>>>>>>

对于需要多个账号签名才可以生效的交易，需要先发起多重签名交易，收集需要的签名，然后再发出

对需要收集签名的账号地址，需要事先维护在一个文件中（假定名为addr_list），每个地址一行

.. code-block:: console
    :linenos:

    YDYBchKWXpG7HSkHy4YoyzTJnd3hTFBgG
    ZAmWoJViiNn5pKz32m2MVgmPnSpgLia7z

假设要发起一笔转账操作

.. code-block:: bash
    :linenos:
    
    # 从账号发起
    ./xchain-cli multisig gen --to czojZcZ6cHSiDVJ4jFoZMB1PjKnfUiuFQ --amount 100 -A addr_list
    # 从合约账号发起
    ./xchain-cli multisig gen --to czojZcZ6cHSiDVJ4jFoZMB1PjKnfUiuFQ --amount 100 -A addr_list --from XC11111111111111@xuper

这样会生成一个tx.out文件，包含了需发起的交易内容

.. code-block:: bash
    :linenos:

    # 各方在签名之前可以check 原始交易是否ok，查看visual.out
    ./xchain-cli multisig check --input tx.out --output visual.out

然后收集需要的签名

.. code-block:: bash
    :linenos:

    # 首先需要发起者自己的签名
    ./xchain-cli multisig sign --tx tx.out --output my.sign
    # 假设addr_list中的地址对应的私钥存放在alice、bob中
    ./xchain-cli multisig sign --keys data/account/alice --tx tx.out --output alice.sign
    ./xchain-cli multisig sign --keys data/account/bob --tx tx.out --output bob.sign

最后将交易和收集好的签名发出

.. code-block:: bash
    :linenos:

    # send后第一个参数是发起者的签名文件，第二个参数是需要收集的签名文件，均为逗号分割
    ./xchain-cli multisig send --tx tx.out my.sign alice.sign,bob.sign