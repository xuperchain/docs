
XuperChain 测试环境使用指南
======================

测试环境说明
------------

在使用测试环境之前，请先点开 ` XuperChain 测试环境说明 <description.html>`_ ，认真阅读 XuperChain 测试环境的目的、使用场景、用户使用条款。

如果您对测试环境说明中的内容有任何疑问，可以通过 `xchain.baidu.com <http://xchain.baidu.com>`_ 联系我们。如果您使用 XuperChain 测试环境，我们认为您已经明确并接受 XuperChain 测试环境说明中的相关内容和用户使用条款。

如何接入
--------

测试环境通过RPC方式提供服务，开发者可以在 `github <https://github.com/xuperchain/xuperchain>`_ 获取源代码，按照README说明编译得到cli客户端，当前测试环境使用v3.2分支。

- 测试环境接入地址： **14.215.179.74:37101**
- 黄反服务的address：  **XDxkpQkfLwG6h56e896f3vBHhuN5g6M9u**

开发者只需要在使用xchain-cli时，通过-H参数指定测试环境地址，即可将客户端命令发送到测试环境。 例如查询账号测试资源：

.. code-block:: bash
    :linenos:

    ./xchain-cli account balance dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN -H 14.215.179.74:37101

关于测试资源
------------

测试环境上部署和执行智能合约需要消耗测试资源，测试环境目前尚未开放外部全节点P2P连接，且测试环境上节点出块并不会获得奖励，但出块节点会获得该块中所有Transaction中支付的测试资源。

目前获取测试资源主要有两种方式：

1. 通过 XuperChain 公开网络渠道微信群、邮箱等等获取测试资质，可以免费获得测试资源。可以通过 `这里 <https://github.com/xuperchain/xuperchain#%E8%81%94%E7%B3%BB%E6%88%91%E4%BB%AC>`_ 的微信二维码加入 XuperChain 用户微信群。
2. 批量资源获取可邮件联系：`xuper.baidu.com <http://xuper.baidu.com>`_

创建账号
--------

创建个人账号(AK)
^^^^^^^^^^^^^^^^

个人账号(AK)其实是一组公私钥对，个人帐号地址(address)是根据公钥经过一定规则导出的一个散列值。个人账号可以离线生成，不需要上链，只有在个人账号产生测试资源变动时(例如转入了一部分测试资源)才会在UTXO中产生记录。

在data/keys下会有一个默认的个人账号(AK)，包括address(你的地址)、private.key(你的私钥)、public.key(你的公钥)，建议按照如下命令重新生成一个独有的个人账号。

- 指定私钥目录：在data/test_demo下生成address、private.key、public.key: ./xchain-cli account newkeys --output data/test_demo
- 覆盖默认目录： 覆盖data/keys下的文件，需要先删除data/keys目录，然后重新生成新的address、private.key、public.key

.. code-block:: bash
    :linenos:
    
    rm -r data/keys
    ./xchain-cli account newkeys 

个人账号地址默认在data/keys/address文件中，可通过cat data/keys/address 查看自己的个人账号地址。

创建合约账号(Account)
^^^^^^^^^^^^^^^^^^^^^

合约账号可以用来部署智能合约，创建合约账号是一个上链操作，因此也需要消耗一定量的测试资源。合约账号可以设置为多个个人账号共同持有，只有一个交易中的背书签名满足一定合约账号的ACL要求，才能代表这个合约账号进行操作。关于合约账号和ACL权限相关的内容，可以参考

.. note::

    创建合约账号需要向黄反服务拿一个签名，对应地，需要将黄反服务的address写到 data/acl/addrs 中，需要注意的是，multisig最终合入签名时需要将签名顺序与 data/acl/addrs 里面的地址顺序保持一致，否则会签名校验失败。

- Step0: 创建合约账号是一个系统合约，可以通过多重签名的方式发起系统合约调用。系统合约调用需要先创建一个合约调用描述文件，例如下面newAccount.json是一个创建合约账号的描述文件。 newAccount.json文件内容：

.. code-block:: python
    :linenos:

    {
        "module_name": "xkernel",
        "method_name": "NewAccount",
        "args" : {
            "account_name": "1234098776890654",  # 说明：16位数字组成的字符串
            "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 1},\"aksWeight\": {\"dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN\": 1}}"  # 这里的address改成自己的address
        }
    }

- Step1: 多重签名需要收集多个账号的签名，在测试环境中主要是需要交易发起者以及黄反服务的签名，因此修改data/acl/addrs文件，将需要收集签名的address写入该文件中。以创建合约账号为例，需要黄反服务背书，因此在该文件中写入黄反服务address。

.. code-block:: bash
    :linenos:

    XDxkpQkfLwG6h56e896f3vBHhuN5g6M9u

- Step2: 生成创建合约账号的原始交易，命令如下：

.. code-block:: bash
    :linenos:

    ./xchain-cli multisig gen --desc newAccount.json -H 14.215.179.74:37101 --fee 1000 --output rawTx.out

- Step3: 向黄反服务获取签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig get --tx ./rawTx.out --host 14.215.179.74:37101 --output complianceCheck.out

