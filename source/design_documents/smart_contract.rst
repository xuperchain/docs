
智能合约
=============
XuperChain 通过 XuperBridge 实现了合约与虚拟机的解耦，由 XuperBridge 统一进行合约上下文的管理，虚拟机只需要关注无状态的合约执行，从而实现一体化的智能合约引擎。

当前在编程语言方面支持 C++、JAVA、Go、Solidity。在运行时方面支持 Native 合约、WASM 合约和 EVM 合约。

语言和运行时之间的关系如下表所示。

.. list-table:: 语言虚拟机兼容矩阵
   :widths: 25 25 25 25 
   :header-rows: 1

   * - 语言
     - Native
     - WASM 
     - EVM 
   * - GO 
     - 支持
     - 实验性支持
     - 不支持
   * - C++
     - 不支持
     - 支持
     - 不支持
   * - JAVA
     - 支持
     - 不支持
     - 不支持
   * - Solidity
     - 不支持
     - 不支持
     - 支持


XuperBridge 桥接层
------------------
XuperBridge 桥接层实现合约和虚拟机的解耦，桥接层主要负责虚拟机的管理、合约上下文管理、合约执行沙盒和合约代码管理等。

智能合约虚拟机
>>>>>>>>>>>>>>
XuperChain 对虚拟机接口提供统一的抽象，使得虚拟机可以作为一个通用的组件。任何实现了虚拟机的接口约束的组件，均可以作为一个合约执行的虚拟机。

XuperChain 对虚拟机的约束由于 InstaneCreator 接口表示

    .. code-block:: go

        type InstanceCreator interface {
            CreateInstance(ctx *Context, cp ContractCodeProvider) (Instance, error)
            RemoveCache(name string)
        }
InstanceCreator 主要有两个接口约束
    * CreateInstance：创建一个虚拟机实例，用于执行一次合约调用
    * RemoveCache：清除有关缓存，释放资源

每个 Instance 则负责一次具体的合约执行。Instance 的接口约束为

    .. code-block:: go

        type Instance interface {
            Exec() error
            ResourceUsed() contract.Limits
            Release()
            Abort(msg string)
        }

Instance 主要有两个资源消耗

    * Exec：执行合约调用
    * ResourceUsed：获取本次合约调用的资源消耗
    * Release：合约执行完毕，释放有关资源
    * Abort：合约执行异常，中止执行

当前 XuperChain 共提供四种类型的虚拟机实现

    * KernelInstance：用于 Kernel 合约的执行
    * EVMInstance： 用于 EVM 合约的执行
    * XVMInstance： 用于 WASM 合约的执行
    * NativeInstance： 用于Native 合约的执行

XuperBridge 提供了虚拟机的注册机制，虚拟机实现只需要调用如下代码即可完成虚拟机的注册

    .. code-block:: protobuf

	    bridge.Register(contractType, Name, driver)
为同一种合约类型注册不同的虚拟机也是允许的。

合约上下文管理
>>>>>>>>>>>>>>

XuperBridge 负责管理合约上下文。

每次合约运行都会有一个伴随合约执行的上下文(context)对象，context里面保存了合约的运行参数，执行沙盒，输出结果，事件，日志等。context用于隔离多个合约的执行，也便于合约的并发执行。所有合约执行的状态信息由 XuperBridge 管理，虚拟机只需要关注无状态的合约执行。

合约执行的所有状态信息由 XuperBridge 的上下文管理器(ContextManager) 统一管理。ContextManager 的主要功能包括：

    * 维护全局递增的 ContextID 
    * 按需要进行 Context 的创建和销毁
    * 保存所有合约调用的状态
    * 根据 ContextID 返回上下文有关信息

1. Context 的创建和销毁

    context在合约虚拟机每次执行合约的时候创建。每个context都有一个context id，这个id由 ContextManager 维护，在xchain启动的时候置0，每次创建一个context对象加1，ContextManager 保存了context id到context对象的映射。

    context id会传递给合约虚拟机，在之后的合约发起系统调用过程中需要带上这个context id来标识本次合约调用以找到对应的context对象。

    context的销毁时机比较重要，因为我们还需要从context对象里面获取合约执行过程中的Response以及读写集，因此有两种解决方案，一种是由调用合约的地方管理，这个是xuper3里面做的。一种是统一销毁，这个是目前的做法，在打包成块结束调用Finalize的时候统一销毁所有在这个块里面的合约context对象。

