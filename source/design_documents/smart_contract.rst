
智能合约
=============


XVM
---

XVM 是 XuperChain AOT(Ahead Of Time) 虚拟机，用于 WebAssembly(简称 WASM) 合约的执行。其基本思路是将每一个 WASM 模块编译成一个动态链接库，每一个 export 方法通过编译成动态链接库里的一个全局符号, xchain 通过 CGO 进行调用。

基本概念
>>>>>>>>

WebAssembly

WebAssembly 执行模式主要包括解释执行, Just In Time(JIT), Ahead Of Time(AOT) 三种执行模式。

动态链接

CGO 

XVM 编译流程
>>>>>>>>
XVM 

XVM 运行时
>>>>>>>>>>

XVM 运行时主要包括运行时数据结构与运行时行为。wasm-rt.h 规定了XVM 运行时需要支持的内容，具体包括

extern void wasm_rt_trap(wasm_rt_trap_t) __attribute__((noreturn));
extern uint32_t wasm_rt_register_func_type(uint32_t params, uint32_t results, ...);
extern void wasm_rt_allocate_memory(wasm_rt_memory_t*, uint32_t initial_pages, uint32_t max_pages);
extern uint32_t wasm_rt_grow_memory(wasm_rt_memory_t*, uint32_t pages);
extern void wasm_rt_allocate_table(wasm_rt_table_t*, uint32_t elements, uint32_t max_elements);
extern uint32_t wasm_rt_call_stack_depth;

1. 全局初始化
2. 内存管理
3. C 指令和 WASM 指令映射
4. 导出函数极值

XVM GAS 机制
>>>>>>>>>>>>

和 wasmtime， wasmer 等通用 WebAssembly 引擎不同, XVM 主要用于智能合约领域

XVM 异常

XVM 语言运行时

XVM 和 xchain 的交互
>>>>>>>>>>>>>>>>>> 

XVM 性能
>>>>>>>>
1. AOT 支持
2. 编译优化
3. 


XVM 合约安全
>>>>>>>>>>>>



WebAssembly(简称WASM) 提供了一种高性能可停止的执行沙盒技术，在性能方面提供和本地执行性能相当的执行环境；在可停止性方面，可以为WASM 合约提供资源quota，超出资源quota 后的WASM 执行会被自动终止；在安全性方面，WASM合约提供内存安全，宿主访问安全等机制，WASM 合约和宿主环境互相隔离，不同 WASM 模块也互相隔离，一个WASM 模块的异常既然不会引起宿主的异常，也不会引起其他模块的异常。
WebAssembly 运行时规范规定了WebAssembly 需要支持的内容，主要包括运行时数据结构与运行时行为。在运行时数据结构方面主要包括运行时表结构，运行时函数等，在运行时行为方面主要包括内存管理，异常处理等。
WebAssembly 作为一种中间表示，本身无法在处理器上执行。为了能够执行WebAssembly，需要有另一个程序将WebAssembly 转化为本地二进制码。通常有解释执行，JIT (预编译)执行和AOT(预编译)执行三种执行模式。解释执行模式是一边读区WebAssembly 字节码。通常，在解释执行模式下，解释器需要为不同的模块存储运行时数据等等。在解释执行模式下，解释器每次读取一条或多条 WASM 指令，并修改对应的运行时数据。
JIT(Just In Time)执行模式是针对解释执行模式的性能优化，将频繁执行的指令提前编译成本地机器码，首次执行时会比较慢，随着时间推移，热点代码被编译成本地机器码之后性能获得大幅提升。
AOT(Ahead of Time) 执行模式则是提前讲所有WASM 字节码编译成本地指令，执行的时候没有编译过程，因此性能最高。AOT 模式启动时需要进行字节码编译，因此启动速度慢。此外，AOT 编译由于不能利用运行时信息，因此特殊条件性性能可能不如 JIT 模式。
XVM 是XuperChain 针对智能合约场景设计的一款 高性能WebAssembly 虚拟机。考虑到在智能合约中，通常一个合约通常被部署一次，之后会有多次调用。在智能合约中，运行时性能的重要性要远远高于启动时性能，因此XVM 选择采用 AOT 预编译模式进行。在XVM 预编译模型中，每个模块被编译成一个本地动态链接库文件。在Linux 上是一个ELF 格式的动态连接库so 文件，在MACOS 上是一个MAC-O 格式的.dylib文件。在将WebAssembly 编译成本地执行文件方面，主要有编译成C，编译成LLVM IR, 编译成其他表示方式三种方案。在具体的实现上，，XVM 选择了方案1，先编译成C语言，再通过宿主机器上的工具链编译成本地动态链接库。选择编译成C 语言，再编译成本地代码的一个优势是可以做到和底层平台无关。XuperChain 默认X86_64 环境进行开发和适配将WebAssembly 首先编译成C 文件，由于C 文件是平台无关的，如果希望在新的平台上使用 XVM ，只需要首先安装本地编译工具链，使用使用本地的默认工具链进行编译即可。使用C 语言作为中间表示的另一个优势是C 语言作为文本文件，可以方便地进行处理，增加自己需要的功能。与其他WebAssembly 不同，XVM 主要用途是在区块链系统中。和传统程序相比，智能合约的执行必须满足可以停性，即可以给合约设置资源配额，超出配额后自动停止合约的执行。为了实现可停止性，XVM 为WebAssembly 增加了gas 机制，在作为中间表示的C 语言中插入 gas 统计指令，当资源消耗超出gas 限制时则自动取消此次之行。出于性能考虑，XVM 并没有在条之后之后均插入gas 指令，而是通过控制流分析，在基本块后插入统计指令。
