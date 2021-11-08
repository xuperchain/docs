
合约管理
============

 XuperChain 支持丰富的智能合约开发语言，比如go，Solitidy，C++，Java等。 



编写合约
--------

 本教程以 counter 合约为例，进行合约基本操作，不同语言合约代码见

    * `c++ counter 合约 <https://github.com/xuperchain/contract-sdk-cpp/blob/main/example/counter.cc>`_

    * `go counter 合约 <https://github.com/xuperchain/contract-sdk-go/tree/main/example/counter>`_

    * `java counter 合约 <https://github.com/xuperchain/contract-sdk-java/tree/main/example/counter>`_


部署wasm合约
------------

1. 编译合约

    C++ 合约使用 `xdev <https://github.com/xuperchain/xdev>`_ 编译，使用前需要安装 xdev 并确保 xdev 所在路径在 PATH 环境变量中。
    
    执行以下命令，编译 counter 合约

    .. code-block:: bash
    
        $ git clone https://github.com/xuperchain/contract-sdk-cpp.git
        $ cd contract-sdk-cpp        
        $ xdev build -o counter.wasm example/counter.cc



.. note::
    1. 编译 C++ 合约依赖从 Dockerhub 拉取镜像，请在编译前确认docker相关环境是可用的
    2. 你可以把生成的 counter.wasm 拷贝到 xuperchain 目录下的 output 目录中，以简化后续命令的执行


2. 部署合约

    部署合约的操作需要由合约账号完成，部署操作同样需要支付手续费，操作前需要确保合约账号下有足够的余额

    .. code-block:: bash

        $ xchain-cli wasm deploy --account XC1111111111111111@xuper  -a '{"creator":"XC1111111111111111@xuper"}' --cname counter counter.wasm

    .. Important::
    运行时会提示手续费的数目，需要按照命令行运行结果给出的数值，添加一个不小于它的费用（使用 --fee 参数）。

 3. 合约调用

    .. code-block:: bash
    
        $ xchain-cli wasm invoke --method increase -a '{"key":"test"}' counter --fee 100
        The gas you cousume is: 93
        The fee you pay is: 100
        Tx id: 141e4c1fb99566ce4b6ba32fa92af73c0e9857189debf773cf5753d64e1416a7

        $ xchain-cli wasm query --method get -a '{"key":"test"}' counter    
        contract response: 1


部署native合约
--------------

native 合约默认处于关闭状态，在部署、调用 native 合约之前，请先查看 `conf/contract.yaml` 中 native一节，确保 native 合约功能开启。

.. code-block:: yaml
    :linenos:

    # 管理native合约的配置
    native:
        enable: true


1. 编译合约 - Golang

    GO 合约使用标准的 GO  环境编译，进入 counter 合约目录

    .. code-block:: bash

        $ git clone https://github.com/xuperchain/contract-sdk-go
        $ cd contract-sdk-go/example/counter
        $ go build -o counter

.. note::
    可以把生成的 counter 文件拷贝到 xuperchain 下的 output 目录，以简化后续命令的执行

1. 编译合约 - Java

    JAVA 合约使用 maven 编译，

    .. code-block:: bash

        $ git clone https://github.com/xuperchain/contract-sdk-java.git 
        $ cd contract-sdk-java/example/counter 
        $ mvn package

.. note::
    可以把生成的 target/counter-0.1.0-jar-with-dependencies.jar 拷贝到 xuperchain 下的 output 目录，以简化后续命令的执行

1. 部署合约

    部署native合约。针对不同语言实现的合约，主要通过 ``--runtime`` 字段进行区分

    .. code-block:: bash

        # 部署golang native合约
        $ xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime go -a '{"creator":"XC1111111111111111@xuper"}'   --cname golangcounter counter
         contract response: ok
         The gas you cousume is: 14311874
         The fee you pay is: 15587517
         Tx id: af0d46f6df2edba4d9d9d07e1db457e5267274b1c9fe0611bb994c0aa7931933

        # 部署java native合约
        $ xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime java   --cname javacounter counter-0.1.0-jar-with-dependencies.jar
         The gas you cousume is: 14311876
         The fee you pay is: 15587517
         Tx id: 875d2c9129973a1c64811d7a5a55ca80743102abc30d19f012656fa52ee0f4f7


2. 合约调用

    针对不同语言实现的 native合约，调用方式相同。通过合约名直接发起合约调用和查询

    .. code-block:: bash

        # 调用golang native合约，Increase方法，golangcounter为合约名
        $ xchain-cli native invoke --method Increase -a '{"key":"test"}' golangcounter

        # 调用golang native合约，Get方法，golangcounter为合约名
        $ xchain-cli native query --method Get -a '{"key":"test"}' golangcounter
        contract response: 1

        # 调用java native合约，increase方法，javacounter为合约名
        $ xchain-cli native invoke --method increase -a '{"key":"test"}' javacounter --fee 10

        # 调用java native合约，get方法，javacounter为合约名
        $ xchain-cli native query --method get -a '{"key":"test"}' javacounter
          contract response: 1