2. 合约上下文的操作

    合约上下文主要包括以下三个操作：

    *  NewContext，创建一个context，需要合约的参数等信息。
    * Invoke，运行一个context，这一步是执行合约的过程，合约执行的结果会存储在context里面。
    * Release，销毁 context，context持有的所有资源得到释放。

4. 合约上下文信息的传递

    合约虚拟机和 XuperBridge 通过系统调用进行通信获取合约状态的通信与传递，通过全局唯一的ContextID 标示需要获取的 Context对象，相关的系统调用具体包括：

        * GetCallArgs：获取上下文参数
        * SetOutput：上下文执行结果
        * PostLog： 输出上下文执行日志
        * EmitEvent：输出上下文事件

    合约 SDK 对上下文管理的有关系统调用进行了封装，合约开发者在合约开发过程中只需要调用本地方法即可完成状态信息的获取和传递。


合约执行沙盒
>>>>>>>>>>>>
XuperBridge 采用两阶段提交技术，预执行阶段生成合约的读写集，提交阶段对带读写集的交易进行签名和提交。节点收到完整交易后进行交易验证，验证通过后将有关数据写入到状态数据库中。

XuperBridge 通过合约执行沙盒（Sandbox）生成读写集，主要包括：

    * XMState：合约 KV 数据的读写集
    * UTXOState： 合约 UTXO 的读写集
    * CrossQuerryState：跨链调用的读写集
    * ContractEventState：合约事件相关的读写集 

1. KV 数据读写集

合约 KV 数据的读写集需要实现事务隔离，具体包括：

    - 读请求不会读到最新的其他事务带来的变更
    - 读请求会读到最新的自己的写请求（包括删除）的变更
    - 写请求在提交前不会被其他合约读到
    - 新写入的会被迭代器读到


为实现以上目标，每次在交易预执行阶段生成一个空白执行沙盒，交易执行过程中记录有关数据的读写情况，各个接口对读写集的影响如下：

    - Get会生成一个读请求
    - Put会产生一个读加一个写
    - Delete会产生一个读加一个特殊的写（TODO）
    - Iterator会对迭代的key产生读

    在 Get 请求中，如果访问的值已在读集中存在，则直接返回，如果不存在，则从账本中进行读取。

    交易验证阶段与预执行阶段相似，区别在于如果访问的值在读集中不存在，则表明读集不相等，交易验证失败。

系统调用设计
>>>>>>>>>>>>

    XuperBridge为所有合约提供统一的合约接口，从抽象方式上类似于linux内核对应于应用程序，内核代码是一份，应用程序可以用各种语言实现，比如 Go，C。
    类比到合约上就是各种合约的功能，如KV访问，QueryBlock，QueryTx等，这些请求都会通过跟xchain通信的方式来执行，这样在其上实现的各种合约虚拟机只需要做纯粹的无状态合约代码执行。

    .. figure:: /images/contract.png
        :alt: XuperBridge
        :align: center
        :width: 300px
        
        XuperBridge

1.合约与 xchain 的通信机制

    xchain进程需要调用合约虚拟机来执行具体的合约代码，合约虚拟机也需要跟xchain进程通信来进行具体的系统调用，这是一个双向通信的过程。这种双向通信在不同虚拟机里面有不同的实现。

    - 在native合约里面由于合约是跑在独立进程，采用跨进程通信的方式进行。这里选用了基于 TCP 作为跨进程通信的传输层，xchain 在启动合约进程的时候把 syscall 的地址以及合约进程的地址传递给合约进程。合约进程一方面监听在 socket 上等待xchain调用自己运行合约代码，另一方面通过 xchain 的 socket 创建一个指向xchain syscall服务的 grpc 客户端来进行系统调用。

    .. figure:: /images/contract-socket.png
        :alt: 合约socket
        :align: center
        :width: 400px
        
        合约 socket

    - 在WASM虚拟机里面情况有所不同，WASM 虚拟机是以 library 的方式链接到 xchain 二进制里面，所以虚拟机和xchain在一个进程空间，通信是在 xchain 和 WASM虚拟机之间进行的，这里牵扯到xchain的数据跟虚拟机里面数据的交换，在实现上是通过WASM自己的模块机制实现的，xchain实现了一个虚拟的WASM模块，合约代码执行到外部模块调用的时候就转到对应的xchain函数调用。:ref:`xvm_communitation` 对 WASM虚拟机与宿主的通信方式有更多的描述。

    - 在 EVM 合约中，合约解释器被嵌入到 xchain 二进制中，有关调用通过本地函数调用的方式执行。
    - 在 kernel 合约中，合约代码本身是 xchain 进程的一部分，有关系统调用通过本地函数调用的方式进行即可。

