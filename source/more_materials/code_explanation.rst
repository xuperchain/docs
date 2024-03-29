
源码解读
========


xupercore
------------

XuperCore是XuperChain的内核框架, 自V5.0版本后, 核心团队对于XuperChain架构进行了升级，独立出超级链内核技术XuperCore。XuperChain为基于XuperCore内核发行的区块链底层解决方案。

XuperCore具有动态内核技术，能够实现无内核代码侵入的自由扩展内核核心组件和轻量级的扩展订制内核引擎，满足面向各类场景的区块链实现的需要，目前提供了全面的、高性能的内核组件实现。

目录结构
>>>>>>>>

XuperCore源码主要由lib、kernel、bcs、example四层组成，在代码结构中分别由四个同名文件夹表示，整体结构示意和目录结构如下。
在架构上，bcs各核心组件的编码同时也是kernel层对应各组件的接口实现。kernel层中的engines模块拼装了各组件，并定义了数据在本区块链引擎中的流转顺序。开发者也可根据自己对业务系统不同的处理方式，定义属于自己的引擎。

.. figure:: ../images/xupercore_structure.jpg
    :alt: XuperCore源码结构
    :align: center

    XuperCore源码结构示意图


+-----------+--------------------------------------------------------------------------+
| 目录名    | 功能                                                                     |
+===========+==========================================================================+
| bcs/      | blockchain core service，领域服务层，主要包含了可被装载的各具体领域组件。|
+-----------+--------------------------------------------------------------------------+
| example/  | 区块链发行版示例，使用各组件实现了一个区块链服务系统。                   |
+-----------+--------------------------------------------------------------------------+
| kernel/   | 内核层，共识、账本、智能合约、网络等主要模块的接口规范及可复用库定义。   |
+-----------+--------------------------------------------------------------------------+
| lib/      | 基础库组件，包括日志、数据库、上下文等封装。                             |
+-----------+--------------------------------------------------------------------------+
| protos/   | 各组件使用到的pb文件。                                                   |
+-----------+--------------------------------------------------------------------------+
| tools/    | 部署脚本示例。                                                           |
+-----------+--------------------------------------------------------------------------+

kernel（内核层）开发套件
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

kernel开发套件主要包括执行引擎示例xuperos以及共识、网络、账本、智能合约等核心组件的通用定义规范。
XuperCore的动态内核架构使得用户可通过根据需要灵活组合各核心组件，从而定制属于自己的引擎示例。

**核心设计要点**
    **a. 多引擎架构**

	engines模块支持多引擎架构，以示例xuperos为例，其通过组合现有内核核心组件，提供了一个具备两层共识及多合约虚拟机的区块链定义。多引擎架构让内核具备可多纬度、轻量级、无代码侵入订制扩展能力。

    **b. 区块链领域组件编程规范**

	consensus、ledger、contract、network、permission中定义了区块链各核心组件的对外接口，各核心组件的上层实现组件都必须按照接口规范进行编码，该规范设计让内核各核心组件可以无代码侵入自由替换扩展。

    **c. 可注册系统合约**

	XuperCore提供了系统合约虚拟机（XKernel）供系统内部使用，支持系统本身扭转的对应合约方法被称为系统合约（KernMethod），各模块可通过系统合约注入，使用Xmodel将自身数据存储在链上，避免链外数据带来的安全性和稳定性干扰。