- Step4: 自己对原始交易签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig sign --tx ./rawTx.out --output my.sign

- Step5: 将原始交易以及签名发送出去，命令如下：

.. code-block:: bash
    :linenos:

    ./xchain-cli multisig send my.sign complianceCheck.out --tx ./rawTx.out -H 14.215.179.74:37101

.. note::
    ``Step5`` 中放签名的地方：第一个my.sign签名对应的是交易发起者(Initiator)，第二个complianceCheck.out签名对应的是需要背书(AuthRequire)的地址，发起者签名和背书签名用空格分开，如果需要多个账号背书，那么多个背书签名用,隔开，且签名顺序需要与data/acl/addrs中的地址顺序一致。

创建成功后，你可以通过这个命令去查看你刚才创建的合约账号：

.. code-block:: bash
    :linenos:

    ./xchain-cli account query --host 14.215.179.74:37101

设置合约账号ACL
^^^^^^^^^^^^^^^

.. note::

    前置条件：将合约账号以及合约账号下的有权限的AK以合约账号/address形式以追加方式存放到data/acl/addrs

- Step1: 生成设置合约账号的原始交易，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig gen --desc accountAclSet.json -H 14.215.179.74:37101 --fee 10 --output rawTx.out

- Step2: 向黄反服务获取签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig get --tx ./rawTx.out --host 14.215.179.74:37101 --output complianceCheck.out

- Step3: 自己对原始交易签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig sign --tx ./rawTx.out --output my.sign

- Step4: 将原始交易以及签名发送出去，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig send my.sign complianceCheck.out,my.sign --tx ./rawTx.out -H 14.215.179.74:37101

accountAclSet.json模版如下：

.. code-block:: python
    :linenos:

    {
        "module_name": "xkernel",
        "method_name": "SetAccountAcl",
        "args" : { 
            "account_name": "XC1234098776890654@xuper",
            "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 1},\"aksWeight\": {\"ak1\": 1}}"
        }   
    }

合约操作
--------

.. note::

    合约操作包括编译、部署、调用、设置合约接口权限，目前XuperChain支持的合约语言包括C++，Go，我们以C++中的counter.cc为例，以此说明合约相关操作。

合约编译
^^^^^^^^

.. note::

    合约编译是指将合约编译成二进制形式

例子：C++版本的counter.cc，counter.cc存放路径为contractsdk/cpp/example 预置条件：安装docker

.. code-block:: bash
    :linenos:

    cd contractsdk/cpp
    sh build.sh

到当前目录build里，将编译好的合约二进制counter.wasm，重新命名为counter，放到某个目录下，比如笔者的目录是./output/

合约账号充入测试资源
^^^^^^^^^^^^^^^^^^^^

合约部署需要合约账号才能操作，因此会消耗合约账号的测试资源，需要开发者先将个人账号的测试资源转一部分给合约账号。(注意，目前不支持合约账号的测试资源再转出给个人账号，因此请按需充入测试资源。)

- Step1: 生成测试资源转给合约账号的原始交易数据，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig gen --to XC1234098776890651@xuper --amount 150000 --output rawTx.out --host 14.215.179.74:37101

其中: --amount是转出的测试资源数量，--to是接收测试资源的账号名。如果转出方不是./data/keys下的默认地址，则可以使用--from指定转账来源账号，并将该来源地址的签名在multisig send时写在Initiator的位置。

- Step2: 向黄反服务获取签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig get --tx ./rawTx.out --output complianceCheck.out --host 14.215.179.74:37101

- Step3: 自己对原始交易签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig sign --tx ./rawTx.out --output my.sign

- Step4: 将原始交易以及签名发送出去，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig send my.sign complianceCheck.out --tx ./rawTx.out -H 14.215.179.74:37101

- Step5: 查询合约账号的测试资源数额，确定转账成功：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli account balance XC1234098776890651@xuper -H 14.215.179.74:37101

合约部署
^^^^^^^^

.. note::

    部署合约的前提条件是先创建一个合约账号，假设按照上述步骤已经创建了一个合约账号 ``XC1234098776890651@xuper`` ，并且对应的合约账号有充裕的测试资源 前置条件：将合约账号以及合约账号下的有权限的AK以 **合约账号/address** 形式以追加方式存放到 data/acl/addrs

- Step0: 合约部署需要在交易中写入满足合约账号ACL的背书AK签名，为了表示某个AK在代表某个账号背书， XuperChain 中定义了一种AK URI，例如 *dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN* 代表 *XC1234098776890651@xuper* 这个合约账号，那么这个背书AK的AK URI可以写成：**XC1234098776890651@xuper/dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN** 。

以此为例，背书AK URI需要同时包含黄反服务和合约账号，因此需要将 data/acl/addrs 文件改成：

.. code-block:: bash
    :linenos:

    XDxkpQkfLwG6h56e896f3vBHhuN5g6M9u
    XC1234098776890651@xuper/dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN

