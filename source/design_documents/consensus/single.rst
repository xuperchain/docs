Single共识
===========
Single称为授权共识，在一个区块链网络中授权固定的address来记账本。Single一般在测试环境中使用，不适合大规模的应用环境。

角色
-------
- 对于矿工：Single是固定 address 周期性出块，因此在调用 ``CompeteMaster`` 的时候主要判断当前时间与上一次出块时间间隔是否达到一个周期；

- 对于验证节点：验证节点除了密码学方面必要的验证之外，还会验证矿工与本地记录的矿工是否一致；

创世块配置
-----------
.. code-block:: bash
    :linenos:

    "genesis_consensus":{
        "name": "single",
        "config": {
            "miner": "TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY", // 指定唯一矿工的xchain节点地址
            "period": "3000" 
        }
    }



