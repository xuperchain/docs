
发起提案
========

XuperChain中有多种提案-投票操作场景，但原理都是一致的，我们以通过提案更改共识算法（single改为tdpos）来介绍具体的操作流程

部署一个Single共识的超级链环境已经在“快速入门”一节有介绍

首先我们需要准备一个tdpos共识的配置，包括出块时间、代表名单等（假设文件名为proposal.json）

.. code-block:: python
    :linenos:

    {
        "module": "proposal",
        "method": "Propose",
        "args" : {
            "min_vote_percent": 51,                 # 生效的资源比例
            "stop_vote_height": 800                 # 计票截至的高度
        },
        "trigger": {
            "height": 1000,                         # 期望生效的高度
            "module": "consensus",
            "method": "update_consensus",
            "args" : {
                "name": "tdpos",
                "config": {
                    "version":"2",
                    "proposer_num":"2",             # 代表个数
                    "period":"3000",
                    "alternate_interval":"6000",
                    "term_interval":"9000",
                    "block_num":"20",
                    "vote_unit_price":"1",
                    "init_proposer": {              # 出块的代表名单
                        "1":["dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN", "U5SHuTiiSP1JAAHVMknqrm66QXk2VhXsK"]
                    }
                }
            }
        }
    }

需要注意的是当前的区块高度，来设置合理的截至计票高度和生效高度。然后在矿工节点下，执行给自己转账的操作，并在 --desc 参数里传入提案

.. code-block:: python
    :linenos:

    ./xchain-cli transfer --to dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN --desc proposal.json --amount 100

运行后会得到本次提案的交易id，需要记录下来供投票使用

对提案进行投票操作由如下命令执行

.. code-block:: python
    :linenos:

    ./xchain-cli vote f26d670b695d9fd5da503a34d130ef19e738b35e031b18b70ad4cbbf6dfe2656 --frozen 1100 --amount 100002825031900000000

这里需要注意进行投票的节点需要有矿工账号的密钥对，以及 --frozen 参数的冻结高度大于提案生效的高度。因为最终通过的规则是投票资源大于总资源的51%，所以需要初始token量最多的矿工账号来进行投票，并保证token数符合要求。

如此进行后，等到区块出到设定的生效高度，便完成了提案-投票的整个流程。其他场景的提案机制都是类似的，仅是json配置文件不同而已。
