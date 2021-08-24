
智能合约
=============

XVM WASM 虚拟机
---------------
XVM 是 XuperChain 自研的 WebAssembly(简称WASM) 虚拟机， AOT(Ahead Of Time) 虚拟机，用于支持 WASM 合约的执行。其基本思路是将每一个 WASM 模块编译成一个动态链接库，每一个 export 方法通过编译成动态链接库里的一个全局符号, xchain 通过 CGO 进行调用。
XVM 主要包括 XVM 运行时，编译工具 XDEV，标准库

基本概念
>>>>>>>>

* WebAssembly

    `WebAssembly <https://webassembly.org/>`_  起源于高性能的 Web 执行技术，后续作为一种通用的编译 `目标代码 <https://zh.wikipedia.org/wiki/%E7%9B%AE%E6%A0%87%E4%BB%A3%E7%A0%81>`_ 

    WebAssembly 执行模式主要包括 `解释执行 <https://zh.wikipedia.org/wiki/%E7%9B%B4%E8%AD%AF%E5%99%A8>`_ , `即时编译 (Just In time, abbr JIT) <https://zh.wikipedia.org/wiki/%E5%8D%B3%E6%99%82%E7%B7%A8%E8%AD%AF>`_ , 提前编译 Ahead Of Time(AOT) 三种执行模式。

* 动态链接

    `动态链接 <https://zh.wikipedia.org/wiki/%E5%8A%A8%E6%80%81%E8%BF%9E%E6%8E%A5%E5%99%A8>`_ 是 linux 等现代操作系统支持运行时符号重定位机制，将符号解析从链接时推迟到运行时。
    通过动态链接机制，可以实现不同应用程序共享链接库、降低可执行文件大小等功能，也可以通过动态链接库实现插件，热更新等功能。
    `POSIX API <https://zh.wikipedia.org/wiki/%E5%8F%AF%E7%A7%BB%E6%A4%8D%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E6%8E%A5%E5%8F%A3>`_ 中提供的动态链接相关的函数包括

    * dlopen: 打开一个动态链接库
    * dlsym: 从动态链接库中查找符号的地址
    * dlclose: 关闭一个动态链接库
    * dlerror: 获取动态链接库中符号的地址

* MMAP 
    Linux 将进程地址空间进行了划分成文本段(Text), 已初始化的数据段(Data), 未初始化的数据(BSS)，堆(Heap)，内存映射(MMAP),栈(Stack) 等区域。通过 `MMAP <https://zh.wikipedia.org/wiki/%E5%86%85%E5%AD%98%E6%98%A0%E5%B0%84>`_ 匿名映射可以为进程分配大块的虚拟内存。与 `brk 系统调用 <https://man7.org/linux/man-pages/man2/brk.2.html>`_ 相比, MMAP 在处理大块内存时有更高的内存利用效率。

* CGO 
    `CGO <https://go.dev/blog/cgo>`_ 是 GO 官方提供的一种在 GO 语言和 C/C++ 中互相调用的机制。

XVM 编译流程
>>>>>>>>
    WebAssembly 作为一种中间表示，本身无法在处理器上执行。为了能够执行WebAssembly，需要有另一个程序将WebAssembly 转化为本地二进制码。通常有解释执行，JIT (预编译)执行和AOT(预编译)执行三种执行模式。
    
    解释执行模式是一边读区WebAssembly 字节码。通常，在解释执行模式下，解释器需要为不同的模块存储运行时数据等等。在解释执行模式下，解释器每次读取一条或多条 WASM 指令，并修改对应的运行时数据。

    JIT(Just In Time)执行模式是针对解释执行模式的性能优化，将频繁执行的指令提前编译成本地机器码，首次执行时会比较慢，随着时间推移，热点代码被编译成本地机器码之后性能获得大幅提升。

    AOT(Ahead of Time) 执行模式则是提前讲所有WASM 字节码编译成本地指令，执行的时候没有编译过程，因此性能最高。AOT 模式启动时需要进行字节码编译，因此启动速度慢。此外，AOT 编译由于不能利用运行时信息，因此特殊条件性性能可能不如 JIT 模式。

    XuperChain 采用 AOT 模式，将每一个 WASM 模块编译成一个动态链接库供 XVM 调用。

    完整加载流程如图所示

    .. figure:: /images/xvm_compile.png
        :alt: XVM编译加载流程
        :align: center
        :width: 600px
        
        XVM编译加载流程
        
    C++ 合约的编译流程为: CPP -> WASM -> C -> 动态链接库

    GO 合约的编译流程为: GO-> WASM-> C -> 动态链接库

    其中动态链接库的格式随 XVM 环境的不同而不同， 在Linux 上是 ELF 格式的可执行文件，在 Mac 上是一个 MAC-O 格式的可执行文件。


