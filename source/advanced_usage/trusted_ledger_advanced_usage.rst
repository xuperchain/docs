可信账本使用文档
==================

 XuperChain 可信账本包含如下四个核心组件：

1. mesatee-core-standalone：TEE Enclave App的开发框架，用户可以根据业务需求开发自己的应用
2. TEESDK：负责与TEE服务的通信，可实现 XuperChain SDK和 XuperChain 对TEE服务的请求
3. xuperchain： XuperChain 开源代码，支持模块的可插拔机制
4.  XuperChain SDK：负责与 XuperChain 通信，可实现交易的封装和上链、数据的加密和解密等

服务部署
--------------

如只想测试TEE的密文计算功能，只需部署TEE和TEESDK；如果想测试链上密文计算功能， 需要全部部署。

部署TEE服务
>>>>>>>>>>>>>

1. 下载mesatee-core-standalone最新代码：https://github.com/xuperdata/mesatee-core-standalone
2. 部署自己实现的app到mesatee_services/fns/sgx_trusted_lib

.. note::
  mesatee-core-standalone并未全部开源，密文计算和秘钥托管功能相关代码暂未公开，用户需根据自身需要开发可信应用。

3. 按照步骤1的文档进行编译，然后启动TEE服务

编译TEESDK
>>>>>>>>>>>>>

1. 拉取TEESDK最新代码：https://github.com/xuperdata/teesdk
2. 按照如下命令进行编译，编译前要将mesatee/teesdk.go中的 **tms_addr.sin_addr.s_addr** 修改为TEE服务部署的地址

.. code-block:: bash

	cd teesdk/mesatee
	cp /path/to/mesatee-core-standalone/release/lib/libmesatee_sdk_c.so lib/
	cd ../
	bash build.sh

3. 编译之后会在build目录产出libmesateesdk.so.0.0.1， 然后将这个文件和mesatee/xchain-plugin/teeconfig.conf拷贝到xchain的pluginPath配置的目录下面。

部署区块链
>>>>>>>>>>>>

1. 拉取 XuperChain 最新代码：https://github.com/xuperchain/xuperchain 
2. 将makefile文件中的 **-mod=vendor** 注释掉后再编译
3. 在编译产出output/conf/xchain.yaml文件中进行如下配置：

.. code-block:: go

	# 块广播模式
	blockBroadcaseMode: 0
	...
	#可信环境的入口, optional
	wasm:
	 driver: "xvm"
	 enableUpgrade: false
	 teeConfig:
	   enable: on
	   pluginPath: "/path/to/libmesateesdk.so.0.0.1"
	   configPath: "/path/to/xchain_plugin/teeconfig.conf"
	 xvm:
	   optLevel: 0
	   
	#是否开启默认的XEndorser背书服务
	enableXEndorser: true


后续部署流程见文档 `XuperChain环境部署 <../quickstart.html>`_

编译xuper-sdk-go
>>>>>>>>>>>>>>>>>>>>

1. 拉取 XuperChain SDK最新代码：https://github.com/xuperdata/xuper-sdk-go
2. 参考如下配置编辑文件conf/sdk.yaml.tee

.. code-block:: go

	tfConfig:
	  teeConfig:
		svn: 0
		enable: on
		tmsport: 8082
		uid: "uid1"
		token: "token1"
		auditors:
		  -
			publicder: /path/to/mesatee-core-standalone/release/services/auditors/godzilla/godzilla.public.der
			sign: /path/to/mesatee-core-standalone/release/services/auditors/godzilla/godzilla.sign.sha256
			enclaveinfoconfig: /path/to/mesatee-core-standalone/release/services/enclave_info.toml
	paillierConfig:
	  enable: off

3. 执行build.sh进行编译，产出main二进制文件
4. 执行main文件即可完成测试

可信应用开发
------------------

用户可根据业务需求开发自己的可信算子和应用

1. 可信算子开发参考 `trust_operators <https://github.com/xuperchain/xuperchain/tree/master/core/contractsdk/cpp/src/xchain/trust_operators>`_  和 `demo_func <https://github.com/xuperdata/mesatee-core-standalone/blob/master/mesatee_services/fns/sgx_trusted_lib/src/trusted_worker/demo_func.rs>`_ 
#. 可信应用开发参考合约 `data_auth <https://github.com/xuperchain/xuperchain/tree/master/core/contractsdk/cpp/example/data_auth>`_
#. 可信合约相关测试参考 `data_auth_test <https://github.com/xuperdata/xuper-sdk-go/blob/master/example/main_data_auth.go>`_
#. mesatee-core-standalone服务相关测试参考 `teesdk_test <https://github.com/xuperdata/teesdk/blob/master/mesatee/teesdk_test.go>`_


