
使用事件订阅功能
================

在使用超级链的过程中，可能会遇到一些异步的情况：比如执行合约的时候，构造的交易是否合法我们可以实时获知，但具体什么时候真正的被节点打包上链就不一样了。当然还有其他类似的场景，针对这种问题，我们引入了事件订阅机制。

事件订阅的接口
--------------

订阅的接口十分简单，只有subscribe和unsubscribe两个，订阅和取消订阅

.. code-block:: protobuf
    :linenos:

    service PubsubService {
        rpc Subscribe (EventRequest) returns (stream Event);
        rpc Unsubscribe (UnsubscribeRequest) returns (UnsubscribeResponse) {}
    }

其中订阅接口的EventRequest格式如下：

.. code-block:: protobuf
    :linenos:

    message EventRequest {
        EventType type = 1;
        bytes payload = 2;
    }
    // EventType 主要有区块、交易、账户 3种
    enum EventType {
        UNDEFINED = 0;
        BLOCK = 1;
        TRANSACTION = 2;
        ACCOUNT = 3;
        SUBSCRIBE_RESPONSE = 4;
    }

请求里的payload是一段序列化的proto对象，因为订阅不同内容需要的参数不尽相同

.. code-block:: protobuf
    :linenos:

    // BlockEventRequest 订阅区块请求
    message BlockEventRequest {
        string bcname = 1;
        string proposer = 2;
        int64 start_height = 3;
        int64 end_height = 4;
        bool need_content = 5;
    }

    // TransactionEventRequest 订阅交易请求
    message TransactionEventRequest {
        string bcname = 1;
        string initiator = 2;
        string auth_require = 3;
        bool need_content = 4;
    }

    // AccountEventRequest 订阅账户请求
    message AccountEventRequest {
        string bcname = 1;
        string from_addr = 2;
        string to_addr = 3;
        bool need_content = 4;
    }

订阅返回的内容格式均为Event，对应不同的订阅类型填充不同的StatusInfo字段，详细内容会放在payload里

.. code-block:: protobuf
    :linenos:

    message Event {
        string id = 1;
        EventType type = 2;
        bytes payload = 3;
        BlockStatusInfo block_status = 4;
        TransactionStatusInfo tx_status = 5;
        AccountStatusInfo account_status = 6;
    }

订阅区块时，填充BlockEventRequest的链名、矿工地址、起止高度、以及是否需要详细内容字段。在订阅高度内，每当此矿工打包出块，便会接收到区块的内容

.. code-block:: protobuf
    :linenos:

    message BlockStatusInfo {
        string bcname = 1;
        string proposer = 2;
        int64 height = 3;
        BlockStatus status = 4;
    }

订阅交易时，可填充TransactionEventRequest的链名、发起方、签名方、以及是否需要详细内容字段，订阅开始后，由指定的账号发起或者有指定账号签名（注意两个条件是逻辑或的关系），便会收到交易内容

.. code-block:: protobuf
    :linenos:

    message TransactionStatusInfo {
        string bcname = 1;
        string initiator = 2;
        repeated string auth_require = 3;
        TransactionStatus status = 4;
    }

订阅账号时，可填充AccountEventRequest的链名、来源方、接收方、以及是否需要详细内容字段，订阅开始后，来源指定账号或者由指定账号接收的（注意两个条件是逻辑或的关系）交易内容均可以收到

.. code-block:: protobuf
    :linenos:

    message AccountStatusInfo {
        string bcname = 1;
        repeated string from_addr = 2;
        repeated string to_addr = 3;
        TransactionStatus status = 4;
    }

三种模式成功订阅后，都可以收到一个全局唯一的订阅id，使用这个id可以构造请求取消此订阅

.. code-block:: protobuf
    :linenos:

    // UnsubscribeRequest 取消事件订阅请求
    message UnsubscribeRequest {
        string id = 1;
    }

当然，进行订阅的进程退出或被杀死，订阅行为也会停止

使用事件订阅
------------

我们在xchain的代码中实现了一个简单的例子，参考 xuperchain/xuperchain/core/test/pubsub 目录，里面有一个示例程序和不同类别订阅需要的参数json文件

正常编译xchain即可获得此demo的可执行文件 event_client，按如下命令执行即可

.. code-block:: bash
    :linenos:

    ./event_client -c subscribe -f accountEventSubscribe.json -h localhost:37101
    ./event_client -c unsubscribe -id xxxxxxxxxxxxxxxxxxx

示例程序中调用的便是上一小节介绍的订阅rpc接口