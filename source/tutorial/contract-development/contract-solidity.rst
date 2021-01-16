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


