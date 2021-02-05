下面大概说明如何编写这四种类型的合约

Solidity合约
^^^^^^^^^^^^

如果本地搭建超级链环境，在部署、调用solidity合约之前，请先查看`conf/xchain.yaml` 中evm一节，确保evm合约功能开启。

.. code-block:: yaml
    :linenos:

    # evm合约配置
    evm:
        driver: "evm"
        enable: true     

编译环境准备
>>>>>>>>>>>>>

安装solc编译器，请参见**https://solidity-cn.readthedocs.io/zh/latest/installing-solidity.html**。

    .. code-block:: bash

        solc --version
        // solc, the solidity compiler commandline interface
        // Version: 0.5.9+commit.c68bc34e.Darwin.appleclang
        // 以上打印说明编译器安装成功

以counter合约为例来看如何编写一个Solidity合约。

合约样例
>>>>>>>>>>>>>

代码在 **contractsdk/evm/example/Counter.sol**

.. code-block:: c++
    :linenos:
	
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

代码
>>>>>>>>>>>>>>

    - solidity合约相关文档请参见 **https://github.com/ethereum/solidity** 。

    - 更多的Solidity语言合约例子在超级链项目的 **core/contractsdk/evm/example** 以及 **https://github.com/OpenZeppelin/openzeppelin-contracts** 里面寻找。

合约编译
>>>>>>>>>>>

Solidity合约使用如下命令来编译合约

.. code-block:: go
    :linenos:
	
    // 通过solc编译合约源码
    solc --bin --abi Counter.sol -o .
    // 合约二进制文件和abi文件分别存放在当前目录下，Counter.bin和Counter.abi

- ``--bin`` ：表示需要生成合约二进制文件
- ``--abi`` ：表示需要生成合约abi文件，用于合约方法以及参数编解码
- ``-o``：表示编译结果输出路径

合约部署
>>>>>>>>>>>>>
Solidity合约部署完整命令如下

.. code-block:: bash
    :linenos:
	
    $ ./xchain-cli evm deploy --account XC1111111111111111@xuper --cname counterevm  --fee 5200000 Counter.bin --abi Counter.abi

- ``--abi`` ：表示合约abi文件

合约调用
>>>>>>>>>>>>>
.. code-block:: bash
    :linenos:
	
    // 合约increase方法调用
    $ ./xchain-cli evm invoke --method increase -a '{"key":"stones"}' counterevm --fee 22787517 --abi Counter.abi
    // 合约get方法调用
    $ ./xchain-cli evm query --method get -a '{"key":"stones"}' counterevm --abi Counter.abi

- ``--abi`` ：表示合约abi文件


部署solidity合约
--------------

如果本地搭建超级链环境，在部署、调用solidity合约之前，请先查看`conf/xchain.yaml` 中evm一节，确保evm合约功能开启。

.. code-block:: yaml
    :linenos:

    # evm合约配置
    evm:
        driver: "evm"
        enable: true

1. 编译合约 - Solidity

    使用solc编译solidity合约。安装solc编译器，请参见**https://solidity-cn.readthedocs.io/zh/latest/installing-solidity.html**。

    .. code-block:: bash

        solc --version
        // solc, the solidity compiler commandline interface
        // Version: 0.5.9+commit.c68bc34e.Darwin.appleclang
        // 以上打印说明编译器安装成功

    编译native合约时，我们以contractsdk/java/example中的counter合约为例

    .. code-block:: bash

        cd contractsdk/evm/example/counter
        // 通过solc编译合约源码
        solc --bin --abi Counter.sol -o .
        // 合约二进制文件和abi文件分别存放在当前目录下，Counter.bin和Counter.abi。

2. 部署合约

    部署solidity合约。

    .. code-block:: bash

        # 部署solidity合约
        xchain-cli evm deploy --account XC1111111111111111@xuper --cname counterevm  --fee 5200000 Counter.bin --abi Counter.abi
        # 其中--abi表示合约的abi文件
        # 部署结果
        # contract response: ok
        # The gas you cousume is: 1789
        # The fee you pay is: 22787517
        # Tx id: 78469246d86a92ad47e5c15991a55978075902809346e48533e09a8eb0e3a7e4

    - ``--abi Counter.abi`` ：表示部署需要使用的abi文件，用于合约方法参数编解码
    - ``-a ``：如果合约需要构造函数，通过-a进行指定。与c++、golang等合约的部署和调用方式相同。

