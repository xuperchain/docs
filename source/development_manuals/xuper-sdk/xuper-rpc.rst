
XuperChain RPC 接口使用说明
===========================

XuperChain为方便用户深度使用 XuperChain 的各项功能，提供了多语言版本的SDK（`JS <https://github.com/xuperchain/xuper-sdk-js>`_，`Golang <https://github.com/xuperchain/xuper-sdk-go>`_，`C# <https://github.com/xuperchain/xuper-sdk-csharp>`_，`Java <https://github.com/xuperchain/xuper-java-sdk>`_，`Python <https://github.com/xuperchain/xuper-python-sdk>`_），这里我们以Golang为例来介绍一下XuperChain的RPC接口使用方式。

.. note::
  目前官方提供的SDK中，golang语言版本的功能最为全面，其他语言的功能弱一些，我们非常欢迎社区朋友一起建设SDK，参与贡献会获得开放网络的资源，可用于购买开放网络的服务。


RPC接口介绍
-----------

查看XuperChain 的 `proto文件 <https://github.com/xuperchain/xuperchain/blob/master/service/pb/xchain.proto>`_ ，可以在service定义中获取所有支持的RPC接口


GetBalance
^^^^^^^^^^

此接口用于查询指定地址中的余额

+----------+---------------+
| 参数结构 | AddressStatus |
+----------+---------------+
| 返回结构 | AddressStatus |
+----------+---------------+

这里 AddressStatus 的定义如下

.. code-block:: protobuf
    :linenos:

    message AddressStatus {
        Header header = 1;
        string address = 2;
        repeated TokenDetail bcs = 3;
    }

其中的 address 字段为需要查询的地址，传入string即可

其中的 bcs 字段为需要查询的链名，因为XuperChain支持平行链的功能，此字段为列表，亦可传入多个链名，

TokenDetail 定义如下：

.. code-block:: protobuf
    :linenos:

    message TokenDetail {
        string bcname = 1;
        string balance = 2;
        XChainErrorEnum error = 3;
    }

请求时只需传入 bcname 字段，例如 "xuper"，其余字段为返回时携带的，balance即为对应平行链上的余额

其中的 Header 如下

.. code-block:: protobuf
    :linenos:

    message Header {
        string logid = 1;
        string from_node = 2;
        XChainErrorEnum error = 3;
    }

Header中的logid是回复中也会携带的id，用来对应请求或追溯日志使用的，一般用 core/global/common.go 中的 Glogid() 生成一个全局唯一id

Header中的from_node一般不需要填写，error字段也是返回中携带的错误内容，发请求时不需填写

以下为Golang示例

.. code-block:: go
    :linenos:

    opts := make([]grpc.DialOption, 0)
    opts = append(opts, grpc.WithInsecure())
    opts = append(opts, grpc.WithMaxMsgSize(64<<20-1))
    conn, _ := grpc.Dial("127.0.0.1:37101", opts...)
    cli := pb.NewXchainClient(conn)

    bc := &pb.TokenDetail{
        Bcname: "xuper",
    }
    in := &pb.AddressStatus{
        Header: global.Glogid(),
        Address: "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN",
        Bcs: []*pb.TokenDetail{bc},
    }
    out, _ := cli.GetBalance(context.Background(), in)

GetBalanceDetail
^^^^^^^^^^^^^^^^

此接口用于查询指定地址中的余额详细情况

+----------+----------------------+
| 参数结构 | AddressBalanceStatus |
+----------+----------------------+
| 返回结构 | AddressBalanceStatus |
+----------+----------------------+

AddressBalanceStatus 定义如下

.. code-block:: protobuf
    :linenos:

    message AddressBalanceStatus {
        Header header = 1;
        string address = 2;
        repeated TokenFrozenDetails tfds = 3;
    }

address字段与GetBalance一样，tfds字段则多了是否冻结的内容，tfds在请求中只需要填充bcname，返回时会有TokenFrozenDetail数组给出正常余额和冻结余额的信息

以下为Golang示例

.. code-block:: go
    :linenos:

    opts := make([]grpc.DialOption, 0)
    opts = append(opts, grpc.WithInsecure())
    opts = append(opts, grpc.WithMaxMsgSize(64<<20-1))
    conn, _ := grpc.Dial("127.0.0.1:37101", opts...)
    cli := pb.NewXchainClient(conn)

    tfd := &pb.TokenFrozenDetails{
        Bcname: "xuper",
    }
    in := &pb.AddressBalanceStatus{
        Header: global.Glogid(),
        Address: "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN",
        Tfds: []*pb.TokenFrozenDetails{bc},
    }
    out, _ := cli.GetBalanceDetail(context.Background(), in)