Step1: 生成部署合约的原始交易，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli wasm deploy --account XC1234098776890651@xuper --cname counter -H 14.215.179.74:37101 -m ./counter --arg '{"creator":"xchain"}' --output contractRawTx.out --fee 137493

Step2: 向黄反服务获取签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig get --tx ./contractRawTx.out --host 14.215.179.74:37101 --output complianceCheck.out

Step3: 自己对原始交易签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig sign --tx ./contractRawTx.out --output my.sign

Step4: 将原始交易以及签名发送出去，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig send my.sign complianceCheck.out,my.sign --tx ./contractRawTx.out -H 14.215.179.74:37101

合约调用
^^^^^^^^

编译合约，部署合约的目的都是为了能够在区块链系统上运行智能合约，本小节说明如下调用合约。

- Step1: 生成合约调用的原始交易，命令有下面两种实现方式：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig gen --desc counterIncrease.json -H 14.215.179.74:37101 --fee 85 --output rawTx.out
    # 或者这样
    ./xchain-cli wasm invoke -a '{"key":"counter"}' --method increase counter -H 14.215.179.74:37101 --fee 85 -m --output rawTx.out

- Step2: 向黄反服务获取签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig get --tx ./rawTx.out --host 14.215.179.74:37101 --output complianceCheck.out

- Step3: 自己对原始交易签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig sign --tx ./rawTx.out --output my.sign

- Step4: 将原始交易以及签名发送出去，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig send my.sign complianceCheck.out --tx ./rawTx.out -H 14.215.179.74:37101

counterIncrese.json模板，如下：

.. code-block:: python
    :linenos:

    {
        "module_name": "wasm",
        "contract_name": "counter",
        "method_name": "increase",
        "args":{
            "key":"counter"
        }
    }

设置合约接口ACL
^^^^^^^^^^^^^^^

.. note::

    | 有这么一种场景：合约账号A部署了counter合约，希望只有拿到特定签名的用户才能调用counter的increase方法，因此XuperChain提供对智能合约某个方法进行权限设置
    | 前置条件：将合约账号以及合约账号下的有权限的AK以合约账号/address形式以追加方式存放到 data/acl/addrs

- Step1: 生成设置合约方法权限(ACL)的原始交易，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig gen --desc methodAclSet.json -H 14.215.179.74:37101 --fee 10 --output rawTx.out

- Step2: 向黄反服务获取签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig get --tx ./rawTx.out --host 14.215.179.74:37101 --output complianceCheck.out

- Step3: 自己对原始交易签名，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig sign --tx ./rawTx.out --output my.sign

- Step4: 将原始交易以及签名发送出去，命令如下：

.. code-block:: bash
    :linenos:
    
    ./xchain-cli multisig send my.sign complianceCheck.out,my.sign --tx ./rawTx.out -H 14.215.179.74:37101

methodAclSet.json的模版，如下：

.. code-block:: python
    :linenos:

    {
        "module_name": "xkernel",
        "method_name": "SetMethodAcl",
        "args" : { 
            "contract_name": "counter",
            "method_name": "increase",
            "acl": "{\"pm\": {\"rule\": 1,\"acceptValue\": 1},\"aksWeight\": {\"TqnHT6QQnD9rjvqRJehEaAUB3ZwzSFZhR\": 1}}"
        }   
    }

FAQ
---

:Q:
    为什么测试环境现在不开放全节点P2P账本同步？

:A:
    目前 XuperChain 仍然处于高速迭代期，为了保证bug能够得到即时修复更新，我们暂时未开放外部P2P节点加入测试环境的功能，但用户通过GRPC接口已经能体验到测试环境的大部分功能。 当然，我们会在测试环境运行一段时间后，开放P2P节点加入乃至开放外部节点成为超级节点，具体时间目前还没有确定，请大家继续关注。


:Q:
    测试环境中的测试资源可以转给别的个人账号吗？

:A:
    不能，测试资源仅供在测试环境上进行 XuperChain 体验、智能合约开发测试使用，用户可以通过加入测试计划免费获得，用户获得的测试资源无法转给其他任何个人账号。

:Q:
    测试环境为什么所有交易都需要黄反服务签名？

:A:
     XuperChain 测试环境上的数据是所有用户透明可见的，为了保证所有用户的体验，我们会对每个transaction中的数据进行合规性检测，尽量避免涉嫌黄反内容上链。用户违规发起涉嫌黄反内容的transaction引起的任何后果，都需要自行承担。请各位测试用户也从自身做起，保障一个干净和谐的网络环境。

:Q:
    编译cpp合约出现 
    *"Post http:///var/run/docker.sock/v1.19/containers/create: dial unix /var/run/docker.sock: 
    permission denied. Are you trying to connect to a TLS-enabled daemon without TLS?"* 
    是什么原因？

:A:
    这可能是因为用户安装docker后，没有创建docker用户组，或者当前运行的系统账号不在docker用户组中，可以尝试下面的命令：

    .. code-block:: bash

        sudo groupadd docker
        sudo usermod -aG docker ${USER}  // 此处${USER}为你编译合约时使用的linux账号
        service docker resteart

