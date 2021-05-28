搭建XPoA共识的 XuperChain 网络
==========================

XPoA是为许可链设计的共识算法，XPoA共识算法的原理可以参考 XuperChain 的设计文档 `XPoA技术文档 <../design_documents/xpoa.html>`_ 。许可链指的是所有参与链系统的节点，都需经过许可，未经过许可的节点不可接入系统。下面介绍下如何搭建一个XPoA共识的 XuperChain 网络。

搭建XPoA共识网络
-----------------

p2p网络配置
>>>>>>>>>>>>>

以搭建3节点网络为例，拷贝xuperchain编译产出的output到node1~node3。每个节点需修改配置文件 *conf/xchain.yaml* 中p2p一节，使用p2pv1，p2pv1是为许可链设计的p2p网络插件。

.. code-block:: yaml

	p2p:
	  module: p2pv1
	  # port是节点p2p网络监听的默认端口，如果在一台机器上部署注意端口配置不要冲突，
	  # node1配置的是47101，node2、node3可以分别设置为47102、47103 
	  port: 47101
	  # 不使用证书
	  isUseCert: false
	  # 配置网络中所有节点的neturl, 格式ip:port, 也加上本节点的neturl
	  staticNodes:
	    xuper:
	      - "127.0.0.1:47101"
	      - "127.0.0.1:47102"
	      - "127.0.0.1:47103"


注意，如果节点分布在不同的机器之上，需要把网络地址中的本地ip改为机器的实际ip。

更新各节点的keys
>>>>>>>>>>>>>>>>>

由于节点目录下的keys都是默认的，node1保持不变，更新node2、node3的keys。更新前需手动删掉data/keys目录。更新keys命令如下：

.. code-block:: shell

	./xchain-cli account newkeys


配置创世块
>>>>>>>>>>>>>

XuperChain系统支持可插拔共识，通过修改创世块的参数，可以创建一个以XPoA为共识的链。创世块配置位于 *data/config/xuper.json* ，修改genesis_consensus一节。各个配置参数详解配置说明如下所示：

.. code-block:: bash

    {
        "version" : "1", 
        "predistribution":[
            {
                "address" : "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN", 
                "quota" : "100000000000000000000"
            }
        ], 
        "maxblocksize" : "128", 
        "award" : "1000000", 
        "decimals" : "8", 
        "award_decay": {
            "height_gap": 31536000,
            "ratio": 1
        }, 
        "gas_price": {
            "cpu_rate": 1000,
            "mem_rate": 1000000,
            "disk_rate": 1,
            "xfee_rate": 1
        }, 
        "new_account_resource_amount": 1000, 
        "genesis_consensus":{
            "name": "xpoa",
            "config": {
                // 声明共识的起始时间戳，建议设置为一个刚过去不久的时间戳，更新前10位
                "timestamp": "1590636296000000000",
               	// 每个矿工连续出块的出块间隔
               	"period":"3000",
               	// 每一轮内每个矿工轮值任期内连续出块的个数
               	"block_num":"10",
               	// xpoa共识依赖的合约名称，无需修改
               	"contract_name":"xpoa_validates",
               	// xpoa共识查询候选人的合约方法，无需修改
               	"method_name":"get_validates",
               	// 指定第一轮初始矿工，所指定的初始矿工需要在网络中存在，不然系统轮到该节点出块时会没有节点出块
               	"init_proposer": [
                    {
                       	"address" : "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN"
                       	, "neturl" : "10.26.29.40:47101"
                    },
                    {
                       	"address" : "VSML7NenZnGZgCEwtbQDKDSrPHhT5wsu6"
                       	, "neturl" : "10.26.29.40:47102"
                    },
                    {
                       	"address" : "bg3KLC3YCmvLWBCNAVHGHLfk3qeWEdoD3"
                       	, "neturl" : "10.26.29.40:47103"
                    }
               	],
               	// 使用chained-bft
               	"bft_config": {}
            }
        }
    }


将修改好的1份xuper.json拷贝到另外2个节点的data/config目录下。

注意，拷贝配置内容到xuper.json时需去掉注释。

创建链并启动xchain
>>>>>>>>>>>>>>>>>>>>

检查data/blockchain 目录下内容为空之后，创建链并启动所有节点。命令如下：

.. code-block:: shell

	# 创建xuper链
	./xchain-cli createChain
	# 启动服务节点
	nohup ./xchain &
	# check服务运行状况，修改-H后参数，可以查询每个节点状态
	for((i=1;i<=3;i++));do
	./xchain-cli status -H 127.0.0.1:3710$i |grep -i height
	done