GetFrozenBalance
^^^^^^^^^^^^^^^^

此接口用于查询指定地址中的冻结余额，请求方式与GetBalance完全一致，这里不再赘述

GetBlock
^^^^^^^^

此接口用于查询指定id的区块内容

+----------+---------+
| 参数结构 | BlockID |
+----------+---------+
| 返回结构 | Block   |
+----------+---------+

BlockID 定义如下

.. code-block:: protobuf
    :linenos:

    message BlockID {
        Header header = 4;
        string bcname = 1;
        bytes blockid = 2;
        bool need_content = 3;  //是否需要内容
    }

header和bcname字段如上所述，blocked为要查询的区块id，注意是bytes类型，可能需要hex decode

need_content字段为布尔值，表明是否需要详细的区块内容（还是只查询区块是否在链和前驱后继）

以下为Golang示例

.. code-block:: go
    :linenos:

    opts := make([]grpc.DialOption, 0)
    opts = append(opts, grpc.WithInsecure())
    opts = append(opts, grpc.WithMaxMsgSize(64<<20-1))
    conn, _ := grpc.Dial("127.0.0.1:37101", opts...)
    cli := pb.NewXchainClient(conn)

    id, _ := hex.DecodeString("ee0d6fd34df4a7e1540df309d47441af4fda6fdd9d841046f18e7680fe0cea8c")
    in := &pb.BlockID{
        Header: global.Glogid(),
        Bcname: "xuper",
        Blockid: id,
        NeedContent: true,
    }
    out, _ := cli.GetBlock(context.Background(), in)

GetBlockByHeight
^^^^^^^^^^^^^^^^

此接口用于查询指定高度的区块内容

+----------+-------------+
| 参数结构 | BlockHeight |
+----------+-------------+
| 返回结构 | Block       |
+----------+-------------+

BlockHeight定义如下

.. code-block:: protobuf
    :linenos:

    message BlockHeight {
        Header header = 3;
        string bcname = 1;
        int64 height = 2;
    }

同GetBlock类似，id换成整型的高度即可，返回内容也是类似的

GetBlockChainStatus
^^^^^^^^^^^^^^^^^^^

此接口用于查询指定链的当前状态

+----------+----------+
| 参数结构 | BCStatus |
+----------+----------+
| 返回结构 | BCStatus |
+----------+----------+

BCStatus定义如下

.. code-block:: protobuf
    :linenos:

    message BCStatus {
        Header header = 1;
        string bcname = 2;
        LedgerMeta meta = 3;
        InternalBlock block = 4;
        UtxoMeta utxoMeta = 5;
        repeated string branchBlockid = 6;
    }

传入参数只需填充header，bcname即可

以下为Golang示例

.. code-block:: go
    :linenos:

    opts := make([]grpc.DialOption, 0)
    opts = append(opts, grpc.WithInsecure())
    opts = append(opts, grpc.WithMaxMsgSize(64<<20-1))
    conn, _ := grpc.Dial("127.0.0.1:37101", opts...)
    cli := pb.NewXchainClient(conn)

    in := &pb.BCStatus{
        Header: global.Glogid(),
        Bcname: "xuper",
    }
    out, _ := cli.GetBlockChainStatus(context.Background(), in)

GetBlockChains
^^^^^^^^^^^^^^

此接口用于查询当前节点上有哪些链

+----------+-------------+
| 参数结构 | CommonIn    |
+----------+-------------+
| 返回结构 | BlockChains |
+----------+-------------+

CommonIn结构很简单，只有header字段，返回的BlockChains也仅有一个链名的string数组

以下为Golang示例

.. code-block:: go
    :linenos:

    opts := make([]grpc.DialOption, 0)
    opts = append(opts, grpc.WithInsecure())
    opts = append(opts, grpc.WithMaxMsgSize(64<<20-1))
    conn, _ := grpc.Dial("127.0.0.1:37101", opts...)
    cli := pb.NewXchainClient(conn)

    in := &pb.CommonIn{
        Header: global.Glogid(),
    }
    out, _ := cli.GetBlockChains(context.Background(), in)

GetSystemStatus
^^^^^^^^^^^^^^^

此接口用于查询当前节点的运行状态

+----------+--------------------+
| 参数结构 | CommonIn           |
+----------+--------------------+
| 返回结构 | SystemsStatusReply |
+----------+--------------------+

此接口相当于先查询了GetBlockChains，在用GetBlockChainStatus查询每个链的状态，不在赘述

GetNetURL
^^^^^^^^^

此接口用于查询当前节点的netUrl

+----------+----------+
| 参数结构 | CommonIn |
+----------+----------+
| 返回结构 | RawUrl   |
+----------+----------+

