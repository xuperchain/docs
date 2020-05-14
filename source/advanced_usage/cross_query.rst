
使用跨链查询功能
================


跨链查询的接口
--------------

跨链查询的接口十分简单，只有cross_query

.. code-block:: c++
    :linenos:

    class Context {
        public:
            virtual bool cross_query(const std::string& uri, 
                            const std::map<std::string, std::string>& args,
                            Response* response) = 0; 
    }

在跨链查询之前，需要部署naming合约到链,合约代码为 core/contractsdk/cpp/example/naming
注意：这里部署naming合约名字固定为 crossQueryNaming

正常部署后，按如下命令执行即可

注册外链的元信息

.. code-block:: bash
    :linenos:

    ./xchain-cli wasm invoke crossQueryNaming --method RegisterChain -a '{"name":"test.xuper","type":"xuper","min_endorsor_num":"1"}' -H 127.0.0.1:37101 

min_endorsor_num要求至少有几个人背书，如果背书节点个数都小于这个数目，那么验证的时候一定过不了背书策略的检查

注册信任的背书节点

.. code-block:: bash
    :linenos:

    ./xchain-cli wasm invoke crossQueryNaming --method AddEndorsor -a '{"name":"test.xuper","address":"WwLgfAatHyKx2mCJruRaML4oVf7Chzp42", "host":"127.0.0.1:37101", "pub_key": "{\"Curvname\":\"P-256\",\"X\":59572894642662849351951007648381266067965665107900867144213709334891664628384,\"Y\":8048742862014975230056503560798576017872466904786606109303178975385452397337}"}' -H 127.0.0.1:37101 

背书节点信息在 data/endorser/keys下，个人按照自己的进行修改


目标链需要开启背书服务，位于代码目录下的 conf/xchain.yaml 

.. code-block:: bash
    :linenos:

    # 是否开启默认的XEndorser背书服务
    enableXEndorser: true

跨链查询的调用
--------------

目标链部署counter合约

原链跨链查询的合约例子，代码位于 core/contractsdk/cpp/example/cross_query_demo

正常部署后，按如下命令执行即可

.. code-block:: bash
    :linenos:

    ./xchain-cli wasm invoke --method get cross
    