通过变更-H 参数，查看每个节点的状态，若所有节点高度都是一致变化的，则证明环境状态正常。

验证集合合约部署和调用
-----------------------

XPoA共识算法中，候选人的变更依赖"验证集合"合约，所以需要部署"验证集合"合约。通过调用合约中的add_validate方法新增候选人、del_validate方法删除候选人、update_validate方法更新候选人neturl、get_validates方法查询候选人列表。通过设置合约方法的ACL，可以限制哪些用户具有变更候选人的权限，设置方法参考 `设置合约方法的ACL <../advanced_usage/create_contracts.html#acl>`_。

创建合约账号
>>>>>>>>>>>>>

合约账号用来做合约的管理，创建合约账号，并给合约账号转账。

.. code-block:: shell

	# 创建合约账号
	[work@]$ node1 -> ./xchain-cli account new --account 1111111111111111 --fee 1000 -H 127.0.0.1:37101
	# 执行结果
	# contract response:
	#         {
	#             "pm": {
	#                 "rule": 1,
	#                 "acceptValue": 1.0
	#             },
	#             "aksWeight": {
	#                 "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN": 1.0
	#             }
	#         }

	# The gas you cousume is: 1000
	# The fee you pay is: 1000
	# Tx id: eb9924c85a16d72f5daf6e6feabb130ef9c8a3ce8f507db08dcb726111aef74f
	# account name: XC1111111111111111@xuper

	# 给合约账号转账
	[work@]$ node1 -> ./xchain-cli transfer --to XC1111111111111111@xuper --amount 100000000 -H 127.0.0.1:37101
	# 执行结果
	# ec6fa53446a8c6ab0d8d45f2bba80c7e5122341ce9b0c85779f80ce1a55f37b6


编译合约
>>>>>>>>>>>>>

"验证集合"合约源码位于core/contractsdk/cpp/example/xpoa_validates，执行如下命令编译合约，编译结果为xpoa_validates.wasm。

.. code-block:: shell

	# prj是xuperchain源码所在目录，设定环境变量
	export PATH=$prj/xuperchain/output:$PATH
	export XDEV_ROOT=$prj/xuperchain/core/contractsdk/cpp
	# 编译合约
	cd $prj/xuperchain/core/contractsdk/cpp/example/xpoa_validates
	xdev build


部署合约
>>>>>>>>>>>>>

部署合约，并设置node1、node2为初始候选人。

.. code-block::  shell

	[work@]$ node1 -> ./xchain-cli wasm deploy --account XC1111111111111111@xuper --cname xpoa_validates --arg '{"addresss":"dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN;VSML7NenZnGZgCEwtbQDKDSrPHhT5wsu6","neturls":"127.0.0.1:47101;127.0.0.1:47102"}' ./xpoa_validates.wasm --fee 222065 -H 127.0.0.1:37101
	# 执行结果
	# contract response: initialize succeed
	# The gas you cousume is: 221920
	# The fee you pay is: 222065
	# Tx id: 4f9f11afcf080199b93d5f308b6dc0e07ce5b9099c36cbf9b4edb2ee398bcfa3


参数说明：

- **wasm deploy**：部署wasm合约
- **--account XC1111111111111111@xuper**：此为部署wasm合约的账号
- **--cname xpoa_validates** ：合约名称，需与xuper.json中配置的contract_name参数一致
- **--arg** ：此为传入合约的参数，这里设置初始矿工，所指定的初始矿工需要在网络中存在，多个矿工用分号间隔，且address与netrul要 一一对应。
- **./xpoa_validates.wasm** ：是编译合约产出的文件

增加候选人
>>>>>>>>>>>>>

以添加node3为候选人为例，添加后等待1分钟，调查看候选人命令，查看是否添加成功。

.. code-block:: shell

	[work@]$ node1 -> ./xchain-cli wasm invoke xpoa_validates --method add_validate --args '{"address":"bg3KLC3YCmvLWBCNAVHGHLfk3qeWEdoD3","neturl":"127.0.0.1:47103"}' --fee 300 -H 127.0.0.1:37101
	# 执行结果
	# contract response: {"address":"bg3KLC3YCmvLWBCNAVHGHLfk3qeWEdoD3","neturl":"127.0.0.1:47103"}
	# The gas you cousume is: 252
	# The fee you pay is: 300
	# Tx id: 5a3993d0e001aa0b140b204c013c6ea0b9741f8e1dfe81db71887579d63ce785


参数说明：