RawUrl除了header字段外仅有一个string字段，表示返回的netURL

QueryACL
^^^^^^^^

此接口用于查询指定合约账号的ACL内容

+----------+-----------+
| 参数结构 | AclStatus |
+----------+-----------+
| 返回结构 | AclStatus |
+----------+-----------+

AclStatus定义如下

.. code-block:: protobuf
    :linenos:

    message AclStatus {
        Header header = 1;
        string bcname = 2;
        string accountName = 3;
        string contractName = 4;
        string methodName = 5;
        bool confirmed = 6;
        Acl acl = 7;
    }

请求中仅需填充header，bcname，accountName即可，其余为返回内容

以下为Golang示例

.. code-block:: go
    :linenos:

    in := &pb.AclStatus{
        Header: global.Glogid(),
        Bcname: "xuper",
        AccountName: "XC1111111111111111@xuper",
    }
    out, _ := cli.QueryACL(context.Background(), in)

QueryTx
^^^^^^^

此接口用于查询指定id的交易内容

+----------+----------+
| 参数结构 | TxStatus |
+----------+----------+
| 返回结构 | TxStatus |
+----------+----------+

TxStatus定义如下

.. code-block:: protobuf
    :linenos:

    message TxStatus {
        Header header = 1;
        string bcname = 2;
        bytes txid = 3;
        TransactionStatus status = 4;  //当前状态
        int64 distance = 5;  //离主干末端的距离（如果在主干上)
        Transaction tx = 7;
    }

请求中仅需填充header，bcname，txid字段

以下为Golang示例

.. code-block:: go
    :linenos:

    id, _ := hex.DecodeString("763ac8212c80b8789cefd049f1529eafe292f4d64eaffbc2d5fe19c79062a484")
    in := &pb.AclStatus{
        Header: global.Glogid(),
        Bcname: "xuper",
        Txid: id,
    }
    out, _ := cli.QueryTx(context.Background(), in)

SelectUTXO
^^^^^^^^^^

此接口用于获取账号可用的utxo列表

+----------+------------+
| 参数结构 | UtxoInput  |
+----------+------------+
| 返回结构 | UtxoOutput |
+----------+------------+

UtxoInput定义如下

.. code-block:: protobuf
    :linenos:

    message UtxoInput {
        Header header = 1;
        // which bcname to select
        string bcname = 2;
        // address to select
        string address = 3;
        // publickey of the address
        string publickey = 4;
        // totalNeed refer the total need utxos to select
        string totalNeed = 5;
        // userSign of input
        bytes userSign = 7;
        // need lock
        bool needLock = 8;
    }

请求中只需填充header，bcname，address，totalNeed，needLock，其中needLock表示是否需要锁定utxo（适用于并发执行场景）

UtxoOutput中的返回即可在组装交易时使用，具体组装交易的过程可参考文档下方

.. code-block:: go
    :linenos:

    in := &pb.UtxoInput{
        Header: global.Glogid(),
        Bcname: "xuper",
        Address: "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN",
        TotalNeed: "50",
        NeedLock: true,
    }
    out, _ := cli.SelectUTXO(context.Background(), in)

SelectUTXOBySize
^^^^^^^^^^^^^^^^

此接口用于获取账号中部分utxo，填满交易后便不在继续获取

+----------+------------+
| 参数结构 | UtxoInput  |
+----------+------------+
| 返回结构 | UtxoOutput |
+----------+------------+

使用过程和SelectUTXO基本相同，仅少了totalNeed字段。适用拥有太多utxo，一次SelectUtxo内容超过交易容纳上限时使用

PreExec
^^^^^^^

此接口用于在节点上进行合约的预执行操作，返回预执行后的请求和回复

+----------+-------------------+
| 参数结构 | InvokeRPCRequest  |
+----------+-------------------+
| 返回结构 | InvokeRPCResponse |
+----------+-------------------+

InvokeRPCRequest定义如下

.. code-block:: protobuf
    :linenos:

    message InvokeRPCRequest {
        Header header = 1;
        string bcname = 2;InvokeRequest
        repeated  requests = 3;
        string initiator = 4;
        repeated string auth_require = 5;
    }

其中的InvokeRequest定义如下

.. code-block:: protobuf
    :linenos:

    message InvokeRequest {
        string module_name = 1;
        string contract_name = 2;
        string method_name = 3;
        map<string, bytes> args = 4;
        repeated ResourceLimit resource_limits = 5;
        string amount = 6;
    }

其中必填字段有module_name，contract_name，method_name，args，具体示例可参见下一章节

PreExecWithSelectUTXO
^^^^^^^^^^^^^^^^^^^^^

