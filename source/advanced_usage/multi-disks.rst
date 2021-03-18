
配置变更
========

.. _multi-disk:

配置多盘存储
------------

由区块链本身特点决定的，区块链服务启动后需要的存储空间会逐渐变多，即使交易不频繁，每到固定出块时间也会占用少量的存储空间。XuperChain提供了一种可以将存储路径配置在多个磁盘上的功能，来更好地支持单个磁盘存储空间不充裕的场景。

位于代码目录下的 core/conf/xchain.yaml ，包含了大部分XuperChain服务启动的配置项，其中有磁盘相关的章节

.. code-block:: yaml
    :linenos:

    # 数据存储路径
    datapath: ./data/blockchain

    # 多盘存储的路径
    datapathOthers:
        - /ssd1/blockchain
        - /ssd2/blockchain
        - /ssd3/blockchain

只需将“多盘存储路径”部分去掉注释，并在conf/plugins.conf更改kv插件配置，便可以灵活配置多个数据存储位置。
更换kv插件的具体方法为：修改conf/plugins.conf文件，将kv项下default中的path改为plugins/kv/kv-ldb-multi.so.1.0.0即可。


.. note:
    配置更新需要在创建链、启动xchain服务之前进行

.. _extension:

替换扩展插件
------------

XuperChain采用了动态链接库的方式实现了加密、共识算法等扩展插件，可以根据实际使用场景进行替换。

插件目录位于 plugins ，对应的配置文件为 conf/plugins.conf （json格式）

.. code-block:: python
    :linenos:

    {
        "crypto":[{
            "subtype": "default",
            "path": "plugins/crypto/crypto-default.so.1.0.0",
            "version": "1.0.0",
            "ondemand": false
        },{
            "subtype": "schnorr",
            "path": "plugins/crypto/crypto-schnorr.so.1.0.0",
            "version": "1.0.0",
            "ondemand": false
        }]
        # ......
    }

需要替换插件则修改对应的 .so 文件路径即可

.. note:
    替换插件后需要重启服务方可生效。如果环境有多个节点，需要注意替换过程中对交易和出块的影响。
