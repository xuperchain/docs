
多节点部署
==========

在阅读本节前，请先阅读“快速入门”，当中介绍了创建单节点网络的创建，在该基础上，搭建一个SINGLE共识的多节点网络，其他节点只要新增p2p网络bootNodes配置即可。如果你想搭建一个TDPoS共识的链，仅需要修改创世块参数中“genesis_consensus”配置参数即可。下面将详细介绍相关操作步骤。

p2p网络配置
-----------

我们以搭建3个节点的网络为例来说明（其实搭建更多节点的原理是一致的），首先需要有一个节点作为“bootNode”，其他节点启动前都配置这个“bootNode”的地址即可实现

对于bootNode节点，我们需要先获取它的netUrl，具体命令如下：

.. code-block:: bash
    :linenos:

    ./xchain-cli netUrl get -H 127.0.0.1:37101

如果不是以默认配置启动的，我们需要先生成它的netUrl，然后再获取

.. code-block:: bash
    :linenos:

    ./xchain-cli netUrl gen -H 127.0.0.1:37101

如此我们会获得一个类似于 
``/ip4/127.0.0.1/tcp/47101/p2p/QmVxeNubpg1ZQjQT8W5yZC9fD7ZB1ViArwvyGUB53sqf8e`` 
样式的返回

对其他的节点，我们需要修改其服务配置 `conf/xchain.yaml` 中p2pv2一节

.. code-block:: yaml
    :linenos:

    p2pV2:
        // port是节点p2p网络监听的默认端口，如果在一台机器上部署注意端口配置不要冲突，
        // node1配置的是47101，node2和node3可以分别设置为47102和47103
        port: 47102
        // 节点加入网络所连接的种子节点的链接信息，
        bootNodes:
        - "/ip4/127.0.0.1/tcp/47101/p2p/QmVxeNubpg1ZQjQT8W5yZC9fD7ZB1ViArwvyGUB53sqf8e"

.. note::
    需要注意的是，如果节点分布在不同的机器之上，需要把netUrl中的本地ip改为机器的实际ip

修改完配置后，即可在每一个节点使用相同配置创建链，然后分别启动bootNode和其他节点，即完成了多节点环境的部署

这里可以使用系统状态的命令检查环境是否正常

.. code-block:: bash
    :linenos:

    ./xchain-cli status -H 127.0.0.1:37101

通过变更 -H 参数，查看每个节点的状态，若所有节点高度都是一致变化的，则证明环境部署成功

搭建TDPoS共识网络
-----------------

XuperUnion系统支持可插拔共识，通过修改创世块的参数，可以创建一个以TDPoS为共识的链。

下面创世块配置（一般位于 data/config/xuper.json）和单节点创世块配置的区别在于创世共识参数genesis_consensus的config配置，各个配置参数详解配置说明如下所示：

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
            "candidate": "RU7Qv3CrecW5waKc1ZWYnEuTdJNjHc43u"
        }
    }

然后将这个json文件（假定文件名为nominate.json）通过转账发出

.. code-block:: bash
    :linenos:

    # 这里转账的目标地址可以任意，转给自己也可以
    ./xchain-cli transfer --to=dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN --desc=nominate.json --amount=1

命令会返回一个Txid，需要记下来，后面的环节可能会使用到

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

同样使用转账的命令发出

.. code-block:: bash
    :linenos:

    ./xchain-cli transfer --to=dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN --desc=vote.json --amount=1

.. note:: 细心的读者可能已经发现这些配置文件的json key 都类似，可以参考 xuperunion/contract/contract.go 中TxDesc的定义

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

然后使用转账操作发出（注意address一致）

.. code-block:: bash
    :linenos:

    ./xchain-cli transfer --to=dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN --desc=vote.json --amount=1

TDPOS结果查询
^^^^^^^^^^^^^

超级链的客户端提供了这一功能

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