此接口用于在节点上进行消耗资源的合约预执行操作，内部是由一个PreExec加上一个SelectUTXO实现的，预执行并选择出需要消耗数额的utxo

+----------+-------------------------------+
| 参数结构 | PreExecWithSelectUTXORequest  |
+----------+-------------------------------+
| 返回结构 | PreExecWithSelectUTXOResponse |
+----------+-------------------------------+

PreExecWithSelectUTXORequest定义如下，实际上就是把预执行的请求结构放在了SelectUTXO结构中

.. code-block:: protobuf
    :linenos:

    message PreExecWithSelectUTXORequest {
        Header header = 1;
        string bcname = 2;
        string address = 3;
        int64 totalAmount = 4;
        SignatureInfo signInfo = 6;
        bool needLock = 7;
        InvokeRPCRequest request = 5;
    }

具体填充方式可参考下一章节

PostTx
^^^^^^

此接口用于提交交易，是大部分操作都需要的最终环节

+----------+-------------+
| 参数结构 | TxStatus    |
+----------+-------------+
| 返回结构 | CommonReply |
+----------+-------------+

请求结构TxStatus定义在QueryTx中已经给出，但提交交易时需要填充Transaction字段，定义如下

.. code-block:: protobuf
    :linenos:

    message Transaction {
        // txid is the id of this transaction
        bytes txid = 1;
        // the blockid the transaction belong to
        bytes blockid = 2;
        // Transaction input list
        repeated TxInput tx_inputs = 3;
        // Transaction output list
        repeated TxOutput tx_outputs = 4;
        // Transaction description or system contract
        bytes desc = 6;
        // Mining rewards
        bool coinbase = 7;
        // Random number used to avoid replay attacks
        string nonce = 8;
        // Timestamp to launch the transaction
        int64 timestamp = 9;
        // tx format version; tx格式版本号
        int32 version = 10;
        // auto generated tx
        bool autogen = 11;
        repeated TxInputExt tx_inputs_ext = 23;
        repeated TxOutputExt tx_outputs_ext = 24;
        repeated InvokeRequest contract_requests = 25;
        // 权限系统新增字段
        // 交易发起者, 可以是一个Address或者一个Account
        string initiator = 26;
        // 交易发起需要被收集签名的AddressURL集合信息，包括用于utxo转账和用于合约调用
        repeated string auth_require = 27;
        // 交易发起者对交易元数据签名，签名的内容包括auth_require字段
        repeated SignatureInfo initiator_signs = 28;
        // 收集到的签名
        repeated SignatureInfo auth_require_signs = 29;
        // 节点收到tx的时间戳，不参与签名
        int64 received_timestamp = 30;
        // 统一签名(支持多重签名/环签名等，与initiator_signs/auth_require_signs不同时使用)
        XuperSignature xuper_sign = 31;
        // 可修改区块链标记
        ModifyBlock modify_block = 32;
    }

Transaction属于XuperChain中比较核心的结构了，下一章我们将介绍各种场景的交易如何构造并提交

RPC接口应用
-----------

本章节将以几个简单的场景为例描述RPC接口的使用方法，主要体现逻辑和步骤。代码中仅使用了原始的RPC接口，如果使用SDK则会简便很多。

发起一次转账
^^^^^^^^^^^^

这里我们演示如何使用RPC接口实现从账号Aclie向账号Bob的一次数额为10的转账，为了进行此操作，我们事先需要有以下信息（均为string）

+-------------+------------+
| Alice的地址 | addr_alice |
+-------------+------------+
| Alice的公钥 | pub_alice  |
+-------------+------------+
| Alice的私钥 | pri_alice  |
+-------------+------------+
| Bob的地址   | addr_bob   |
+-------------+------------+

发起转账交易的总体逻辑为，首先通过SelectUTXO获取Alice数额为10的资产，然后构造交易，最后通过PostTx提交

