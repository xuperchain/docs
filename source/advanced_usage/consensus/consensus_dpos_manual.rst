TDPoS类使用
===========

共识状态查看
-------------

共识状态查询
^^^^^^^^^^^^^

**1. 通用共识状态查询**

.. code-block:: bash
    
    ./bin/xchain-cli consensus status

**2. TDPoS存储字段查询**

.. code-block:: bash

    // 若装载Chained-BFT组件，--type后需填写xpos
    ./bin/xchain-cli consensus invoke --type tdpos --method getTdposInfos --fee ${1000_IF_NEED}

.. Important::
    后续提及的合约变更操作之后，并不会立即生效，必须在下一个term生效。同时，从下一个term的第一个区块被生产开始，到下一个term的最后一个区块生产结束，这期间的候选人集合不变。


创世块配置介绍
^^^^^^^^^^^^^^^

Tdpos类共识的创世块示例在上述 ``/data/genesis/tdpos.json`` 中，下面简要介绍:

.. code-block:: bash
    :linenos:

	"genesis_consensus":{
            "name": "tdpos",   // 共识名称，TDPoS和XPoS的统称
            "config": {
		    "timestamp": "1559021720000000000",   // 开始时间，可忽略
		    "proposer_num": "2",   // 【重要】候选人集合总人数，配置后只能通过【共识升级修改】
		    "period": "3000",   // 【重要】每个块生产固定时间，单位为毫秒，示例所示为3s一个块
		    "alternate_interval": "3000",   // 同一轮矿工切换间隙时间
		    "term_interval": "6000",    // term切换间隙时间
		    "block_num": "20",  // 【重要】每个候选人在一轮轮数中需要出块的数目
		    "vote_unit_price": "1", // 计票单位
		    "init_proposer": {
		        "1": ["TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY", "SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co"] // 【重要】数组中记录了全部初始候选人节点的address
		    },
		    // , "bft_config":{}  // 可选项，即加载chained-bft组件，加载后共识实际上为XPoS。
	    }
    }

TDPoS投票流程整体介绍
^^^^^^^^^^^^^^^^^^^^^

**1. 整体流程**
TDPoS类命令行操作，仅限变更候选人集合地址信息，主要需要以下流程：

- 某节点发起 **候选人提名nominate** ，发起需要是一个ACL账户，该ACL账户需包含被提名人的地址，走多签流程完成候选人池的修改。完成之后，指定节点加入候选人池。

- 节点对候选人池进行 **投票vote** ，对候选人池中显示的节点地址投票。

-  **计票** ，在每轮term开始时，会检查候选人投票池的 TopK名候选人(即创世块 ``proposer_num`` 字段)并指定为该轮候选人集合。

- ***注意**，若投票的目标候选人池数量小于创世块 ``proposer_num`` 字段，投票并不会生效。

**2. 治理Token生成**
TDPoS的先决条件是 **必须先生成相关代币** ，通过下述命令生成。治理Token的生成在任意节点皆可触发，但只会按照创世块的配置分配。具体可见 `治理Token <../governance.html#xuperchain>`_

- ***注意**，下述提案投票时必须确保ACL或者节点账户拥有Token，即先向账户发起transfer，否则会报失败错误。

候选人流程
^^^^^^^^^^^^

**1. 提名候选人流程**

- **ACL账户准备**
  提名候选人需要通过合约ACL实现（若A提名B，则需要建立A、B的ACL账户，并保证两者均签名才能通过提案）。合约ACL多签流程如下。

.. code-block:: bash
    :linenos:

	./bin/xchain-cli account new --desc account.des --fee 1000
	./bin/xchain-cli transfer --to XC1111111111111111@xuper --amount 1000000000
..

  具体account.des示例如下。 

.. code-block:: bash
    :linenos: 

	// account.des
    {
        "module_name": "xkernel",
        "method_name": "NewAccount",
        "contract_name": "$acl",
        "args" : {
            "account_name": "1111111111111111",
            "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 0.6},\"aksWeight\": {\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\": 0.5, \"SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co\": 0.5}}"}
    }
..

 .. Important::
    注意应有文件data/acl/addrs。

    .. code-block:: bash
        :linenos:

	// addr
        XC1111111111111111@xuper/TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY
        XC1111111111111111@xuper/SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co


- **提名候选人** 

 提名候选人的命令行如下。

