
智能合约开发详解
==========================

简介
----------

百度 XuperChain 是一个支持多语言合约的区块链框架，有多种语言来供大家选择使用开发智能合约。目前 XuperChain 的智能合约可以使用solidity、c++、go以及 java语言来编写，solidity为EVM合约，c++和go 支持 wasm合约，go和java支持native合约。solidity合约应用最为广泛，完美兼容以太坊开源社区以及相关开发工具，c++合约合约性能会更好些，go合约在易用性上更好，java合约的开发者会更多些。大家可以根据需要选择自己喜欢的语言来编写智能合约，这篇文章会通过一步步的指引来帮助大家使用solidity、c++、go或者java来编写 XuperChain 的智能合约，在阅读完文章后，希望大家对如何编写，部署和测试 XuperChain 的智能合约有初步的认识。  

或使用 XuperChain XuperOS，支持合约可视化管理、在线上链。 `点击了解 <https://xchain.baidu.com/n/console#/xuperos/contracts?type=mine>`_ 

准备工作
------------

环境要求
^^^^^^^^^^^^

目前 XuperChain 节点主要运行在linux和mac上，windows不能运行 XuperChain 节点。

1. go >= 1.12.x && <= 1.13.x
#. g++ >= 4.8.2 或者 clang++ >= 3.3
#. Docker

下载编译xuperchain
^^^^^^^^^^^^^^^^^^^^^

智能合约只有部署到链上才能运行，因此我们首先要编译并启动xuperchain节点。
::

    如果需要使用特定分支，使用git checkout来切换特定分支，如 **git checkout v3.7**
	

.. code-block:: bash
    :linenos:

    $ cd $HOME
    $ git clone https://github.com/xuperchain/xuperchain.git  xuperchain
    $ cd xuperchain && make

设置环境变量
^^^^^^^^^^^^^^^^^^^^^^

这些环境变量有助于我们更方便的执行一些命令而不用指定命令的全路径。

.. code-block:: bash
    :linenos:
	
    export PATH=$HOME/xuperchain/output:$PATH
    export XDEV_ROOT=$HOME/xuperchain/core/contractsdk/cpp

启动xuperchain
^^^^^^^^^^^^^^^^^^^^^^^^^^^
::

    –vm ixvm参数是选择ixvm合约虚拟机，开发合约过程中使用ixvm虚拟机能加快合约部署

--------------------

.. code-block:: bash
    :linenos:
	
    $ cd output
    ## 首先创建链
    $ ./xchain-cli createChain
    ## 后台启动xuperchain节点
    $ nohup ./xchain --vm ixvm &

创建合约账号
^^^^^^^^^^^^^^^^^^^^

合约账号用来进行合约管理，比如合约的权限控制等，要部署合约必须创建合约账号，同时合约账号里面需要有充足的xuper来部署合约。

创建合约账号XC1111111111111111@xuper.

.. code-block:: go
    :linenos:
	
    $ ./xchain-cli account new --account 1111111111111111 --fee 2000
    contract response:
            {
                "pm": {
                    "rule": 1,
                    "acceptValue": 1.0
                },
                "aksWeight": {
                    "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN": 1.0
                }
            }
    The gas you cousume is: 1000
    The fee you pay is: 2000
    Tx id: d62704970705a2682e2bd2c5b4f791065871fd45f64c87815b91d8a00039de35
    account name: XC1111111111111111@xuper

给合约账号转账

.. code-block:: go
    :linenos:
	
    $ ./xchain-cli transfer --to XC1111111111111111@xuper --amount 100000000
    cd26657006f6f75f07bd53ad0a7fe74d76985cd592542d8cc87dc3fcdde115f5

小结
^^^^^^^^^^^^^

至此我们完成了所有的准备工作，包括编译xuperchain，创建链，启动节点，创建合约账号，后面我们开始体验怎么编译，部署和调用智能合约。

快速体验
---------------

在开始编写智能合约之前首先通过一个简单的例子来给大家演示合约是如何从代码到字节码，以及如何部署到链上，如何发起对智能合约的调用。
我们使用一个c++合约为例来展示如何编译、部署、调用合约。