.. code-block:: go
    :linenos:

    // 获取Alice的utxo
    utxoreq := &pb.UtxoInput{
        Header: global.Glogid(),
        Bcname: "xuper",
        Address: addr_alice,
        TotalNeed: "10",
        NeedLock: true,
    }
    utxorsp, _ := cli.SelectUTXO(context.Background(), utxoreq)
    // 声明一个交易，发起者为Alice地址，因为是转账，所以Desc字段什么都不填
    // 如果是提案等操作，将客户端的 --desc 参数写进去即可
    tx := &pb.Transaction{
        Version: 1,
        Coinbase: false,
        Desc: []byte(""),
        Nonce: global.GenNonce(),
        Timestamp: time.Now().UnixNano(),
        Initiator: addr_alice,
    }
    // 填充交易的输入，即Select出来的Alice的utxo
    for _, utxo := range utxorsp.UtxoList {
        txin := &pb.TxInput{
            RefTxid: utxo.RefTxid,
            RefOffset: utxo.RefOffset,
            FromAddr: utxo.ToAddr,
            Amount: utxo.Amount,
        }
        tx.TxInputs = append(tx.TxInputs, txin)
    }
    // 填充交易的输出，即给Bob的utxo，注意Amount字段的类型
    amount, _ := big.NewInt(0).SetString("10", 10)
    txout := &pb.TxOutput{
        ToAddr: []byte(addr_bob),
        Amount: amount.Bytes(),
    }
    tx.TxOutputs = append(tx.TxOutputs, txout)
    // 如果Select出来的Alice的utxo多于10，需要构造一个给Alice的找零
    total, _ := big.NewInt(0).SetString(utxorsp.TotalSelected, 10)
    if total.Cmp(amount) > 0 {
        delta := total.Sub(total, amount)
        charge := &pb.TxOutput{
            ToAddr: []byte(addr_alice),
            Amount: delta.Bytes(),
        }
        tx.TxOutputs = append(tx.TxOutputs, charge)
    }
    // 接下来用Alice的私钥对交易进行签名，在此交易中，我们只需Alice签名确认即可
    tx.AuthRequire = append(tx.AuthRequire, addr_alice)
    // 签名需要的库在 github.com/xuperchain/xuperchain/core/crypto/client
    // 和 github.com/xuperchain/xuperchain/core/crypto/hash
    cryptoCli, _ := client.CreateCryptoClient("default")
    sign, _ := txhash.ProcessSignTx(cryptoCli, tx, []byte(pri_alice))
    signInfo := &pb.SignatureInfo{
        PublicKey: pub_alice,
        Sign: sign,
    }
    // 将签名填充进交易
    tx.InitiatorSigns = append(tx.InitiatorSigns, signInfo)
    tx.AuthRequireSigns = append(tx.AuthRequireSigns, signInfo)
    // 生成交易ID
    tx.Txid, _ = txhash.MakeTransactionID(tx)
    // 构造最终要Post的TxStatus
    txs := &pb.TxStatus{
        Bcname: "xuper",
        Status: pb.TransactionStatus_UNCONFIRM,
        Tx: tx,
        Txid: tx.Txid,
    }
    // 最后一步，执行PostTx
    rsp, err := cli.PostTx(context.Background(), txs)
    // 这里的rsp即CommonReply，包含logid等内容
    // 交易id我们已经生成在tx.Txid中，不过是bytes，输出可能需要hex.EncodeToString一下

新建合约账号
^^^^^^^^^^^^

这里我们演示创建一个合约账号 XC1234567812345678@xuper ，ACL如下

.. code-block:: python
    :linenos:

    {
        "pm": {
            "rule": 1,
            "acceptValue": 1.0
        },
        "aksWeight": {
            "XXXaddress-aliceXXX" : 0.6,
            "XXXXaddress-bobXXXX" : 0.4
        }
    }
    
为了进行此操作，我们事先需要有以下信息

+-------------+------------+
| Alice的地址 | addr_alice |
+-------------+------------+
| Alice的公钥 | pub_alice  |
+-------------+------------+
| Alice的私钥 | pri_alice  |
+-------------+------------+
| ACL的内容   | acct_acl   |
+-------------+------------+

创建合约账号的总体逻辑为，首先进行创建合约账号的预执行，然后构造相应的交易内容（如果需要支付资源由Alice出），最后提交交易

