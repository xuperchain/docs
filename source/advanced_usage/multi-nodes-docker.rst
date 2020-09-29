
多节点部署
==========


使用 docker-compose 快速体验 3 节点 p2p 网络
-----------


直接在命令行执行如下命令，快速启动一个三节点的 p2p 网络

.. code-block:: bash
    :linenos:

    wget https://raw.githubusercontent.com/chenfengjin/xuperchain/dev/docker-compose.yml && docker-compose up


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

然后生成一个提名交易，超级链上进行候选人提名需要冻结大于链上资产总量的十万分之一的utxo（当前的总资产可以通过 `status查询命令 <../quickstart.html#svr-status>`_ 查看结果的utxoTotal字段）

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