创建合约工程
^^^^^^^^^^^^^^^^^
::

    xdev工具是随xuperchain发布的一个合约编译和测试工具，在编译完xuperchain之后生成在output目录。

-----------

xdev提供了一个默认的c++合约工程模板

.. code-block:: bash
    :linenos:
    
    $ xdev init hello-cpp

 
这个命令创建了一个hello-cpp的合约工程

编译合约
^^^^^^^^^^^^^^^
::

    第一次编译的时间会长一点，因为xdev需要下载编译器镜像，以及编译 XuperChain 的标准库。


.. code-block:: bash
    :linenos:
	
    $ xdev build -o hello.wasm
    CC main.cc
    LD wasm


编译结果为hello.wasm，后面我们使用这个文件来部署合约

部署合约
^^^^^^^^^^^^^

.. code-block:: bash
    :linenos:
	
    $ ./xchain-cli wasm deploy --account XC1111111111111111@xuper --cname hello  --fee 5200000 --runtime c ./hello-cpp/hello.wasm
    contract response: initialize succeed
    The gas you cousume is: 151875
    The fee you pay is: 5200000
    Tx id: 8c33a91c5cf564a28e7b62cad827ba91e19abf961702659dd8b70a3fb872bdf1


此命令看起来很长，但是其中很多参数都有默认值，我们先来看一下参数的含义：

    - **wasm deploy** ：此为部署wasm合约的命令参数，不做过多解释
    - **--account XC1111111111111111@xuper** ：此为部署wasm合约的账号（只有合约账号才能进行合约的部署）
    - **--cname hello** ：这里的hello是指部署后在链上的合约名字，可以自行命名（但有规则，长度在4～16字符）
    - **--runtime c** 指明我们部署的是一个c++代码编译的合约，如果是go合约这里填 **go** 即可。
    - **--fee** 为我们部署这个合约所需要的xuper
    - 最后的hello.wasm是合约编译好的文件

调用合约
^^^^^^^^^^^^^

.. code-block:: bash
    :linenos:
	
    $ ./xchain-cli wasm invoke --method hello --fee 110000 hello
    contract response: hello world
    The gas you cousume is: 35
    The fee you pay is: 110000
    Tx id: d8989ad1bfd2d08bd233b7a09a544cb07976fdf3429144c42f6166d28e9ff695


参数解释如下：

    - **wasm invoke** 表示我们要调用一个合约
    - **--method hello** 表示我们要调用合约的 **hello** 方法
    - **--fee** 指明我们这次调用合约花费的xuper
    - 最后的参数指明我们调用的合约名字 **hello**

小结
^^^^^^^^^^^^

通过本节的学习，我们快速掌握了如果编译，部署和调用合约，在下面的章节里面我们学些如果使用solidity、c++、go或者java语言来编写智能合约。

合约编写详解
---------------

XuperChain目前主要支持以太坊solidity合约，两种编译成wasm格式的合约语言， **c++** 和 **go**，以及两种native合约 **go** 和 **java** ，合约框架的整体结构是一致的，在不同语言上的表现形式不太一样，但熟悉一种语言的SDK之后很容易迁移到其他语言。

下面大概说明如何编写这四种类型的合约

Solidity合约
^^^^^^^^^^^^

如果本地搭建 XuperChain 环境，在部署、调用solidity合约之前，请先查看`conf/xchain.yaml` 中evm一节，确保evm合约功能开启。

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

    - 更多的Solidity语言合约例子在 XuperChain 项目的 **core/contractsdk/evm/example** 以及 **https://github.com/OpenZeppelin/openzeppelin-contracts** 里面寻找。

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


C++合约
^^^^^^^^^^^^

以counter合约为例来看如何编写一个C++合约。

合约样例
>>>>>>>>>>>>>

代码在 **contractsdk/cpp/example/counter.cc**

