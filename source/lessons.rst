
XuperChain 小课堂
============

.. image:: images/b.png
    :width: 450px
    :align: center
    :class: banner

.. container:: number

    第一期

.. container:: myclass

    .. container:: title

        什么是区块链共识算法？

    .. container:: text

        一种通过确认交易上链顺序从而保证网络节点状态一致并且结合经济学中的博弈论让攻击者的攻击成本远远大于收益的算法。常见的区块链共识算法包括：POW,POS,DPOS,VBFT,SPOS等。

.. container:: myclass

    .. container:: title

        TDPOS是什么共识机制？

    .. container:: text

        TDPOS是百度在DPOS共识算法(Delegated Proof of Staking，委托权益证明)基础上自研改进的共识算法。区块链网络中的持币用户通过不定期选举出一小群节点，让这些节点进行区块创建、签名、验证和相互监督。TDPOS在DPOS基础上做了很多优化和细节改造并且TDPOS作为百度 XuperChain 的默认共识算法。

.. container:: number

    第二期

.. container:: myclass

    .. container:: title

        什么是权限控制系统？

    .. container:: text

        权限控制系统是为了约束资源查询/更新等能力而引入的一种系统要素。常见的权限控制系统包括：基于ACL的权限控制系统，基于RBAC的权限控制系统，基于ABAC的权限控制系统。

.. container:: myclass

    .. container:: title

         XuperChain 的权限控制系统是什么？

    .. container:: text

        百度 XuperChain 基于ACL权限控制模型实现了一套去中心化的权限控制系统，用于限制合约资源数据的访问/更新等能力，从而保障合约资源数据的安全。百度 XuperChain 自研的权限控制系统目前支持签名阈值策略、AK集签名策略等。

.. container:: number

    第三期

.. container:: myclass

    .. container:: title

        什么是公有链、联盟链以及私有链？

    .. container:: text

        公有链是指所有人都可以参与的区块链，所有人都可以查询、发送、接收、验证交易等特性；联盟链亦称为许可链，参与方限制为联盟成员，参与方通常是各个企业、机构，金融、物流以及司法等是联盟链的主要应用场景；私有链是指参与方受限为企业、机构或者个体，主要用于解决可审计问题。

.. container:: myclass

    .. container:: title

         XuperChain （XuperChain）是什么？

    .. container:: text

         XuperChain 是百度自研的区块链底层技术，具有链内并行技术、可插拔共识机制、一体化智能合约等领先技术，支持隐私保护和安全机制，具有可兼容性、扩展性强、高性能等特点。不仅适用于面向企业以及机构之间的联盟链应用场景，同时适用于公有链应用场景。目前XuperChain已经应用于司法、版权、边缘计算、数据协同、溯源、电子政务、智慧医疗等多个领域。

.. container:: number

    第四期

.. container:: myclass

    .. container:: title

        什么是区块链账户？

    .. container:: text

        区块链账户是指用于标识区块链网络中不同身份的一种机制。

.. container:: myclass

    .. container:: title

        百度 XuperChain 中的账户是什么？

    .. container:: text

        百度 XuperChain 使用了两种类型的账户，包括普通账户以及合约账户。(1)普通账户通常由账号(address)、公私钥对以及余额组成。账号可以操作转账。(2)合约账户相比普通账户而言，是一个更高级的账户类型，可以为多个账户角色进行权重分配，分配之后多个角色(包括普通账户或者合约账户)可以共同管理合约账户下面的数据资产(包括智能合约、访问权限列表、余额等)。相比传统中心化的权限管理模式而言，不是由某个账户对数据资产进行专权化管理；账户权限一但创建之后，即实现了不同权重账户的多中心化资产管理模式，不同账户角色也可以通过共同签名来更改权限。
        
.. container:: number

    第五期

.. container:: myclass

    .. container:: title
    
        普通账户与合约账户的应用场景各有哪些？
    
    .. container:: text
    
        普通账户的资产只归属一个人，而合约账户会分配多个账户共同管理合约账户下面的资产(包括智能合约、访问权限列表、余额等)。因此，在部署合约以及需要多方共同管理资产时，需要使用合约账户；其他应用场景下，普通账户与合约账户没有明显区别。