**引擎可定制化**
    **a. 区块链引擎**
	区块链引擎是XuperCore的一个重要概念，其表示了驱动区块链系统运转的一系列定制逻辑，也可以被看作为对系统中的特定一条区块链结构的定义，这条特定的区块链由共识、网络、账本和智能合约等核心模块组成，且有清晰的调用逻辑关系。

    **b. xuperos**
	XuperCore的具体引擎放置在kernel下的engines，代码中给定了一款官方定制示例xuperos。具体如下表。

	+--------------+---------------------------------------------------------------------------------+
	| 模块名       | 功能                                                                            |
	+==============+=================================================================================+
	| common/      | 定义上下文。定义链接口规范，xuperos中的链提交流程特定为“预执行-执行”。          |
	+--------------+---------------------------------------------------------------------------------+
	| config/      | 定义本引擎配置，包括主链名称和区块广播模式等配置。                              |
	+--------------+---------------------------------------------------------------------------------+
	| reader/      | 链对外暴露的读能力集合。同时定义了共识、智能合约、账本和utxo的读接口。          |
	+--------------+---------------------------------------------------------------------------------+
	| chainmgmt.go | chainmgmt定义了一个管理者结构和行为，其支持多条链的同时管理。                   |
        +--------------+---------------------------------------------------------------------------------+
	| net/         | 本引擎绑定的区块链节点消息处理模块，负责处理定义的多种p2p网络消息。             |
	+--------------+---------------------------------------------------------------------------------+
	| miner/       | 本引擎定义的矿工结构，负责生产区块和同步区块，定义组织区块的逻辑。              |
	+--------------+---------------------------------------------------------------------------------+
	| chain.go     | 定义本引擎中一条通用链的具体数据结构和行为。                                    |
	+--------------+---------------------------------------------------------------------------------+
	| engine.go    | 定义xuperos执行引擎，可看作区块链节点的启动和销毁入口。                         |
        +--------------+---------------------------------------------------------------------------------+
	| event/       | 本引擎定义的一种事件通知系统，目前支持区块粒度的相关交易通知订阅功能。          |
	+--------------+---------------------------------------------------------------------------------+
	| asyncworker/ | 本引擎定义的交易异步事件机制，使用事件通知，使得注册的相关交易会在被上链时执行。|
	+--------------+---------------------------------------------------------------------------------+
	| parachain/   | 本引擎定义的一种平行链机制，支持链的动态加载和卸载。                            |
	+--------------+---------------------------------------------------------------------------------+