.. code-block:: c++
    :linenos:
	
    #include "xchain/xchain.h"
    struct Counter : public xchain::Contract {};
    DEFINE_METHOD(Counter, initialize) {
        xchain::Context* ctx = self.context();
        const std::string& creator = ctx->arg("creator");
        if (creator.empty()) {
            ctx->error("missing creator");
            return;
        }
        ctx->put_object("creator", creator);
        ctx->ok("initialize succeed");
    }
    DEFINE_METHOD(Counter, increase) {
        xchain::Context* ctx = self.context();
        const std::string& key = ctx->arg("key");
        std::string value;
        ctx->get_object(key, &value);
        int cnt = 0;
        cnt = atoi(value.c_str());
        char buf[32];
        snprintf(buf, 32, "%d", cnt + 1);
        ctx->put_object(key, buf);
        ctx->ok(buf);
    }
    DEFINE_METHOD(Counter, get) {
        xchain::Context* ctx = self.context();
        const std::string& key = ctx->arg("key");
        std::string value;
        if (ctx->get_object(key, &value)) {
            ctx->ok(value);
        } else {
            ctx->error("key not found");
        }
    }


代码解析
>>>>>>>>>>>>>>

下面我们逐行解析合约代码：

    - **#include <xchain/xchain.h>** 为必须的，里面包含了编写合约所需要的库。

    - **struct Counter : public xchain::Contract {}**: 声明了我们的合约类，所有的合约类都要继承自 **xchain::Contract** 。

    - **DEFINE_METHOD(Counter, initialize)** 我们通过 **DEFINE_METHOD** 来为合约类定义合约方法，在这个例子里面我们为 **Counter** 类定义了一个叫 **initialize** 的合约方法。

    - **xchain::Context* ctx = self.context()** :用来获取合约的上下文，每个合约都有一个对应的合约执行上下文，通过上下文我们可以获取合约参数，写入合约数据，context对象是我们经常要操作的一个对象。

    - **const std::string& creator = ctx->arg("creator");** ，用于从合约上下文里面获取合约方法的参数，这里我们获取了名字叫 **creator** 的合约参数，合约的参数列表是一个map结构, key为合约参数的名字，value为参数对应的用户传递的值。

    - **ctx->put_object("creator", creator);** 通过合约上下文的 **put_object** 方法，我们可以向链上写入数据。

    - **ctx->ok("initialize succeed");** 用于返回合约的执行结果，如果合约执行失败则调用 **ctx->error** 。

通过上面的代码分析我们得到了如下知识

- 一个合约有多个方法组成，如counter合约的 **initialize** ， **increase** , **get** 方法。
- **initialize** 是每个合约必须实现的方法，这个合约方法会在部署合约的时候自动执行。
- 每个合约方法有一个 **Context** 对象，通过这个对象我们能获取到很多有用的方法，如获取用户参数等。
- 通过 **Context** 对象的 **ok** 或者 **error** 方法我们能给调用方反馈合约的执行情况:成功或者失败。

更多的c++语言合约例子在 XuperChain 项目的 **core/contractsdk/cpp/example** 里面寻找。

Go合约
^^^^^^^^^^^^

以counter合约为例来看如何编写一个go合约。

合约样例
>>>>>>>>>>>>>

代码在 **contractsdk/go/example/counter/counter.go**

.. code-block:: go
    :linenos:
	
    package main
    import (
        "strconv"
        "github.com/xuperchain/xuperchain/core/contractsdk/go/code"
        "github.com/xuperchain/xuperchain/core/contractsdk/go/driver"
    )
    type counter struct{}
    func (c *counter) Initialize(ctx code.Context) code.Response {
        creator, ok := ctx.Args()["creator"]
        if !ok {
            return code.Errors("missing creator")
        }
        err := ctx.PutObject([]byte("creator"), creator)
        if err != nil {
            return code.Error(err)
        }
        return code.OK(nil)
    }
    func (c *counter) Increase(ctx code.Context) code.Response {
        key, ok := ctx.Args()["key"]
        if !ok {
            return code.Errors("missing key")
        }
        value, err := ctx.GetObject(key)
        cnt := 0
        if err == nil {
            cnt, _ = strconv.Atoi(string(value))
        }
        cntstr := strconv.Itoa(cnt + 1)
        err = ctx.PutObject(key, []byte(cntstr))
        if err != nil {
            return code.Error(err)
        }
        return code.OK([]byte(cntstr))
    }
    func (c *counter) Get(ctx code.Context) code.Response {
        key, ok := ctx.Args()["key"]
        if !ok {
            return code.Errors("missing key")
        }
        value, err := ctx.GetObject(key)
        if err != nil {
            return code.Error(err)
        }
        return code.OK(value)
    }
    func main() {
        driver.Serve(new(counter))
    }