.. code-block:: bash

    :linenos:
	
	./bin/xchain-cli consensus invoke --type tdpos --method nominateCandidate --isMulti --account ${ACL_ACCOUNT} --fee ${1000_IF_NEED} --desc ${NOMINATE_FILE} -H:${PORT}
	// default: 后续会生成一个tx.out在当前目录下
	// default: 注意需要在建立/data/acl/addrs，标明提名人和被提名人信息
	// default: 上述走多签流程
	 
	 
	./bin/xchain-cli multisig sign --tx=./tx.out --output=./key1.sign
	./bin/xchain-cli multisig sign --tx=./tx.out  --keys ${被提名人keys地址}  --output=./key2.sign
	./bin/xchain-cli multisig send --tx ./tx.out ./key1.sign,./key2.sign ./key1.sign,./key2.sign -H:${PORT}
	// 成功后会生成txid
..

 nominate_file文件示例如下。

.. code-block:: bash
    :linenos:

	// nominate_file
	{
	    "candidate": "SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co",
	    "amount": "100"
	}


    

**2. 撤销候选人流程**
 撤销候选人流程将候选人池中指定候选人删除，抵押Token将会归还给投票的原所属人。

.. code-block:: bash
    :linenos:

    ./bin/xchain-cli consensus invoke --type tdpos --method revokeNominate --account ${ACCOUNT_IF_NEED} --isMulti --fee ${1000_IF_NEED} --desc ${REVOKE_NOMINATE_FILE} -H:${PORT}
	 
    // default: 会生成一个tx.out在当前目录下，操作内容和nominate一样
    // default: 注意需要在建立/data/acl/addrs，标明提名人和被提名人信息
    // default: 上述走多签流程
    ./bin/xchain-cli multisig sign --tx=./tx.out --output=./key1.sign
    ./bin/xchain-cli multisig sign --tx=./tx.out  --keys ${acl keys地址}  --output=./key2.sign
    ./bin/xchain-cli multisig send --tx ./tx.out ./key1.sign,./key2.sign ./key1.sign,./key2.sign -H:${PORT}
    // 成功后会生成txid
..

 revoke_nominate_file文件示例如下。

.. code-block:: bash
    :linenos:

	// revoke_nominate_file
	{
	    "candidate": "iYjtLcW6SVCiousAb5DFKWtWroahhEj4u"
	}


投票流程
^^^^^^^^^^^^

**1. 向候选人池进行投票**

.. code-block:: bash
    :linenos:

	./bin/xchain-cli consensus invoke --type tdpos --method nominateCandidate --isMulti --account ${ACL_ACCOUNT} --fee ${1000_IF_NEED} --desc ${NOMINATE_FILE} -H:${PORT}
	// default: 后续会生成一个tx.out在当前目录下
	// default: 注意需要在建立/data/acl/addrs，标明提名人和被提名人信息
	// default: 上述走多签流程
	 
	 
	./bin/xchain-cli multisig sign --tx=./tx.out --output=./key1.sign
	./bin/xchain-cli multisig sign --tx=./tx.out  --keys ${被提名人keys地址}  --output=./key2.sign
	./bin/xchain-cli multisig send --tx ./tx.out ./key1.sign,./key2.sign ./key1.sign,./key2.sign -H:${PORT}
	// 成功后会生成txid

..

 vote_file示例如下。

.. code-block:: bash
    :linenos:

	// vote_file
	{
	    "candidate": "iYjtLcW6SVCiousAb5DFKWtWroahhEj4u",
	    "amount": "10"
	}

**2. 撤销投票**
 投票人可将自己的票数撤销，撤销后原先被抵押的Token将会归还给投票人，同时将会影响下一term候选人。

.. code-block:: bash
    :linenos:

    ./bin/xchain-cli consensus invoke --type tdpos --method revokeVote --fee ${1000_IF_NEED} --desc ${REVOKE_VOTE_FILE} -H:${PORT} (--account ${ACCOUNT_IF_NEED}[Optional]  --isMulti[Optional])
    // 走default还是走optional流程，取决于四中vote是否使用acl账户
    // default: 成功后会生成txid
    // optional流程，多签流程
    // optional: 如果有--account --isMulti flag后续会生成一个tx.out在当前目录下，操作内容和nominate一样
    // optional: 注意需要在建立/data/acl/addrs，标明提名人和被提名人信息
    // optional: 上述走多签流程
    ./bin/xchain-cli multisig sign --tx=./tx.out --output=./key1.sign
    ./bin/xchain-cli multisig sign --tx=./tx.out  --keys ${acl keys地址}  --output=./key2.sign
    ./bin/xchain-cli multisig send --tx ./tx.out ./key1.sign,./key2.sign ./key1.sign,./key2.sign -H:${PORT}
    // 成功后会生成txid
..

 revoke_vote_file示例文件如下。

.. code-block:: bash
    :linenos:

	// revoke_vote_file
	{
	    "candidate": "iYjtLcW6SVCiousAb5DFKWtWroahhEj4u",
	    "amount": "1"
	}
..