bcs（blockchain core service）层
>>>>>
**核心组件**
    **a. consensus共识**
	**组件规范**
		bcs层定义的共识组件均遵循kernel层的热插拔共识（pluggable_consensus）流程，统一由kernel层热插拔共识进行组装、吊起和销毁，并严格实现了热插拔共识对外定义的接口。

	**开发须知**
		目前本层共识实现使用了特定标准进行开发，将共识分为status（共识实时状态）、schedule（候选人节点选举逻辑）、kernel_contract（系统合约）。

		status实现了热插拔共识的ConsensusStatus接口，实时状态目前被存储在内存中，向外提供当前矿工等共识相关信息的读取能力。

		schedule定义了共识模块内部选举候选人（即矿工）的逻辑。

		kernel_contract是共识模块自定义的一些系统合约，用于将共识相关信息在链上存储，避免了链外数据的使用，用户可以根据需求定制自己的相关系统合约。

    **b. xledger账本**
	**账本**
		首先需注意的是，区块链执行引擎和账本组件是强绑定关系，不同区块链执行引擎可以选择绑定不同的账本组件，但通常只有唯一映射的关系。考虑到框架整体的可扩展性，kernel层ledger中只对数据结构做了基本要求，仅抽象定义合约和共识依赖接口规范，不做账本其他结构和接口约束，由具体账本实现自由定义，因此，在bcs层自定义账本需考虑到账本在区块链系统中的所有细节。本框架提供了xledger实现，虑到交易池、状态机、账本之间的强相关关系，xledger把交易池、状态机、账本统一归到账本组件提供。

	**状态机**
		状态机（state）一方面可以看作账本的状态映射，一方面也存储着待打包的未确认交易。xledger中的状态机主要定义了以下结构。

		+---------------------------+-----------------------------------------------------------+
		| 模块名                    | 功能                                                      |
		+===========================+===========================================================+
		| meta/                     | 元信息表，存储当前最新区块状态。                          |
		+---------------------------+-----------------------------------------------------------+
		| utxo/                     | 定义原生代币utxo及utxo表。                                |
		+---------------------------+-----------------------------------------------------------+
		| xmodel/                   | 定义xmodel模型、xmodel数据表和历史版本表。                |
		+---------------------------+-----------------------------------------------------------+
		| block.go                  | 定义区块数据结构和行为。                                  |
		+---------------------------+-----------------------------------------------------------+
		| block_height_notifier.go  | 支持event事件订阅功能，当最新区块更新时通知监听者。       |
		+---------------------------+-----------------------------------------------------------+
		| reserved_contract.go      | 支持背书检查。                                            |
		+---------------------------+-----------------------------------------------------------+
		| state.go                  | 状态机对外暴露功能，包括验证交易VerifyTx、执行交易DoTx等。|
		+---------------------------+-----------------------------------------------------------+
		| tx_verification.go        | 状态机具体验证交易方法集合。                              |
		+---------------------------+-----------------------------------------------------------+


	**未确认交易**
		xledger的未确认交易表被定义在tx文件夹下。


    **c. network网络**
	**组件规范**
		bcs层定义的网络组件p2pv1和p2pv2均遵循kernel层的Network接口规范，提供了以下接口的实现。

		+-----------------------------------------------------------+-------------------------------------------------------+
		| 接口                                                      | 功能                                                  |
		+===========================================================+=======================================================+
		| SendMessage(xctx.XContext, *pb.XuperMessage,              | 发送消息，异步模式。                                  |
		| ...p2p.OptionFunc) error                                  |                                                       |
		+-----------------------------------------------------------+-------------------------------------------------------+
		| SendMessageWithResponse(xctx.XContext, *pb.XuperMessage,  | 发送消息，同步模式，节点会收集对等节点的响应。        |
		| ...p2p.OptionFunc) ([]*pb.XuperMessage, error)            |                                                       |
		+-----------------------------------------------------------+-------------------------------------------------------+
		| NewSubscriber(pb.XuperMessage_MessageType,                | 订阅者实现，用于区分不同消息类型和处理方法。          |
		| ...p2p.OptionFunc) ([]*pb.XuperMessage, error)            |                                                       |
		+-----------------------------------------------------------+-------------------------------------------------------+
		| Context() *nctx.NetCtx                                    | 网络组件必须使用kernel层定义的网络上下文。            |
		+-----------------------------------------------------------+-------------------------------------------------------+
		| PeerInfo() pb.PeerInfo                                    | 对等节点的邻居节点，节点信息必须符合kernel层定义的    |
		|                                                           | pb结构，节点账户Account使用string类型标识，为acl账户。|
		+-----------------------------------------------------------+-------------------------------------------------------+


**组件开发须知**
    **开发者在自定义组件时，需要严格遵守kernel层对各模块的接口规范**


交易结构解释
------------

在xuperchain中，有多种交易。在xuperchain中，有多种交易类型，本文以 **转账** 和 **合约调用** 交易为示例，对交易结构作出说明。

转账交易
>>>>>>>
**transfer**

.. note::

	以下是由 **cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2** 转账 **900** 给 **ikzHZrCidH49oJ9xWvbVX4ZkRSmzHK6fs** 的交易

