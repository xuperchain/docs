
提案和投票机制
==============

.. figure:: ../images/proposal-1.png
    :align: center

    图1：提案和投票机制示意图

提案和投票机制是区块链系统实现自我进化的关键。系统首次上线后难免遇到很多问题，我们提供提案/投票机制为区块链的社区治理提供便利的工具，以保证未来系统的可持续发展。具体实现方法如下：

Step1：提案者（proposer) 通过发起一个事务声明一个可调用的合约，并约定提案的投票截止高度，生效高度；
Step2：投票者(voter) 通过发起一个事务来对提案投票，当达到系统约定的投票率并且账本达到合约的生效高度后，合约就会自动被调用；
Step3：为了防止机制被滥用，被投票的事务的需要冻结参与者的一笔燃料，直到合约生效后解冻。

共识可升级
----------

.. figure:: ../images/proposal-2.png
    :align: center

    图2：XuperChain提案机制进行共识升级

XuperChain提供可插拔共识机制，通过提案和投票机制，升级共识算法或者参数。图2简要说明了如何使用XuperChain的提案机制进行共识升级。

系统参数可升级
--------------

通过提案和投票机制，区块链自身的运行参数也是可升级的。包括：block大小、交易大小、挖矿奖励金额和衰减速度等。

下面通过一个例子来说明，假设一条链，最开始用的是POW共识，创始块如下：

.. code-block:: python
    :linenos:

    {
        "version" : "1",
        "predistribution": [
            {}
        ],
        "maxblocksize" : "128",
        "award" : "1000000",
        "decimals" : "8",
        "award_decay": {
            "height_gap": 31536000,
            "ratio": 0.5
        },
        "genesis_consensus": {
            "name": "pow",
            "config": {
                    "defaultTarget": "19",      # 默认难度19个0 bits前缀
                    "adjustHeightGap": "10",    # 每10个区块调整一次难度
                    "expectedPeriod": "15",     # 期望15秒一个区块
                    "maxTarget": "22"
            }
        }
    }

然后，我们想将其共识切换到TDPOS共识。

步骤1:由提案者发起提案，提案没有额外的代价，通过命令行的desc选项指向提案用的json即可。
提案json的内容如下：

.. code-block:: python
    :linenos:

    {
        "module": "proposal",
        "method": "Propose",
        "args" : {
            "min_vote_percent": 51,     # 当投票者冻结的资产占全链的51%以上时生效提案
            "stop_vote_height": 120     # 停止计票的高度是:120
        },
        "trigger": {
            "height": 130,              # 提案生效高度是：130
            "module": "consensus",
            "method": "update_consensus",
            "args" : {
                "name": "tdpos",
                "config": {
                    "proposer_num":"3",
                    "period":"3000",
                    "term_gap":"60000",
                    "alternate_interval": "3000",
                    "term_interval": "6000",
                    "block_num":"10",
                    "vote_unit_price":"1",
                    "init_proposer": {
                        "1": ["dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN", "f3prTg9itaZY6m48wXXikXdcxiByW7zgk", "U9sKwFmgJVfzgWcfAG47dKn1kLQTqeZN3"]
                    }
                }
            }
        }
    }

把上面的json保存在myprop.json, 然后运行：

.. code-block:: bash
    :linenos:

    ./xchain-cli transfer --to `cat data/keys/address` --desc ./myprop.json --amount 1

得到一个txid，此处为 ``67cc7cd23b7fcbe0a4919d5c581b3fda759da13cdd97414afa7539e221727594``

然后，通过

.. code-block:: bash
    :linenos:

    ./xchain-cli tx query 67cc7cd23b7fcbe0a4919d5c581b3fda759da13cdd97414afa7539e221727594

确认该交易已经上链（标志是blockid不为空了）

步骤2：可以对这个提案投票。投票需要冻结自己资产，并且冻结高度必须大于停止计票的高度。

.. code-block:: bash
    :linenos:

    ./xchain-cli vote –amount 100000000 –frozen 121 67cc7cd23b7fcbe0a4919d5c581b3fda759da13cdd97414afa7539e221727594

.. note:: 注意：冻结高度121需要大于提案停止计票高度120, 否则是无效投票。

另外，累计投票金额数量必须大于全链总量的51%  (51%是提案json中指定的，但是最小不能少于50%)

.. code-block:: bash
    :linenos:

    ./xchain-cli account balance –Z # 可以查看自己被冻结的资产总量。
    ./xchain-cli status --host localhost:37301  | grep -i total # 查询全链的资产总量。

步骤3：最后，等到当前生效高度到达，会发现共识已经切换到TDPOS了。

.. code-block:: bash
    :linenos:

    ./xchain-cli tdpos status 

此命令可以查看tdpos状态。