go合约的整体框架结构跟c++合约一样，在表现形式上稍微有点不一样：

- c++合约使用 **DEFINE_METHOD** 来定义合约方法，go通过结构体方法来定义合约方法。
- c++通过 **ctx->ok** 来返回合约数据，go通过返回 **code.Response** 对象来返回合约数据。
- go合约需要在main函数里面调用 **driver.Serve** 来启动合约。

更多的go语言合约例子在 XuperChain 项目的 **core/contractsdk/go/example** 里面寻找。

合约编译
>>>>>>>>>>>

Go合约使用如下命令来编译合约

.. code-block:: go
    :linenos:
	
    go build -o hello


合约部署
>>>>>>>>>>>>>

.. code-block:: bash
    :linenos:
	
    $ ./xchain-cli native deploy --account XC1111111111111111@xuper --cname hello  --fee 5200000 --runtime go ./hello-go/hello


Go合约的调用跟c++合约参数一致。

Java合约
^^^^^^^^^^^^

java合约目前只支持native合约。

如果本地搭建 XuperChain 环境，在部署、调用native合约之前，请先查看`conf/xchain.yaml` 中native一节，确保native合约功能开启。

.. code-block:: yaml
    :linenos:

    # 管理native合约的配置
    native:
        enable: true

以counter合约为例来看如何编写一个java合约。        

编译环境准备
>>>>>>>>>>>>>

编译Java sdk：Java版本不低于Java1.8版本
    
包管理器：maven，mvn版本3.6+

    .. code-block:: bash

        # 编译java sdk
        cd contractsdk/java
        mvn install -f pom.xml
        # 产出二进制文件target/java-contract-sdk-0.1.0.jar，并自动安装到mvn本地仓库下

合约样例
>>>>>>>>>>>>>

代码在 **contractsdk/java/example/counter/src/main/java/com/baidu/xuper/example/Counter.java**

.. code-block:: java
    :linenos:
	
    package com.baidu.xuper.example;

    import java.math.BigInteger;

    import com.baidu.xuper.Context;
    import com.baidu.xuper.Contract;
    import com.baidu.xuper.ContractMethod;
    import com.baidu.xuper.Driver;
    import com.baidu.xuper.Response;

    /**
    * Counter
    */
    public class Counter implements Contract {

        @Override
        @ContractMethod
        public Response initialize(Context ctx) {
            return Response.ok("ok".getBytes());
        }

        @ContractMethod
        public Response increase(Context ctx) {
            byte[] key = ctx.args().get("key");
            if (key == null) {
                return Response.error("missing key");
            }
            BigInteger counter;
            byte[] value = ctx.getObject(key);
            if (value != null) {
                counter = new BigInteger(value);
            } else {
                ctx.log("key " + new String(key) + " not found, initialize to zero");
                counter = BigInteger.valueOf(0);
            }
            ctx.log("get value " + counter.toString());
            counter = counter.add(BigInteger.valueOf(1));
            ctx.putObject(key, counter.toByteArray());

            return Response.ok(counter.toString().getBytes());
        }

        @ContractMethod
        public Response get(Context ctx) {
            byte[] key = ctx.args().get("key");
            if (key == null) {
                return Response.error("missing key");
            }
            BigInteger counter;
            byte[] value = ctx.getObject(key);
            if (value != null) {
                counter = new BigInteger(value);
            } else {
                return Response.error("key " + new String(key) + " not found)");
            }
            ctx.log("get value " + counter.toString());

            return Response.ok(counter.toString().getBytes());
        }

        public static void main(String[] args) {
            Driver.serve(new Counter());
        }
    }