.. container:: myclass

    .. container:: title
    
        账户与账号的区别是什么？
    
    .. container:: text
    
        账号是账户的组成部分，作为账户的唯一标识符，有固定的生成规则。比如，在百度 XuperChain 中，dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN是一个有效的普通账户的账号；XC1111111111111111@xuper是一个有效的合约账户的账号。

.. container:: number

    第六期
    
.. container:: myclass

    .. container:: title
    
        P2P网络是什么？
        
    .. container:: text
    
        P2P网络也称为对等网络，它是一种网络技术和网络拓扑结构。目前P2P技术已经应用于流媒体、点对点通讯等领域，也就是我们常说的BT工具和电驴，比较常见的P2P网络协议有BitTorrent、ED2K等。
        
.. container:: myclass

    .. container:: title
    
        区块链P2P网络是什么？
        
    .. container:: text
    
        区块链P2P网络主要用于区块链节点之间数据传输和广播、节点发现和维护。因此，区块链P2P网络主要解决数据获取以及节点定位两个问题。节点发现和局域网穿透技术主要解决的是节点定位问题，节点交互协议主要解决的是数据获取问题。节点发现主流协议有Gossip以及KAD，局域网穿透协议主要有NAT。
        
.. container:: number

    第七期
    
.. container:: myclass

    .. container:: title
    
        混盘技术是什么？
        
    .. container:: text
    
        混盘技术也称为多盘技术，将多个磁盘从逻辑上当作一个磁盘来处理，主要用于解决只支持本地单盘场景下数据库空间不够的问题（即扩展性问题），比如被广泛使用的LevelDB。目前对LevelDB的多盘扩展技术，大部分是采用了多个LevelDB实例的方式，也就是每个盘一个单独的LevelDB实例。
        
.. container:: myclass

    .. container:: title
    
         XuperChain 自研的混盘技术
        
    .. container:: text
    
        多个LevelDB实例的方式好处是简单，不需要修改LevelDB底层代码，缺点是牺牲了多行原子写入的功能。在区块链的应用场景中，需要保证多个写入操作是原子性的特性。 XuperChain 改造LevelDB存储引擎本身，在引擎内部完成了数据文件的多盘放置，能够确保所有写入更新操作的原子性，从而能够满足区块链场景的交易原子性要求。
        
.. container:: number

    第八期
    
.. container:: myclass

    .. container:: title
    
        平行链是什么？
        
    .. container:: text
    
        平行链是相对于单链而言的，在只有一条链情况下，所有交易都由根链验证、执行、存储、打包到区块，在交易量高的情况下，存在吞吐低，延时高的问题。为了解决这类扩展性问题，从根链衍生出多条子链，各个子链打包自己链上的交易，账本、共识算法、网络等模块都可以相互独立。
        
.. container:: myclass

    .. container:: title
    
        百度 XuperChain 中的平行链是什么？
        
    .. container:: text

    	百度 XuperChain 通过系统合约方式创建平行链，平行链之间相互独立，拥有各自的账本和共识算法等模块，目前平行链之间共享p2p网络。不同的业务可以跑在不同的平行链上，起到了业务隔离效果，在使用平行链时，需要通过--name指定需要操作的平行链的名字。

.. container:: number

    第九期
    
.. container:: myclass

    .. container:: title
    
        用户可以通过哪些客户端接口访问百度 XuperChain ？

    .. container:: text
    
        1. xchain-cli，交互式命令行工具，直接使用xchain-cli即可发起操作，本质是通过rpc接口与服务端进行交互，可以从xuperchain库中获取；xchain-cli具有丰富的命令，包括创建账户、普通转账、合约部署以及调用、提案、投票、链上交易以及区块查询等功能；比如./xchain-cli transfer --to bob --amount 1就可以发起一笔向bob转账1个utxo的交易，更多命令可以通过./xchain-cli -h获取；
        2. SDK：提供一系列的API接口，用户可以基于提供的API接口做定制化的操作，相比xchain-cli更灵活；目前开源的SDK包括Go SDK，Python SDK，C# SDK；
        3. curl：直接通过curl命令来发起查询、构造交易等操作，客户端除了curl，不依赖任何三方库，此时需要服务端启动xchain-httpgw，然后通过curl http://localhost:8098/v1/get_balance -d '{"bcs":[{"bcname":"xuper"}, "address":"bob"], 即可查询xuper链上bob的余额信息

