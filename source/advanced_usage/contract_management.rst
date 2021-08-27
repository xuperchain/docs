
合约管理
============

 XuperChain 支持丰富的智能合约开发语言，比如go，Solitidy，C++，Java等。 

阅读本节前，请先确保完成 `XuperChain环境部署 <../quickstart/quickstart.html#xuperchain>`_  



编写合约
--------

 可以根据合约示例代码，编写自己的合约

    `c++ counter 合约 <https://github.com/xuperchain/xuperchain/blob/master/core/contractsdk/cpp/example/counter.cc>`_,
    `go counter 合约 <https://github.com/xuperchain/xuperchain/tree/master/core/contractsdk/go/example/counter>`_,
    `java counter 合约 <https://github.com/xuperchain/xuperchain/tree/master/core/contractsdk/java/example/counter>`_


部署wasm合约
------------

1. 编译合约

    对于C++合约，已提供编译脚本，位于 contractsdk/cpp/build.sh。

    需要注意的是，脚本依赖从hub.baidubce.com拉取的docker镜像，请在编译前确认docker相关环境是可用的

2. 部署合约


    部署合约的操作需要由合约账号完成，部署操作同样需要支付手续费，操作前需要确保合约账号下有足够的余额

    .. code-block:: bash

        $ ./xchain-cli wasm deploy --account XC1111111111111111@xuper  -a '{"creator":"XC1111111111111111@xuper"}' --cname counter ../core/contractsdk/cpp/build/counter.wasm

    运行时会提示手续费的数目，使用 --fee 参数传入即可

 3. 合约调用

    .. code-block:: bash
    
        $ ./xchain-cli wasm invoke --method increase -a '{"key":"test"}' counter --fee 100
        The gas you cousume is: 93
        The fee you pay is: 100
        Tx id: 141e4c1fb99566ce4b6ba32fa92af73c0e9857189debf773cf5753d64e1416a7

        $ ./xchain-cli wasm query --method get -a '{"key":"test"}' counter    
        contract response: 1


部署native合约
--------------

如果本地搭建 XuperChain 环境，在部署、调用 native 合约之前，请先查看`conf/xchain.yaml` 中native一节，确保native合约功能开启。

.. code-block:: yaml
    :linenos:

    # 管理native合约的配置
    native:
        enable: true

        # docker相关配置
        docker:
            enable:false
            # 合约运行的镜像名字
            imageName: "docker.io/centos:7.5.1804"
            # cpu核数限制，可以为小数
            cpus: 1
            # 内存大小限制
            memory: "1G"
        # 停止合约的等待秒数，超时强制杀死
        stopTimeout: 3

1. 编译合约 - Golang

    编译native合约时，只要保持环境和编译XuperChain源码时一致即可，我们以 contractsdk/go/example 中的 counter 合约为例

    .. code-block:: bash

        cd contractsdk/go/example/counter
        go build

2. 编译合约 - Java

    我们以contractsdk/java/example中的counter合约为例

    .. code-block:: bash

        $ cd contractsdk/java/example/counter
        $ mvn package

3. 部署合约

    部署native合约。针对不同语言实现的合约，主要通过 ``--runtime`` 字段进行区分

    .. code-block:: bash

        # 部署golang native合约
        $ ./xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime go -a '{"creator":"XC1111111111111111@xuper"}'   --cname golangcounter ../core/contractsdk/go/example/counter/counter
         contract response: ok
         The gas you cousume is: 14311874
         The fee you pay is: 15587517
         Tx id: af0d46f6df2edba4d9d9d07e1db457e5267274b1c9fe0611bb994c0aa7931933

        # 部署java native合约
        $ ./xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime java   --cname javacounter ../core/contractsdk/java/example/counter/target/counter-0.1.0-jar-with-dependencies.jar
         The gas you cousume is: 14311876
         The fee you pay is: 15587517
         Tx id: 875d2c9129973a1c64811d7a5a55ca80743102abc30d19f012656fa52ee0f4f7


4. 合约调用

    针对不同语言实现的 native合约，调用方式相同。通过合约名直接发起合约调用和查询

    .. code-block:: bash

        # 调用golang native合约，Increase方法，golangcounter为合约名
        $ ./xchain-cli native invoke --method Increase -a '{"key":"test"}' golangcounter

        # 调用golang native合约，Get方法，golangcounter为合约名
        $ ./xchain-cli native query --method Get -a '{"key":"test"}' golangcounter
        contract response: 1

        # 调用java native合约，increase方法，javacounter为合约名
        $ ./xchain-cli native invoke --method increase -a '{"key":"test"}' javacounter --fee 10

        # 调用java native合约，get方法，javacounter为合约名
        $ ./xchain-cli native query --method get -a '{"key":"test"}' javacounter
          contract response: 1


部署solidity合约
------------------

如果本地搭建 XuperChain 环境，在部署、调用solidity合约之前，请先查看`conf/xchain.yaml` 中evm一节，确保evm合约功能开启。

.. code-block:: yaml
    :linenos:

    # evm合约配置
    evm:
        driver: "evm"
        enable: true

1. 编译合约 - Solidity

    使用 solc 编译solidity合约。安装 solc 编译器，请参见**https://solidity-cn.readthedocs.io/zh/latest/installing-solidity.html**。

    .. code-block:: bash

        solc --version
        // solc, the solidity compiler commandline interface
        // Version: 0.5.9+commit.c68bc34e.Darwin.appleclang

    我们以contractsdk/evm/example中的counter合约为例

    .. code-block:: bash

        cd core/contractsdk/evm/example/counter
        // 通过solc编译合约源码
        solc --bin --abi Counter.sol -o .
        // 合约二进制文件和abi文件分别存放在当前目录下，Counter.bin和Counter.abi。