2. 数据传输协议
    无论是在 WASM 合约中还是在原生合约中，由于 xchain 和合约的地址空间不同，需要涉及到数据的序列化和反序列化。选择 ` protobuf <https://developers.google.com/protocol-buffershttps://developers.google.com/protocol-buffers>`_ 作为数据的序列化和反序列化协议。
    在 WASM 合约中，为了减少合约提及，降低运行时内存开销，选择 `lite-runtime <https://squidfunk.github.io/protobluff/guide/runtimes/#lite-runtime>` 进行数据的序列化和反序列化。 :ref:`toolchain` 中的 EMCC 内置了 protobuf 的 runtime，在链接时链接到 WASM 目标文件中。

3. 系统调用接口

    XuperChain 提供了通用的系统调用接口，所有服务由 SyscallService 提供，不同合约根据合约类型的不同采用grpc 或者 memrpc 的方式请求系统调用。
    
    按照系统调用的不同可以分为以下几类：
    
    * 数据访问：合约对状态数据的读写，主要包括 KV 访问和迭代器访问
    * 链上服务：合约查询链上数据，主要包括查询区块，查询交易，合约调用，合约内转账，跨链查询
    * 状态管理：和执行上下文交互，主要包括获取调用参数，调用日志，调用事件，返回调用结果
    * 其他：心跳信息，主要用于 native 合约

    完整的 SyscallService pb 声明如下。

.. code-block:: protobuf
    :linenos:

    service Syscall {
        // KV service
        rpc PutObject(xchain.contract.sdk.PutRequest) returns (xchain.contract.sdk.PutResponse);
        rpc GetObject(xchain.contract.sdk.GetRequest) returns (xchain.contract.sdk.GetResponse);
        rpc DeleteObject(xchain.contract.sdk.DeleteRequest) returns (xchain.contract.sdk.DeleteResponse);
        rpc NewIterator(xchain.contract.sdk.IteratorRequest) returns (xchain.contract.sdk.IteratorResponse);

        // Chain service
        rpc QueryTx(xchain.contract.sdk.QueryTxRequest) returns (xchain.contract.sdk.QueryTxResponse);
        rpc QueryBlock(xchain.contract.sdk.QueryBlockRequest) returns (xchain.contract.sdk.QueryBlockResponse);
        rpc Transfer(xchain.contract.sdk.TransferRequest) returns (xchain.contract.sdk.TransferResponse);
        rpc ContractCall(xchain.contract.sdk.ContractCallRequest) returns (xchain.contract.sdk.ContractCallResponse);
        rpc CrossContractQuery(xchain.contract.sdk.CrossContractQueryRequest) returns (xchain.contract.sdk.CrossContractQueryResponse);
        rpc GetAccountAddresses(xchain.contract.sdk.GetAccountAddressesRequest) returns (xchain.contract.sdk.GetAccountAddressesResponse);

        // Heartbeat
        rpc Ping(xchain.contract.sdk.PingRequest) returns (xchain.contract.sdk.PingResponse);

        // Post log
        rpc PostLog(xchain.contract.sdk.PostLogRequest) returns (xchain.contract.sdk.PostLogResponse);

        rpc GetCallArgs(xchain.contract.sdk.GetCallArgsRequest) returns (xchain.contract.sdk.CallArgs);
        rpc SetOutput(xchain.contract.sdk.SetOutputRequest) returns (xchain.contract.sdk.SetOutputResponse);

        // Send Event
        rpc EmitEvent(xchain.contract.sdk.EmitEventRequest) returns (xchain.contract.sdk.EmitEventResponse);
    }

