
.. _network-deploy:

网络部署
------------------

本节内容将手把手教你使用XuperChain搭建一个3节点的区块链网络。帮助开发者掌握XuperChain网络的部署流程。

.. _read-prepare:

前置阅读
^^^^^^^^
在阅读本节前，请先阅读 `XuperChain环境部署 <../quickstart/quickstart.html#xuperchain>`_  和 `XuperChain基本操作 <../quickstart/quickstart.html#basic-operation>`_ ，了解XuperChain单节点网络部署和基本操作等。


.. _envioment-prepare:

准备环境
^^^^^^^^
**1. 创建网络部署环境**

.. code-block:: bash

    # 在xuperchain目录执行
    make testnet


**2. 查看网络部署环境**

.. code-block:: bash

    tree testnet


可以看到如下部署环境，其中有3个节点，分别为node1、node2、node3。

.. code-block:: bash

    testnet
    ├── node1
    │   ├── bin
    │   │   ├── wasm2c
    │   │   ├── xchain
    │   │   └── xchain-cli
    │   ├── conf
    │   │   ├── contract.yaml
    │   │   ├── engine.yaml
    │   │   ├── env.yaml
    │   │   ├── ledger.yaml
    │   │   ├── log.yaml
    │   │   ├── network.yaml
    │   │   ├── server.yaml
    │   │   └── xchain-cli.yaml
    │   ├── control.sh
    │   └── data
    │       ├── genesis
    │       │   ├── poa.json
    │       │   ├── pow.json
    │       │   ├── tdpos.json
    │       │   ├── xpoa.json
    │       │   ├── xpos.json
    │       │   └── xuper.json
    │       ├── keys
    │       │   ├── address
    │       │   ├── private.key
    │       │   └── public.key
    │       └── netkeys
    │           ├── cacert.pem
    │           ├── cert.pem
    │           ├── net_private.key
    │           └── private.key
    ├── node2
    │   ├── bin
    │   │   ├── wasm2c
    │   │   ├── xchain
    │   │   └── xchain-cli
    │   ├── conf
    │   │   ├── contract.yaml
    │   │   ├── engine.yaml
    │   │   ├── env.yaml
    │   │   ├── ledger.yaml
    │   │   ├── log.yaml
    │   │   ├── network.yaml
    │   │   ├── server.yaml
    │   │   └── xchain-cli.yaml
    │   ├── control.sh
    │   └── data
    │       ├── genesis
    │       │   ├── poa.json
    │       │   ├── pow.json
    │       │   ├── tdpos.json
    │       │   ├── xpoa.json
    │       │   ├── xpos.json
    │       │   └── xuper.json
    │       ├── keys
    │       │   ├── address
    │       │   ├── private.key
    │       │   └── public.key
    │       └── netkeys
    │           ├── cacert.pem
    │           ├── cert.pem
    │           ├── net_private.key
    │           └── private.key
    └── node3
    ├── bin
    │   ├── wasm2c
    │   ├── xchain
    │   └── xchain-cli
    ├── conf
    │   ├── contract.yaml
    │   ├── engine.yaml
    │   ├── env.yaml
    │   ├── ledger.yaml
    │   ├── log.yaml
    │   ├── network.yaml
    │   ├── server.yaml
    │   └── xchain-cli.yaml
    ├── control.sh
    └── data
        ├── genesis
        │   ├── poa.json
        │   ├── pow.json
        │   ├── tdpos.json
        │   ├── xpoa.json
        │   ├── xpos.json
        │   └── xuper.json
        ├── keys
        │   ├── address
        │   ├── private.key
        │   └── public.key
        └── netkeys
            ├── cacert.pem
            ├── cert.pem
            ├── net_private.key
            └── private.key


.. _p2p-config:

网络配置说明
^^^^^^^^^^^^
.. note:: 上述创建好的部署环境，网络已经默认配置好，此段仅仅是为了说明，开发者也可以跳过此小节，直接调到 `启动网络 <../advanced_usage/multi_nodes.html#net-start>`_ 章节

