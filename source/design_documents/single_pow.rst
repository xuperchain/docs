
Single及PoW共识
===============

介绍
----

Single以及PoW属于不同类型的区块链共识算法。其中，PoW(Proof Of Work，工作量证明)是通过解决一道特定的问题从而达成共识的区块链共识算法；而Single亦称为授权共识，在一个区块链网络中授权固定的address来记账本。Single一般在测试环境中使用，不适合大规模的应用环境。PoW适用于公有链应用场景。

算法流程
--------

**Single共识**

- 对于矿工：Single是固定 address 周期性出块，因此在调用 CompeteMaster 的时候主要判断当前时间与上一次出块时间间隔是否达到一个周期；
- 对于验证节点：验证节点除了密码学方面必要的验证之外，还会验证矿工与本地记录的矿工是否一致；

**Pow共识**

- 对于矿工：每次调用 CompeteMaster 都返回 true，表明每次调用 CompeteMaster 的结果都是矿工该出块了；
- 对于验证节点：验证节点除了密码学方面必要的验证之外，还会验证区块的难度值是否符合要求；


在 XuperChain 中使用Single或PoW共识
-----------------------------

只需修改 data/config 中的创世块配置即可指定使用共识

使用Single共识的创世块配置
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: python
    :linenos:

    {
        "version" : "1", 
        "consensus" : {
            # 共识算法类型
            "type"  : "single",
            # 指定出块的address
            "miner" : "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN"
        },
        # 预分配
        "predistribution":[
            {
                "address" : "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN",
                "quota" : "100000000000000000000"
            }
        ],
        # 区块大小限制
        "maxblocksize" : "128",
        # 出块周期
        "period" : "3000",
        # 出块奖励
        "award" : "428100000000",
        # 精度
        "decimals" : "8",
        # 出块奖励衰减系数
        "award_decay": {
            "height_gap": 31536000,
            "ratio": 1
        },
        # 系统权限相关配置
        "permission": {
            "CreateAccount" : { "rule" : "NULL", "acl": {}},
            "SetAccountAcl": { "rule" : "NULL", "acl": {}},
            "SetContractMethodAcl": { "rule" : "NULL", "acl": {}}
        }
    }


使用PoW共识的创世块配置
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: python
    :linenos:

    {
        "version" : "1",
        # 预分配
        "predistribution":[
            {
                "address" : "Y4TmpfV4pvhYT5W17J7TqHSLo6cqq23x3",
                "quota" : "1000000000000000"
            }
        ], 
        "maxblocksize" : "128",
        "award" : "1000000",
        "decimals" : "8",
        "award_decay": {
            "height_gap": 31536000,
            "ratio": 0.5
        },
        "genesis_consensus":{
            "name": "pow",
            "config": {
                    # 默认难度值
                    "defaultTarget": "19",
                    # 每隔10个区块做一次难度调整
                    "adjustHeightGap": "10",
                    "expectedPeriod": "15",
                    "maxTarget": "22"
            }
        }
    }


关键技术
--------

Single共识的原理简单，不再赘述。

**PoW共识**

解决一道难题过程，执行流程如下：

- **step1** 每隔一个周期判断是否接收到新的区块。若是，跳出解决难题流程，若不是，进行 **step2** ；
- **step2** 判断当前计算难度值是否符合要求。若是，跳出难题解决流程，若不是难度值加1，继续 **step1** ；

伪代码如下：

.. code-block:: go
    :linenos:

    // 在每次挖矿时，设置为true
    // StartPowMinning
    for {
        // 每隔round次数，判断是否接收到新的区块，避免与网络其他节点不同步
        if gussCount % round == 0 && !l.IsEnablePowMinning() {
            break
        }
        // 判断当前计算难度值是否符合要求
        if valid = IsProofed(block.Blockid, targetBits); !valid {
            guessNonce += 1
            block.Nonce = guessNonce
            block.Blockid, err = MakeBlockID(block)
            if err != nil {
                return nil, err 
            }   
            guessCount++
            continue
        }   
        break
    }   
    // valid为false说明还没挖到块
    // l.IsEnablePowMinning() == true  --> 自己挖出块
    // l.IsEnablePowMinning() == false --> 被中断
    if !valid && !l.IsEnablePowMinning() {
        l.xlog.Debug("I have been interrupted from a remote node, because it has a higher block")
        return nil, ErrMinerInterrupt
    }