4. xchain 对合约的调用
    
    在 XuperChain 中， 除了合约会通过系统调用接口请求 xchain 提供的各种服务外， xchain 也需要请求执行合约代码。xchain 对合约的调用随合约类型的不同而不同。

    在原生合约中，每个合约是一个进程，合约进程和 xchain 拥有不同的地址空间，甚至可能处于不同的 `namespace <https://en.wikipedia.org/wiki/Linux_namespaces>`_，合约进程在启动的时候会监听一个本地 TCP 端口，作为 grpc 服务端等待 xchain 进程发起的执行合约调用的请求。

    原生合约提供的GRPC 服务如下所示。

    .. code-block:: protobuf

        service NativeCode {
            rpc Call(xchain.contract.sdk.NativeCallRequest) returns (xchain.contract.sdk.NativeCallResponse);
            rpc Ping(xchain.contract.sdk.PingRequest) returns (xchain.contract.sdk.PingResponse);
            }

    在 WASM 合约中，虚拟机被嵌入到 xchain 二进制中，每个合约被编译成一个本地的动态链接库，合约方法是动态链接库中的导出函数，因此合约调用根据合约名和合约方法的名称，找到对应的合约方法的地址，通过 cgo 进行本地调用即可。

    在 EVM 合约中，合约采用解释执行的方式，合约虚拟机作为一个库，被嵌入到 xchain 二进制文件中，合约调用时只需要为解释器设置对应的参数，调用解释器编程库提供的方法即可。

    在 Kernel 合约中，Kernel 合约和 xchain 在同一个二进制中， 共享同一个地址空间。XuperChain 通过 Register 机制实现 Kernel 合约的注册，执行时只需要使用 Register的getKernelMethod 方法，找到对应的合约代码的地址进行本地调用即可。

WASM 合约支持
>>>>>>>>>>>>>
    XuperChain 通过 :ref:`xvm` 实现对 WASM 合约的支持。当前支持通过 C/C++ 语言来开发智能合约，也实验性质地支持通过 GO语言(<=1.13) 来开发智能合约。

    在 WASM 合约中，每个合约是一个被编译成一个 WASM 模块，xchain 为合约提供执行沙盒环境，不同合约之间互相隔离，合约访问的系统资源受到严格的控制。

    WASM 合约性能高，安全性好，支持 GAS 计费机制，适用于公链，也适用于联盟链等场景。

原生合约支持
>>>>>>>>>>>>>>
    XuperChain 也提供原生合约（也称 native 合约）支持，当前支持通过 GO/JAVA 来进行智能合约开发，也可以方便地拓展到其他语言。

    在原生合约中，每个合约是一个运行在本地或者容器中的进程，合约和 xchain 之间通过 GRPC 协议进行通讯。需要注意的是，原生合约不支持 GAS 机制，安全性略弱。可以使用容器技术对原生合约可以访问的资源做基本的限制。

    原生合约扩展性强，语言支持多，主要适用于联盟链场景。

EVM 合约支持
>>>>>>>>>>>
    XuperChain 提供了对 EVM 合约的支持，可以使用 solidity 语言进行智能合约开发，以太坊合约开发者可以方便的使用自己熟悉的语言。

    在 EVM 合约中，合约以解释执行的方式执行，合约解释器被嵌入到 xchain 二进制中。
    相比于 WASM 合约和 原生合约，以太坊合约在性能方面路弱，主要适用于已有业务迁移至xhcian 的场景。


 合约代码管理
 >>>>>>>>>>>>
 XuperBridge 负责合约代码的管理，合约代码管理由 ContractCodeProvider 提供，主要接口约束为：

    .. code-block:: go

        type ContractCodeProvider interface {
        GetContractCodeDesc(name string) (*protos.WasmCodeDesc, error)
        GetContractCode(name string) ([]byte, error)
        GetContractAbi(name string) ([]byte, error)
        }

    ContractCodeProvider 主要功能提供合约代码以及合约的ABI（针对 EVM 合约）
    合约部署时，合约代码从请求中获取代码，合约调用时从账本获取代码。 ContractCodeProvider 还维护了合约代码的缓存，当存在内存活着磁盘的缓存时，ContractCodeProvider 直接返回对应的代码缓存。
    
