
智能合约
=============


XVM WASM 虚拟机
---

XVM 是 XuperChain 自研的 WebAssembly(简称WASM) 虚拟机， AOT(Ahead Of Time) 虚拟机，用于支持 WASM 合约的执行。其基本思路是将每一个 WASM 模块编译成一个动态链接库，每一个 export 方法通过编译成动态链接库里的一个全局符号, xchain 通过 CGO 进行调用。
XVM 主要包括 XVM 运行时，编译工具 XDEV，标准库

基本概念
>>>>>>>>

WebAssembly

WebAssembly 执行模式主要包括解释执行, Just In Time(JIT), Ahead Of Time(AOT) 三种执行模式。

动态链接
linux 等现代操作系统支持运行时重定位机制，将符号解析从链接时推迟到运行时。通过动态链接机制，可以实现XXXX
POSIX API 在动态链接方面主要由 dlfcn.h 文件提供，主要包括 dlopen dlsym dlclose dlerror

MMAP 
Linux 将进程地址空间进行了划分，主要包括

CGO 
GO 提供的一种 FFI

XVM 编译流程
>>>>>>>>
XVM 编译流程为
CPP -> WASM -> C-> 动态链接库
GO-> WASM-> C-> 动态链接库
其中动态链接库在 Linux 上是 ELF  格式的可执行文件，在 Mac 上是一个 MAC-O 格式的可执行文件。



XVM 运行时
>>>>>>>>>>

XVM 运行时主要包括运行时数据结构与运行时行为。运行数据提供XXX，运行时行为XXX

运行时数据结构
XVM 相关的核心数据结构主要包括 xvm_resolver_t，xvm_code_t，和 xvm_context_t
 TODO： 确认下跨合约调用相关的适宜
xvm_resolver_t 主要负责全局符号的解析，函数的解析，跨合约调用等功能，
xvm_code_t 代表一个 wasm 模块，其声明如下所示
xvm_context_t 代表一次具体的合约调用


XVM 运行时行为遵循 wasm-rt.h 的约束

extern void wasm_rt_trap(wasm_rt_trap_t) __attribute__((noreturn));
extern uint32_t wasm_rt_register_func_type(uint32_t params, uint32_t results, ...);
extern void wasm_rt_allocate_memory(wasm_rt_memory_t*, uint32_t initial_pages, uint32_t max_pages);
extern uint32_t wasm_rt_grow_memory(wasm_rt_memory_t*, uint32_t pages);
extern void wasm_rt_allocate_table(wasm_rt_table_t*, uint32_t elements, uint32_t max_elements);
extern uint32_t wasm_rt_call_stack_depth;

2. 内存管理
WASM 内存模型
在 WASM 内存采用按页分配的方式，每页大小为 65535K，一个 WASM 模块最多允许 65535 页，总的内存大小为 4G。
WASM 将 4G 的内存空间划分为保留段，静态数据段，栈段，堆段四个不同的区域。
内存分配
TODO 补全部
内存分配为 WASM 模块分配内存。在 XVM  中涉及内存分配的地方主要包括: 大内存分配主要在初始化表，初始化外部函数，初始化全局变量等等
小内存主要用于合约调用，合约 code 等等。 
XVM中，以 64K 为一页，按页进行内存分配。在每个 WASM 模块加载时，XVM 默认分配一个页面的内存。 XVM 在内存管理方面分为大块内存管理与小内存管理。针对大块内存，采用 MMAP 分配内存，针对小内存，采用 calloc 分配内存。
wasm_rt_allocate_memory
内存初始化
内存使用
内存释放
内存增长
WASM 支持动态的内存分配，
memoryGraw
外部内存:
1. 运行时初始化
3. C 指令和 WASM 指令映射
4. 导出函数极值

XVM 计费和机制
>>>>>>>>>>>>
TODO 换成可以配置，非侵入式的
和 wasmtime， wasmer 等通用 WebAssembly 运行时略有差异, XVM 主要用于智能合约的执行。
XVM 采用代码注入的方式的方式实现资源与计费机制。
在 WASM 

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


