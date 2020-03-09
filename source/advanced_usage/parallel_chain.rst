
使用平行链
==========

创建平行链
----------

现在超级链中创建平行链的方式是：发起一个系统智能合约，发到xuper链。

当前xchain.yaml有两个配置项：

.. code-block:: yaml
    :linenos:

    Kernel:
        # minNewChainAmount 设置创建平行链时最少要转多少utxo（门槛）到同链名的address
        minNewChainAmount: “100”
        # newChainWhiteList 有权创建平行链的address白名单
        newChainWhiteList:
            - dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN: true

创建平行链的json文件（模版），如下：

.. code-block:: python
    :linenos:

    {
        "Module": "kernel",
        "Method": "CreateBlockChain",
        "Args": {
            "name": "HelloChain",
            "data": "{\"version\": \"1\", \"consensus\": {\"miner\":\"dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN\", \"type\":\"single\"},\"predistribution\":[{\"address\": \"dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN\",\"quota\": \"1000000000000000\"}],\"maxblocksize\": \"128\",\"period\": \"3000\",\"award\": \"1000000\"}"
        }
    }

使用如下指令即可创建平行链：

.. code-block:: bash
    :linenos:

    ./xchain-cli transfer --to HelloChain --amount 100 --desc createChain.json

创建群组
--------

如果希望创建的平行链只在自己希望的小范围使用，那么可以参考此节配置群组功能

当前超级链中创建群组的方式是：在xuper链上部署GroupChain智能合约，将节点白名单加到GroupChain合约中。

在创世块中配置群组合约配置：

.. code-block:: python
    :linenos:

    {
        "group_chain_contract": {
            "module_name": "wasm",
            "contract_name": "group_chain",
            "method_name": "list",
            "args":{}
        }
    }

如果需要确保HelloChain具备群组属性，且白名单为<ip1,addr1>,<ip2,addr2>，其他节点不能获取这条平行链的信息，可以按如下操作

step1: 在xuper链部署GroupChain合约

.. code-block:: bash
    :linenos:

    # 需要使用合约账号，部署编译好的合约文件
    ./xchain-cli wasm deploy --account XC1111111111111111@xuper --cname group_chain ./group_chain.wasm --fee xxx

step2: 调用GroupChain合约的AddNode方法将<ip1,add1>,<ip2,add2>加入白名单

.. code-block:: bash
    :linenos:

    ./xchain-cli wasm invoke group_chain --method addNode -a '{"bcname":"HelloChain", "ip":"ip1", "address":"addr1"}'
    ./xchain-cli wasm invoke group_chain --method addNode -a '{"bcname":"HelloChain", "ip":"ip2", "address":"addr2"}'

step3: 调用GroupChain合约的AddChain确保HelloChain具备群组特性

.. code-block:: bash
    :linenos:

    ./xchain-cli wasm invoke group_chain --method addChain -a '{"bcname":"HelloChain"}'

至此即完成了群组的设置，只有<ip1,add1>,<ip2,add2>两个节点可以获取平行链HelloChain的内容了。