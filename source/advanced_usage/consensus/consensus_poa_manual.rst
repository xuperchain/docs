PoA类使用
===========

共识状态查看
-------------

共识状态查询
^^^^^^^^^^^^

**1. 通用共识状态查询**

.. code-block:: bash

	./bin/xchain-cli consensus status

**2. PoA存储字段查询**

.. code-block:: bash

	// 若不装载Chained-BFT组件，--type后需填写poa
        ./bin/xchain-cli consensus invoke --type xpoa --method getValidates --fee ${1000_IF_NEED}

.. Important::
     变更之后，并不会立即生效，必须在3个块高度之后生效(高度为H的高度，H+3之后才会生效，此处实际使用快照读取)。

创世块配置介绍
---------------

PoA类共识的创世块示例在上述 ``/data/genesis/xpoa.json`` 中，下面简要介绍:

.. code-block:: bash
    :linenos:

	"genesis_consensus":{
	    "name": "xpoa", // 共识名称
            "config": {
                "period":3000,  // 【重要】每个块生产固定时间，单位为毫秒，示例所示为3s一个块
                "block_num":40, // 【重要】每个候选人在一轮轮数中需要出块的数目
                "init_proposer": {
                    "address" : ["TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY", "SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co"]  // 【重要】数组中记录了全部初始候选人节点的address
                }
                // , "bft_config":{}  可选项，即配置chained-bft组件。
            }
	}

PoA候选人变更流程整体介绍
---------------------------

PoA整体候选人变更流程详细介绍请见 `PoA流程 <../../design_documents/consensus/poa.html#xuperchain>`_ 。

Xpoa类命令行操作，仅限变更目前的validators集合address地址，一步即可完成。候选人集合中的节点发起操作变更，发送成功之后，将在三个块之后生效，候选人集合被改变。

修改候选人流程
^^^^^^^^^^^^^^

- **ACL账户准备**

修改候选人需要通过合约ACL实现，我们建议将ACL设定为当前全部候选人集合的均值权限。例如初始状态下有节点1和节点2为候选人集合节点，那么ACL账户为节点1和节点2的组合账户，每人的权限均分分配为0.5，阈值权限为0.6，需两人全部签名。用户可根据业务场景需求自设定ACL账户。

ACL多签流程如下:

.. code-block:: bash

    ./bin/xchain-cli account new --desc account.des --fee 1000
    ./bin/xchain-cli transfer --to XC1111111111111111@xuper --amount 1000000000

具体account.des示例如下:

.. code-block:: bash

    // account.des
    {
        "module_name": "xkernel",
        "method_name": "NewAccount",
        "contract_name": "$acl",
        "args" : {
            "account_name": "1111111111111111",
            "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 0.6},\"aksWeight\": {\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\": 0.5, \"SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co\": 0.5}}"}
    }

.. Important::
    注意应有文件data/acl/addrs。

    .. code-block:: bash

        // addr
        XC1111111111111111@xuper/TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY
        XC1111111111111111@xuper/SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co

更改候选人集合的命令行如下，增删改全部仅使用一个方法editValidates。该方法走多签流程。

.. code-block:: bash
    :linenos:
	
	./bin/xchain-cli consensus invoke --type xpoa --method editValidates --isMulti --account ${ACL_ACCOUNT} --fee ${1000_IF_NEED} --desc ${EDIT_FILE} -H:${PORT}

	// 后续会生成一个tx.out在当前目录。
	// 注意需要在建立/data/acl/addrs，标明ACL账户信息。
	./bin/xchain-cli multisig sign --tx=./tx.out --output=./key1.sign
	./bin/xchain-cli multisig sign --tx=./tx.out  --keys ${acl keys地址}  --output=./key2.sign
	./bin/xchain-cli multisig send --tx ./tx.out ./key1.sign,./key2.sign ./key1.sign,./key2.sign -H:${PORT}

	// 成功后会生成txid
..

具体edit_file示例如下。 

.. code-block:: bash
    :linenos: 

	// edit_file
	{
	    "validates":"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY;SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co;iYjtLcW6SVCiousAb5DFKWtWroahhEj4u"
	}
..