节点加入网络需要通过网络中一个或者多个种子节点，区块链网络中任何一个节点都可以作为种子节点，通过配置种子节点的网络连接地址netURL可以加入网络。

**1. 查看种子节点netURL**

假设我们设定node1、node2、node3都是种子节点，分别查看3个节点的netURL

.. code-block:: bash

    # 查看node1节点连接地址netURL
    cd node1
    ./bin/xchain-cli netURL preview
    # 得到如下结果，实际使用时，需要将ip配置节点的真实ip，port配置成
    /ip4/{{ip}}/tcp/{{port}}/p2p/Qmf2HeHe4sspGkfRCTq6257Vm3UHzvh2TeQJHHvHzzuFw6

    # 查看node2节点连接地址netURL
    cd ../node2
    ./bin/xchain-cli netURL preview
    /ip4/{{ip}}/tcp/{{port}}/p2p/QmQKp8pLWSgV4JiGjuULKV1JsdpxUtnDEUMP8sGaaUbwVL

    # 查看node3节点连接地址netURL
    cd ../node3
    ./bin/xchain-cli netURL preview
    /ip4/{{ip}}/tcp/{{port}}/p2p/QmZXjZibcL5hy2Ttv5CnAQnssvnCbPEGBzqk7sAnL69R1E

如果想给节点分配一个新的网络连接地址，可以使用如下命令:

.. code-block:: bash

    cd node1
    ./bin/xchain-cli netURL gen


**2. p2p网络配置**

.. code-block:: bash

    # 查看
    cd node1
    cat conf/network.yaml


.. code-block:: bash

    # p2p network config

    # Module is the name of p2p module plugin.(p2pv1 | p2pv2)
    module: p2pv2
    # Port the p2p network listened
    port: 47101
    # Address multiaddr string
    address: /ip4/127.0.0.1/tcp/47101
    # IsTls config the node use tls secure transparent
    isTls: true
    # KeyPath is the netdisk private key path
    keyPath: netkeys
    # BootNodes config the bootNodes the node to connect
    bootNodes:
      - "/ip4/127.0.0.1/tcp/47101/p2p/Qmf2HeHe4sspGkfRCTq6257Vm3UHzvh2TeQJHHvHzzuFw6"
      - "/ip4/127.0.0.1/tcp/47102/p2p/QmQKp8pLWSgV4JiGjuULKV1JsdpxUtnDEUMP8sGaaUbwVL"
      - "/ip4/127.0.0.1/tcp/47103/p2p/QmZXjZibcL5hy2Ttv5CnAQnssvnCbPEGBzqk7sAnL69R1E"
    # service name
    serviceName: localhost

.. note:: 注意: 如果您是部署在同一个节点上，p2p模块端口应该配置不同，同时不要和其他已经被占用的端口冲突


.. _net-start:

启动网络
^^^^^^^^

进入每个节点部署路径，分别启动每个节点:

.. code-block:: bash

    cd ./testnet/node1
    sh ./control.sh start
 # 如果sh命令运行不成功的话可以使用bash命令
 #  bash ./control.sh start

    cd ../node2
    sh ./control.sh start
 # 如果sh命令运行不成功的话可以使用bash命令
 #  bash ./control.sh start

    cd ../node3
    sh ./control.sh start
 # 如果sh命令运行不成功的话可以使用bash命令
 #  bash ./control.sh start


.. _net-state:

确认服务状态
^^^^^^^^^^^^

分别查看每个节点运行状态：

.. code-block:: bash

    ./bin/xchain-cli status -H :37101
    ./bin/xchain-cli status -H :37102
    ./bin/xchain-cli status -H :37103


.. _net-join:

在已运行的网络中添加节点
^^^^^^^^^^^^^^^^^^^^

现在我们要向当前网络添加node4, 首先需要制作一个节点：

