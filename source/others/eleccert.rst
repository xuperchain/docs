
电子存证合约
============

或使用 XuperChain XuperOS，其已发布丰富的合约模板，涵盖溯源、存证、积分、去中心化等多行业模板。 `点击了解 <https://xchain.baidu.com/n/console#/xuperos/contracts?type=market>`_ 

问题引入
--------

假设我们面临着这样的一个问题：“几个摄影师朋友找到你，他们的摄影作品上传到自己的blog后总是被其他人盗用，使用水印之类的方法也无法避免像截取部分这种情况，他们需要一个能证明摄影作品最早是由自己上传、而且具有法律效力可供自己进行维权的工具”

显然区块链对于解决此问题有很大的帮助，它的不可篡改等特性很适合存证维权的场景，我们可以通过XuperChain来构建一个存取证据的智能合约（担心不被法院认可？ `这里 <https://36kr.com/p/5168629>`_ 或许能够解答你的疑问）

下面我们就来教你帮助摄影师朋友开发一个能够存储照片版权、还能在发现被盗用后进行维权的智能合约

数据结构的设计
--------------

对于摄影作品，通常是一个图片文件，其大小根据清晰度等原因可以多达几十MB（甚至更多），为避免存储空间浪费、以及保证区块链交易的效率，我们可以使用哈希算法（例如SHA256）只将图片的哈希值上链，而原图可以保存在其他地方

我们可以这样定义“证据文件”的数据结构，包含哈希值和上传的时间戳

.. code-block:: go
    :linenos:

    type UserFile struct {
        Timestamp int64
        Hashval   []byte
    }

为了能够存储多个“证据文件”，并且能够服务于更多的摄影师朋友，我们可以定义一个上传者到文件的map

.. code-block:: go
    :linenos:

    type User struct {
        Owner     string
        UserFiles map[string]*UserFile
    }

代码样例可以参看：`contractsdk/go/example/eleccert.go <https://github.com/xuperchain/xuperchain/blob/master/core/contractsdk/go/example/eleccert/eleccert.go>`_

电子存证合约的功能实现
----------------------

从场景我们可以大致推断，以下两个功能是必要的

- 存储一个到“证据文件”区块链（save方法）
- 获取已经存储过的某一个“证据文件”（query方法）

更底层考虑，我们可以使用XuperChain提供的合约SDK功能 `PutObject <../development_manuals/XuperCDT.html#putobject>`_ 和 `GetObject <../development_manuals/XuperCDT.html#getobject>`_ 来提供实际的存取功能

对于XuperChain中的智能合约，Initialize是一个必须实现的方法，当且仅当合约被部署的时候会运行一次，我们这里采用“每个摄影师部署自己的合约来存储自己需要的作品”这种方式，将一些和上传者相关的初始化操作放在函数中

Save、Query和Initialize方法的具体实现可以参考代码样例

合约使用方法
------------

合约部署（Deploy）
^^^^^^^^^^^^^^^^^^

编译并部署合约的过程可以参考 `部署 native 合约 <../advanced_usage/create_contracts.html#wasm>`_ 章节，注意资源消耗可以一开始不加 --fee 参数，执行后会给出需要消耗的资源数

合约执行（Save）
^^^^^^^^^^^^^^^^

执行合约进行“存证操作”的命令如下（运行需要使用 --fee 参数提供资源消耗）：

.. code-block:: bash
    :linenos:

    ./xchain-cli native invoke -a '下面json中args字段的内容' --method save -H localhost:37101 eleccert

.. code-block:: python
    :linenos:

    {
        "module_name": "wasm",          # native or wasm
        "contract_name": "eleccert",    # contract name
        "method_name": "save",          # invoke or query
        "args": {
            "owner": "aaa",             # user name
            "filehash": "存证文件的hash值",
            "timestamp": "存证的timestamp"
        }
    }

合约查询（Query）
^^^^^^^^^^^^^^^^^

执行合约进行“取证操作”的命令如下（查询操作不需要提供资源）：

.. code-block:: bash
    :linenos:

    ./xchain-cli native query -a 'args内容' --method query -H localhost:37101 eleccert

.. code-block:: python
    :linenos:

    {
        "module_name": "native",        # native or wasm
        "contract_name": "eleccert",    # contract name
        "method_name": "query",         # invoke or query
        "args": {
            "owner": "aaa",             # user name
            "filehash": "文件hash值"
        }
    }
    # output 如下
    {
        "filehash": "文件hash值",
        "timestamp": "文件存入timestamp"
    }