java合约的整体框架结构跟c++、go合约一样，在表现形式上稍微有点不一样：

- c++合约使用 **DEFINE_METHOD** 来定义合约方法，go通过结构体方法来定义合约方法，java通过定义class类方法来定义合约。
- c++通过 **ctx->ok** 来返回合约数据，go通过返回 **code.Response** 对象来返回合约数据，java通过 **Response.ok** 来返回合约数据。
- java合约需要在main函数里面调用 **Driver.serve** 来启动合约。

更多的java语言合约例子在 XuperChain 项目的 **core/contractsdk/java/example** 里面寻找。

合约编译
>>>>>>>>>>>

java合约使用如下命令来编译合约

.. code-block:: bash

    cd contractsdk/java/example/counter
    mvn package -f pom.xml
    # 产出二进制文件target/counter-0.1.0-jar-with-dependencies.jar，用于合约部署


合约部署
>>>>>>>>>>>>>
native合约和wasm合约在合约部署和合约执行上通过 **native** 和 **wasm** 字段进行区分。

不同语言的合约通过 **--runtime** 参数进行指定，完整命令如下。

.. code-block:: bash

    # 部署golang native合约
    ./xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime java counter-0.1.0-jar-with-dependencies.jar --cname javacounter
    
- ``--runtime c`` ：表示部署的是c++合约
- ``--runtime go`` ：表示部署的是golang合约
- ``--runtime java``：表示部署的是java合约


java合约的调用跟c++、go合约参数一致。

小结
^^^^^^^^^

在这个章节里面我们学习了如何使用solidity、c++、go和java语言来编写合约，更多的合约例子可以在对应语言SDK的example目录里面寻找，在下一章节我们学习如果给合约编写单元测试。

合约单测
-----------

如果每次测试合约都需要部署到链上再发起调用会特别麻烦，xdev工具提供了单测能力，可以脱离链上环境运行合约。

test目录下放着合约测试文件，文件以 .test.js结尾，可以有多个测试文件。
以hello-cpp目录下的test/hello.test.js为例，文件内容如下:

.. code-block:: c++
    :linenos:
	
    var assert = require("assert");
    Test("hello", function (t) {
        var contract;
        t.Run("deploy", function (tt) {
            contract = xchain.Deploy({
                name: "hello",
                code: "../hello.wasm",
                lang: "c",
                init_args: {}
            })
        });
        t.Run("invoke", function (tt) {
            resp = contract.Invoke("hello", {});
            assert.equal(resp.Body, "hello world");
        })
    })


使用Test函数来定义测试case，hello为测试名字, 匿名js function作为测试的body。
全局对象xchain是我们跟xchain环境打交道的入口，xchain.Deploy用来部署一个合约到xchain环境，返回的contract对象，调用contract.Invoke方法即可调用合约。
Deploy和Invoke方法都是通过抛出异常的方式来处理错误，测试框架会自动捕获错误来结束测试case。t.Run可以定义子测试case。

使用如下命令来启动测试

.. code-block:: bash
    :linenos:
	
    $ cd hello-cpp
    $ xdev test # 测试test目录下的所有case
    === RUN   hello
    === RUN   hello/deploy
    === RUN   hello/invoke
    --- PASS: hello (0.11s)
        --- PASS: hello/deploy (0.07s)
        --- PASS: hello/invoke (0.02s)
    PASS



VSCode编辑器集成
-------------------------

配置编译和测试task
^^^^^^^^^^^^^^^^^^^^^

为了方便在vscode里面编译和测试合约，在 **.vscode/tasks.json** 里面添加如下内容

.. code-block:: json
    :linenos:
	
    {
        // See https://go.microsoft.com/fwlink/?LinkId=733558
        // for the documentation about the tasks.json format
        "version": "2.0.0",
        "tasks": [
            {
                "label": "xdev build",
                "type": "shell",
                "command": "xdev build -p",
                "options": {
                    "cwd": "${workspaceFolder}"
                },
                "group": {
                    "kind": "build",
                    "isDefault": true
                }
            },
            {
                "label": "xdev test",
                "type": "shell",
                "command": "xdev test",
                "options": {
                    "cwd": "${workspaceFolder}"
                }
            }
        ]
    }