- **wasm invoke**：调用合约
- **--method add_validate**：调用add_validate方法
- **--args**：传入的参数，填写待添加候选人的address和neturl

查看候选人
>>>>>>>>>>>>>

查询结果中，候选人按字典序排列。

.. code-block:: shell

	[work@]$ node1 -> ./xchain-cli wasm invoke xpoa_validates --method get_validates -H 127.0.0.1:37101
	# 执行结果
	# contract response: {"proposers":[{"address":"VSML7NenZnGZgCEwtbQDKDSrPHhT5wsu6","neturl":"127.0.0.1:47102"},{"address":"bg3KLC3YCmvLWBCNAVHGHLfk3qeWEdoD3","neturl":"127.0.0.1:47103"},{"address":"dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN","neturl":"127.0.0.1:47101"}]}
	# The gas you cousume is: 439
	# You need add fee


- **wasm invoke**：调用合约
- **--method get_validates**：调用get_validates方法

更新候选人
>>>>>>>>>>>>>

候选人的netrul发生变化后，需要更新。以更新node3的neturl为例，比如更新为localhost:47103。修改后等待1分钟，调查看候选人命令，查看是否修改成功。

.. code-block:: shell

	[work@]$ node1 -> ./xchain-cli wasm invoke xpoa_validates --method update_validate -a '{"address":"bg3KLC3YCmvLWBCNAVHGHLfk3qeWEdoD3","neturl":"localhost:47103"}' --fee 300 -H 127.0.0.1:37101
	# 执行结果
	# contract response: {"address":"bg3KLC3YCmvLWBCNAVHGHLfk3qeWEdoD3","neturl":"localhost:47103"}
	# The gas you cousume is: 263
	# The fee you pay is: 300
	# Tx id: 6e6289c513169cd32c44fa05bb06c0eba0f37f05acd5eb6ae4573ae266363b76

参数说明：

- **wasm invoke**：调用合约
- **--method update_validate**：调用update_validate方法
- **--args**：传入的参数，填写待更新候选人的address和neturl

删除候选人
>>>>>>>>>>>>>

将node3从候选人集合删除。删除后等待1分钟，调查看候选人命令，查看是否删除成功。

.. code-block:: shell

	[work@]$ node1 -> ./xchain-cli wasm invoke xpoa_validates --method del_validate -a '{"address":"bg3KLC3YCmvLWBCNAVHGHLfk3qeWEdoD3"}' --fee 300 -H 127.0.0.1:37101
	# 执行结果
	# contract response: ok
	# The gas you cousume is: 128
	# The fee you pay is: 300
	# Tx id: a033b1c4b548c3515a29b5d643fdad20cc778c71a75a95869ddaae067177d7c4

- **wasm invoke**：调用合约
- **--method del_validate**：调用del_validate方法
- **--args**：传入的参数，填写待删除候选人的address和neturl

查看当前正在出块的候选人
>>>>>>>>>>>>>>>>>>>>>>>>>

通过日志，可查看当前正在出块的候选人。示例如下，其中proposer是正在出块候选人。并且，多个候选人按字典序轮值出块。

.. code-block:: shell

	[work@]$ node1 -> tailf logs/xchain.log|grep "bft NewView"
	t=2020-06-28T17:04:24+0800 lvl=info msg="bft NewView" module=xchain viewNum=550 dpm.currentView=550 proposer=bg3KLC3YCmvLWBCNAVHGHLfk3qeWEdoD3 preProposer=VSML7NenZnGZgCEwtbQDKDSrPHhT5wsu6 err=nil

	t=2020-06-28T17:04:27+0800 lvl=info msg="bft NewView" module=xchain viewNum=551 dpm.currentView=551 proposer=bg3KLC3YCmvLWBCNAVHGHLfk3qeWEdoD3 preProposer=VSML7NenZnGZgCEwtbQDKDSrPHhT5wsu6 err=nil

常见问题
-----------

- 端口冲突：注意如果在一台机器上部署多个节点，各个节点的RPC监听端口以及p2p监听端口都需要设置地不相同，避免冲突；
- 节点公私钥冲突：注意网络中不同节点./data/keys下的文件内容都应该不一样，这个文件夹是节点在网络中的唯一标识，每个节点需要独自生成，否则网络启动异常；
- 遇到The gas you cousume is: XXXX, You need add fee 通过加--fee XXXX 参数附加资源；

- Chained-Bft算法要求3个矿工的集群，不可以有矿工故障，所以如果使用更新候选人接口将节点neturl更新错误，将无法出块，需删除data/blockchain 目录下内容后，从10.1.4节开始重新部署环境。