.. container:: number

    第十期
    
.. container:: myclass

    .. container:: title
    
        Gas在区块链中的作用是什么？

    .. container:: text
    
        Gas是一种资源消耗计量单位，比如执行智能合约时消耗的资源数量。用于奖励矿工并防止恶意攻击，是区块链生态系统可持续发展的重要因素。通常，Gas由各种可衡量资源按照特定比例累加而成。

.. container:: myclass

    .. container:: title
    
        百度 XuperChain 中，如何计算Gas？

    .. container:: text
    
        百度 XuperChain 中采用了如下可衡量资源：CPU，Mem，Disk，XFee。其中，CPU是指一个合约执行时消耗的CPU指令，Mem是指一个合约上下文消耗的内存大小，Disk是指一个合约上下文的磁盘大小，而XFee是一种特殊资源，主要针对系统合约消耗的资源，比如创建一个合约账号、设置合约方法的ACL需要消耗的资源。Gas计算公式为：Gas = CPU * cpu_rate + Mem * mem_rate + Disk * disk_rate + XFee * xfee_rate，其中cpu_rate，mem_rate，disk_rate，xfee_rate为资源与Gas的兑换比例。

.. container:: number

    第十一期
    
.. container:: myclass

    .. container:: title
    
        区块链的链上治理是指什么？

    .. container:: text
    
        区块链的链上治理是指在一个涉及很多利益方的区块链网络中，为了升级系统共识参数并保证区块链网络持续演进的链上解决方案（比特币和以太坊就因为系统共识参数升级分歧发生过多次硬分叉）。
        
.. container:: myclass

    .. container:: title
    
        百度 XuperChain 的链上治理是如何做的？

    .. container:: text
    
        百度 XuperChain 提出一种提案机制，首先，提案发起人会发起一笔修改系统共识参数的提案交易；然后，提案发起人将提案交易通过链外方式（比如邮件列表或者论坛、线下聚会等）告诉社区，对提案作进一步解释，并号召大家投票；之后，区块链网络中的用户可以对该提案交易进行投票；最后，如果投票数量超过提案交易中规定的最低票数，该提案交易就会生效。

.. container:: number

    第十二期
    
.. container:: myclass

    .. container:: title
    
        区块链中，虚拟机的作用是什么？

    .. container:: text
    
        虚拟机为智能合约提供了一个对底层透明的执行环境，主要工作包括指令解析、链上交互、Gas计算等。目前常见的虚拟机包括EVM，基于WASM的虚拟机等。

.. container:: myclass

    .. container:: title
    
         XuperChain 虚拟机是如何执行合约的？

    .. container:: text
    
        XVM(Xuper Virtual Machine， XuperChain 虚拟机)目前支持在预编译模式以及解释模式下执行智能合约。
        1. 预编译模式下：在合约部署时，XVM会将wasm指令编译成本地机器可以运行的指令(由wasm2c来做，主要工作包括将wasm转换成c、系统调用、Gas统计等功能)；在合约调用时，直接执行相应的指令即可。因此，预编译模式下，合约部署需要消耗时间，通常为数秒；而合约调用因为不需要再次做指令映射，执行效率高；
        2. 解释模式下：在合约调用时，XVM对wasm指令挨个解释执行(主要工作包括对wasm指令进行解释执行、Gas统计等功能)。因为在合约部署时不需要做指令映射，合约部署较快；在合约调用时，需要对wasm指令挨个做指令映射，执行效率低。

.. container:: number

    第十三期
    
.. container:: myclass

    .. container:: title
    
        区块链中常见的安全问题有哪些？

    .. container:: text
    
        区块链中常见的攻击包括DDoS攻击、女巫攻击、整数溢出、可重入攻击、拜占庭攻击等，主要体现在网络层、智能合约层、共识层、数据层等方面。