4. 合约调用

    调用solidity合约。通过合约名直接发起合约调用和查询。

    .. code-block:: bash

        # 调用solidity合约，increase方法，counterevm为合约名
        xchain-cli evm invoke --method increase -a '{"key":"test"}' counterevm --fee 22787517 --abi Counter.abi
        # 调用结果
        # contract response:
        # The gas you cousume is: 65
        # The fee you pay is: 22787517
        # Tx id: 94655ab00188de70c3ef2f91b9db0d156142ce92f91a5da20f0f1fc7830fb700

        # 调用solidity合约，get方法，counterevm为合约名
        xchain-cli native query --method Get -a '{"key":"test"}' counterevm --abi Counter.abi
        # 调用结果，其中0表示返回值的次序，1为返回值
        # key,value: 0 1

5. 超级链账户与EVM账户地址转换

    超级链有普通地址、合约账户以及合约名，这三类账户在EVM运行时需要转换为以太坊的地址类型（16进制编码字符串，形如0x1234567890abcdef1234567890abcdef12345678格式）。超级链提供了上述三个地址与EVM地址类型转换工具。

    .. code-block:: bash

        # xchain合约账户地址转evm地址，contract-account表示超级链合约账户
        xchain-cli evm addr-trans -t x2e -f XC1111111111111113@xuper
        result, 3131313231313131313131313131313131313133    contract-account
        
        # evm地址转xchain合约账户，contract-account表示超级链合约账户
        xchain-cli evm addr-trans -t e2x -f 3131313231313131313131313131313131313133
        result, XC1111111111111113@xuper     contract-account        
        
        # xchain普通账户地址转evm地址，xchain表示超级链普通账户
        xchain-cli evm addr-trans -t e2x -f 93F86A462A3174C7AD1281BCF400A9F18D244E06
        result, dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN   xchain        
        
        # xchain普通账户地址转evm地址，xchain表示超级链普通账户
        xchain-cli evm addr-trans -t x2e -f dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN
        result, 93F86A462A3174C7AD1281BCF400A9F18D244E06   xchain      
        
        # xchain合约名地址转evm地址，contract-name表示超级链合约名
        xchain-cli evm addr-trans -t x2e -f storagedata11
        result, 313131312D2D2D73746F72616765646174613131   contract-name    
        
        # evm地址转xchain合约名，contract-name表示超级链合约名
        xchain-cli evm addr-trans -t e2x -f 313131312D2D2D73746F72616765646174613131
        result, storagedata11   contract-name

    - ``x2e`` ：表示超级链地址转换为EVM地址
    - ``e2x`` ：表示EVM地址转换为超级链地址。



    超级链有普通地址、合约账户以及合约名，这三类账户在EVM运行时需要转换为以太坊的地址类型（16进制编码字符串，形如0x1234567890abcdef1234567890abcdef12345678格式）。超级链提供了上述三个地址与EVM地址类型转换工具。

    .. code-block:: bash

        # xchain合约账户地址转evm地址，contract-account表示超级链合约账户
        xchain-cli evm addr-trans -t x2e -f XC1111111111111113@xuper
        result, 3131313231313131313131313131313131313133    contract-account
        
        # evm地址转xchain合约账户，contract-account表示超级链合约账户
        xchain-cli evm addr-trans -t e2x -f 3131313231313131313131313131313131313133
        result, XC1111111111111113@xuper     contract-account        
        
        # xchain普通账户地址转evm地址，xchain表示超级链普通账户
        xchain-cli evm addr-trans -t e2x -f 93F86A462A3174C7AD1281BCF400A9F18D244E06
        result, dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN   xchain        
        
        # xchain普通账户地址转evm地址，xchain表示超级链普通账户
        xchain-cli evm addr-trans -t x2e -f dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN
        result, 93F86A462A3174C7AD1281BCF400A9F18D244E06   xchain      
        
        # xchain合约名地址转evm地址，contract-name表示超级链合约名
        xchain-cli evm addr-trans -t x2e -f storagedata11
        result, 313131312D2D2D73746F72616765646174613131   contract-name    
        
        # evm地址转xchain合约名，contract-name表示超级链合约名
        xchain-cli evm addr-trans -t e2x -f 313131312D2D2D73746F72616765646174613131
        result, storagedata11   contract-name

    - ``x2e`` ：表示超级链地址转换为EVM地址
    - ``e2x`` ：表示EVM地址转换为超级链地址。