.. code-block:: go

      {
        // 交易id hash
        "txid": "fbd7a7fb4228dbda5ffd6bbab49ca11801da411ee664b5f6b8e876bf820d38b5",
        // 交易所在区块的id hash
        "blockid": "cd96466204e0f82d866f8cd31612cbb0683bcf76749eb976aab04fdc2cf51a41",
        // 交易输入集合
        "txInputs": [
          {
            // 选中引用的utxo
            "refTxid": "29417e4f3da9723fa2efbd73fc79b8f04ccf78359f40e88b9a89e84ca01f0ae5",
            "refOffset": 0,
            // from 地址
            "fromAddr": "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2",
            // 此次选中的utxo金额
            "amount": "1000"
          }
        ],
        // 交易输出集合
        "txOutputs": [
          {
            // 此次转账金额
            "amount": "900",
            // to 地址，转给谁
            "toAddr": "ikzHZrCidH49oJ9xWvbVX4ZkRSmzHK6fs"
          },
          {
            // 转账金额，utxo 选中1000，此次需要900，剩下的100要转回给自己。
            "amount": "100",
            "toAddr": "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2"
          }
        ],
        // 交易说明
        "desc": "transfer from console",
        // 用于避免重放攻击的随机数
        "nonce": "16632239546569658860225826",
        // 启动交易的时间戳
        "timestamp": 1663223954004887000,
        // tx 交易版本号
        "version": 3,
        // 是否是自动生成的交易
        "autogen": false,
        // 挖矿奖励
        "coinbase": false,
        // 交易扩展输入
        "txInputsExt": null,
        // 交易扩展输入
        "txOutputsExt": null,
        // 合约请求
        "contractRequests": null,
        // 交易发起者，可以是address 或 account
        "initiator": "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2",
        // 交易发起需要被收集签名的Address集合信息，包括用于utxo转账和用于合约调用
        "authRequire": [
          "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2"
        ],
        // 交易发起者对交易元数据签名，签名的内容包括auth_require字段
        "initiatorSigns": [
          {
            "publickey": "{\"Curvname\":\"P-256\",\"X\":23382601204102541715374124844953012608593295267747539900959924016134547431406,\"Y\":24224141399742517661144006914182151613904450740565807059057602081995839331020}",
            "sign": "30440220594b4b7a51978bb50ab247c518b34261a7bd0b9779c4353b6ae24c4442b3b846022024fe55fba3b600e8700ade72624df4eb6017b276245bc686bdc0d436d410ac54"
          }
        ],
        // 收集到的签名
        "authRequireSigns": [
          {
            "publickey": "{\"Curvname\":\"P-256\",\"X\":23382601204102541715374124844953012608593295267747539900959924016134547431406,\"Y\":24224141399742517661144006914182151613904450740565807059057602081995839331020}",
            "sign": "3046022100e517627c5bdad30cfff10306ec8123e70691f3cffa527ed81e22e28382d380560221009a81af47f08c4792ecf371604de16ede0c3bbdfd42754652a5fc0d0fd5f9128b"
          }
        ],
        // 节点收到tx的时间戳，不参与签名
        "receivedTimestamp": 1663223954008931000,
        // 可修改区块链标记
        "modifyBlock": {
          // 本交易是否已被修改标记
          "marked": false,
          // txid交易被修改生效的高度
          "effectiveHeight": 0,
          // txid交易被effective_txid的交易提出可修改区块链的请求
          "effectiveTxid": ""
        }
      }


合约部署交易
>>>>>>>>>>

**DeployWasmContract**

.. note::

	以下是由 cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2 使用合约账号 XC1234567812345678@xuper 部署wasm合约 StudentScore 生成的。