.. container:: myclass

    .. container:: title
    
         XuperChain 做了哪些安全工作？

    .. container:: text
    
         XuperChain 主要在密钥安全、网络安全、数据安全、共识安全以及智能合约安全等方面做了系列工作。
        1. 密钥安全方面，支持密钥加密存储、助记词恢复、密钥备份等能力；
        2. 网络安全方面，通过TLS进行数据加密传输，通过CA实现联盟准入机制，节点身份认证以及分层网络路由保护机制，来源IP数量限制等；
        3. 数据安全方面，除了基本密码学机制外，还实现账号与权限系统细粒度区分数据访问权限；
        4. 共识安全方面，实现了bft组件，能够抵抗拜占庭节点攻击；
        5. 智能合约方面，通过wasm实现指令级资源审计，屏蔽对底层存在较大风险的系统调用接口，保证应用层安全。

.. container:: number

    第十四期
    
.. container:: myclass

    .. container:: title
    
        关于UTXO的命令有哪些？

    .. container:: text
    
        1. 查询用户UTXO面额：./xchain-cli account balance；
        2. 查询用户UTXO详细信息：./xchain-cli account list-utxo；可以通过该命令查看哪些utxo当前可用，哪些utxo当前被锁定以及哪些utxo当前被冻结；
        3. 合并UTXO：./xchain-cli account merge；可以通过该命令将用户多个utxo合并，来解决因UTXO太零散导致交易过大问题；
        4. 拆分UTXO：./xchain-cli account split；可以通过该命令将用户的一个UTXO进行拆分，解决用户无法同时发起多笔交易的问题；

.. container:: number

    第十五期
    
.. container:: myclass

    .. container:: title
    
         XuperChain 开放网络是什么？

    .. container:: text
    
         XuperChain 开放网络是基于百度完全自主研发的开源技术搭建的区块链基础服务网络，由分布在全国的超级联盟节点组成，符合中国标准，为用户提供区块链应用快速部署和运行的环境，以及计算和存储等资源的弹性付费能力，直接降低用户部署和运维成本，让信任链接更加便利。
        
.. container:: myclass

    .. container:: title
    
         XuperChain 开放网络有哪些优势？

    .. container:: text
    
        1. 自主安全高可靠：基于百度完全自主研发且开源的区块链技术搭建，满足中国区块链标准要求；
        2. 灵活便捷低门槛： 无需建链即可运用区块链技术，丰富的合约模板和强大的功能组件，降低使用门槛；
        3. 弹性付费成本低：具备计算和存储等资源的弹性付费能力，可以实现按需按量灵活计费，一分钱即可用；
        4. 节点开放公信强：由分布全国的超级联盟节点构成，面向社会开放节点接入，具备极强的公信力；

.. container:: number

    第十六期

.. container:: myclass

    .. container:: title

         XuperChain 有哪些交易类型？

    .. container:: text 

         XuperChain 主要包括三种交易类型：
        1. 普通转账交易：基于用户utxo进行转账，此类交易包含utxo的引用关系，即TxInput和TxOutput，能够并行执行；
        2. 二代合约交易：主要用于修改系统共识参数，比如升级共识算法、提案等操作，此类交易执行顺序与区块高度绑定，只能串行执行；
        3. 三代合约交易：采用两阶段提交，首先通过预执行获取合约数据读写集，然后组装交易并转发给记账节点执行，此类交易执行顺序与区块高度无关，能够并行执行。

.. container:: myclass

    .. container:: title

        XuperChain如何统一UTXO和智能合约模型？

    .. container:: text

        UTXO模型主要用于存储用户的utxo数据，一般适用于普通转账交易；而智能合约存储模型主要用于存储用户合约相关数据。本质上，这两种存储模型都是存储用户数据并且包含数据版本依赖关系。因此， XuperChain 自研一套通用的存储模型XuperModel，基于key记录用户数据的依赖关系，实现UTXO和智能合约底层数据存储模型的统一。而比特币和以太坊底层存储模型不同，导致它们无法做到兼容。