2. 部署合约

    部署solidity合约。

    .. code-block:: bash

        ./xchain-cli evm deploy --account XC1111111111111111@xuper --cname counterevm  --fee 5200000 ../core/contractsdk/evm/example/counter/Counter.bin --abi ../core/contractsdk/evm/example/counter/Counter.abi
         contract response: ok
         The gas you cousume is: 1789
         The fee you pay is: 22787517
         Tx id: 78469246d86a92ad47e5c15991a55978075902809346e48533e09a8eb0e3a7e4

    - ``--abi Counter.abi`` ：表示部署需要使用的abi文件，用于合约方法参数编解码 
    - ``-a ``：如果合约需要构造函数，通过-a进行指定。与c++、golang等合约的部署和调用方式相同。 

4. 合约调用

    调用solidity合约。通过合约名直接发起合约调用和查询。

    .. code-block:: bash

        # 调用solidity合约，increase方法，counterevm为合约名
        $ ./xchain-cli evm invoke --method increase -a '{"key":"test"}' counterevm --fee 22787517

        # 调用solidity合约，get方法，counterevm为合约名
        $ ./xchain-cli evm query --method get -a '{"key":"test"}' counterevm
        # 调用结果，其中0表示返回值的次序，1为返回值
        # key,value: 0 1

5.  XuperChain 账户与EVM账户地址转换

     XuperChain 有普通地址、合约账户以及合约名，这三类账户在EVM运行时需要转换为以太坊的地址类型（16进制编码字符串，形如0x1234567890abcdef1234567890abcdef12345678格式）。 XuperChain 提供了上述三个地址与EVM地址类型转换工具。

    .. code-block:: bash

        # xchain合约账户地址转evm地址，contract-account表示 XuperChain 合约账户
        ./xchain-cli evm addr-trans -t x2e -f XC1111111111111113@xuper
        result, 3131313231313131313131313131313131313133    contract-account
        
        # evm地址转xchain合约账户，contract-account表示 XuperChain 合约账户
        ./xchain-cli evm addr-trans -t e2x -f 3131313231313131313131313131313131313133
        result, XC1111111111111113@xuper     contract-account        
        
        # xchain普通账户地址转evm地址，xchain表示 XuperChain 普通账户
        ./xchain-cli evm addr-trans -t e2x -f 93F86A462A3174C7AD1281BCF400A9F18D244E06
        result, dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN   xchain        
        
        # xchain普通账户地址转evm地址，xchain表示 XuperChain 普通账户
        ./xchain-cli evm addr-trans -t x2e -f dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN
        result, 93F86A462A3174C7AD1281BCF400A9F18D244E06   xchain      
        
        # xchain合约名地址转evm地址，contract-name表示 XuperChain 合约名
        ./xchain-cli evm addr-trans -t x2e -f storagedata11
        result, 313131312D2D2D73746F72616765646174613131   contract-name    
        
        # evm地址转xchain合约名，contract-name表示 XuperChain 合约名
        ./xchain-cli evm addr-trans -t e2x -f 313131312D2D2D73746F72616765646174613131
        result, storagedata11   contract-name

    - ``x2e`` ：表示 XuperChain 地址转换为EVM地址
    - ``e2x`` ：表示EVM地址转换为 XuperChain 地址。

合约升级
--------
XuperChain 支持合约升级，在使用合约升级功能之前需要修改 conf/xchain.yaml，开启合约升级功能

.. code-block:: yaml

    # 合约通用配置
    contract:   
        enableUpgrade: true

合约升级与合约部署的命令十分类似，区别在于
    1. 不需要指定 runtime
    2. 不需要指定初始化参数
    
以升级 wasm 的 counter 合约为例

.. code-block:: bash

    ./xchain-cli wasm upgrade --account XC1111111111111111@xuper --cname counter ../core/contractsdk/cpp/build/counter.wasm

设置合约方法的ACL
------------------

1. 准备desc文件setMethodACL.desc

    .. code-block:: json
        
        {
            "module_name": "xkernel",
            "method_name": "SetMethodAcl",
            "args" : {
                "contract_name": "counter",
                "method_name": "increase",
                "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 1.0},\"aksWeight\": {\"UU4kyZcQinAMsBSPRLUA34ebXrfZtB4Z8\": 1}}"
                }
        }

    参数说明：

    - **module_name**： 模块名称，用固定值xkernel 
    - **method_name** ：方法名称，用固定值SetMethodAcl
    - **contract_name**：合约名称
    - **method_name**：合约方法名称
    - **acl**：合约方法的acl

2. 设置合约方法ACL

    设置合约方法ACL的操作，需符合合约账号的ACL，在3.2节，使用 **XC1111111111111111@xuper** 部署的counter合约，合约账号ACL里 只有1个AK，所以在data/acl/addrs中添加1行，如果合约账号ACL里有多个AK，则填写多行。

    .. code-block:: bash

        echo "XC1111111111111111@xuper/dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN" > data/acl/addrs

    执行如下命令，设置ACL：

    .. code-block:: bash

        ./xchain-cli multisig gen --desc ./setMethodACL.desc --fee 1 -H 127.0.0.1:37101
        ./xchain-cli multisig sign --output sign.out
        ./xchain-cli multisig send sign.out sign.out -H 127.0.0.1:37101

3. 查看合约方法ACL

    .. code-block:: bash

            [work@]$ deploy-env -> ./xchain-cli acl query --contract counter --method increase -H :37101    
            # 执行结果  
            # { 
            #   "pm": { 
            #     "rule": 1,    
            #     "acceptValue": 1
            #   },  
            #   "aksWeight": {  
            #     "UU4kyZcQinAMsBSPRLUA34ebXrfZtB4Z8": 1    
            #   }   
            # }