.. code-block:: go

    {
      // 交易id hash
      "txid": "741243b5f740f0da214d078839e7e4b5b194be96b4b17760044884baec924d64",
      // 交易所在区块id hash
      "blockid": "9d5cecdd0f446a2bd4a953ab81d22773a5122028f8c2b98923efef3ead7e8e68",
      // 交易输入集合
      "txInputs": [
        {
          // 引用的utxo id
          "refTxid": "b9f7b691488a0005e477e30e542882cb9bb9af8681b129fc18a926c7983003a0",
          // 该笔交易返回的索引
          "refOffset": 0,
          // from 地址，部署合约消耗的是合约账户的资源。
          "fromAddr": "XC1234567812345678@xuper",
          // 选中的utxo 金额
          "amount": "100000000"
        }
      ],
      // 交易输出集合
      "txOutputs": [
        {
          // 剩下的金额转回给自己
          "amount": "99843195",
          // to 合约账户
          "toAddr": "XC1234567812345678@xuper"
        },
        {
          // gas
          "amount": "156805",
          // 转给系统
          "toAddr": "$"
        }
      ],
      // 交易说明
      "desc": "",
      // 防止重放攻击的随机数
      "nonce": "166322609243925090",
      // 交易启动的时间
      "timestamp": 1663226092868230000,
      // 交易版本
      "version": 3,
      // 是否自动生成的交易
      "autogen": false,
      // 出块奖励
      "coinbase": false,
      // 交易扩展输入
      "txInputsExt": [
        {
          // 读取的资源模块
          "bucket": "StudentScore",
          // 读取的资源字段
          "key": "Owner",
          // 引用的id， 为空说明当时该值不存在
          "refTxid": "",
          // 引用的交易返回的索引
          "refOffset": 0
        },
        {
          // 读取的资源模块
          "bucket": "XCAccount",
          // 读取的资源
          "key": "XC1234567812345678@xuper",
          // 引用的交易id 合约账号创建的交易
          "refTxid": "009bddeaf8ce5611d54e37d2f7aa860ee616565a0e2602173f93055beb9913b6",
          // 医用的交易返回的索引
          "refOffset": 1
        },
        {
          // 读取的资源模块
          "bucket": "XCAccount2Contract",
          // 读取的资源
          "key": "XC1234567812345678@xuper\u0001StudentScore",
          // 引用的交易id 为空说明当时该值不存在
          "refTxid": "",
          // 引用的交易返回的索引
          "refOffset": 0
        },
        {
          // 读取的资源模块
          "bucket": "XCContract2Account",
          // 读取的资源
          "key": "StudentScore",
          // 引用的交易id 为空说明当时该值不存在
          "refTxid": "",
          // 引用的交易返回的索引
          "refOffset": 0
        },
        {
          // 读取的资源模块
          "bucket": "contract",
          // 读取的资源
          "key": "StudentScore.code",
          // 引用的交易id 为空说明当时该值不存在
          "refTxid": "",
          // 引用的交易返回的索引
          "refOffset": 0
        },
        {
          // 读取的资源模块
          "bucket": "contract",
          // 读取的资源
          "key": "StudentScore.desc",
          // 引用的交易id 为空说明当时该值不存在
          "refTxid": "",
          // 引用的交易返回的索引
          "refOffset": 0
        }
      ],
      // 交易扩展输出
      "txOutputsExt": [
        {
          // 此次改动的资源模块
          "bucket": "StudentScore",
          // 改动的资源
          "key": "Owner",
          // 值
          "value": "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2"
        },
        {
          // 此次改动的资源模块
          "bucket": "XCAccount2Contract",
          // 改动的资源
          "key": "XC1234567812345678@xuper\u0001StudentScore",
          // 值
          "value": "true"
        },
        {
          // 此次改动的资源模块
          "bucket": "XCContract2Account",
          // 改动的资源
          "key": "StudentScore",
          // 值
          "value": "XC1234567812345678@xuper"
        },
        {
          // 此次改动的资源模块
          "bucket": "contract",
          // 改动的资源
          "key": "StudentScore.code",
          // 合约源代码编译后的文件，太长省略
          "value": "......",
          // 合约说明
          "contract_desc": "\n\u0001c*\u0004wasm",
          // 合约名称
          "contract_name": "StudentScore",
          // 合约初始化参数
          "init_args": "{\"owner\":\"Y0F6MlEzNTZDa3V4VU5ick5YNHlZaW1uVFp1WHFDNVMy\"}"
          },
        	// 资源限制
          "resource_limits": [
            {
              "type": "CPU",
              "limit": 54552
            },
            {
              "type": "MEMORY",
              "limit": 1048576
            },
            {
              "type": "DISK",
              "limit": 156748
            },
            {
              "type": "XFEE",
              "limit": 0
            }
          ]
        }
      ],
    	// 交易发起者
      "initiator": "XC1234567812345678@xuper",
    	// 需要收集的签名
      "authRequire": [
        "XC1234567812345678@xuper/cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2"
      ],
    	// 交易发起者签名
      "initiatorSigns": [
        {
          "publickey": "{\"Curvname\":\"P-256\",\"X\":23382601204102541715374124844953012608593295267747539900959924016134547431406,\"Y\":24224141399742517661144006914182151613904450740565807059057602081995839331020}",
          "sign": "3045022100e824b1c9fdaa6b5911774fafb89e2f4aaa0720bac2e99d05a0d8a0d26ad4d5d602201c8b3780fc5e23afd9b6fe0a9062b004ac2a8ca1e476a41efa549d6402e3969d"
        }
      ],
    	// 收集到的所有签名
      "authRequireSigns": [
        {
          "publickey": "{\"Curvname\":\"P-256\",\"X\":23382601204102541715374124844953012608593295267747539900959924016134547431406,\"Y\":24224141399742517661144006914182151613904450740565807059057602081995839331020}",
          "sign": "3045022100e824b1c9fdaa6b5911774fafb89e2f4aaa0720bac2e99d05a0d8a0d26ad4d5d602201c8b3780fc5e23afd9b6fe0a9062b004ac2a8ca1e476a41efa549d6402e3969d"
        }
      ],
    	// 节点收到交易的时间
      "receivedTimestamp": 1663226092902982000,
    	// 可修改区块链标记
      "modifyBlock": {
        // 本交易是否已被修改标记
        "marked": false,
        // txid交易被修改生效的高度
        "effectiveHeight": 0,
        // txid交易被effective_txid的交易提出可修改区块链的请求
        "effectiveTxid": ""
      }
    }


