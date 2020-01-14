
操作指导
========

如何获取XuperChain
------------------

目前XuperChain已经发布了2个版本，最新版本为v3.2，可以在github获取发布包

- `XuperChain v3.2 <https://github.com/xuperchain/xuperchain/releases/tag/v3.2.0>`_
- `XuperChain v3.1 <https://github.com/xuperchain/xuperchain/releases/tag/v3.1.0>`_

如何升级软件
------------

当版本升级时，需要更新为新版本的代码，并重新编译，然后将 plugins文件夹, 二进制文件xchain，xchain-cli 全部替换后全部重新启动即可，注意多节点模式下需要先启动bootNodes节点。

配置文件说明
------------

XuperChain的配置文件默认读取有3个优先级：

- 默认配置：系统中所有配置项都有默认的配置信息，这个是优先级最低的配置；
- 配置文件：通过读取配置文件的方式，可以覆盖系统中默认的参数配置，默认的配置文件为 ./conf/xchain.yaml；
- 启动参数：有一些参数支持启动参数的方式设置，该设置方式的优先级最高，会覆盖配置文件中的配置项；

.. code-block:: yaml
    :linenos:

    log:
    filepath: logs // 日志输出目录
    filename: xchain // 日志文件名
    console: true //是否答应console日志
    level : trace // 日志等级，debug < trace < info < warn < error < crit
    tcpServer:
    port: :57404 // 节点RPC服务监听端口
    p2pv2:
    port: 47404 // 节点p2p网络监听的端口
    bootNodes: /ip4/127.0.0.1/tcp/47401/p2p/QmXRyKS1BFmneUEuwxmEmHyeCSb7r7gSNZ28gmDXbTYEXK  // 节点加入网络链接的种子节点的netUrl
    miner:
    keypath: ./data/keys //节点address目录
    datapath: ./data/blockchain //账本存储目录
    utxo:
    cachesize: 5000 //Utxo内存cache大小设置
    tmplockSeconds: 60 //GenerateTx的临时锁定期限，默认是60秒

core目录各文件说明
------------------

===========  ==========================
模块         功能及子文件说明
===========  ==========================
acl          acl查询 account_acl.go 查询合约账号ACL的接口定义 acl_manager.go 查询合约账号ACL,合约方法ACL的具体实现 contract_acl.go 查询合约方法ACL的接口定义
cmd          XuperChain命令行功能集合，比如多重签名、交易查询、区块查询、合约部署、合约调用、余额查询等
common       公共组件 batch_chan.go 将交易批量写入到channel中 common.go 获取序列化后的交易/区块的大小 lru_cache.go lru cache实现 util.go 去重string切片中的元素
config       系统配置文件 config.go 包括日志配置、Tcp配置、P2p配置、矿工配置、Utxo配置、Fee配置、合约配置、控制台配置、节点配置、raft配置等
consensus    共识模块 base 共识算法接口定义 consensus.go 可插拔共识实现 tdpos dpos共识算法的具体实现 single single共识算法的具体实现
contract     智能合约 contract.go 智能合约接口定义 contract_mgr.go 创建智能合约实例 kernel 系统级串行智能合约 proposal 提案 wasm wasm虚拟机
core         xchaincore.go 区块链的业务逻辑实现 xchainmg.go 负责管理多条区块链 xchainmg_validate.go 对区块、交易、智能合约的合法性验证业务逻辑 sync.go 节点主动向其它节点同步区块业务逻辑 xchaincore_net.go 通过广播形式向周围节点要区块 xchainmg_net.go 注册接收的消息类型 xchainmg_util.go 权限验证
crypto       密码学模块 account 生成用户账号 client 密码学模块的客户端接口 config 定义创建账号时产生的助记词中的标记符的值，及其所对应的椭圆曲线密码学算法的类 hash hash算法 sign 签名相关 utils 常用功能
global       全局方法/变量 common.go 全局方法 global.go 全局变量
kv           存储接口与实现 kvdb 单盘存储 mstorage 多盘存储
ledger       账本模块 genesis.go 创世区块相关实现 ledger.go 账本核心业务逻辑实现 ledger_hash.go 账本涉及的hash实现，如生成Merkle树，生成区块ID
log          日志模块 log.go 创建日志实例
p2pv2        p2p网络模块 pb p2p网络消息的pb定义 config.go p2p网络配置 filter.go p2p网络节点过滤实现 server.go p2p网络对外接口实现 stream.go p2p网络流的定义与实现 subscriber.go p2p网络消息订阅定义与实现 util.go p2p网络的全局方法 handlerMap.go p2p网络消息处理入口 node.go p2p网络节点定义与实现 stream_pool.go p2p网络节点对应的流定义与实现 type.go p2p网络对外接口定义
permission   权限验证模块 permission.go 权限验证的业务逻辑实现 ptree 权限树 rule 权限模型 utils 通用工具
pluginmgr    插件管理模块 pluginmgr.go 插件管理的业务逻辑实现 xchainpm.go 插件初始化工作
replica      多副本模块 replica.go 多副本raft业务逻辑实现
server       util.go 通用工具实现，如获取远程节点ip
xuper3       contract contract/bridge xuperbridge定义与实现 contract/kernel 系统级合约(走预执行) contract/vm.go 虚拟机接口定义
xuper3       xmodel xmodel实现 xmodel/pb 版本数据pb定义 xmodel/dbutils.go xmodel通用方法 xmodel/env.go 预执行环境初始化 xmodel/xmodel_cache.go model cache实现 xmodel/xmodel_iterator.go model迭代器实现 xmodel/xmodel_verify.go 读写集验证 xmodel/interface.go xmodel接口定 xmodel/versioned_data.go 版本数据 xmodel/xmodel_cache_iterator.go model cache迭代器 xmodel/xmodel.go model业务逻辑实现
vendor       依赖的三方库
utxo         utxo模块 acl_valid_verify.go acl验证业务逻辑实现，包括SetAccountAcl, SetMethodAcl, 合约调用时的权限验证 topsort.go 交易集合的拓扑排序实现 txhash 交易相关的hash async.go 异步处理 tx_contract_generator.go 合约交易操作 utxo_cache.go utxo cache实现 utxo_item.go utxo表定义 withdraw.go 赎回实现 tx_contract_verifier.go 合约交易操作
===========  ==========================