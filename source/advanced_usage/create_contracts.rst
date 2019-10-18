
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

    将编译好的合约二进制文件（以counter为例）放到目录node/data/blockchain/${chain name}/wasm/下，这里我们默认的链名 ${chain name}=xuper

    部署合约的操作需要由合约账号完成，部署操作同样需要支付手续费，操作前需要确保合约账号下有足够的余额

    示例中我们的环境里创建了一条名为xuper的链，包含一个合约账号 **XC1111111111111111@xuper** 
    
    .. only:: html

        账号的acl查询如下：

        .. figure:: ../images/checkacl.gif
            :alt: 查询acl
            :align: center

    为部署合约，我们需要事先准备一个符合权限的地址列表（示例中将其保存在 data/acl/addrs 文件），这里因为acl里只有一个AK，我们只需在文件中添加一行（如果acl中需要多个AK，那么编辑文件，每行填写一个即可）

    .. code-block:: bash

        echo "XC1111111111111111@xuper/dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN" > data/acl/addrs

    然后我们按照以下命令来部署wasm合约counter

    .. code-block:: bash

        ./xchain-cli wasm deploy --account XC1111111111111111@xuper --cname counter -m -a '{"creator": "someone"}' -A data/acl/addrs -o tx.output --keys data/keys --name xuper -H localhost:37101 counter

    此命令看起来很长，但是其中很多参数都有默认值，我们先来看一下参数的含义：

    - ``wasm deploy`` ：此为部署wasm合约的命令参数，不做过多解释
    - ``--account XC1111111111111111@xuper`` ：此为部署wasm合约的账号（只有合约账号才能进行合约的部署）
    - ``--cname counter`` ：这里的counter是指部署后在链上的合约名字，可以自行命名（但有规则，长度在4～16字符）
    - ``-m`` ：意为多重签名的方式，目前版本的xchain部署wasm合约都需要以这种方式
    - ``-a '{"creator": "someone"}'`` ：此为传入合约的参数，供合约Initialize方法使用（此参数并非必须，只不过此处的counter合约需要传一个"creator"参数，参见contractsdk/cpp/example/counter.cc）
    - ``-A data/acl/addrs`` ：此即为需要收集签名的列表，默认路径为data/acl/addrs，如不是则需要显式传入（注意权重要满足acl要求）
    - ``-o tx.output`` ：此为输出的tx文件，可不传，默认文件名为tx.out
    - ``--keys data/keys`` ：此为部署发起者的密钥地址，可不传，默认值即为data/keys（部署发起者也要进行签名）
    - ``--name xuper`` ：此为区块链名称，默认为xuper，如果创建链名称不是xuper则需要显式传入
    - ``-H localhost:37101`` ：xchain服务的地址，默认是本机的37101端口，如不是则需要显式传入
    - 最后的counter是合约编译好的文件（编译完成默认是counter.wasm）


    在此处，我们大部分参数取的是默认值，所以命令参数不必这么多了

    .. code-block:: bash

        ./xchain-cli wasm deploy --account XC1111111111111111@xuper --cname counter -m -a '{"creator": "someone"}' counter

    .. only:: html

        运行效果如下

        .. figure:: ../images/deploywasm.gif
            :alt: 发起wasm合约部署
            :align: center

    运行时会提示手续费的数目，使用 --fee 参数传入即可

    然后收集所需AK的签名，因为示例中我们只有一个AK（同时也是发起者），所以只需要签名一次

    .. code-block:: bash

        ./xchain-cli multisig sign --tx tx.out --output sign.out --keys data/keys

    这里的 ``--output`` ``--keys`` 参数也有默认值（输出到sign.out文件，密钥位于data/keys），可以不加。运行后我们即可获得此AK的签名

    .. only:: html

        运行效果如下

        .. figure:: ../images/signtx.gif
            :alt: 对tx签名
            :align: center

    收集完发起者和acl需要的签名后，我们即可发送交易，完成合约部署了

    .. code-block:: bash

        ./xchain-cli multisig send --tx tx.out sign.out sign.out

    这里 multisig send 为发送多重签名的命令参数， ``--tx`` 是交易文件，后边的两个参数分别为发起者的签名和acl的签名（acl中有多个AK时，用逗号连接多个签名文件）。运行命令可得到交易上链后的id，我们也可以使用以下命令来查询部署结果

    .. code-block:: bash

        ./xchain-cli account contracts --account XC1111111111111111@xuper

    会显示此合约账号部署过的所有合约

    .. only:: html

        运行效果如下

        .. figure:: ../images/sendtx.gif
            :alt: 发送部署交易
            :align: center


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