.. _xvm:

XVM WASM 虚拟机
---------------
    XVM 是 XuperChain 自研的 WebAssembly(简称WASM) 虚拟机， 采用AOT(Ahead Of Time) 模式执行，用于支持 WASM 合约的执行。其基本思路是将每一个 WASM 模块编译成一个动态链接库，每一个 export 方法通过编译成动态链接库里的一个全局符号， xchain 通过 CGO 进行调用。

    广义的 XVM 除了 XVM 运行时之外，还包括构建工具 XDEV，编译工具 EMCC，合约标准库 contract-sdk-cpp。

基本概念
>>>>>>>>

* WebAssembly

    `WebAssembly <https://webassembly.org/>`_  起源于高性能的 Web 执行技术，后续作为一种通用的编译 `目标代码 <https://zh.wikipedia.org/wiki/%E7%9B%AE%E6%A0%87%E4%BB%A3%E7%A0%81>`_ 得到浏览器外的支持，作为通用的沙盒执行技术，广泛应用于物联网，边缘计算，区块链等领域。

    WebAssembly 执行模式主要包括 `解释执行 <https://zh.wikipedia.org/wiki/%E7%9B%B4%E8%AD%AF%E5%99%A8>`_ ， `即时编译 (Just In time, abbr JIT) <https://zh.wikipedia.org/wiki/%E5%8D%B3%E6%99%82%E7%B7%A8%E8%AD%AF>`_ ，提前编译 Ahead Of Time(AOT) 三种执行模式。

* 动态链接

    `动态链接 <https://zh.wikipedia.org/wiki/%E5%8A%A8%E6%80%81%E8%BF%9E%E6%8E%A5%E5%99%A8>`_ 是 linux 等现代操作系统支持运行时符号重定位机制，将符号解析从链接时推迟到运行时。
    通过动态链接机制，可以实现不同应用程序共享链接库、降低可执行文件大小等功能，也可以通过动态链接库实现插件，热更新等功能。
    `POSIX API <https://zh.wikipedia.org/wiki/%E5%8F%AF%E7%A7%BB%E6%A4%8D%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E6%8E%A5%E5%8F%A3>`_ 中提供的动态链接相关的函数包括

    * dlopen: 打开一个动态链接库
    * dlsym: 从动态链接库中查找符号的地址
    * dlclose: 关闭一个动态链接库
    * dlerror: 获取动态链接库中符号的地址

* MMAP 
    Linux 将进程地址空间进行了划分成文本段(Text)，已初始化的数据段(Data)，未初始化的数据(BSS)，堆(Heap)，内存映射(MMAP)，栈(Stack) 等区域。通过 `MMAP <https://zh.wikipedia.org/wiki/%E5%86%85%E5%AD%98%E6%98%A0%E5%B0%84>`_ 匿名映射可以为进程分配大块的虚拟内存。与 `brk 系统调用 <https://man7.org/linux/man-pages/man2/brk.2.html>`_ 相比， MMAP 在处理大块内存时有更高的内存利用效率。


XVM 编译流程
>>>>>>>>
    WebAssembly 作为一种中间表示，本身无法在处理器上执行。为了能够执行WebAssembly，需要有另一个程序将 WebAssembly 转化为本地二进制码。通常有解释执行，JIT (即时编译)执行和AOT(预编译)执行三种执行模式。
    
    解释执行模式是一边读取 WebAssembly 字节码，一边执行有关指令。通常，在解释执行模式下，解释器需要为不同的模块存储运行时数据等等。在解释执行模式下，解释器每次读取一条或多条 WASM 指令，并修改对应的运行时数据。

    JIT(Just In Time)执行模式是针对解释执行模式的性能优化，将频繁执行的指令提前编译成本地机器码，首次执行时会比较慢，随着时间推移，热点代码被编译成本地机器码之后性能获得大幅提升。

    AOT(Ahead of Time) 执行模式则是提前将所有WASM 字节码编译成本地指令，执行的时候没有编译过程，因此性能通常最高。AOT 模式启动时需要进行字节码编译，因此启动速度慢。此外，AOT 编译由于不能利用运行时信息，因此特殊条件下性能可能不如 JIT 模式。

    XuperChain 采用 AOT 模式，将每一个 WASM 模块编译成一个动态链接库供 XVM 调用。

    完整编译加载流程如图所示。

    .. figure:: /images/xvm_compile.png
        :alt: XVM编译加载流程
        :align: center
        :width: 600px
        
        XVM编译加载流程
        
    针对C++ 合约，完整的编译加载流程为: CPP -> WASM -> C -> 动态链接库。

    针对GO 合约，完整的编译加载流程为: GO -> WASM-> C -> 动态链接库。

    其中动态链接库的格式随 XVM 环境的不同而不同， 在Linux 上是 ELF 格式的可执行文件，在 Mac 上是一个 MAC-O 格式的可执行文件。


