
多节点部署
==========

在阅读本节前，请先阅读“快速入门”，当中介绍了创建单节点网络的创建，在该基础上，搭建一个SINGLE共识的多节点网络，其他节点只要新增p2p网络bootNodes配置即可。如果你想搭建一个TDPoS共识的链，仅需要修改创世块参数中“genesis_consensus”配置参数即可。下面将详细介绍相关操作步骤。

p2p网络配置
-----------

我们以搭建3个节点的网络为例来说明（其实搭建更多节点的原理是一致的），首先需要有一个节点作为种子节点“bootNode”，其他节点通过该种子节点的链接地址“netURL”加入网络：

对于bootNode节点，我们需要先获取它的netURL，具体命令如下：

.. code-block:: bash
    :linenos:

    ./xchain-cli netURL get -H 127.0.0.1:37101

如果不是以默认配置启动的，我们需要先生成它的netURL，然后再获取

.. code-block:: bash
    :linenos:

    ./xchain-cli netURL gen         #重新生成本地节点的网络私钥
    ./xchain-cli netURL preview     #显示本地节点的p2p地址

通过上述操作，我们会得到该节点的链接地址： 
``/ip4/127.0.0.1/tcp/47101/p2p/QmVxeNubpg1ZQjQT8W5yZC9fD7ZB1ViArwvyGUB53sqf8e`` 


对其他的节点，我们需要修改其服务配置 `conf/xchain.yaml` 中p2p一节

.. code-block:: yaml
    :linenos:

    p2p:
        module: p2pv2
        // port是节点p2p网络监听的默认端口，如果在一台机器上部署注意端口配置不要冲突，
        // node1配置的是47101，node2和node3可以分别设置为47102和47103
        port: 47102
        // 节点加入网络所连接的种子节点的链接信息，
        bootNodes:
        - "/ip4/127.0.0.1/tcp/47101/p2p/QmVxeNubpg1ZQjQT8W5yZC9fD7ZB1ViArwvyGUB53sqf8e"

.. note::
    需要注意的是，如果其他节点分布在不同的机器之上，需要把种子节点的netURL中的127.0.0.1改为种子节点的实际物理ip；

修改完其他节点的配置后，即可在每一个节点使用相同配置创建链，然后分别启动bootNode和其他节点，即完成了多节点环境的部署

这里可以使用系统状态的命令检查环境是否正常

.. code-block:: bash
    :linenos:

    ./xchain-cli status -H 127.0.0.1:37101

通过变更 -H 参数，查看每个节点的状态，若所有节点高度都是一致变化的，则证明环境部署成功

搭建TDPoS共识网络
-----------------

XuperChain系统支持可插拔共识，通过修改创世块的参数，可以创建一个以TDPoS为共识的链。

下面创世块配置（一般位于 core/data/config/xuper.json）和单节点创世块配置的区别在于创世共识参数genesis_consensus的config配置，各个配置参数详解配置说明如下所示：

.. code-block:: python
    :linenos:

    {
        "version" : "1",
        "predistribution":[
            {
                "address" : "mahtKhdV5SZP4FveEBzX7j6FgUGfBS9om",
                "quota" : "100000000000000000000"
            }
        ],
        "maxblocksize" : "128",
        "award" : "1000000",
        "decimals" : "8",
        "award_decay": {
            "height_gap": 31536000,
            "ratio": 1
        },
        "genesis_consensus": {
            "name": "tdpos",
            "config": {
                # tdpos共识初始时间，声明tdpos共识的起始时间戳，建议设置为一个刚过去不旧的时间戳
                "timestamp": "1548123921000000000", 
                # 每一轮选举出的矿工数，如果某一轮的投票不足以选出足够的矿工数则默认复用前一轮的矿工
                "proposer_num":"3",
                # 每个矿工连续出块的出块间隔
                "period":"3000",
                # 每一轮内切换矿工时的时间间隔，需要为period的整数倍
                "alternate_interval":"6000",
                # 切换轮时的出块间隔，即下一轮第一个矿工出第一个块距离上一轮矿工出最后一个块的时间间隔，需要为period的整数配
                "term_interval":"9000", 
                # 每一轮内每个矿工轮值任期内连续出块的个数
                "block_num":"200",
                # 为被提名的候选人投票时，每一票单价，即一票等于多少Xuper
                "vote_unit_price":"1",
                # 指定第一轮初始矿工，矿工个数需要符合proposer_num指定的个数，所指定的初始矿工需要在网络中存在，不然系统轮到该节点出块时会没有节点出块
                "init_proposer": {
                    "1":["RU7Qv3CrecW5waKc1ZWYnEuTdJNjHc43u","XpQXiBNo1eHRQpD9UbzBisTPXojpyzkxn","SDCBba3GVYU7s2VYQVrhMGLet6bobNzbM"]
                }
            }
        }
    }

修改完每个节点的创世块配置后，需要确认各节点的 data/blockchain 目录下内容为空。然后重新按照上一节的步骤，在各节点上创建链，启动所有节点，即完成TDPoS共识的环境部署。

选举TDPOS候选人
---------------

选举候选人包括提名和投票两个环节，具体操作和 `发起提案 <initiate_proposals.html>`_ 类似

提名候选人
^^^^^^^^^^

首先需要准备一个提名的配置，json格式

.. code-block:: python
    :linenos:

    {
        "module": "tdpos",
        "method": "nominate_candidate",
        "args": {
            # 此字段为要提名的候选人的地址
            "candidate": "kJFcY3FjmNU8xk6cRzHvTPmChUQ3SBGVE",
            # 此字段为候选人节点的netURL
            "neturl": "/ip4/10.0.4.6/tcp/47101/p2p/QmRmdBSyHpKPvhsvmyys8f1jDM4x1S9cbCwZaBMqMKjwhV"
        }
    }