.. container:: number

    第十七期

.. container:: myclass

    .. container:: title

         XuperChain 中，交易执行支持哪些模式？
        
    .. container:: text
    
         XuperChain 支持三种交易执行模式，分别为同步模式、纯异步模式以及异步阻塞模式。
        1. 同步模式：客户端发起一笔交易并等待交易执行结果；xchain节点更新交易状态时，加锁，锁内只能同时更新一个交易状态；
        2. 纯异步模式：客户端发起一笔交易并直接返回；xchain节点积攒批量交易，在更新交易状态时，加锁，锁内同时更新批量交易状态；
        3. 异步阻塞模式：客户端发起一笔交易并等待交易执行结果；xchain节点积攒批量交易，在更新交易状态时，加锁，锁内同时更新批量交易状态；

.. container:: myclass

    .. container:: title

        如何使用同步、纯异步以及异步阻塞模式？

    .. container:: text

        三种模式是互斥的，默认采用同步模式。在xchain节点启动时，通过flag来选择。通过nohup ./xchain --asyncBlockMode=true & 启动异步阻塞模式；通过nohup ./xchain --asyncMode=true & 启动纯异步模式。

.. container:: number

    第十八期

.. container:: myclass

    .. container:: title

        如何参与 XuperChain 的开发？
        
    .. container:: text
    
        1. 可以通过阅读 XuperChain 任意开源项目，包括源代码、文档，以便了解当前的开发方向；
        2. 找到自己感兴趣的功能或者模块；
        3. 实际开发时需要自测功能是否正常、性能是否符合预期，并运行make & make test检查是否通过所有单测；
        4. 发起一个Pull Request，如果你的代码合入到主干后，就有机会运行在线上机器上。

.. container:: myclass

    .. container:: title

        如何提一个PR？

    .. container:: text

        1. 从GitHub上fork XuperChain 的项目，并通过git拉取到本地；
        2. 在本地用git新起一个分支，贡献的代码全部放在本地分支上；
        3. 本地代码开发完毕，通过git push将本地分支代码提交至远程服务端；
        4. 点击GitHub对应项目栏下面的Pull Request按钮，填写需要合并的分支以及被合并的分支，然后点击create pull request即发起一个PR。

.. container:: number

    第十九期

.. container:: myclass

    .. container:: title

         XuperChain 支持消息推送机制吗？
        
    .. container:: text
    
        消息推送是指客户端主动向xchain节点订阅感兴趣的消息类型，当该类型的消息在链上被触发时，xchain节点会主动将该行为推送给客户端；
        目前， XuperChain 支持三种消息类型的推送，分别为区块消息、交易消息以及账户消息。
        1. 区块消息：用户可以订阅具有特定策略的区块，当链上触发这类区块时，会将消息主动推送给客户端；
        2. 交易消息：用户可以订阅具有特定策略的交易，当链上触发这类交易时，会将消息主动推送给客户端；
        3. 账户消息：当用户的余额发生变化时，会将消息推送给客户端。

.. container:: myclass

    .. container:: title

        如何使用 XuperChain 的消息推送机制？

    .. container:: text

        目前， XuperChain 的master分支支持消息推送机制。通过在xchain.yaml中增加pubsubService配置来启动事件推送服务。同时 XuperChain 提供了一个简单的客户端来订阅、接收自己感兴趣的消息。针对每种消息类型可用的策略可以参考event.proto文件。

.. container:: number

    第二十期

.. container:: myclass

    .. container:: title

         XuperChain 支持群组功能吗？
        
    .. container:: text
    
        群组是一种为了实现平行链之间隐私数据隔离，不同平行链只有指定节点才能参与区块打包、区块同步、区块/交易转发等能力的机制。

.. container:: myclass

    .. container:: title

        如何使用 XuperChain 的群组功能？

    .. container:: text

        目前， XuperChain 的master分支支持群组功能。在创世块配置文件中配置群组合约的相关参数，包括合约名、方法名等，并部署好群组合约( XuperChain 有群组合约的默认实现)即可调用群组合约为平行链增加节点白名单，从而让平行链具备群组能力。