XVM 运行时
>>>>>>>>>>

    WASM 模块被编译成动态链接库之后还不能直接执行，XVM 运行时提供了 WASM 模块执行的入口，负责编译成动态链接库的 WASM 模块与操作系统之间的交互。

    从功能上来看， XVM 运行时主要包括运行时数据结构与运行时行为。运行时数据结构为动态链接库的装载，外部函数的调用等提供数据结构支持，运行时行为则包括运行时内存管理，运行时异常，执行栈等

    * 运行时数据结构

     XVM 相关的核心数据结构主要包括 xvm_resolver_t，xvm_code_t，和 xvm_context_t

        * xvm_resolver_t 

            主要负责全局符号的解析，函数的解析，函数调用等功能，

        * xvm_code_t 

            xvm_code_t 代表一个 wasm 模块或者一个动态链接库，xvm_code_t 对象包含了如何解析外部函数，如何新建一个独立的执行环境(xvm_context_t)等必须的信息。

        * xvm_context_t

            xvm_context_t 代表一次隔离的 WASM 调用，拥有自己独立的内存页，栈空间，独立的表结构，GAS 限制等资源等。在 xvm_context_t 中保留了 module_handle 的指针，包含了初始化该 context 的 xvm_code_t 的所有导出符号的列表。xvm_context_t 中也保留了生成该 context 的 xvm_code_t 的指针。

    * 运行时行为

        运行时行为在 XVM 中定义，以回调用函数的形式提供，在初始化 xvm_context_t，执行导出函数等的时候被被动态链接库调用。

        XVM 运行时行为遵循 wasm-rt.h 的约束，主要包括 

            * wasm_rt_trap: 处理异常
            * wasm_rt_register_func_type：注册函数类型
            * wasm_rt_allocate_memory: 分配内存
            * wasm_rt_grow_memory: 内存增长
            * wasm_rt_allocate_table： 分配表
            * wasm_rt_call_stack_depth：获取栈深度

        后续章节会对运行时行为有详细的描述

XVM 内存管理
>>>>>>>>>>>>

    在 WASM 中，内存采用按页分配的方式，每页大小为 65535K，一个 WASM 模块最多允许 65535 页，总的内存大小为 4G。WASM 将 4G 的内存空间划分为保留段，静态数据段，栈段，堆段四个不同的区域。

    XVM 内存管理主要包括两部分，分别是 XVM 自身的内存以及为 WASM 模块分配的内存。为 XVM 分配的内存主要用于初始化 WASM 模块的表，初始化外部函数，初始化全局变量，WASM 运行时栈等等。 

    针对页内存，XVM 按照 WASM 的标准进行内存的申请和分配，64K 为一页，按页进行内存分配。在每个 WASM 模块加载时，XVM 默认分配一个页面的内存。 针对大块内存，采用 MMAP 匿名页进行内存分配。WASM 中的每个内存页对应于XVM 进程 MMAP 区的一个匿名内存映射。采用匿名页映射的优势在于能够模块卸载的时候能够比较方便进行页面回收，降低 XVM 进程的内存占用。
    
    除了 WASM 的内存外，WASM 模块的初始化，WASM 函数调用也需要动态地申请内存等等。由这些内存较小，需要频繁进行分配和释放，对这些内存，采用 calloc(sbrk) 从 XVM 进程的堆空间分配内存。

    需要注意的是，XVM 当前不支持内存增长，只能在模块初始化的时候进行所需的页内存的分配。

