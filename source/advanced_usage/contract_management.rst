
合约管理
========

XuperChain 通过 XuperBridge 技术支持多语言和运行时，当前支持使用 C++, JAVA, Solidity 来编写智能合约，支持 WASM,Native，EVM 等多种合约运行时间


安装依赖
--------

.. tabs::

   .. group-tab:: C++

      - Docker
      - XDEV 合约构建测试工具

   .. group-tab:: GO

      - GO 1.13

   .. group-tab:: JAVA

      - JAVA 1.8+
      - Maven 

   .. group-tab:: Solidity

      - `solc 编译器 <https://solidity-cn.readthedocs.io/zh/latest/installing-solidity.html>`_ 


环境准备
--------
1. `本地部署 XuperChain 环境 <https://xuperchain.readthedocs.io/zh/latest/quickstart.html>`_
2. 修改本地配置并重启 xchain 进程

.. tabs::

   .. group-tab:: C++

      使用 ixvm 以加快合约部署速度

    .. code-block:: yaml
        :linenos:

        # evm合约配置
        evm:
            driver: "evm"
            enable: true
    注意: 

    ixvm 采用解释模式执行，在性能上远低于 XVM，请勿在生产环境中使用。
    
   .. group-tab:: GO

    .. code-block:: yaml
        :linenos:

        # 管理native合约的配置
        native:
            enable: true
            # 停止合约的等待秒数，超时强制杀死
            stopTimeout: 3

   .. group-tab:: JAVA

      如果本地搭建 XuperChain 环境，在部署、调用 native 合约之前，请先查看`conf/xchain.yaml` 中native一节，确保native合约功能开启。

        .. code-block:: yaml
            :linenos:

            # 管理native合约的配置
            native:
                enable: true

   .. group-tab:: Solidity

      开启 EVM 合约支持
        .. code-block:: yaml
            :linenos:

            # evm合约配置
            evm:
                driver: "evm"
                enable: true







合约代码
--------

.. tabs::

   .. group-tab:: C++ 

        .. literalinclude:: counter.cc

   .. group-tab:: GO  

        .. literalinclude:: counter.go


   .. group-tab:: JAVA

        .. literalinclude:: counter.java

   .. group-tab:: Solidity

        .. literalinclude:: counter.sol

合约编译
--------

.. tabs::

   .. group-tab:: C++

    .. code-block:: bash
        :linenos:

        xdev build -o counter counter.cc 

   .. group-tab:: GO

    .. code-block:: bash
        :linenos:

        go build -o counter counter.go 

   .. group-tab:: JAVA

    .. code-block:: bash
        :linenos:

        mvn package

   .. group-tab:: Solidity

    .. code-block:: bash
        :linenos:

        solc --bin --abi Counter.sol -o .

合约部署
--------

.. tabs::

   .. group-tab:: C++

    .. code-block:: bash

      $ xchain-cli wasm deploy --account XC1111111111111111@xuper  -a '{"creator":"xchain"}' --cname counter counter

   .. group-tab:: GO

    .. code-block:: bash

        # 部署golang native合约
        $ xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime go -a '{"creator":"XC1111111111111111@xuper"}'   --cname golangcounter ../core/contractsdk/go/example/counter/counter
         contract response: ok
         The gas you cousume is: 14311874
         The fee you pay is: 15587517
         Tx id: af0d46f6df2edba4d9d9d07e1db457e5267274b1c9fe0611bb994c0aa7931933

   .. group-tab:: JAVA

    .. code-block:: bash

        # 部署java native合约
        $ xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime java   --cname javacounter ../core/contractsdk/java/example/counter/target/counter-0.1.0-jar-with-dependencies.jar
         The gas you cousume is: 14311876
         The fee you pay is: 15587517
         Tx id: 875d2c9129973a1c64811d7a5a55ca80743102abc30d19f012656fa52ee0f4f7

   .. group-tab:: Solidity

    .. code-block:: bash

        $ xchain-cli evm deploy --account XC1111111111111111@xuper --cname counterevm  --fee 5200000 ../core/contractsdk/evm/example/counter/Counter.bin --abi ../core/contractsdk/evm/example/counter/Counter.abi
         contract response: ok
         The gas you cousume is: 1789
         The fee you pay is: 22787517
         Tx id: 78469246d86a92ad47e5c15991a55978075902809346e48533e09a8eb0e3a7e4

    - ``--abi Counter.abi`` ：表示部署需要使用的abi文件，用于合约方法参数编解码
    - ``-a ``：如果合约需要构造函数，通过-a进行指定。与c++、golang等合约的部署和调用方式相同。

合约调用
--------

.. tabs::

   .. group-tab:: C++

    .. code-block:: bash
    
        $ xchain-cli wasm invoke --method increase -a '{"key":"test"}' counter --fee 100
        The gas you cousume is: 93
        The fee you pay is: 100
        Tx id: 141e4c1fb99566ce4b6ba32fa92af73c0e9857189debf773cf5753d64e1416a7


   .. group-tab:: GO

    .. code-block:: bash

        # 调用golang native合约，Increase方法，golangcounter为合约名
        $ ./xchain-cli native invoke --method Increase -a '{"key":"test"}' golangcounter


   .. group-tab:: JAVA

    .. code-block:: bash

        # 调用java native合约，increase方法，javacounter为合约名
        $ ./xchain-cli native invoke --method increase -a '{"key":"test"}' javacounter --fee 10


   .. group-tab:: Solidity
      
    .. code-block:: bash

        # 调用solidity合约，increase方法，counterevm为合约名
        $ ./xchain-cli evm invoke --method increase -a '{"key":"test"}' counterevm --fee 22787517

        # 调用solidity合约，get方法，counterevm为合约名
        $ ./xchain-cli evm query --method get -a '{"key":"test"}' counterevm
        # 调用结果，其中0表示返回值的次序，1为返回值
        # key,value: 0 1

合约查询
--------

.. tabs::

   .. group-tab:: C++

    .. code-block:: bash
    

        $ xchain-cli wasm query --method get -a '{"key":"test"}' counter    
        contract response: 1

   .. group-tab:: GO

    .. code-block:: bash

        # 调用golang native合约，Get方法，golangcounter为合约名
        $ ./xchain-cli native query --method Get -a '{"key":"test"}' golangcounter
        contract response: 1

   .. group-tab:: JAVA

    .. code-block:: bash

        # 调用java native合约，get方法，javacounter为合约名
        $ ./xchain-cli native query --method get -a '{"key":"test"}' javacounter
          contract response: 1

   .. group-tab:: Solidity

      
    .. code-block:: bash

        # 调用solidity合约，increase方法，counterevm为合约名
        $ ./xchain-cli evm invoke --method increase -a '{"key":"test"}' counterevm --fee 22787517

        # 调用solidity合约，get方法，counterevm为合约名
        $ ./xchain-cli evm query --method get -a '{"key":"test"}' counterevm
        # 调用结果，其中0表示返回值的次序，1为返回值
        # key,value: 0 1


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

.. tabs::

   .. group-tab:: C++

    .. code-block:: bash

        $ xchain-cli wasm upgrade --account XC1111111111111111@xuper --cname counter counter

   .. group-tab:: GO

    .. code-block:: bash

        $ xchain-cli native upgrade --account XC1111111111111111@xuper --cname counter counter

   .. group-tab:: JAVA

    .. code-block:: bash

        $ xchain-cli native upgrade --account XC1111111111111111@xuper --cname counter counter

   .. group-tab:: Solidity

    .. code-block:: bash

        $ xchain-cli evm upgrade --account XC1111111111111111@xuper --cname counter counter