合约调用交易
>>>>>>>>>>

**addScore**

.. note::

	以下是由 cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2 第一次调用wasm合约（StudentScore）的 addScore() 方法生成的交易


.. code-block:: go

    {
      // 交易id hash
      "txid": "14a74b33135404e3a0218e8738dfc5588696f1d309286444f90c0aaa6de09b81",
      // 交易所在区块id hash
      "blockid": "9fe8bcab839e667cd3de1ab6c9427b0f605b32abe09da3aa2bba777f61e75483",
      // 交易输入集合
      "txInputs": [
        {
          // 选中引用的utxo
          "refTxid": "009bddeaf8ce5611d54e37d2f7aa860ee616565a0e2602173f93055beb9913b6",
          "refOffset": 0,
          // from 地址
          "fromAddr": "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2",
          // 选中的utxo 金额
          "amount": "99999000"
        }
      ],
      // 交易输出集合
      "txOutputs": [
        {
          // 金额 减去 gas 费用之后剩下的转给自己。
          "amount": "99998869",
          // to 地址
          "toAddr": "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2"
        },
        {
          // gas 费用
          "amount": "131",
          // to 地址，系统
          "toAddr": "$"
        }
      ],
      "desc": "",
      // 防止重放攻击的随机数
      "nonce": "1663226443 7410470",
      // 交易启动的时间戳
      "timestamp": 1663226443217546000,
      // 交易版本
      "version": 3,
      // 是否为自动生成的交易
      "autogen": false,
      // 挖矿奖励
      "coinbase": false,
      // 交易扩展输入集合
      "txInputsExt": [
        {
          // 此次读取的资源模块
          "bucket": "StudentScore",
          // addScore 方法中读取到的值。
          "key": "Owner",
          // 引用的交易id
          "refTxid": "741243b5f740f0da214d078839e7e4b5b194be96b4b17760044884baec924d64",
          // 该交易输出的引用索引
          "refOffset": 0
        },
        {
          // 此次读取的资源模块
          "bucket": "StudentScore",
          // addScore 方法中读取到的值。
          "key": "R_alice",
          // 引用的交易id 为空说明该值当前不存在
          "refTxid": "",
          // 该交易输出的引用索引
          "refOffset": 0
        },
        {
          // 此次读取的资源模块
          "bucket": "contract",
          // 读取合约模块中 StudentScore 合约说明
          "key": "StudentScore.desc",
          // 引用的交易id
          "refTxid": "741243b5f740f0da214d078839e7e4b5b194be96b4b17760044884baec924d64",
          // 该交易输出的引用索引
          "refOffset": 4
        }
      ],
      // 交易扩展输出集合
      "txOutputsExt": [
        {
          // 此次作出修改的资源
          "bucket": "StudentScore",
          // 此次作出修改的资源
          "key": "R_alice",
          // 修改的值
          "value": "{\"科目A\"：\"100分\"，\"科目B\"：\"95分\"}"
        }
      ],
      // 合约调用请求体
      "contractRequests": [
        {
          // 合约类型名称
          "moduleName": "wasm",
          // 合约名称
          "contractName": "StudentScore",
          // 合约方法
          "methodName": "addScore",
          // 参数
          "args": {
            "data": "{\"科目A\"：\"100分\"，\"科目B\"：\"95分\"}",
            "userid": "alice"
          },
          // 资源限制
          "resource_limits": [
            {
              "type": "CPU",
              "limit": 77539
            },
            {
              "type": "MEMORY",
              "limit": 1048576
            },
            {
              "type": "DISK",
              "limit": 51
            },
            {
              "type": "XFEE",
              "limit": 0
            }
          ]
        }
      ],
      // 交易发起者
      "initiator": "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2",
      // 交易发起需要被收集签名的Address集合信息，包括用于utxo转账和用于合约调用
      "authRequire": [
        "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2"
      ],
      // 交易发起者对交易元数据签名，签名的内容包括auth_require字段
      "initiatorSigns": [
        {
          "publickey": "{\"Curvname\":\"P-256\",\"X\":23382601204102541715374124844953012608593295267747539900959924016134547431406,\"Y\":24224141399742517661144006914182151613904450740565807059057602081995839331020}",
          "sign": "304602210095aca485112f5ea921e17a48d5cee7fc70495d7067724f7217be84e6ed9e9e3e02210096c8aac07cadd9696137f1be16af23886446226e47baf7988f07df69eab5d192"
        }
      ],
       // 收集到的签名
      "authRequireSigns": [
        {
          "publickey": "{\"Curvname\":\"P-256\",\"X\":23382601204102541715374124844953012608593295267747539900959924016134547431406,\"Y\":24224141399742517661144006914182151613904450740565807059057602081995839331020}",
          "sign": "304602210095aca485112f5ea921e17a48d5cee7fc70495d7067724f7217be84e6ed9e9e3e02210096c8aac07cadd9696137f1be16af23886446226e47baf7988f07df69eab5d192"
        }
      ],
      // 节点收到交易的时间戳，不参与签名
      "receivedTimestamp": 1663226443228000000,
      // 可修改区块链标记
      "modifyBlock": {
        // 本交易是否已被修改标记
        "marked": false,
        // txid交易被修改生效的高度
        "effectiveHeight": 0,
        // txid交易被effective_txid的交易提出可修改区块链的请求
        "effectiveTxid": ""
      }
    }


