
平行链、群组与CA中心
========================
XuperChain 在联盟链场景提供了整套解决方案，例如支持平行链、群组，同时提供了 XuperFront 与XuperChain 共同作为全节点，以支持节点权限管理、CA、证书等功能。
本章节主要介绍通过 `XuperFront <https://github.com/xuperchain/xuper-front>`_ 与 `XuperCA <https://github.com/xuperchain/xuper-ca>`_ 搭建联盟链场景的网络，同时介绍平行链与群组的功能。


下载编译
-----------
本章节中以 XuperChain 项目下的 testnet 为例，同时搭配 XuperFront 与 XuperCA 一起搭建三个节点的网络并启用证书功能。

1. 下载 xchain，并编译。

    .. code-block:: bash

        git clone https://github.com/xuperchain/xuperchain.git 
        cd xuperchain 
        make 
        make testnet
        #会创建 testnet 目录，同时下面有node1-3三个目录

2. 下载 ca，并编译。

    .. code-block:: bash

        git clone https://github.com/xuperchain/xuper-ca.git 
        cd xuper-ca 
        make 

3. 下载 xfront，并编译。

    .. code-block:: bash
    
        git clone https://github.com/xuperchain/xuper-front.git 
        cd xuper-front 
        make

4. 拷贝文件。将编译好的 front 文件拷贝到 testnet 下的每个节点的 bin 目录下：

    .. code-block:: bash
    
        #在 xuper-fonrt/output 目录下执行。
        cp front/bin/front xuperchain/testnet/node1/bin/
        cp front/conf/front.yaml xuperchain/testnet/node1/conf/
        #注意，以上命令为示例，目录结构要依照自己的环境，目的将 front 的可执行文件与配置文件拷贝到 xchain 节点目录下。
        #同时要拷贝到 testnet 下的 node1、node2、node3 下。

CA 服务启动
---------------

1. 修改 CA 配置文件。
   
   在 CA 的编译产出目录下，有 bin/ca-server 可执行文件以及 conf/caserver.yaml 配置文件，其中一个配置内容为 caAdmin，代表 CA 的根管理员，可以执行 CA 所有操作。
   由于本次搭建的是 XuperChain 下的 testnet 三个节点网络，方便起见，将 node1 的节点地址设置为 CA 的根管理员。将 CA 的配置文件改为如下：

    .. code-block:: bash
    
        # ca的根管理员账户, 该账户可执行ca内的所有操作
        caAdmin: TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY
        #此地址为 node1 节点 data/keys/address 地址

2. 启动 CA。启动 CA 服务前，你需要先创建网络以及向网络中添加节点。

    .. code-block:: bash

        # 初始化
        ./bin/ca-server init
        #添加网络
        ./bin/ca-server addNet --Net testnet --Addr $adminAddr
        # Net 为网络名称，Addr 为网络管理员的地址

        #网络中添加节点
        ./bin/ca-server addNode --Net testnet --Addr $testAddr --Admin $adminAddr
        # 这里Addr 一定是网络中所有节点下的 data/keys/address 的地址，否则拉不到证书。

        #启动ca
        nohup ./bin/ca-server &

xfront 与 xchain 配置和启动
------------------------------------
本次搭建的网络中，xfront 与 xchain 共同作为一个节点，xfront 作为 xchain 的代理，所以你需要先配置好配置文件。

1. 修改 xfront 配置。下面以 node1 的配置为例，其他两个节点配置类似，只是端口不同。
   node1 xfront 配置修改部分如下：

    .. code-block:: bash

        # xchain地址配置
        xchainServer:
        # 对应 xchain 的节点 rpc 端口，每个 xchain 节点配置不同，在 xchain 的 server.yaml 文件中。
        rpc: :37101
        # xchain tls的地址,如果不用的话可以不配置
        host: 127.0.0.1:47101
        # front 作为xchain代理对其他xchain服务的端口号
        port: :57101
        # front证书地址
        tlsPath: ./data/cert
        master: xuper

        # 数据库配置 ./data/db/ca.db
        dbConfig:
        dbType: sqlite3
        #dbType: mysql
        dbPath: /tmp/ca.db
        mysqlDbUser: root
        mysqlDbPwd: 123456
        mysqlDbHost: 127.0.0.1
        mysqlDbPort: 3306
        mysqlDbDatabase: front_db

        # CA地址
        caConfig:
        # 远程ca开关, 联盟网络true/公开网络false,  默认true
        caSwitch: true
        # 远程ca地址
        host: 127.0.0.1:8098

        # 当前节点的网络名称，此处配置很关键。
        netName: testnet

2. xchain 配置文件修改，修改 xchain 的 network.yaml 配置文件如下（本示例同样以 node1 为例）：

    .. code-block:: bash

        # p2p network config

        # Module is the name of p2p module plugin.(p2pv1 | p2pv2)
        module: p2pv1
        # Port the p2p network listened
        port: 47101
        # Address multiaddr string
        address: /ip4/127.0.0.1/tcp/47101
        # IsTls config the node use tls secure transparent
        isTls: true
        # KeyPath is the netdisk private key path
        keyPath: netkeys

        staticNodes:
        xuper: # 这里就是 xfront 端口配置。
            - "127.0.0.1:57101"
            - "127.0.0.1:57102"
            - "127.0.0.1:57103"
        hello: # 此处配置用于平行链。
            - "127.0.0.1:57101"

        # BootNodes config the bootNodes the node to connect
        #bootNodes:
        #  - "/ip4/127.0.0.1/tcp/47101/p2p/Qmf2HeHe4sspGkfRCTq6257Vm3UHzvh2TeQJHHvHzzuFw6"
        #  - "/ip4/127.0.0.1/tcp/47102/p2p/QmQKp8pLWSgV4JiGjuULKV1JsdpxUtnDEUMP8sGaaUbwVL"
        #  - "/ip4/127.0.0.1/tcp/47103/p2p/QmZXjZibcL5hy2Ttv5CnAQnssvnCbPEGBzqk7sAnL69R1E"
        # service name
        serviceName: testnet