计算当前区块难度值过程，执行流程如下：

- **step1** 判断当前区块所在高度是否比较小。若是，直接复用默认的难度值，跳出计算区块难度值过程，若不是，继续 **step2** ；
- **step2** 获取当前区块的前一个区块的难度值；
- **step3** 判断当前区块是否在下一个难度调整周期范围内。若是，继续 **step4** ；若不是，继续 **step5** ；
- **step4** 获取当前区块的前一个区块的难度值，并计算经历N个区块，预期/实际消耗的时间，并根据公式调整难度值，跳出计算区块难度值过程；
- **step5** 如果当前区块所在高度在下一次区块难度调整的周期范围内，直接复用前一个区块的难度值，跳出计算区块难度值过程；

伪代码如下：

.. code-block:: go
    :linenos:

    func (pc *PowConsensus) calDifficulty(curBlock *pb.InternalBlock) int32 {
        // 如果当前区块所在高度比较小，直接复用默认的难度值
        if curBlock.Height <= int64(pc.config.adjustHeightGap) {
            return pc.config.defaultTarget
        }   
        height := curBlock.Height
        preBlock, err := pc.getPrevBlock(curBlock, 1)
        if err != nil {
            pc.log.Warn("query prev block failed", "err", err, "height", height-1)
            return pc.config.defaultTarget
        }
        // 获取当前区块前一个区块的难度值   
        prevTargetBits := pc.getTargetBitsFromBlock(preBlock)
        // 如果当前区块所在高度恰好是难度值调整所在的高度周期
        if height%int64(pc.config.adjustHeightGap) == 0 { 
            farBlock, err := pc.getPrevBlock(curBlock, pc.config.adjustHeightGap)
            if err != nil {
                pc.log.Warn("query far block failed", "err", err, "height", height-int64(pc.config.adjustHeightGap))
                return pc.config.defaultTarget
            }
            // 经历N个区块，预期消耗的时间
            expectedTimeSpan := pc.config.expectedPeriod * (pc.config.adjustHeightGap - 1)
            // 经历N个区块，实际消耗的时间
            actualTimeSpan := int32((preBlock.Timestamp - farBlock.Timestamp) / 1e9)
            pc.log.Info("timespan diff", "expectedTimeSpan", expectedTimeSpan, "actualTimeSpan", actualTimeSpan)
            //at most adjust two bits, left or right direction
            // 避免难度值调整太快，防止恶意攻击
            if actualTimeSpan < expectedTimeSpan/4 {
                actualTimeSpan = expectedTimeSpan / 4
            }
            if actualTimeSpan > expectedTimeSpan*4 {
                actualTimeSpan = expectedTimeSpan * 4
            }
            difficulty := big.NewInt(1)
            difficulty.Lsh(difficulty, uint(prevTargetBits))
            difficulty.Mul(difficulty, big.NewInt(int64(expectedTimeSpan)))
            difficulty.Div(difficulty, big.NewInt(int64(actualTimeSpan)))
            newTargetBits := int32(difficulty.BitLen() - 1)
            if newTargetBits > pc.config.maxTarget {
                pc.log.Info("retarget", "newTargetBits", newTargetBits)
                newTargetBits = pc.config.maxTarget
            }
            pc.log.Info("adjust targetBits", "height", height, "targetBits", newTargetBits, "prevTargetBits", prevTargetBits)
            return newTargetBits
        } else {
            // 如果当前区块所在高度在下一次区块难度调整的周期范围内，直接复用前一个区块的难度值
            pc.log.Info("prev targetBits", "prevTargetBits", prevTargetBits)
            return prevTargetBits
        }
    }