XVM 和 xchain 的交互
>>>>>>>>>>>>>>>>>> 
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
XuperBridge 桥接层实现了 xchain 运行时和合约的接耦，通过 XuperBridge 为合约提供通用的抽象接口，


原生合约支持

EVM 合约支持




WebAssembly(简称WASM) 提供了一种高性能可停止的执行沙盒技术，在性能方面提供和本地执行性能相当的执行环境；在可停止性方面，可以为WASM 合约提供资源quota，超出资源quota 后的WASM 执行会被自动终止；在安全性方面，WASM合约提供内存安全，宿主访问安全等机制，WASM 合约和宿主环境互相隔离，不同 WASM 模块也互相隔离，一个WASM 模块的异常既然不会引起宿主的异常，也不会引起其他模块的异常。
WebAssembly 运行时规范规定了WebAssembly 需要支持的内容，主要包括运行时数据结构与运行时行为。在运行时数据结构方面主要包括运行时表结构，运行时函数等，在运行时行为方面主要包括内存管理，异常处理等。
WebAssembly 作为一种中间表示，本身无法在处理器上执行。为了能够执行WebAssembly，需要有另一个程序将WebAssembly 转化为本地二进制码。通常有解释执行，JIT (预编译)执行和AOT(预编译)执行三种执行模式。解释执行模式是一边读区WebAssembly 字节码。通常，在解释执行模式下，解释器需要为不同的模块存储运行时数据等等。在解释执行模式下，解释器每次读取一条或多条 WASM 指令，并修改对应的运行时数据。
JIT(Just In Time)执行模式是针对解释执行模式的性能优化，将频繁执行的指令提前编译成本地机器码，首次执行时会比较慢，随着时间推移，热点代码被编译成本地机器码之后性能获得大幅提升。
AOT(Ahead of Time) 执行模式则是提前讲所有WASM 字节码编译成本地指令，执行的时候没有编译过程，因此性能最高。AOT 模式启动时需要进行字节码编译，因此启动速度慢。此外，AOT 编译由于不能利用运行时信息，因此特殊条件性性能可能不如 JIT 模式。
XVM 是XuperChain 针对智能合约场景设计的一款 高性能WebAssembly 虚拟机。考虑到在智能合约中，通常一个合约通常被部署一次，之后会有多次调用。在智能合约中，运行时性能的重要性要远远高于启动时性能，因此XVM 选择采用 AOT 预编译模式进行。在XVM 预编译模型中，每个模块被编译成一个本地动态链接库文件。在Linux 上是一个ELF 格式的动态连接库so 文件，在MACOS 上是一个MAC-O 格式的.dylib文件。在将WebAssembly 编译成本地执行文件方面，主要有编译成C，编译成LLVM IR, 编译成其他表示方式三种方案。在具体的实现上，，XVM 选择了方案1，先编译成C语言，再通过宿主机器上的工具链编译成本地动态链接库。选择编译成C 语言，再编译成本地代码的一个优势是可以做到和底层平台无关。XuperChain 默认X86_64 环境进行开发和适配将WebAssembly 首先编译成C 文件，由于C 文件是平台无关的，如果希望在新的平台上使用 XVM ，只需要首先安装本地编译工具链，使用使用本地的默认工具链进行编译即可。使用C 语言作为中间表示的另一个优势是C 语言作为文本文件，可以方便地进行处理，增加自己需要的功能。与其他WebAssembly 不同，XVM 主要用途是在区块链系统中。和传统程序相比，智能合约的执行必须满足可以停性，即可以给合约设置资源配额，超出配额后自动停止合约的执行。为了实现可停止性，XVM 为WebAssembly 增加了gas 机制，在作为中间表示的C 语言中插入 gas 统计指令，当资源消耗超出gas 限制时则自动取消此次之行。出于性能考虑，XVM 并没有在条之后之后均插入gas 指令，而是通过控制流分析，在基本块后插入统计指令。