.. code-block:: bash

    # copy node1 为node4
    cp -Rf node1 ./node4
    cd node4


**调整端口**

xuperchain 的端口配置分别在 conf/network.yaml(p2p网络配置) 与 conf/server.yaml(系统端口配置) 中。

将server.yaml 中以下端口修改:

.. code-block:: yaml

    # Rpc service listen port
    rpcPort: 37104
    # GWPort
    GWPort: 37304
    # MetricPort
    metricPort: 37204

在调整 conf/network.yaml 之前，我们需要先给node4重新生成一个keys:

.. code-block:: bash

    ./bin/xchain-cli account newkeys -f

    # output
    create account using crypto type default
    create account in ./data/keys

给node4重新分配一个网络连接地址并查看:

.. code-block:: bash

    ./bin/xchain-cli netURL gen
    ./bin/xchain-cli netURL preview

    # output
    /ip4/127.0.0.1/tcp/47101/p2p/QmPJP37mZBUeAe9AqbbAtapCkEibU45T2MYw4brYPLoQH7

修改 conf/network.yaml 中的端口，并且在bootNodes 中加入node1的netURL:

.. code-block:: yaml

    # p2p network config

    # Module is the name of p2p module plugin.(p2pv1 | p2pv2)
    module: p2pv2
    # Port the p2p network listened
    port: 47104
    # Address multiaddr string
    address: /ip4/127.0.0.1/tcp/47104
    # IsTls config the node use tls secure transparent
    isTls: false
    # KeyPath is the netdisk private key path
    keyPath: netkeys
    # BootNodes config the bootNodes the node to connect
    bootNodes:
    # node1 的 netURL
    - "/ip4/127.0.0.1/tcp/47101/p2p/Qmf2HeHe4sspGkfRCTq6257Vm3UHzvh2TeQJHHvHzzuFw6"
    # service name
    serviceName: localhost

**启动节点**

.. code-block:: bash

    bash control.sh start

    # 查看状态
    ./bin/xchain-cli status -H :37104

    # output 中的 peers 可以看到已经链接到网络。
    "peers": [
    "/ip4/127.0.0.1/tcp/47102/p2p/QmQKp8pLWSgV4JiGjuULKV1JsdpxUtnDEUMP8sGaaUbwVL",
    "/ip4/127.0.0.1/tcp/47103/p2p/QmZXjZibcL5hy2Ttv5CnAQnssvnCbPEGBzqk7sAnL69R1E",
    "/ip4/127.0.0.1/tcp/47101/p2p/Qmf2HeHe4sspGkfRCTq6257Vm3UHzvh2TeQJHHvHzzuFw6"
    ],

    # 看node1 的 peers
    ./bin/xchain-cli status -H :37101

    # output peers 中也发现了我们新加入的 node4
    "peers": [
    "/ip4/127.0.0.1/tcp/47104/p2p/QmPJP37mZBUeAe9AqbbAtapCkEibU45T2MYw4brYPLoQH7",
    "/ip4/127.0.0.1/tcp/47103/p2p/QmZXjZibcL5hy2Ttv5CnAQnssvnCbPEGBzqk7sAnL69R1E",
    "/ip4/127.0.0.1/tcp/47102/p2p/QmQKp8pLWSgV4JiGjuULKV1JsdpxUtnDEUMP8sGaaUbwVL"
    ],


常见问题
^^^^^^^^^^^^
- 端口冲突：注意如果在一台机器上部署多个节点，各个节点的RPC监听端口以及p2p监听端口都需要设置地不相同，避免冲突；
- 不同节点公私钥和netURL冲突：注意网络中不同节点./data/keys下的文件和./data/netkeys下的内容都应该不一样，这两个文件夹是节点在网络中的唯一标识，每个节点需要独自生成，否则网络启动异常；
- 启动时连接种子节点失败：注意要先将种子节点启动，再起动其他节点，否则会因为加入网络失败而启动失败；
