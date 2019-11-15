
超级链小课堂
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

        TDPOS是百度在DPOS共识算法(Delegated Proof of Staking，委托权益证明)基础上自研改进的共识算法。区块链网络中的持币用户通过不定期选举出一小群节点，让这些节点进行区块创建、签名、验证和相互监督。TDPOS在DPOS基础上做了很多优化和细节改造并且TDPOS作为百度超级链的默认共识算法。

.. container:: number

    第二期

.. container:: myclass

    .. container:: title

        什么是权限控制系统？

    .. container:: text

        权限控制系统是为了约束资源查询/更新等能力而引入的一种系统要素。常见的权限控制系统包括：基于ACL的权限控制系统，基于RBAC的权限控制系统，基于ABAC的权限控制系统。

.. container:: myclass

    .. container:: title

        超级链的权限控制系统是什么？

    .. container:: text

        百度超级链基于ACL权限控制模型实现了一套去中心化的权限控制系统，用于限制合约资源数据的访问/更新等能力，从而保障合约资源数据的安全。百度超级链自研的权限控制系统目前支持签名阈值策略、AK集签名策略等。

.. container:: number

    第三期

.. container:: myclass

    .. container:: title

        什么是公有链、联盟链以及私有链？

    .. container:: text

        公有链是指所有人都可以参与的区块链，所有人都可以查询、发送、接收、验证交易等特性；联盟链亦称为许可链，参与方限制为联盟成员，参与方通常是各个企业、机构，金融、物流以及司法等是联盟链的主要应用场景；私有链是指参与方受限为企业、机构或者个体，主要用于解决可审计问题。

.. container:: myclass

    .. container:: title

        超级链（XuperChain）是什么？

    .. container:: text

        超级链是百度自研的区块链底层技术，具有链内并行技术、可插拔共识机制、一体化智能合约等领先技术，支持隐私保护和安全机制，具有可兼容性、扩展性强、高性能等特点。不仅适用于面向企业以及机构之间的联盟链应用场景，同时适用于公有链应用场景。目前XuperChain已经应用于司法、版权、边缘计算、数据协同、溯源、电子政务、智慧医疗等多个领域。

.. container:: number

    第四期

.. container:: myclass

    .. container:: title

        什么是区块链账户？

    .. container:: text

        区块链账户是指用于标识区块链网络中不同身份的一种机制。

.. container:: myclass

    .. container:: title

        百度超级链中的账户是什么？

    .. container:: text

        百度超级链使用了两种类型的账户，包括普通账户以及合约账户。(1)普通账户通常由账号(address)、公私钥对以及余额组成。账号可以操作转账。(2)合约账户相比普通账户而言，是一个更高级的账户类型，可以为多个账户角色进行权重分配，分配之后多个角色(包括普通账户或者合约账户)可以共同管理合约账户下面的数据资产(包括智能合约、访问权限列表、余额等)。相比传统中心化的权限管理模式而言，不是由某个账户对数据资产进行专权化管理；账户权限一但创建之后，即实现了不同权重账户的多中心化资产管理模式，不同账户角色也可以通过共同签名来更改权限。
        
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
    
        账号是账户的组成部分，作为账户的唯一标识符，有固定的生成规则。比如，在百度超级链中，dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN是一个有效的普通账户的账号；XC1111111111111111@xuper是一个有效的合约账户的账号。

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
    
        超级链自研的混盘技术
        
    .. container:: text
    
        多个LevelDB实例的方式好处是简单，不需要修改LevelDB底层代码，缺点是牺牲了多行原子写入的功能。在区块链的应用场景中，需要保证多个写入操作是原子性的特性。超级链改造LevelDB存储引擎本身，在引擎内部完成了数据文件的多盘放置，能够确保所有写入更新操作的原子性，从而能够满足区块链场景的交易原子性要求。