.. code-block:: go
    :linenos:

    // 构造创建合约账号的请求
    args := make(map[string][]byte)
    args["account_name"] = []byte(1234567812345678)
    args["acl"] = []byte(acct_acl)
    invokereq := &pb.InvokeRequest{
        ModuleName: "xkernel",
        MethodName: "NewAccount",
        Args: args,
    }
    invokereqs := []*pb.InvokeRequest{invokereq}
    // 构造合约预执行的请求
    authrequire := []string{addr_alice}
    rpcreq := &pb.InvokeRPCRequest{
        Header: global.Glogid(),
        Bcname: "xuper",
        Requests: invokereqs,
        Initiator: addr_alice,
        AuthRequire: authrequire,
    }
    // 花手续费需要出资的账号确认，填充一个验证的签名，才能正确的拿出utxo来
    // 签名需要的库在 github.com/xuperchain/xuperchain/core/crypto/client
    // 和 github.com/xuperchain/xuperchain/core/crypto/hash
    content := hash.DoubleSha256([]byte("xuper" + addr_alice + "0" + "true"))
    cryptoCli, _ := client.CreateCryptoClient("default")
    prikey, _ := cryptoCli.GetEcdsaPrivateKeyFromJSON([]byte(pri_alice))
    sign, _ := cryptoCli.SignECDSA(prikey, content)
    signInfo := &pb.SignatureInfo{
        PublicKey: pub_alice,
        Sign: sign,
    }
    // 组合一个PreExecWithSelectUTXORequest用来预执行同时拿出需要支付的Alice的utxo
    prereq := &pb.PreExecWithSelectUTXORequest{
        Header: global.Glogid(),
        Bcname: "xuper",
        Address: addr_alice,
        TotalAmount: 0,
        SignInfo: signInfo,
        NeedLock: true,
        Request: rpcreq,
    }
    prersp := cli.PreExecWithSelectUTXO(context.Background(), prereq)
    // 构造一个Alice发起的交易
    tx := &pb.Transaction{
        Version: 1,
        Coinbase: false,
        Desc: []byte(""),
        Nonce: global.GenNonce(),
        Timestamp: time.Now().UnixNano(),
        Initiator: addr_alice,
    }
    // 填充支付的手续费，手续费需要“转账”给地址“$”
    amount := big.NewInt(prersp.Response.GasUsed)
    fee := &pb.TxOutput{
        ToAddr: []byte("$"),
        Amount: amount.Bytes(),
    }
    tx.TxOutputs = append(tx.TxOutputs, fee)
    // 填充select出来的Alice的utxo
    for _, utxo := range prersp.UtxoOutput.UtxoList {
        txin := &pb.TxInput{
            RefTxid: utxo.RefTxid,
            RefOffset: utxo.RefOffset,
            FromAddr: utxo.ToAddr,
            Amount: utxo.Amount,
        }
        tx.TxInputs = append(tx.TxInputs, txin)
    }
    // 处理找零的逻辑
    total, _ := big.NewInt(0).SetString(prersp.UtxoOutput.TotalSelected, 10)
    if total.Cmp(amount) > 0 {
        delta := total.Sub(total, amount)
        charge := &pb.TxOutput{
            ToAddr: []byte(addr_alice),
            Amount: delta,
        }
    }
    // 填充预执行的结果
    tx.ContractRequests = prersp.GetResponse().GetRequests()
    tx.TxInputsExt = prersp.GetResponse().GetInputs()
    tx.TxOutputsExt = prersp.GetResponse().GetOutputs()
    // 给交易签名
    tx.AuthRequire = append(tx.AuthRequire, addr_alice)
    txsign, _ := txhash.ProcessSignTx(cryptoCli, tx, []byte(pri_alice))
    txsignInfo := &pb.SignatureInfo{
        PublicKey: pub_alice,
        Sign: txsign,
    }
    tx.InitiatorSigns = append(tx.InitiatorSigns, txsignInfo)
    tx.AuthRequireSigns = append(tx.AuthRequireSigns, txsignInfo)
    // 生成交易ID
    tx.Txid, _ = txhash.MakeTransactionID(tx)
    // 构造最终要Post的TxStatus
    txs := &pb.TxStatus{
        Bcname: "xuper",
        Status: pb.TransactionStatus_UNCONFIRM,
        Tx: tx,
        Txid: tx.Txid,
    }
    // 最后一步，执行PostTx
    rsp, err := cli.PostTx(context.Background(), txs)

修改合约账号ACL
^^^^^^^^^^^^^^^

延续上一小节的例子，假设我们要把ACL修改成以下状态

.. code-block:: python
    :linenos:

    {
        "pm": {
            "rule": 1,
            "acceptValue": 1.0
        },
        "aksWeight": {
            "XXXaddress-aliceXXX" : 1.0,
            "XXXXaddress-bobXXXX" : 1.0
        }
    }

为了进行此操作，我们事先需要有以下信息

+-------------+------------+
| Alice的地址 | addr_alice |
+-------------+------------+
| Alice的公钥 | pub_alice  |
+-------------+------------+
| Alice的私钥 | pri_alice  |
+-------------+------------+
| Bob的地址   | addr_bob   |
+-------------+------------+
| Bob的公钥   | pub_bob    |
+-------------+------------+
| Bob的私钥   | pri_bob    |
+-------------+------------+
| 新ACL的内容 | new_acl    |
+-------------+------------+

修改ACL的总体逻辑为，首先进行修改的预执行，然后构造交易发送，这里需要注意的是，修改ACL操作需要满足现有的ACL要求才有权限，即Alice Bob都需要签名确认。简单起见，当中的手续费依然由Alice支付。