然后将这个json文件（假定文件名为nominate.json）通过多重签名命令发出。提名候选人的操作需要提名者和被提名候选人的两个签名（如果是自己提名自己，那么就只需要一个签名了）

首先要准备一个需收集签名的地址列表，可以参考 `发起多重签名交易 <../quickstart.html#multisig>`_

.. code-block:: console
    :linenos:

    YDYBchKWXpG7HSkHy4YoyzTJnd3hTFBgG
    kJFcY3FjmNU8xk6cRzHvTPmChUQ3SBGVE

然后生成一个提名交易， XuperChain 上进行候选人提名需要冻结大于链上资产总量的十万分之一的utxo（当前的总资产可以通过 `status查询命令 <../quickstart.html#svr-status>`_ 查看结果的utxoTotal字段）

.. code-block:: bash
    :linenos:

    # 这里转账的目标地址可以任意，转给自己也可以，注意冻结参数为-1，表示永久冻结
    ./xchain-cli multisig gen --to=dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN --desc=nominate.json --amount=10000000000000000 --frozen -1 -A addr_list --output nominate.tx

命令会生成交易内容，然后对其进行签名

.. code-block:: bash
    :linenos:

    # 提名者签名
    ./xchain-cli multisig sign --tx nominate.tx --output nominate.sign --keys path/to/nominate
    # 候选人签名
    ./xchain-cli multisig sign --tx nominate.tx --output candidate.sign --keys path/to/candidate

然后将生成的交易发送

.. code-block:: bash
    :linenos:

    # send 后面的签名有两个参数，第一个为发起方的签名，第二个为需要收集的签名（列表逗号分隔）
    ./xchain-cli multisig send --tx nominate.tx nominate.sign nominate.sign,candidate.sign

发送交易会返回一个txid，这里需要记录下来，后面可能会用到

投票
^^^^

投票的配置也是一个json格式

.. code-block:: python
    :linenos:

    {
        "module": "tdpos",
        "method": "vote",
        "args": {
            # 提名过的address
            "candidates":["RU7Qv3CrecW5waKc1ZWYnEuTdJNjHc43u"]
        }
    }

同样使用转账的命令发出，注意投票的utxo需要永久冻结。

.. code-block:: bash
    :linenos:

    # 同样，转账目标地址可任意填写，转给自己也可以
    ./xchain-cli transfer --to=dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN --desc=vote.json --amount=1 --frozen -1

根据共识算法配置的候选人集合大小（上面配置中的"proposer_num"字段，假设为n），每一轮出块结束后系统都会查看被提名的候选人数目是否达到n，如果没有达到则继续按上一轮的顺序出块；如果达到n则会统计得票靠前的n个节点为新一轮的矿工集合

.. note:: 细心的读者可能已经发现这些配置文件的json key 都类似，可以参考 xuperchain/core/contract/contract.go 中TxDesc的定义

撤销提名 && 撤销投票
^^^^^^^^^^^^^^^^^^^^

Json格式的配置又来了

.. code-block:: python
    :linenos:

    {
        "module":"proposal",
        "method": "Thaw",
        "args" : {
            # 此处为提名或者投票时的txid，且address与提名或者投票时需要相同
            "txid":"02cd75a721f2589a3ff6768b49650b46fa0b042f970df935b4d28a15aa19e49a"
        }
    }

然后使用转账操作发出（注意address一致），撤销提名/投票后，当时被冻结的资产会解冻，可以继续使用了

.. code-block:: bash
    :linenos:

    ./xchain-cli transfer --to=dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN --desc=thaw.json --amount=1

TDPOS结果查询
^^^^^^^^^^^^^

 XuperChain 的客户端提供了这一功能

1. 查询候选人信息

.. code-block:: bash

    ./xchain-cli tdpos query-candidates

2. 查看某一轮的出块顺序

.. code-block:: bash

    ./xchain-cli tdpos query-checkResult -t=30

3. 查询提名信息：某地址发起提名的记录

.. code-block:: bash

    ./xchain-cli tdpos query-nominate-records -a=dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN

4. 被提名查询：某个候选人被提名的记录

.. code-block:: bash

    ./xchain-cli tdpos query-nominee-record -a=RU7Qv3CrecW5waKc1ZWYnEuTdJNjHc43u

5. 某选民的有效投票记录

.. code-block:: bash

    ./xchain-cli tdpos query-vote-records -a=dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN

6. 某候选人被投票记录

.. code-block:: bash

    ./xchain-cli tdpos query-voted-records -a=RU7Qv3CrecW5waKc1ZWYnEuTdJNjHc43u

各种查询命令的详细参数列表可以通过 ./xchain-cli tdpos -h 查询

常见问题
--------

- 端口冲突：注意如果在一台机器上部署多个节点，各个节点的RPC监听端口以及p2p监听端口都需要设置地不相同，避免冲突；
- 节点公私钥和节点netUrl冲突：注意网络中不同节点./data/keys下的文件和./data/netkeys下的内容都应该不一样，这两个文件夹是节点在网络中的唯一标识，每个节点需要独自生成，否则网络启动异常；
- 启动时链接bootNodes节点失败：注意要先将bootNodes节点启动，再起动其他节点，否则会因为加入网络失败而启动失败；
- 遇到The gas you cousume is: XXXX, You need add fee 通过加--fee XXXX 参数附加资源；