3. 启动节点，需要分别启动 node1、node2、node3 的 xfront。

    .. code-block:: bash

        nohup ./bin/front &
        
        # xfront 启动后，会生成 cert 目录，将内容拷贝到 netkeys 目录下。
        cd data
        cp cert/* netkeys/

平行链与群组
------------------
- 平行链：相对于主链而言，运行在 XuperChain 中的用户级区块链实例，用户通过调用主链的智能合约创建。功能与主链无区别，全网节点均可以获取平行链账本数据，实现整体架构水平可扩展。
- 群组：作用于平行链，具备群组特性的平行链，只有特定节点才拥有该平行链的账本数据。群组具备的特性包括私密性、动态性。群组中可以添加地址信息，并且这些信息可以互相共享平行链。
  同时群组有 admin 权限，admin 可以有权限向群组中添加、删除成员。

平行链的管理是通过系统合约，可以调用系统合约创建平行链，停用平行链。同时在创建平行链时，可以指定群组。

1. 创建平行链，不设置群组：

    .. code-block:: bash

        ./bin/xchain-cli xkernel invoke '$parachain' --method createChain \
        -a '{"name": "hello","data": "{\"version\":\"1\",\"predistribution\":[{\"address\":\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\",\"quota\":\"100000000000000000000\"}],\"maxblocksize\":\"128\",\"award\":\"1000000\",\"decimals\":\"8\",\"award_decay\":{\"height_gap\":31536000,\"ratio\":1},\"gas_price\":{\"cpu_rate\":1000,\"mem_rate\":1000000,\"disk_rate\":1,\"xfee_rate\":1},\"new_account_resource_amount\":1000,\"genesis_consensus\":{\"name\":\"single\",\"config\":{\"miner\":\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\",\"period\":\"3000\"}}}"}' \
        --fee 1000

    上面命令中，创建平行链是调用系统合约，--method 说明要创建平行链，-a 是平行链创世的信息，其中的 name 字段是链的名字，data 字段和 xchain 节点的创世文件（node1/data/genesis/xuper.json）格式一致。

    此命令只是创建了平行链，但是没有显示说明创建群组，这种情况会创建一个默认的群组。接下来看下如果创建平行链时如何显示创建对应的群组:

2. 创建平行链，同时设置群组：

    .. code-block:: bash

        ./bin/xchain-cli xkernel invoke '$parachain' --method createChain \
        -a '{"name": "hi","data": "{\"version\":\"1\",\"predistribution\":[{\"address\":\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\",\"quota\":\"100000000000000000000\"}],\"maxblocksize\":\"128\",\"award\":\"1000000\",\"decimals\":\"8\",\"award_decay\":{\"height_gap\":31536000,\"ratio\":1},\"gas_price\":{\"cpu_rate\":1000,\"mem_rate\":1000000,\"disk_rate\":1,\"xfee_rate\":1},\"new_account_resource_amount\":1000,\"genesis_consensus\":{\"name\":\"single\",\"config\":{\"miner\":\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\",\"period\":\"3000\"}}}","group":"{\"name\":\"hi\",\"admin\":[\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\",\"SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co\"]}"}' \
        --fee 1000

    上面命令中，-a 参数同样是平行链的创世配置，但是这次加上一个 group 字段，说明在平行链创世时，同时创建一个群组。

3. 停用平行链，创建平行链后我们还可以停用此平行链：

    .. code-block:: bash
        ./bin/xchain-cli  xkernel invoke '$parachain' --method stopChain -a '{"name":"hello"}' --fee 1000

4. 同时可以修改指定群组的配置信息：

    .. code-block:: bash

        ./bin/xchain-cli xkernel invoke '$parachain' --method editGroup -a '{"name":"hi","admin":"[\"TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY\"]"}' --fee 100

5. 参数详解。在创建平行链时可以看到，-a 参数中包括了平行链的创世配置信息，以及群组的信息，每个字段的详细含义如下：

    .. code-block:: json

        {
            "name": "$Blockchain_Name",
            "data": "$Genesis_Configuration",
            "group": "$Group_Configuration"
        }
    
    其中 data 为创世配置。group 为群组配置：

    .. code-block:: json

        {
            "name": "hi",
            "admin": [
                "TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY",
                "SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co"
            ],
            "identities":["TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY", "SmJG3rH2ZzYQ9ojxhbRCPwFiE9y6pD1Co"]
        }

    name 字段为群组的名字且必须与平行链名字相同，admin 为群组的管理员列表，可以修改群组的配置，identities 为有权限访问群组信息的地址。

    上面提到在创建平行链时可以不显示指定群组配置那么默认的配置就是如下：

    .. code-block:: json

        {
            "name": "平行链名字",
            "admin": [
                "发起者地址"
            ],
        }