.. code-block:: go
    :linenos:

    // 构造修改ACL的请求
    args := make(map[string][]byte)
    args["account_name"] = []byte(1234567812345678)
    args["acl"] = []byte(new_acl)
    invokereq := &pb.InvokeRequest{
        ModuleName: "xkernel",
        MethodName: "SetAccountAcl",
        Args: args,
    }
    invokereqs := []*pb.InvokeRequest{invokereq}

    // 构造合约预执行的请求，和上一节一样，此处省略
    ///////////////////////////////////////////////
    // 花手续费需要出资的账号确认，填充验证的签名，和上一节一样，此处省略
    /////////////////////////////////////////////////////////////////////
    // 按上一节逻辑一样，填充花费、找零，然后填充预执行的结果
    tx.ContractRequests = prersp.GetResponse().GetRequests()
    tx.TxInputsExt = prersp.GetResponse().GetInputs()
    tx.TxOutputsExt = prersp.GetResponse().GetOutputs()
    // 给交易签名需要原ACL里的多个账号了
    tx.AuthRequire = append(tx.AuthRequire, addr_alice)
    tx.AuthRequire = append(tx.AuthRequire, addr_bob)
    alicesign, _ := txhash.ProcessSignTx(cryptoCli, tx, []byte(pri_alice))
    alicesignInfo := &pb.SignatureInfo{
        PublicKey: pub_alice,
        Sign: alicesign,
    }
    bobsign, _ := txhash.ProcessSignTx(cryptoCli, tx, []byte(pri_bob))
    bobsignInfo := &pb.SignatureInfo{
        PublicKey: pub_bob,
        Sign: bobsign,
    }
    tx.InitiatorSigns = append(tx.InitiatorSigns, alicesignInfo)
    tx.AuthRequireSigns = append(tx.AuthRequireSigns, alicesignInfo)
    tx.AuthRequireSigns = append(tx.AuthRequireSigns, bobsignInfo)
    // 然后和上一节一致了，生成交易ID
    tx.Txid, _ = txhash.MakeTransactionID(tx)
    // 构造最终要Post的TxStatus
    txs := &pb.TxStatus{
        Bcname: "xuper",
        Status: pb.TransactionStatus_UNCONFIRM,
        Tx: tx,
        Txid: tx.Txid,
    }
    // 最后一步，执行PostTx
    rsp, err := cli.PostTx(context.Background(), txs)

部署一个合约
^^^^^^^^^^^^

这里我们演示使用合约账号 XC1234567812345678@xuper 部署一个C++的counter合约，init参数为{"creator":"xchain"}，假设合约账号的ACL是修改过的版本

为了进行此操作，我们事先需要有以下信息

+------------------+---------------+
| 合约文件字节内容 | contract_code |
+------------------+---------------+
| Alice的地址      | addr_alice    |
+------------------+---------------+
| Alice的公钥      | pub_alice     |
+------------------+---------------+
| Alice的私钥      | pri_alice     |
+------------------+---------------+

部署合约的总体逻辑为，首先构造deploy操作预执行，部署需要的手续费由合约账号出，需要的签名由Alice提供（因为一个签名就满足ACL了）