XVM 运行时
>>>>>>>>>>

    WASM 模块被编译成动态链接库之后还不能直接执行，XVM 运行时提供了 WASM 模块执行的入口，负责编译成动态链接库的 WASM 模块与操作系统之间的交互。从功能上来看， XVM 运行时主要包括运行时数据结构与运行时行为。运行时数据结构为动态链接库的装载，外部函数的调用等提供数据结构支持，运行时行为则包括运行时内存管理，运行时异常，执行栈等

    * 运行时数据结构

     XVM 相关的核心数据结构主要包括 xvm_resolver_t，xvm_code_t，和 xvm_context_t

        * xvm_resolver_t 主要负责全局符号的解析，函数的解析，跨合约调用等功能，
        * xvm_code_t 代表一个 wasm 模块，其声明如下所示
        * xvm_context_t 代表一次具体的调用

    * 运行时行为
    
        XVM 运行时行为遵循 wasm-rt.h 的约束，主要包括 
            * wasm_rt_trap 
            * wasm_rt_register_func_type
            * wasm_rt_allocate_memory
            * wasm_rt_grow_memory
            * wasm_rt_allocate_table
            * wasm_rt_call_stack_depth

        后续章节会对运行时行为有详细的描述

XVM 内存管理
>>>>>>>>>>>>
    
    在 WASM 中，内存采用按页分配的方式，每页大小为 65535K，一个 WASM 模块最多允许 65535 页，总的内存大小为 4G。WASM 将 4G 的内存空间划分为保留段，静态数据段，栈段，堆段四个不同的区域。

    XVM 内存分配可以分为两个部分，页内存和非页内存。页内存和 WASM 模块的内存，主要用于初始化 WASM 模块的表，初始化外部函数，初始化全局变量，WASM 运行时栈等等。 

    针对页内存，XVM 按照 WASM 的标准进行内存的申请和分配，64K 为一页，按页进行内存分配。在每个 WASM 模块加载时，XVM 默认分配一个页面的内存。 针对大块内存，采用 MMAP 匿名页进行内存分配。WASM 中的每个内存页对应于XVM 进程 MMAP 区的一个匿名内存映射。采用匿名页映射的优势在于能够模块卸载的时候能够比较方便进行页面回收，降低 XVM 进程的内存占用。
    
    非页内存主要用于 WASM 模块的初始化，WASM 函数调用等等。由这些内存较小，需要频繁进行分配和释放，对这些内存，采用 calloc(sbrk) 从 XVM 进程的堆空间分配内存。

    需要注意的是，XVM 当前不支持内存增长，智能在模块初始化的时候进行所需的页内存的分配。

    
C 指令和 WASM 指令映射
>>>>>>>>>>>>>>>>>>>>>>

TBD 

WASM 外部函数
>>>>>>>>>>>>>

 TBD

