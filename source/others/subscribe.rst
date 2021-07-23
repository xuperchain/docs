
使用事件订阅功能
================

在使用 XuperChain 的过程中，可能会遇到一些异步的情况：比如执行合约的时候，构造的交易是否合法我们可以实时获知，但具体什么时候真正的被节点打包上链就不一样了。当然还有其他类似的场景，针对这种问题，我们引入了事件订阅机制。

事件订阅的接口
--------------

订阅的接口十分简单，只有Subscribe一个

.. code-block:: protobuf
    :linenos:

    service EventService {
        rpc Subscribe (SubscribeRequest) returns (stream Event);
    }

其中订阅接口的SubscribeRequest格式如下：

.. code-block:: protobuf
    :linenos:

    message SubscribeRequest {
        SubscribeType type = 1;
        bytes filter = 2;
    }

    enum SubscribeType {
        // 区块事件，payload为BlockFilter
        BLOCK = 0;
    }

请求里的filter用来设置事件过滤参数，是一段序列化的proto对象，因为订阅不同内容需要的参数不尽相同

``BLOCK`` 事件的过滤参数如下：

.. code-block:: protobuf
    :linenos:

    message BlockFilter {
        string bcname = 1;
        BlockRange range = 2;
        bool exclude_tx = 3;
        bool exclude_tx_event = 4;
        string contract = 10;
        string event_name = 11;
        string initiator = 12;
        string auth_require = 13;
        string from_addr = 14;
        string to_addr = 15;
    }

    message BlockRange {
        string start = 1;
        string end = 2;
    }

其中各个字段的说明如下：

- ``bcname`` 链名，必填字段
- ``range`` 指定起始订阅位置和结束位置，如果没有指定则默认从当前最新区块开始，持续订阅。
- ``exclude_tx`` 是否去掉FilteredTransaction数据
- ``exclude_tx_event`` 是否去掉ContractEvent数据
- ``contract`` 匹配合约名字，为空的话匹配所有合约
- ``event_name`` 匹配合约事件名字，为空的话匹配所有合约事件name
- ``initiator`` 匹配交易发起者地址，为空的话匹配所有交易发起者
- ``auth_require`` 匹配交易的auth_require中的任何一个地址，为空匹配所有
- ``from_addr`` 匹配转账发起者地址，为空的话匹配所有转账发起者
- ``to_addr`` 匹配转账接受者地址，为空的匹配所有转账接受者

``BlockRange`` 字段意义：

- 如果 ``start_num`` 和 ``end_num`` 都为空，则表示从当前最新区块开始，持续订阅最新区块。
- 如果 ``start_num`` 为空， ``end_num`` 不为空，则表示从当前最新区块开始，订阅到指定区块，如果``end_num``小与当前区块则什么也不做。
- 如果 ``start_num`` 不为空， ``end_num`` 为空，则从 ``start_num`` 开始持续订阅。
- 如果 ``start_num`` 和 ``end_num`` 都不为空，按照指定区块范围订阅，左闭右开。

.. note::
    需要注意的是过滤字段都是正则表达式，如果需要全匹配名字为 ``counter`` 的合约，``contract`` 字段需要为 ``^counter$`` ，
    不能为 ``counter`` ，这么写会匹配到名为 ``counter1`` 的合约。

订阅返回的内容格式均为Event，事件的详细内容会放在payload里

.. code-block:: protobuf
    :linenos:

    message Event {
        bytes payload = 1;
    }

订阅 ``BLOCK`` 事件时，填充如下内容:

.. code-block:: protobuf
    :linenos:

    message ContractEvent {
        string contract = 1;
        string name = 2;
        bytes body = 3;
    }
    
    message FilteredTransaction {
        string txid = 1;
        repeated ContractEvent events = 2;
    }

    message FilteredBlock {
        string bcname = 1;
        string blockid = 2;
        int64 block_height = 3; 
        repeated FilteredTransaction txs = 4;
    }


当然，订阅RPC接口断开的时候，订阅行为也会停止

使用事件订阅
------------
使用前，请检查xchain的配置conf/xchain.yaml，确保有如下配置：

.. code-block:: yaml
    :linenos:

    # 事件订阅相关配置
    event:
        enable: true
        # 每个ip的最大订阅连接数，为0的话不限连接数
        addrMaxConn: 5


使用命令行订阅事件
>>>>>>>>>>>>>>>

``xchain-cli`` 的 ``watch`` 指令可以用来监听事件，命令行参数的说明如下：

- ``-f, --filter`` 过滤器字段，JSON格式的，字段解释见 ``message BlockFilter``
- ``--oneline``         是否将事件打印在一行，方便命令行解析
- ``--skip-empty-tx``   默认watch命令会打印所有的block，即使block里面没有交易，这么做是为了方面做断点记录，``--skip-empty-tx`` 参数可以不打印不包含交易的block

如下是一些例子

1. 订阅所有的新块

.. code-block:: bash
    :linenos:

    ./xchain-cli watch 

2. 订阅名字为 ``counter`` 的合约

.. code-block:: bash
    :linenos:

    ./xchain-cli watch -f '{"contract":"^counter$"}'

3. 订阅 ``counter`` 合约的 ``increase`` 合约事件

.. code-block:: bash
    :linenos:

    ./xchain-cli watch -f '{"contract":"^counter$", "event_name":"^increase$"}'

4. 订阅区块高度从100开始的事件（断点续传）

.. code-block:: bash
    :linenos:

    ./xchain-cli watch -f '{"range":{"start":"100"}}'

5. 订阅区块高度区间为[100, 200)的事件

.. code-block:: bash
    :linenos:

    ./xchain-cli watch -f '{"range":{"start":"100", "end":"200"}}'
