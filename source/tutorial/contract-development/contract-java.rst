.. _tutorial/contract-development-java:

Java合约
^^^^^^^^^^^^

预备知识
>>>>>>>>

:ref:`tutorial/cli` 

.. note::

    请先完成 :ref:`tutorial/cli`  中的教程，以确设置对应账号和权限
    
1.合约样例
>>>>>>>>>>>

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

2.合约编译
>>>>>>>>>>>

.. code-block:: bash

    cd contractsdk/java/example/counter
    mvn package -f pom.xml
    # 产出二进制文件target/counter-0.1.0-jar-with-dependencies.jar，用于合约部署


3.合约部署
>>>>>>>>>>>>>

.. code-block:: bash

    xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime java targets/counter-0.1.0-jar-with-dependencies.jar --cname counter
    

4. 合约调用
>>>>>>>>>>>>>

    .. code-block:: bash

        $ xchain-cli native invoke --method increase -a '{"key":"test"}' counter --fee 10
         contract response: 1
         The gas you cousume is: 6
         The fee you pay is: 10
         Tx id: 4b46d9b1292481dcac3b504d5f8031e4eff44d8514c9508f121145cfa141d9db

        $ xchain-cli native query --method get -a '{"key":"test"}' counter
        contract response: 1146398290725d36631aa70f731bc3174e6484a9a