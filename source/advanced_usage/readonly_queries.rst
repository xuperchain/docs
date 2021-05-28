只读跨链场景使用文档
=======================

跨链的背景知识可以参考 XuperChain 的技术文档 ` XuperChain 跨链技术 <../design_documents/cross_chain.html>`_ ，这里介绍一下 XuperChain 跨链只读使用说明。

B网络搭建
--------------

搭建B网络，设置背书配置为true，部署被调用合约B,例如counter：

.. code-block:: go
	:linenos:
	
	1. xchain.yaml增加配置： enableXEndorser: true
	2. 配置节点背书公私钥，./data/endorser/keys 目录下，增加背书地址及公私钥；
	
A网络搭建
---------------

搭建A网络，部署跨链寻址合约，部署测试合约A用于查看B网络的counter合约；

部署查询合约A
^^^^^^^^^^^^^^^

查询合约可参考：core/contractsdk/cpp/example/cross_query_demo/src/main.cc

.. code-block:: go
	:linenos:

	DEFINE_METHOD(Hello, cross_query) {
		xchain::Context* ctx = self.context();
		xchain::Response response;
		// 合约SDK 增加cross query方法
		ctx->cross_query("xuper://mainnet.xuper?module=wasm&bcname=xuper&contract_name=counter&method_name=get", {{"key", "zq"}}, &response); 
		*ctx->mutable_response() = response; 
	}
	
部署跨链寻址合约
^^^^^^^^^^^^^^^^

 XuperChain 提供了默认的寻址合约（crossQueryNaming）的实现，路径为core/contractsdk/cpp/example/naming/src/naming.cc。在 core/contractsdk/cpp 目录下执行 sh build.sh 即可编译生成 naming.wasm ，即可使用 naming.wasm实现寻址合约的部署。

创建合约账户
^^^^^^^^^^^^^^^^
::

    ./xchain-cli account new --account 1111111111111111 --fee 1000
    ./xchain-cli transfer --to XC1111111111111111@xuper --amount 9999999999999999    ##给合约账号充钱

部署wasm
^^^^^^^^^^^^^^^^

#注意：合约名必须为crossQueryNaming
::
    ./xchain-cli wasm deploy -n crossQueryNaming ./naming.wasm  --account XC1111111111111111@xuper --fee xxxxx

注册链名
^^^^^^^^^^^^^^^^^
::

    ./xchain-cli wasm invoke crossQueryNaming --method RegisterChain -a '{"name":"mainnet.xuper","type":"xuper", "min_endorsor_num":"2"}' --fee 888

- name：B网络.链名
- type：链的种类， XuperChain 
- min_endorsor_num： 表示背书个数

添加信任节点
^^^^^^^^^^^^^^^^^^

#注意此处address及pub_key在./data/endorser/keys下
::

    ./xchain-cli wasm invoke crossQueryNaming --method AddEndorsor -a '{"name":"mainnet.xuper", "address":"bobfffff", "host":"ip1:port1", "pub_key":"xxxxx"}' --fee 555

    ./xchain-cli wasm invoke crossQueryNaming --method AddEndorsor -a '{"name":"mainnet.xuper", "address":"alicefffff", "host":"ip2:port2", "pub_key":"yyyyy"}' --fee 555
 
- address：背书地址
- host：背书节点ip:port
- pub_key: 背书公钥

链名解析
^^^^^^^^^^^^^^^^^^^
::

    ./xchain-cli wasm query crossQueryNaming --method Resolve -a '{"name":"mainnet.xuper"}'

跨链查询
---------------------

B网络调用counter
^^^^^^^^^^^^^^^^^^^

在B网络调用counter合约，自增key值并查询自增后的结果：
::

    ./xchain-cli wasm invoke counter --method increase -a '{"key":"zq"}'--fee 100-H=ipB:portB
    ./xchain-cli wasm invoke counter --method get -a '{"key":"zq"}'--fee 100-H=ipB:portB
	
A网络调用crossQueryNaming
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

在A网络调用crossQueryNaming查询，即实现跨链查询B网络xuper链上counter合约key值结果：
::

    ./xchain-cli wasm invoke cross_query_demo --method cross_query -H=ipA:portA