.. note::

	以下是由 cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2 第2次调用wasm合约（StudentScore）的 addScore() 方法生成的交易，用于体现交易扩展输入中 *refTxid* 字段


.. code-block:: go

    {
      // 交易id hash
      "txid": "277d04e4a4024bdb656a6d94f8b8d2f305444f674b977068dc8d57d1e756887c",
      // 交易所在区块id hash
      "blockid": "344c8c6024116b153e1e4ae63d2ab976f433f73f2b7a50b4c56f908f95597d54",
      // 交易输入集合
      "txInputs": [
        {
          // 引用的utxo 交易id
          "refTxid": "14a74b33135404e3a0218e8738dfc5588696f1d309286444f90c0aaa6de09b81",
          // 交易输出的引用索引
          "refOffset": 0,
          // from 账户
          "fromAddr": "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2",
          // 选择的utxo 金额
          "amount": "99998869"
        }
      ],
      // 交易输出集合
      "txOutputs": [
        {
          // 扣除gas 之后剩下的转回给自己
          "amount": "99998742",
          // to addr 自己
          "toAddr": "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2"
        },
        {
          // gas
          "amount": "127",
          // 转给系统
          "toAddr": "$"
        }
      ],
      // 交易说明
      "desc": "",
      // 防止重放攻击的随机数
      "nonce": "166323643435443823",
      // 交易启动的时间
      "timestamp": 1663236434507981000,
      // 交易版本
      "version": 3,
      // 是否自动生成的交易
      "autogen": false,
      // 出块奖励
      "coinbase": false,
      // 交易扩展输入集合
      "txInputsExt": [
        {
          // 读取的资源模块
          "bucket": "StudentScore",
          // 读取的资源
          "key": "Owner",
          // 引用的交易id 对应合约部署初次创建的交易id
          "refTxid": "741243b5f740f0da214d078839e7e4b5b194be96b4b17760044884baec924d64",
          // 该交易输出的引用索引
          "refOffset": 0
        },
        {
          // 读取的资源模块
          "bucket": "StudentScore",
          // 读取的资源
          "key": "R_alice",
          // 引用的交易id 对应上次调用该方法的交易id
          "refTxid": "14a74b33135404e3a0218e8738dfc5588696f1d309286444f90c0aaa6de09b81",
          // 改交易输出的引用索引
          "refOffset": 0
        },
        {
          // 读取的资源模块
          "bucket": "contract",
          // 读取的资源
          "key": "StudentScore.desc",
          // 引用的交易id 对应合约部署的交易id
          "refTxid": "741243b5f740f0da214d078839e7e4b5b194be96b4b17760044884baec924d64",
          // 该交易输出的引用索引
          "refOffset": 4
        }
      ],
      // 交易扩展输出集合
      "txOutputsExt": [
        {
          // 修改的资源模块
          "bucket": "StudentScore",
          // 修改的资源
          "key": "R_alice",
          // 值
          "value": "{\"科目C\": \"70分\", \"科目D\": \"50分\"}"
        }
      ],
      // 合约请求结构
      "contractRequests": [
        {
          // 合约类型名称
          "moduleName": "wasm",
          // 合约名称
          "contractName": "StudentScore",
          // 合约方法
          "methodName": "addScore",
          // 参数
          "args": {
            "data": "{\"科目C\": \"70分\", \"科目D\": \"50分\"}",
            "userid": "alice"
          },
          // 资源限制
          "resource_limits": [
            {
              "type": "CPU",
              "limit": 77093
            },
            {
              "type": "MEMORY",
              "limit": 1048576
            },
            {
              "type": "DISK",
              "limit": 47
            },
            {
              "type": "XFEE",
              "limit": 0
            }
          ]
        }
      ],
      // 交易发起者
      "initiator": "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2",
      // 需要收集的签名
      "authRequire": [
        "cAz2Q356CkuxUNbrNX4yYimnTZuXqC5S2"
      ],
      // 交易发起者对交易元数据进行签名
      "initiatorSigns": [
        {
          "publickey": "{\"Curvname\":\"P-256\",\"X\":23382601204102541715374124844953012608593295267747539900959924016134547431406,\"Y\":24224141399742517661144006914182151613904450740565807059057602081995839331020}",
          "sign": "3046022100d8c078885505cd0edbd39ad8a43f5ac73c1d94c52f16f4866687516a125965b20221008fc9699fc46a15615ce67eb8bb754ba3d8c0f5197aa5afbbc258021d9dbf2f94"
        }
      ],
      // 收集到的签名
      "authRequireSigns": [
        {
          "publickey": "{\"Curvname\":\"P-256\",\"X\":23382601204102541715374124844953012608593295267747539900959924016134547431406,\"Y\":24224141399742517661144006914182151613904450740565807059057602081995839331020}",
          "sign": "3046022100d8c078885505cd0edbd39ad8a43f5ac73c1d94c52f16f4866687516a125965b20221008fc9699fc46a15615ce67eb8bb754ba3d8c0f5197aa5afbbc258021d9dbf2f94"
        }
      ],
      // 节点接收到交易的时间
      "receivedTimestamp": 1663236434523268000,
      // 可修改区块链标记
      "modifyBlock": {
        // 本交易是否已被修改标记
        "marked": false,
        // txid交易被修改生效的高度
        "effectiveHeight": 0,
        // txid交易被effective_txid的交易提出可修改区块链的请求
        "effectiveTxid": ""
      }
    }
