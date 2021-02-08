.. _tutorial/contract-development-java:

Java合约
^^^^^^^^^^^^

预备知识
>>>>>>>>

:ref:`tutorial/cli` 


java合约目前只支持native合约。

如果本地搭建超级链环境，在部署、调用native合约之前，请先查看`conf/xchain.yaml` 中native一节，确保native合约功能开启。

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

更多的java语言合约例子在超级链项目的 **core/contractsdk/java/example** 里面寻找。

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


4. 合约调用

    调用native合约。针对不同语言实现的native合约，调用方式相同。通过合约名直接发起合约调用和查询

    .. code-block:: bash

        # 调用golang native合约，Increase方法，golangcounter为合约名
        xchain-cli native invoke --method Increase -a '{"key":"test"}' golangcounter --fee 10
        # 调用结果
        # contract response: 1
        # The gas you cousume is: 6
        # The fee you pay is: 10
        # Tx id: b387e2247780a5f5da1070a931b37c4fc7f1b68c072768053a43cffe36f2e0fb

        # 调用golang native合约，Get方法，golangcounter为合约名
        xchain-cli native query --method Get -a '{"key":"test"}' golangcounter
        # 调用结果
        # contract response: 1

        # 调用java native合约，increase方法，javacounter为合约名
        xchain-cli native invoke --method increase -a '{"key":"test"}' javacounter --fee 10
        # 调用结果
        # contract response: 1
        # The gas you cousume is: 6
        # The fee you pay is: 10
        # Tx id: 4b46d9b1292481dcac3b504d5f8031e4eff44d8514c9508f121145cfa141d9db

        # 调用java native合约，get方法，javacounter为合约名
        xchain-cli native query --method get -a '{"key":"test"}' javacounter
        # 调用结果
        # contract response: 1146398290725d36631aa70f731bc3174e6484a9a

3. 部署合约

    部署native合约。针对不同语言实现的合约，主要通过 ``--runtime`` 字段进行区分

    .. code-block:: bash

        # 部署golang native合约
        xchain-cli native deploy --account XC1111111111111111@xuper -a '{"creator":"XC1111111111111111@xuper"}' --fee 15587517 --runtime go counter --cname golangcounter
        # 部署结果
        # contract response: ok
        # The gas you cousume is: 14311874
        # The fee you pay is: 15587517
        # Tx id: af0d46f6df2edba4d9d9d07e1db457e5267274b1c9fe0611bb994c0aa7931933

        # 部署java native合约
        xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime java counter-0.1.0-jar-with-dependencies.jar --cname javacounter
        # 部署结果
        # contract response: ok
        # The gas you cousume is: 14311876
        # The fee you pay is: 15587517
        # Tx id: 875d2c9129973a1c64811d7a5a55ca80743102abc30d19f012656fa52ee0f4f7

    - ``--runtime go`` ：表示部署的是golang native合约
    - ``--runtime java``：表示部署的是java native合约

2. 编译合约 - Java

    编译Java sdk：Java版本不低于Java1.8版本
    
    包管理器：maven，mvn版本3.6+

    .. code-block:: bash

        # 编译java sdk
        cd contractsdk/java
        mvn install -f pom.xml
        # 产出二进制文件target/java-contract-sdk-0.1.0.jar，并自动安装到mvn本地仓库下

    编译native合约时，我们以contractsdk/java/example中的counter合约为例

    .. code-block:: bash

        cd contractsdk/java/example/counter
        mvn package -f pom.xml
        # 产出二进制文件target/counter-0.1.0-jar-with-dependencies.jar，用于合约部署

部署native合约
--------------

如果本地搭建超级链环境，在部署、调用native合约之前，请先查看`conf/xchain.yaml` 中native一节，确保native合约功能开启。

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

