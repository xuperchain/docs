
本章节将指导您获取XuperChain的代码并部署一个基础的可用环境，还会展示一些基本操作

.. _env-deploy:

XuperChain环境部署
------------------

.. _env-prepare:

准备环境
^^^^^^^^

XuperChain主要由Golang开发，需要首先准备编译运行的环境

- 安装go语言编译环境，版本为1.11或更高
    - 下载地址：`golang <https://golang.org/dl/>`_
- 安装git
    - 下载地址：`git <https://git-scm.com/download>`_

.. _env-compiling:

编译XuperChain
^^^^^^^^^^^^^^

- 使用git下载源码到本地

    - git clone https://github.com/xuperchain/xuperchain.git

- 执行命令

.. code-block:: bash

    $ cd xuperchain
    $ make

- 在output目录得到bin，conf， data 三个文件夹以及一个 control.sh 脚本


.. note::

    make 时，可能出现拉取失败的情况，可以配置GOPROXY解决此问题
    
    $ export GOPROXY=https://goproxy.cn,direct

    GOPATH问题报错,不推荐使用go1.11版本之前的版本

    GCC版本需要升级到4或5以上


.. _basic-operation:

XuperChain基本操作
------------------

在output下，有bin, conf, data三个目录,以及一个control.sh 脚本

各目录的功能如下表：

.. list-table::
   :widths: 5 100
   :header-rows: 1

   * -  目录名
     -  功能
   * - output/
     - 节点根目录
   * - ├─ bin
     - 可执行文件存放目录
   * - │  ···   ├─ wasm2c  
     - 账本目录(智能合约会用到)     
   * - │  ···   ├─ xchain  
     - xchain服务的二进制文件
   * - │  ···   ├─ xchain-cli
     - xchain客户端工具
   * - ├─ conf 
     - 配置相关目录
   * - │  ···   ├─ xchain.yaml
     - xchain服务的配置信息（注意端口冲突）
   * - │  ···   ├─ engine.yaml
     - 引擎相关配置
   * - │  ···   ├─ env.yaml
     - 本地环境相关配置，设置key存储路径等
   * - │  ···   ├─ ledger.yaml
     - 存储引擎相关配置，levelDB等
   * - │  ···   ├─ log.yaml
     - 日志相关配置，日志级别，保留时间等
   * - │  ···   ├─ network.yaml
     - 网络相关配置，单机多节点配置时需更改端口等
   * - │  ···   ├─ server.yaml
     - 服务相关配置，如端口，tls等
   * - │  ···   ├─ xchain-cli.yaml
     - xchain客户端相关配置，交易是否需要配置，交易发送节点等
   * - ├─ control.sh 
     - 启动脚本
   * - ├─ data 
     - 数据的存放目录，创世块信息，以及共识和合约的样例   
   * - │  ···   ├─ blockchain
     - 账本目录
   * - │  ···   ├─ keys 
     - 此节点的地址，具有全局唯一性     
   * - │  ···   ├─ netkeys
     - 此节点的网络标识ID，具有全局唯一性
   * - │  ···   └─ config 
     - 包括创始的共识，初始的资源数，矿工奖励机制等
   * - ├─ logs  
     - 程序日志目录 
   * - ├─ tmp  
     - 临时文件夹，目前存储进程pid  
  
.. _svr-deploy:

部署xchain服务
^^^^^^^^^^^^^^

.. _start-chain:

启动服务
>>>>>>>>>>>>

xuper5为我们启动服务提供了方便的脚本，只需要一条命令使用controll.sh脚本启动即可。

.. code-block:: bash


    # 启动xuper链
    $ bash control.sh start 
    /home/ubuntu/go/src/github.com/xuperchain/output/bin/xchain
    /home/ubuntu/go/src/github.com/xuperchain/output/conf/env.yaml
    2021/08/10 19:26:57 start create chain.bc_name:xuper genesis_conf:./data/genesis/xuper.json env_conf:./conf/env.yaml
    2021/08/10 19:26:57 create ledger succ.bc_name:xuper start xchain. cmd:nohup /home/ubuntu/go/src/github.com/xuperchain/output/bin/xchain startup --conf /home/ubuntu/go/src/github.com/xuperchain/output/conf/env.yaml >/home/ubuntu/go/src/github.com/xuperchain/output/logs/nohup.out 2>&1 &
    .start proc succ.
    start finish.pid:17242
    Done!



这样，我们就成功启动一条链。

control.sh 脚本提供 start | stop | restart | forcestop 四个命令，可以使用bash control.sh help查看

.. _svr-start:

确认服务状态
>>>>>>>>>>>>>>>>>>

按照默认配置，xchain服务会监听37101端口，可以使用如下命令查看xchain服务的运行状态

.. code-block:: bash

    # check服务运行状况
    $ bin/xchain-cli status -H 127.0.0.1:37101
    {
      "blockchains": [
      {
        "name": "xuper",
        "ledger": {
          "rootBlockid": "d93c260ea5639a55e1fcad3df494495efad5c65d46e846b6db3a9194a4212886",
          "tipBlockid": "9555ca5af579db67734f27013dfaae48d93e4c3e8adcf6ca8f3dc1adb06d0b6f",
          "trunkHeight": 137
        },
        ....
            "9555ca5af579db67734f27013dfaae48d93e4c3e8adcf6ca8f3dc1adb06d0b6f"
         ]
        }
      ],
     "peers": null,
     "speeds": {}
   }

.. _basic-usage:

基本功能的使用
^^^^^^^^^^^^^^

.. _create-account:

创建新账号
>>>>>>>>>>