XVM 计费和机制
>>>>>>>>>>>>
    和 wasmtime， wasmer 等通用 WebAssembly 运行时略有差异, XVM 主要用于智能合约的执行，需要满足可停止，可计费等特性。解释执行模式下，每一条指令的执行都可以被 WASM 运行时提前拦截，运行时只需要在每次执行指令前统计对应的指令的GAS 消耗即可。为了在 AOT 模式下实现以可停止性和可计费等特性，XVM 采用代码注入的方式的方式实现资源与计费机制。

    在 XVM 编译加载的第二阶段(WASM -> C），XVM 采用 `WABT <https://github.com/webassembly/wabt>`_ 完成从 WASM 到 C 的转换。XVM 使用的 WABT 为定制版本，在完成基本的分析和转换之后，WABT 会在每个基本块的第一条指令前插入一条 GAS 消耗检查的指令，判断当前基本块执行完成后是否会超出 GAS 限制，如果执行完成会超出限制，则跑抛出异常。异常会被 XVM 运行时捕获并返回给上层调用方，由调用方来决定GAS 超出限制后的处理方式。需要注意的是，XVM 的 GAS 消耗检查指令是在实际执行之前进行的。

    XVM 的 GAS 限制是调用粒度的，每次函数调用的时候会设置此次函数调用的最大 GAS 限制，此次调用失败只会影响到这次调用

XVM 异常
>>>>>>>>

XVM 提供异常机制用于进行

XVM 语言运行时
>>>>>>>>>>>>>>
XVM 提供了XXX，不同语言需要进行适配。
当前 XVM 对GO 语言 和 C/C++ 语言提供了支持
1. C 语言
C 语言没有运行时，针对 C 语言的运行时支持主要是对内存区域的划分，具体划分方式为
TODO 补充地址范围
A-B: 保留数据区
B-C: 静态数据区
C-D: 栈区
D-E: 堆区

2. GO 语言
XVM 对 GO 语言的支持作为一个实验特性提供，尝试在 XVM 中对带运行时语言进行支持。XVM 通过 import 函数的方式，提供GO语言的运行时。
以 go1.13 为例，GO 的WASM 运行时主要包括
    1. 时钟和定时器
    2. 系统调用
    3. 调度器
    4. 
3. WASI 支持


XVM 和宿主进程的交互
>>>>>>>>>>>>>>>>>> 
XVM 作为一个嵌入式虚拟机，以二进制的方式链接到宿主进程中

TODO：补充链接
XuperChain 通过 XXXX，Code 代表， Context 代表一次具体的合约调用，合约代码只需要关注无状态的合约执行即可

XVM 抽象 XVM 和 xchain 交互主要包括 code，context，call
1. resolver 
TODO： 补充描述
WebAssembly  XXX
Resolver 为 WASM 合约提供了访问宿主功能的能力，主要包括 xvm_resolve_global，xvm_resolve_func，xvm_call_func 
1. xvm_new_code/xvm_init_code 
xvm_new_code 和 xvm_init_code 实现了 code 管理，code 是

2. xvm_new_contex/xvm_init_context
xvm_new_context 和 xvm_init_context 实现了 context 的初始化, 

3. xvm_call
xvm_call 

4. xvm 

5. 指针管理

XVM 性能
>>>>>>>>
XVM 从设计到实现上都十分关注运行时性能，这里针对一些性能方面的优化进行描述。
1. AOT 支持
2. 编译优化
当前广泛使用的编译器为 GCC 和 CLANG，两者都提供丰富的选项用于控制编译期行为
在 XuperChain 中,XVM 通过代码注入的方式实现了 GAS 计费机制，
3. 缓存机制
4. 内存对齐
5. 消息序列化

XVM 模块安全
>>>>>>>>>>>>
XVM 在安全方面主要包括
1. 模块对宿主机的安全: 模块无法访问宿主上的敏感资源，内存访问等收到宿主的严格限制
2. 模块之间的安全性：不同模块之间的安全性需要
内存安全
资源隔离

XVM 工具链
XVM 工具链主要包括构建工具 xdev 和 合约 SDK
XVM 工具链主要包括 emcc, wasm2c, cc，xdev等，其中 emcc 实现将 C 语言合约编译成WebAssembly(在 GO 语言的 WASM 合约中由 GO 的编译器将 go 合约编译成WASM 模块)， wasm2c 实现将 WebAssembly 模块编译成 C 源代码(.c)和头文件(.h)，CC 工具将源代码和头文件编译成本地的动态链接库。

在 CC 的选择上，XVM 没有单独的编译工具链，而是直接采用宿主工具支持。选择宿主工具的优势在于
1. 可移植性
2. 技术优势

在 wasm2c 中，XVM 提供了对wabt 中的
1. 使用 XVM 自带的 wasm 工具，针对智能合约场景优化，支持 GAS 机制, 
2. 使用用户自定义的 wasm2c 工具，不提供 GAS 支持，作为通用的 WebAssembly 运行时



XuperBridge 桥接层
------------------
XuperBridge 桥接层实现了 XXX



合约执行沙盒
>>>>>>>>>>>>

1. KV接口与读写集
>>>>>>>>>>>>>>
合约每次执行的产出为一系列KV操作的读写集，读写集的概念详细见 :doc:`XuperModel <./XuperModel>`。

KV的接口：

- GetObject(key)
- PutObject(key, value)
- DeleteObject(key)
- NewIterator(start, limit)

各个接口对读写集的影响：

- Get会生成一个读请求
- Put会产生一个读加一个写
- Delete会产生一个读加一个特殊的写（TODO）
- Iterator会对迭代的key产生读

效果：

- 读请求不会读到最新的其他tx带来的变更
- 读请求会读到最新的自己的写请求（包括删除）的变更
- 写请求在提交前不会被其他合约读到
- 新写入的会被迭代器读到



内核调用设计
>>>>>>>>>>>>

XuperBridge为所有合约提供统一的合约接口，从抽象方式上类似于linux内核对应于应用程序，内核代码是一份，应用程序可以用各种语言实现，比如go,c。类比到合约上就是各种合约的功能，如KV访问，QueryBlock, QueryTx等，这些请求都会通过跟xchain通信的方式来执行，这样在其上实现的各种合约虚拟机只需要做纯粹的无状态合约代码执行。

.. figure:: ../images/contract.png
    :alt: XuperBridge
    :align: center
    :width: 300px
    
    XuperBridge

合约与xchain进程的双向通信
>>>>>>>>>>>>>>>>>>>>>>>>>>

xchain进程需要调用合约虚拟机来执行具体的合约代码，合约虚拟机也需要跟xchain进程通信来进行具体的系统调用，如KV获取等，这是一个双向通信的过程。

.. figure:: ../images/contract-com.png
    :alt: 合约双向通信
    :align: center
    :width: 300px
    
    合约双向通信

这种双向通信在不同虚拟机里面有不同的实现，

- 在native合约里面由于合约是跑在docker容器里面的独立进程，因此牵扯到跨进程通信，这里选用了unix socket作为跨进程通信的传输层，xchain在启动合约进程的时候把syscall的socket地址以及合约进程的socket地址传递给合约进程，合约进程一方面监听在unix socket上等待xchain调用自己运行合约代码，另一方面通过xchain的unix socket创建一个指向xchain syscall服务的grpc客户端来进行系统调用。

.. figure:: ../images/contract-socket.png
    :alt: 合约socket
    :align: center
    :width: 400px
    
    合约socket

- 在WASM虚拟机里面情况有所不同，WASM虚拟机是以library的方式链接到xchain二进制里面，所以虚拟机和xchain在一个进程空间，通信是在xchain和WASM虚拟机之间进行的，这里牵扯到xchain的数据跟虚拟机里面数据的交换，在实现上是通过WASM自己的模块机制实现的，xchain实现了一个虚拟的WASM模块，合约代码执行到外部模块调用的时候就转到对应的xchain函数调用，由于xchain和合约代码的地址空间不一样，还是牵扯到序列化和反序列化的动作。

.. figure:: ../images/contract-wasm.png
    :alt: WASM合约
    :align: center
    :width: 500px
    
    WASM合约

PB接口
>>>>>>

合约暴露的代码接口

.. code-block:: protobuf
    :linenos:

    service NativeCode {
        rpc Call(CallRequest) returns (CallResponse);
    }

xchain暴露的syscall接口

.. code-block:: protobuf
    :linenos:

    service Syscall {
        // KV service
        rpc PutObject(PutRequest) returns (PutResponse);
        rpc GetObject(GetRequest) returns (GetResponse);
        rpc DeleteObject(DeleteRequest) returns (DeleteResponse);
        rpc NewIterator(IteratorRequest) returns (IteratorResponse);

        // Chain service
        rpc QueryTx(QueryTxRequest) returns (QueryTxResponse);
        rpc QueryBlock(QueryBlockRequest) returns (QueryBlockResponse);
        rpc Transfer(TransferRequest) returns (TransferResponse);
    }



合约执行上下文
>>>>>>>>>>

每次合约运行都会有一个伴随合约执行的上下文(context)对象，context里面保存了合约的kv cache对象，运行参数，输出结果等，context用于隔离多个合约的执行，也便于合约的并发执行。

1. Context的创建和销毁

context在合约虚拟机每次执行合约的时候创建。
每个context都有一个context id，这个id由合约虚拟机维护，在xchain启动的时候置0，每次创建一个context对象加1，合约虚拟机保存了context id到context对象的映射。
context id会传递给合约虚拟机，在Docker里面即是合约进程，在之后的合约发起KV调用过程中需要带上这个context id来标识本次合约调用以找到对应的context对象。

context的销毁时机比较重要，因为我们还需要从context对象里面获取合约执行过程中的Response以及读写集，因此有两种解决方案，一种是由调用合约的地方管理，这个是xuper3里面做的，一种是统一销毁，这个是目前的做法，在打包成块结束调用Finalize的时候统一销毁所有在这个块里面的合约context对象。

2. 合约上下文的操作

- NewContext，创建一个context，需要合约的参数等信息。
- Invoke，运行一个context，这一步是执行合约的过程，合约执行的结果会存储在context里面。
- Release，销毁 context，context持有的所有资源得到释放。

原生合约支持
>>>>>>>>>>>>>>

EVM 合约支持
>>>>>>>>>>>

WASM 合约支持
>>>>>>>>>>>>>

语言/合约兼容矩阵
>>>>>>>>>>>>>>>>>>

语言合约功能
>>>>>>>>>>>>
 TODO： 放到合约 SDK 部分介绍


WebAssembly(简称WASM) 提供了一种高性能可停止的执行沙盒技术，在性能方面提供和本地执行性能相当的执行环境；在可停止性方面，可以为WASM 合约提供资源quota，超出资源quota 后的WASM 执行会被自动终止；在安全性方面，WASM合约提供内存安全，宿主访问安全等机制，WASM 合约和宿主环境互相隔离，不同 WASM 模块也互相隔离，一个WASM 模块的异常既然不会引起宿主的异常，也不会引起其他模块的异常。
WebAssembly 运行时规范规定了WebAssembly 需要支持的内容，主要包括运行时数据结构与运行时行为。在运行时数据结构方面主要包括运行时表结构，运行时函数等，在运行时行为方面主要包括内存管理，异常处理等。
XVM 是XuperChain 针对智能合约场景设计的一款 高性能WebAssembly 虚拟机。考虑到在智能合约中，通常一个合约通常被部署一次，之后会有多次调用。在智能合约中，运行时性能的重要性要远远高于启动时性能，因此XVM 选择采用 AOT 预编译模式进行。在XVM 预编译模型中，每个模块被编译成一个本地动态链接库文件。在Linux 上是一个ELF 格式的动态连接库so 文件，在MACOS 上是一个MAC-O 格式的.dylib文件。在将WebAssembly 编译成本地执行文件方面，主要有编译成C，编译成LLVM IR, 编译成其他表示方式三种方案。在具体的实现上，，XVM 选择了方案1，先编译成C语言，再通过宿主机器上的工具链编译成本地动态链接库。选择编译成C 语言，再编译成本地代码的一个优势是可以做到和底层平台无关。XuperChain 默认X86_64 环境进行开发和适配将WebAssembly 首先编译成C 文件，由于C 文件是平台无关的，如果希望在新的平台上使用 XVM ，只需要首先安装本地编译工具链，使用使用本地的默认工具链进行编译即可。使用C 语言作为中间表示的另一个优势是C 语言作为文本文件，可以方便地进行处理，增加自己需要的功能。与其他WebAssembly 不同，XVM 主要用途是在区块链系统中。和传统程序相比，智能合约的执行必须满足可以停性，即可以给合约设置资源配额，超出配额后自动停止合约的执行。为了实现可停止性，XVM 为WebAssembly 增加了gas 机制，在作为中间表示的C 语言中插入 gas 统计指令，当资源消耗超出gas 限制时则自动取消此次之行。出于性能考虑，XVM 并没有在条之后之后均插入gas 指令，而是通过控制流分析，在基本块后插入统计指令。


extern void wasm_rt_trap(wasm_rt_trap_t) __attribute__((noreturn));
extern uint32_t wasm_rt_register_func_type(uint32_t params, uint32_t results, ...);
extern void wasm_rt_allocate_memory(wasm_rt_memory_t*, uint32_t initial_pages, uint32_t max_pages);
extern uint32_t wasm_rt_grow_memory(wasm_rt_memory_t*, uint32_t pages);
extern void wasm_rt_allocate_table(wasm_rt_table_t*, uint32_t elements, uint32_t max_elements);
extern uint32_t wasm_rt_call_stack_depth;