.. code-block:: go
    :linenos:

    // 构造部署合约的请求，关注args的内容，基本上和使用xchain-cli一致
    args := make(map[string][]byte)
    args["account_name"] = []byte("XC1234567812345678@xuper")
    args["contract_name"] = []byte("counter")
    // github.com/golang/protobuf/proto
    codedesc := desc := &pb.WasmCodeDesc{
        Runtime: "c",
    }
    desc, _ := proto.Marshal(codedesc)
    args["contract_desc"] = desc
    args["contract_code"] = contract_code
    initarg := `{"creator":"` + base64.StdEncoding.EncodeToString([]byte("xchain")) + `"}`
    args["init_args"] = []byte(initarg)
    invokereq := &pb.InvokeRequest{
        ModuleName: "xkernel",
        MethodName: "Deploy",
        Args: args,
    }
    invokereqs := []*pb.InvokeRequest{invokereq}
    // 这里预执行的authrequire格式为 XC1234567812345678@xuper/dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN，
    // 表示是“某个合约账号的股东”，与直接写账号地址含义是不同的，ACL需求多个签名的时候即多个“股东”
    authrequires := []string{"XC1234567812345678@xuper/XXXaddress-aliceXXX"}
    rpcreq := &pb.InvokeRPCRequest{
        Header: global.Glogid(),
        Bcname: "xuper",
        Requests: invokereqs,
        Initiator: addr_alice,
        AuthRequire: authrequires,
    }
    // SelectUTXO的目标是合约账号中的余额，出资账号签名中的地址变成了合约账号，与“创建账号”小节有区别
    content := hash.DoubleSha256([]byte("xuper" + "XC1234567812345678@xuper" + "0" + "true"))
    prikey, _ := cryptoCli.GetEcdsaPrivateKeyFromJSON([]byte(pri_alice))
    sign, _ := cryptoCli.SignECDSA(prikey, content)
    signInfo := &pb.SignatureInfo{
        PublicKey: pub_alice,
        Sign: sign,
    }
    // 组合一个PreExecWithSelectUTXORequest用来预执行同时拿出需要支付的合约账号的utxo
    prereq := &pb.PreExecWithSelectUTXORequest{
        Header: global.Glogid(),
        Bcname: "xuper",
        Address: "XC1234567812345678@xuper",
        TotalAmount: 0,
        SignInfo: signInfo,
        NeedLock: true,
        Request: rpcreq,
    }
    prersp, _ := cli.PreExecWithSelectUTXO(context.Background(), prereq)
    // 构造一个Alice发起的交易
    tx := &pb.Transaction{
        Version: 1,
        Coinbase: false,
        Desc: []byte(""),
        Nonce: global.GenNonce(),
        Timestamp: time.Now().UnixNano(),
        Initiator: addr_alice,
    }
    // 填充支付的手续费，手续费需要“转账”给地址“$”
    amount := big.NewInt(prersp.Response.GasUsed)
    fee := &pb.TxOutput{
        ToAddr: []byte("$"),
        Amount: amount.Bytes(),
    }
    tx.TxOutputs = append(tx.TxOutputs, fee)
    // 填充select出来的Alice的utxo
    for _, utxo := range prersp.UtxoOutput.UtxoList {
        txin := &pb.TxInput{
            RefTxid: utxo.RefTxid,
            RefOffset: utxo.RefOffset,
            FromAddr: utxo.ToAddr,
            Amount: utxo.Amount,
        }
        tx.TxInputs = append(tx.TxInputs, txin)
    }
    // 处理找零的逻辑
    total, _ := big.NewInt(0).SetString(prersp.UtxoOutput.TotalSelected, 10)
    if total.Cmp(amount) > 0 {
        delta := total.Sub(total, amount)
        charge := &pb.TxOutput{
            ToAddr: []byte("XC1234567812345678@xuper"),
            Amount: delta,
        }
    }
    // 填充预执行的结果
    tx.ContractRequests = prersp.GetResponse().GetRequests()
    tx.TxInputsExt = prersp.GetResponse().GetInputs()
    tx.TxOutputsExt = prersp.GetResponse().GetOutputs()
    // 给交易签名，此处也是以“股东”身份签名
    tx.AuthRequire = append(tx.AuthRequire, "XC1234567812345678@xuper/XXXaddress-aliceXXX")
    txsign, _ := txhash.ProcessSignTx(cryptoCli, tx, []byte(pri_alice))
    txsignInfo := &pb.SignatureInfo{
        PublicKey: pub_alice,
        Sign: txsign,
    }
    // 虽然Alice和“股东Alice”含义不同，但签名的私钥是一样的
    tx.InitiatorSigns = append(tx.InitiatorSigns, signInfo)
    tx.AuthRequireSigns = append(tx.AuthRequireSigns, signInfo)
    tx.Txid, _ = txhash.MakeTransactionID(tx)
    // 构造最终要Post的TxStatus
    txs := &pb.TxStatus{
        Bcname: "xuper",
        Status: pb.TransactionStatus_UNCONFIRM,
        Tx: tx,
        Txid: tx.Txid,
    }
    // 最后一步，执行PostTx
    rsp, err := cli.PostTx(context.Background(), txs)

执行一个wasm合约
^^^^^^^^^^^^^^^^

这里我们演示使用Alice账号调用上一节部署的counter合约，执行 increase 方法，参数为 {"key": "example"}

为了进行此操作，我们事先需要有以下信息

+------------------+---------------+
| Alice的地址      | addr_alice    |
+------------------+---------------+
| Alice的公钥      | pub_alice     |
+------------------+---------------+
| Alice的私钥      | pri_alice     |
+------------------+---------------+

执行合约的总体逻辑为，首先构造相应预执行请求并预执行，如果是查询，那么直接读预执行结果即可，如果是要调用上链的操作，使用预执行结果组建交易并发送

.. code-block:: go
    :linenos:

    // 构造执行合约的请求
    args := make(map[string][]byte)
    args["key"] = []byte("example")
    invokereq := &pb.InvokeRequest{
        ModuleName: "wasm",
        MethodName: "increase",
        ContractName: "counter",
        Args: args,
    }
    invokereqs := []*pb.InvokeRequest{invokereq}
    // 其他内容和“创建合约账号”一节完全一致