PoW共识
===========
PoW(Proof Of Work，工作量证明)是通过解决一道特定的问题从而达成共识的区块链共识算法, 本实现参考了Bitcoin的PoW算法。

流程
---------

- **矿工：** 每次调用 ``CompeteMaster`` 都返回 true，表明每次调用 ``CompeteMaster`` 的结果都是矿工该出块了。

- **矿工：** 调用 ``CalculateBlock`` 接口进行工作量证明。

- **验证节点：** 验证节点除了密码学方面必要的验证之外，还会验证区块的难度值是否符合要求。

创世块配置
------------
.. code-block:: bash
    :linenos:

    "genesis_consensus":{
        "name": "pow",
        "config": {
            "defaultTarget": "19", // 默认难度值
            "adjustHeightGap": "10", // 每隔10个区块做一次难度调整
            "expectedPeriod": "15", // 每个区块调整的默认时间
            "maxTarget": "22" // 最大难度值
        }
    }