部署solidity合约
------------------

在部署、调用solidity合约之前，请先查看`conf/contract.yaml` 中evm一节，确保evm合约功能开启。

.. code-block:: yaml
    :linenos:

    # evm合约配置
    evm:
        driver: "evm"
        enable: true

1. 编译合约 - Solidity

    使用  `solc 编译器 <https://solidity-cn.readthedocs.io/zh/latest/installing-solidity.html>`_ 编译 solidity 合约。

    .. code-block:: bash

        solc --version
        // solc, the solidity compiler commandline interface
        // Version: 0.5.9+commit.c68bc34e.Darwin.appleclang

    我们以如下Counter 合约为例

    .. code-block:: bash

        pragma solidity >=0.0.0;

        contract Counter {
            address owner;
            mapping (string => uint256) values;

            constructor() public{
                owner = msg.sender;
            }

            function increase(string memory key) public payable{
                values[key] = values[key] + 1;
            }

            function get(string memory key) view public returns (uint) {
                return values[key];
            }

            function getOwner() view public returns (address) {
                return owner;
            }

        }
    
    .. code-block:: bash

        solc --bin --abi Counter.sol -o .
.. note::
    可以把生成的 Counter.abi 和 Counter.bin  拷贝到 xuperchain 下的 output 目录，以简化后续命令的执行
2. 部署合约


    .. code-block:: bash

        xchain-cli evm deploy --account XC1111111111111111@xuper --cname counterevm  --fee 5200000 Counter.bin --abi Counter.abi
         contract response: ok
         The gas you cousume is: 1789
         The fee you pay is: 22787517
         Tx id: 78469246d86a92ad47e5c15991a55978075902809346e48533e09a8eb0e3a7e4

    - ``--abi Counter.abi`` ：表示部署需要使用的abi文件，用于合约方法参数编解码 
    - ``-a`` ：如果合约需要构造函数，通过-a进行指定 

3. 合约调用

    调用solidity合约。通过合约名直接发起合约调用和查询。

    .. code-block:: bash

        # 调用solidity合约，increase方法，counterevm为合约名
        $ xchain-cli evm invoke --method increase -a '{"key":"test"}' counterevm --fee 22787517

        # 调用solidity合约，get方法，counterevm为合约名
        $ xchain-cli evm query --method get -a '{"key":"test"}' counterevm
        # 调用结果，其中0表示返回值的次序，1为返回值
        # key,value: 0 1

4.  XuperChain 账户与EVM账户地址转换

     XuperChain 有普通地址、合约账户以及合约名，这三类账户在EVM运行时需要转换为以太坊的地址类型（16进制编码字符串，形如0x1234567890abcdef1234567890abcdef12345678格式）。 XuperChain 提供了上述三个地址与EVM地址类型转换工具。

    .. code-block:: bash

        # xchain合约账户地址转evm地址，contract-account表示 XuperChain 合约账户
        xchain-cli evm addr-trans -t x2e -f XC1111111111111113@xuper
        result, 3131313231313131313131313131313131313133    contract-account
        
        # evm地址转xchain合约账户，contract-account表示 XuperChain 合约账户
        xchain-cli evm addr-trans -t e2x -f 3131313231313131313131313131313131313133
        result, XC1111111111111113@xuper     contract-account        
        
        # xchain普通账户地址转evm地址，xchain表示 XuperChain 普通账户
        xchain-cli evm addr-trans -t e2x -f 93F86A462A3174C7AD1281BCF400A9F18D244E06
        result, dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN   xchain        
        
        # xchain普通账户地址转evm地址，xchain表示 XuperChain 普通账户
        xchain-cli evm addr-trans -t x2e -f dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN
        result, 93F86A462A3174C7AD1281BCF400A9F18D244E06   xchain      
        
        # xchain合约名地址转evm地址，contract-name表示 XuperChain 合约名
        xchain-cli evm addr-trans -t x2e -f storagedata11
        result, 313131312D2D2D73746F72616765646174613131   contract-name    
        
        # evm地址转xchain合约名，contract-name表示 XuperChain 合约名
        xchain-cli evm addr-trans -t e2x -f 313131312D2D2D73746F72616765646174613131
        result, storagedata11   contract-name

    - ``x2e`` ：表示 XuperChain 地址转换为EVM地址
    - ``e2x`` ：表示EVM地址转换为 XuperChain 地址。

合约升级
--------
XuperChain 支持合约升级，在使用合约升级功能之前需要修改 conf/contract.yaml，开启合约升级功能

.. code-block:: yaml

    # 合约通用配置
    contract:   
        enableUpgrade: true

合约升级与合约部署的命令十分类似，区别在于
    1. 不需要指定 runtime
    2. 不需要指定初始化参数
    
以升级 wasm 的 counter 合约为例

.. code-block:: bash

    xchain-cli wasm upgrade --account XC1111111111111111@xuper --cname counter counter.wasm

其他合约的升级命令类似