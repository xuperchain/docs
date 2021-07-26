
XPoA共识
=========

介绍
----

XPoA是 XuperChain 对PoA的一种实现，其基本思想是在节点中动态设定一组验证节点，验证节点组在预设的时间段内进行组内轮流出块(称之为轮值)，即其余节点在某特定验证节点V出块的时间段内统一将交易发送给V，交易由该验证节点V打包成区块。

XPoA支持动态变更验证节点，可以通过指令修改现有的验证节点组，包括对当前验证节点组进行删除和添加操作。在该算法中，预设时间段包括确定单个区块的出块时间，以及验证节点单次轮值出块数量。 同样，XPoA通过Chained-BFT算法来保证轮值期间的安全性。

详细操作请参考 `XPoA使用文档 <../advanced_usage/construct-XPoA.html>`_


技术细节
---------

在XPoA中，网络中的节点有两种角色，分别是“普通节点”和“验证节点”：

1. 普通节点：普通节点仅对验证节点进行验证，计算当前时间点下验证节点地址是否于计算结果吻合。
2. 验证节点：进行区块打包工作；在更改验证节点组过程中，多数验证节点需确定更改结果添加和删除操作方能生效。


**修改验证组规则**

验证组信息通过合约调用进行修改，流程主要有以下几点：

1. 在收到该信息后，验证节点通过签名信息确认交易真实性
2. 验证节点在UtxoVM中进行系统调用并更新当前验证人集合读写集
3. 验证人集合并不会立即影响当前共识，在三个区块后集合才能生效

**验证节点间轮值**

每一轮的时间由配置xuper.json指定，在单轮时间段内，区块打包由目前验证节点组中的节点按顺序轮流完成。在通过合约发起验证节点变更后，变更会在三个区块后才触发，然后验证节点按照新的验证组继续进行轮值。

.. image:: https://raw.githubusercontent.com/aucusaga/LearnXuperchainPicRep/master/XPoA/XPoA.jpg
    :align: center
 
 

调度代码具体实现如下:
 

.. code-block:: go
    
    func (xpoa *XPoa) minerScheduling(timestamp int64) (term int64, pos int64, blockPos int64) {
		...
		// 每一轮的时间
		termTime := xpoa.xpoaConf.period * int64(len(xpoa.proposerInfos)) * xpoa.xpoaConf.blockNum
		// 每个矿工轮值时间
		posTime := xpoa.xpoaConf.period * xpoa.xpoaConf.blockNum
    	// 当前轮数
		term = (timestamp-xpoa.termTimestamp)/termTime + 1
    	// 本轮已过时间
		resTime := (timestamp - xpoa.termTimestamp) - (term-1)*termTime
		// 当前验证节点所属位置
    	pos = resTime / posTime
    	// 当前验证节点所处轮值时间已过时间
		resTime = resTime - (resTime/posTime)*posTime
    	// 当前验证节点已出块数量
		blockPos = resTime/xpoa.xpoaConf.period + 1
		...
		return
	}


调度流程如下:

.. image::  https://raw.githubusercontent.com/aucusaga/LearnXuperchainPicRep/master/XPoA/minerScheduling.jpg
    :align: center

**拜占庭容错**

XPoA验证节点轮值过程中，采取了 `Chained-Bft <chained_bft.html>`_ 防止矿工节点的作恶。


整体代码
----------

XPoA实现主要在 ``consensus/xpoa`` 路径下，其主要是通过智能合约的方式实现的，合约在 ``contractsdk/cpp/example/xpoa_validates/src`` 路径下，主要有以下几个合约方法：

.. code-block:: c++
    :linenos:

    /*XPoA添加一个新的候选人节点*/
    DEFINE_METHOD(Hello, add_validate) {
    	...
    }
    /*XPoA删除一个候选人节点*/
    DEFINE_METHOD(Hello, del_validate) {
    	...
    }
    /*XPoA更新一个候选人节点信息*/
    DEFINE_METHOD(Hello, update_validate) {
    	...
    }
    /*查询当前候选人节点信息*/
    DEFINE_METHOD(Hello, get_validates) {
    	...
    }

核心接口如下：

.. code-block:: go
    :linenos:

    func (xpoa *XPoa) minerScheduling(timestamp int64) (term int64, pos int64, blockPos int64) {
        // 轮值时间调度计算规则
        ...
        return
    }
    func (xpoa *XPoa) getCurrentValidates() ([]*cons_base.CandidateInfo, int64, int64, error) {
        // 获取当前验证组信息，若无法查询则使用xuper.json初始化值
        ...
        return candidateInfos.Proposers, confirmedTime, confirmedHeight, nil
    }
    func (xpoa *XPoa) updateValidates(curHeight int64) (bool, error) {
        // 查询当前验证组，判断当前时间点是否需要更新验证组
        ...
        return true, nil
    }
    func (xpoa *XPoa) updateViews(viewNum int64) error {
        // 获取当前验证节点以及下一验证节点，创建下一轮新视图
        ...
        return xpoa.bftPaceMaker.NextNewView(viewNum, nextProposer, proposer)
    }
    func (xpoa *XPoa) getProposerWithTime(timestamp, height int64) (string, error) {
        // 根据当前时间戳计算当前验证节点是谁并返回其地址
        ...
        return xpoa.proposerInfos[pos].Address, nil
    }