XVM 计费和机制
>>>>>>>>>>>>
    和 wasmtime， wasmer 等通用 WebAssembly 运行时略有差异，XVM 主要用于智能合约的执行，需要满足可停止，可计费等特性。解释执行模式下，每一条指令的执行都可以被 WASM 运行时提前拦截，运行时只需要在每次执行指令前统计对应的指令的 GAS 消耗即可。为了在 AOT 模式下实现以可停止性和可计费等特性，XVM 采用代码注入的方式的方式实现资源与计费机制。

    在 XVM 编译加载的第二阶段(WASM -> C），XVM 采用 `WABT <https://github.com/webassembly/wabt>`_ 完成从 WASM 到 C 的转换。XVM 使用的 WABT 为定制版本，在完成基本的分析和转换之后，WABT 会在每个 `基本块 <https://en.wikipedia.org/wiki/Basic_block>`_  的第一条指令前插入一条 GAS 消耗检查的指令，判断当前基本块执行完成后是否会超出 GAS 限制，如果执行完成会超出限制，则抛出异常。异常会被 XVM 运行时捕获并返回给上层调用方，由调用方来决定GAS 超出限制后的处理方式。需要注意的是，XVM 的 GAS 消耗检查指令是在实际执行之前进行的，不需要进行后续指令的执行即可确认是否超出限制。

    XVM 的 GAS 限制是调用粒度的，每次函数调用的时候会设置此次函数调用的最大 GAS 限制，此次调用失败只会影响到本次调用。

XVM 异常处理
>>>>>>>>

    XVM 提供异常机制用于支持运行时错误。系统初始化时自动设置 wasm_rt_trap，其中 wasm_rt_trap 是一个 GO 的函数。该函数主要是功能是做一些数据格式与数据类型的转换，如果发生异常则直接 panic。 在每次进行 CGO 调用的时候通过延迟执行(defer) 注册一个错误处理函数，捕获有关异常。

    XVM 异常主要分为两种类型，分别是 WASM 执行异常和外部函数异常。前者是 WASM 规范规定的的异常以及 GAS 异常，后者主要是执行一些外部函数过程中的异常。

    WASM 执行异常主要包括
        * WASM_RT_TRAP_OOB,          /** Out-of-bounds access in linear memory. */
        * WASM_RT_TRAP_INT_OVERFLOW, /** Integer overflow on divide or truncation. */
        * WASM_RT_TRAP_DIV_BY_ZERO,  /** Integer divide by zero. */
        * WASM_RT_TRAP_INVALID_CONVERSION, /** Conversion from NaN to integer. */
        * WASM_RT_TRAP_UNREACHABLE,        /** Unreachable instruction executed. */
        * WASM_RT_TRAP_CALL_INDIRECT,  /** Invalid call_indirect, for any reason. */
        * WASM_RT_TRAP_EXHAUSTION,     /** Call stack exhausted. */
        * WASM_RT_TRAP_GAS_EXHAUSTION, /** Gas exhaustion. */
        * WASM_RT_TRAP_INVALID_ARGUMENT, /** Invalid argument. */

    外部函数异常主要发生在 XVM 运行时执行外部函数时的异常，如 GO 的 runtime 初始化的时间的异常，WASM 的外部函数中使用未支持的功能等等。


XVM 语言运行时
>>>>>>>>>>>>>>

    当前 XVM 支持 GO 语言 和 C/C++ 语言。

    1. C/C++ 语言
    
        c++ 因为没有runtime，因此运行环境相对比较简单，只需要设置基础的堆栈分布以及一些系统函数还有emscripten的运行时函数即可。

        c++合约的内存分布

        .. figure:: /images/wasm-c++-memory.png
            :alt: c++合约的内存分布
            :align: center
            :width: 100px
            
            c++合约的内存分布

    2. GO 语言

        XVM 对 GO 语言的支持作为一个实验特性提供，尝试在 XVM 中对带运行时语言进行支持。GO语言的运行时以外部函数的方式提供。GO 的WASM 运行时主要包括

            * 时钟和定时器
            * GO 系统调用
            * 调度器相关
            * 其他运行时函数

        go运行环境
        ^^^^^^^^^^
        .. figure:: /images/gowasm.png
            :alt: go合约运行时结构
            :align: center
            :width: 400px
            
            GO 合约运行时结构


    3. WASI 支持

        `WASI <https://github.com/WebAssembly/WASI>`_ 提供了一套与引擎无关的非 Web 环境下的系统 API，给 WASM 引擎提供了通过系统引擎访问外部资源的能力。
        XVM 也提供了 WASI 的支持。

.. _xvm_communitation:

XVM 和 WASM 模块的通信
>>>>>>>>>>>>>>>>> 

    XVM 和 WASM 模块的交机制主要包括 XVM 向 WASM 模块传递数据以及 WASM 模块向 XVM 传递数据。
    
    在 XVM 向 WASM 模块的通信方面，主要依靠 xvm_call 函数完成，该函数接收 params, param_len 两个参数，XVM 在进行函数调用前设置这两个参数即可。
    
    在 WASM 模块向XVM的通信方面，主要依靠外部函数完成。由于 WASM  的内存是 XVM 宿主进程的页映射，XVM 可以访问 WASM 模块的内存。在进行少量数据传输时，可以直接通过外部函数的参数进行传递，在需要进行大量内容传递时，需要调用方和被调用方约定参数的序列化方式(如PB)，数据地址，数据的长度，并通过外部函数参数传递数据地址和数据长度即可。
    
    以 C++ 合约的系统调用为例，其的函数签名为

    .. code-block:: go

        func (s *syscallResolver) cCallMethodv2(
                ctx exec.Context,
                methodAddr, methodLen uint32,
                requestAddr, requestLen uint32,
                responseAddr, responseLen uint32,
                successAddr uint32,
                ) uint32

    各个参数含义如下

        * methodAddr 和 methodLen 指定了需要调用的方法的地址和长度，method 为 ASCII 字符串
        * requestAddr 和 requestLen 指定了请求的地址和长度，Request 为 PB 序列化的的 Request
        * responseAddr 和 responseLen 返回值的地址和长度，Response 为 PB 序列化的 Response
        * successAddr 为标志，表示调用是否成功
    
    当合约执行过程中需要进行系统调用时，首先分配返回值所需的内存空间，将请求序列化后放到指定的位置，然后发起系统调用(WASM 的外部函数调用)。

    XVM 执行到该函数时，首先获取该合约调用(一个已经初始化的 xvm_context_t)的完整内存，通过方法地址和方法长度获取系统调用的方法，通过请求地址和请求长度并进行反序列化，执行成功之后将返回值及返回值的长度序列化写入到对应的内存区域。

    外部调用结束，控制流程返回到 WASM 模块时，合约从对应的返回值地址获取返回值，并反序列化得到系统调用的结果。

.. _ toolchain:

XVM 工具链
>>>>>>>>>>

    XVM 作为一个智能合约设计的虚拟机，广义的 XVM 除了 XVM 运行时之外，还包括构建工具 XDEV，编译工具 EMCC，合约标准库 contract-sdk-cpp/contract-sdk-go 中和 XVM 交互的部分。为了能够运行将 C 编译成动态链接库，还需要在宿主节点上提供本地的 C++ 开发工具链。

    在本地 C/C++ 工具链的选择上，XVM 没有单独的编译工具链，而是直接采用宿主工具支持。选择宿主工具的优势在于可移植性和扩展性。在使用 XVM 的过程中，选择和平台架构适配的工具即可完成编译成该平台的动态链接库，如果本地开发工具支持交叉编译，那么也支持编译到不同的目标后端；同时，也可以根据自己的需求选择使用 CLANG 或者使用 GCC 进行编译，充分发挥不同工具的优势。

    在 wasm2c 的选择上，XVM 自带了一份经过定制的 wabt。可以使用 XVM 自带的 wasm 工具，针对智能合约场景优化，支持 GAS 机制，也可以使用用户自定义的 wasm2c 工具，不提供 GAS 支持，作为通用的 WebAssembly 运行时。
