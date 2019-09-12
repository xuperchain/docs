
创建合约
========

编写合约
--------

源码可以参考 xuperchain/xuperunion/contractsdk/go/example/math/math.go 

主要实现struct中initialize，invoke和query三个方法来实现自己的逻辑

.. code-block:: go
    :linenos:

    func (m *math) Initialize(nci code.Context) code.Response { ... }
    func (m *math) Invoke(nci code.Context) code.Response { ... }
    func (m *math) Query(nci code.Context) code.Response { ... }

每个函数的入口参数均为 code.Context ，具体结构可参考 xuperchain/xuperunion/contractsdk/go/code/context.go
接口中定义了如何获取传入方法的参数，如何使用读写功能，以及如何在链上进行交易/区块的查询、转账或调用其他合约

.. code-block:: go
    :linenos:

    type Context interface {
        Args() map[string][]byte
        Caller() string
        Initiator() string
        AuthRequire() []string

        PutObject(key []byte, value []byte) error
        GetObject(key []byte) ([]byte, error)
        DeleteObject(key []byte) error
        NewIterator(start, limit []byte) Iterator

        QueryTx(txid []byte) (*TxStatus, error)
        QueryBlock(blockid []byte) (*Block, error)
        Transfer(to string, amount *big.Int) error
        Call(module, contract, method string, args map[string][]byte) (*Response, error)
    }

对于C++版本的合约，可以参考代码 contractsdk/cpp/example/counter.cc 原理和Golang合约是一致的

.. note::
    除了 Initialize 外的其他函数，是可以自行定义函数名的，可参考contractsdk/go/example/counter/counter.go中的具体实例，在之后调用合约时写明函数名即可

部署wasm合约
------------

1. 编译合约 - Golang

    注意合约编译环境与源码编译环境一致，编译参数如下

    .. code-block:: bash

        GOOS=js GOARCH=wasm go build XXX.go

2. 编译合约 - C++

    对于C++合约，已提供编译脚本，位于 contractsdk/cpp/build.sh，需要注意的是，脚本依赖从hub.baidubce.com拉取的docker镜像，请在编译前确认docker相关环境是可用的

3. 部署wasm合约

    将编译好的合约二进制文件（以counter为例）放到目录node/data/blockchain/${chain name}/native/下，这里我们默认的链名 ${chain name}=xuper

    部署合约的操作需要由合约账号完成，部署操作同样需要支付手续费，操作前需要确保合约账号下有足够的余额

    在合约账号权限AK是节点账号的情况下（即ACL中有当前节点的签名即可生效），我们按照如下命令即可完成部署

    .. code-block:: bash

        ./xchain-cli wasm deploy --account XC1111111111111111@xuper --cname counter -H localhost:37101 data/blockchain/xuper/wasm/counter

    运行时会提示手续费的数目，使用 --fee 参数传入即可

    对于合约账号权限AK有多个的情况，部署操作需要多方的签名，需要提前在 data/acl/addrs 维护好需要的合作的地址列表（每个AK地址写一行），运行时增加 -m 参数

    .. code-block:: bash

        ./xchain-cli wasm deploy --account XC1111111111111111@xuper --cname counter -H localhost:37101 -m data/blockchain/xuper/wasm/counter

    生成的 tx.out 就像类似修改ACL的操作一样，收集各个AK的签名，然后发送即可

部署native合约
--------------

1. 编译合约

    编译native合约时，只要保持环境和编译xuperunion源码时一致即可，我们还是以example中的counter为例

    .. code-block:: bash

        cd contractsdk/go/example/counter
        go build
        # 产出二进制counter

2. 激活合约

    native合约部署需要进行一次 `提案-投票 <initiate_proposals.html>`_ 操作，
