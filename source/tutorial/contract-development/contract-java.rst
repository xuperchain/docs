Java合约
^^^^^^^^^^^^

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