编译合约
^^^^^^^^^^^^^^

Run Build Task(⇧⌘B)来启动构建

.. image:: ../images/xdev-build1.gif
    :align: center

跑合约单测
^^^^^^^^^^^^^

调用Run Task命令之后，选择xdev test来触发单元测试

.. image:: ../images/xdev-test.gif
    :align: center


代码补全
^^^^^^^^^^^^^^

为了让vscode帮我们自动补全代码，需要做如下配置，在项目的.vscode/settings.json文件里面加上这一个配置

.. code-block:: go
    :linenos:
	
    {
        "C_Cpp.default.compileCommands": "${workspaceFolder}/compile_commands.json"
    }


之后就能用vscode的自动补全功能了.

开放网络集成环境
---------------------

 XuperChain 开放网络是基于百度自研底层技术搭建的区块链基础服务网络，符合中国标准，超级节点遍布全国，区块链网络完全开放，为用户提供区块链快速部署和运行的环境，最低2元钱就用上的区块链服务，让信任链接更加便利。

 XuperChain 开放网络为开发者提供了合约开发、编译、部署、管理的一站式可视化集成环境，下面介绍如何在开放网络上开发部署智能合约。

.. image:: ../images/xuperos-dashboard.png
    :align: center

账户注册
^^^^^^^^^^^^

    1. 在 XuperChain 官网 https://xchain.baidu.com/ 使用百度账号登录，如果没有百度账号请先注册。
    #. 进入 XuperChain 开放网络控制台，第一次登录的用户，平台会为用户创建区块链账户，请按照创建账户指引文档完成安全码设置，并记录自己的助记词和私钥。

.. image:: ../images/xuperos-create-account.png
    :align: center
	
创建合约账户
^^^^^^^^^^^^^^^^

    1. 在工作台，选择「开放网络 —> 合约管理」，点击「创建合约账户」
    #. 进入创建合约账户页，输入安全码后点击「确认创建」，系统自动生成账户名称后，即创建完毕 
	
.. image:: ../images/xuperos-no-account.png
    :align: center
	
	
合约开发和部署
^^^^^^^^^^^^^^^^

    1. 在工作台，选择「开放网络 —> 合约管理」，点击「创建智能合约」

    #. 进入新页面，按要求填写基本信息、编辑合约代码，编译成功后点击「安装」，即可进入合约安装(部署)流程。 合约代码编译有两种方式：
	
       + 模板合约；选择模板后，只需在模板代码中填写相关参数即可（参考模板详情完成参数填写）
       + 自定义合约；在编辑器内完成C++语言的合约编辑即可

.. image:: ../images/xuperos-create-contract.png
    :align: center

3. 进入安装流程，用户需按合约代码完成预执行操作。点击「开始验证」，执行通过会进入安装确认页

        + 模板合约；系统会提供模板的函数，只需填写参数即可（可参考模板详情）
        + 自定义合约；根据页面操作说明，完成函数、参数填写 

.. image:: ../images/xuperos-install-contract.png
    :align: center

4. 进入确认安装页，页面显示安装合约预计消耗的余额。点击「安装合约」将合约上链，上链过程需要等待10S左右。安装完成后，在合约管理列表中可看到合约状态变更为‘安装成功’，即该合约已完成安装。


合约调用
^^^^^^^^^^^^

目前开放网络支持通过Go和Javascript两种SDK调用智能合约。

    - Go SDK：https://github.com/xuperchain/xuper-java-sdk
    - Javascript SDK：https://github.com/xuperchain/xuper-sdk-js

结语
-------

通过上面的学习，相信大家已经掌握了如何编写 XuperChain 智能合约的方法，想要更深入了解 XuperChain ，可以通过访问 XuperChain 开源项目 https://github.com/xuperchain/xuperchain 来获取更多的学习资料。