xchain中，账号类型分为“普通账号”和“合约账号”。

普通账号有程序离线生成，在本地保存；

合约账号是XuperChain中用于智能合约管理的单元，由普通账户发起交易，在链上生成的一个16位数字的账户，存储在链上。发起合约相关交易，比如合约调用时，需要使用合约账户。

.. code-block:: bash

    # 创建普通用户, 生成的地址，公钥，私钥在--output 指定位置
    $ bin/xchain-cli account newkeys --output data/bob
    create account using crypto type default
    create account in data/bob

    ## 创建合约账号
    bin/xchain-cli account new --account 1111111111111111 --fee 2000
    
在data/bob目录下会看到文件address，publickey，privatekey生成

.. _balance:

查询资源余额
>>>>>>>>>>>>

对于普通账号，可使用如下命令查询账号资源余额，其中 -H 参数为xchain服务的地址

.. code-block:: bash


    # 根据账户存储的路径，查询该账户的余额。--keys为要查询的账户的地址
    $ bin/xchain-cli account balance --keys data/keys
    100000000000338000000

    # 根据地址查询该账户余额
    $ bin/xchain-cli account balance TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY
    100000000000401000000

    
.. _transfer:

转账
>>>>

转账操作需要提供源账号的私钥目录，也就类似“2.1.1 创建新账号”中生成的目录，这里注意到并不需要提供目标账号的任何密钥，只需要提供地址即可

.. code-block:: bash
    
    # --keys 从此地址 转给 --to地址 --amount 金额
    $ bin/xchain-cli transfer --to czojZcZ6cHSiDVJ4jFoZMB1PjKnfUiuFQ --amount 10 --keys data/keys/ -H 127.0.0.1:37101
    24d53ea6e61ede8dc4fe65a04fd30da17c079a359e700738f8795dfddc55ffb4

命令执行的返回是转账操作的交易id（txid）


.. _querytx:

查询交易信息
>>>>>>>>>>>>

通过以下命令可以查询交易的信息，包括交易状态、交易的源和目标账号、交易的金额、所在的区块（如果已上链）等内容

.. code-block:: bash
    :linenos:

    # 可查询上一步生成的txid的交易信息
    $ bin/xchain-cli tx query 24d53ea6e61ede8dc4fe65a04fd30da17c079a359e700738f8795dfddc55ffb4 -H 127.0.0.1:37101
    {
       "txid": "24d53ea6e61ede8dc4fe65a04fd30da17c079a359e700738f8795dfddc55ffb4",
       "blockid": "e83eae0750d0f48cc2b45f25d853fb587d124552851bf6693757e0715837b377",
       "txInputs": [
        {
          "refTxid": "2650aa0c0e8088def98093a327b475fa7577fa8e266c5775435f7c022fe0f463",
          "refOffset": 0,
          "fromAddr": "TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY",
          "amount": "1000000"
        }
       ],
      ......
      "authRequireSigns": [
       {
          "publickey": "{\"Curvname\":\"P-256\",\"X\":36505150171354363400464126431978257855318414556425194490762274938603757905292,\"Y\":79656876957602994269528255245092635964473154458596947290316223079846501380076}",
          "sign": "30460221009509e35b1341284b5d1f22b48c862ecfe2856056196c5650bc203b8a4ed0d454022100f8d286c63ad8eb3bc605bc08da4ff417aaff3c0433a31039f608bb47a90b1267"
        }
       ],
      "receivedTimestamp": 1628596303271475925,
      "modifyBlock": {
        "marked": false,
        "effectiveHeight": 0,
        "effectiveTxid": ""
      }
    }


.. _queryblock:

查询block信息
>>>>>>>>>>>>>

通过blockid可以查询区块的相关信息，包括区块内打包的交易、所在链的高度、前驱/后继区块的id等内容

.. code-block:: bash

    # 可查询上一步交易所在的block id信息
    $ bin/xchain-cli block e83eae0750d0f48cc2b45f25d853fb587d124552851bf6693757e0715837b377 -H 127.0.0.1:37101

    {
      "version": 1,
      "blockid": "e83eae0750d0f48cc2b45f25d853fb587d124552851bf6693757e0715837b377",
      "preHash": "41c74e22ccea7dcf1db6ba0d7e1eefd6cfbd7bac7659c3d8cd33d2a009201003",
      "proposer": "TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY",
      "sign": "3044021f349da2d5c238175a6e7df23262eeb122014f0a0040fc4ce109a3ab2c22b2700221009d92198061193fcd47e25c8f5c2b54e1ea2ffb4aaab675384c4d6408ab2b63de",
      "pubkey": "{\"Curvname\":\"P-256\",\"X\":36505150171354363400464126431978257855318414556425194490762274938603757905292,\"Y\":79656876957602994269528255245092635964473154458596947290316223079846501380076}",
      "merkleRoot": "d22d2423a93911e42f96370167d878f6780fea44fac6a13771c7532e1969c949",
      "height": 492,
      ......
      "txCount": 2,
      "merkleTree": [
        "4a7e42654cf79d6525f6b6d55673b57a92048ee96de950e962db99b102e048a4",
        "24d53ea6e61ede8dc4fe65a04fd30da17c079a359e700738f8795dfddc55ffb4",
        "d22d2423a93911e42f96370167d878f6780fea44fac6a13771c7532e1969c949"
      ],
      "inTrunk": true,
      "nextHash": "a541ed97789537166bec5778aad7ba0f68e52a04d1073b244ee1ea6cd38d8f63",
      "failedTxs": null,
      "curTerm": 0,
      "curBlockNum": 0,
      "justify": {}
    }
