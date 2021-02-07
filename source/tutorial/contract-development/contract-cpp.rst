.. _tutorial/contract-development-cpp:

C++合约
^^^^^^^^^^^^

以counter合约为例来看如何编写一个C++合约。

合约样例
>>>>>>>>>>>>>

代码在 **contractsdk/cpp/example/counter.cc**

.. code-block:: c++
    :linenos:
	
    #include "xchain/xchain.h"
    struct Counter : public xchain::Contract {};
    DEFINE_METHOD(Counter, initialize) {
        xchain::Context* ctx = self.context();
        const std::string& creator = ctx->arg("creator");
        if (creator.empty()) {
            ctx->error("missing creator");
            return;
        }
        ctx->put_object("creator", creator);
        ctx->ok("initialize succeed");
    }
    DEFINE_METHOD(Counter, increase) {
        xchain::Context* ctx = self.context();
        const std::string& key = ctx->arg("key");
        std::string value;
        ctx->get_object(key, &value);
        int cnt = 0;
        cnt = atoi(value.c_str());
        char buf[32];
        snprintf(buf, 32, "%d", cnt + 1);
        ctx->put_object(key, buf);
        ctx->ok(buf);
    }
    DEFINE_METHOD(Counter, get) {
        xchain::Context* ctx = self.context();
        const std::string& key = ctx->arg("key");
        std::string value;
        if (ctx->get_object(key, &value)) {
            ctx->ok(value);
        } else {
            ctx->error("key not found");
        }
    }


代码解析
>>>>>>>>>>>>>>

下面我们逐行解析合约代码：

    - **#include <xchain/xchain.h>** 为必须的，里面包含了编写合约所需要的库。

    - **struct Counter : public xchain::Contract {}**: 声明了我们的合约类，所有的合约类都要继承自 **xchain::Contract** 。

    - **DEFINE_METHOD(Counter, initialize)** 我们通过 **DEFINE_METHOD** 来为合约类定义合约方法，在这个例子里面我们为 **Counter** 类定义了一个叫 **initialize** 的合约方法。

    - **xchain::Context* ctx = self.context()** :用来获取合约的上下文，每个合约都有一个对应的合约执行上下文，通过上下文我们可以获取合约参数，写入合约数据，context对象是我们经常要操作的一个对象。

    - **const std::string& creator = ctx->arg("creator");** ，用于从合约上下文里面获取合约方法的参数，这里我们获取了名字叫 **creator** 的合约参数，合约的参数列表是一个map结构, key为合约参数的名字，value为参数对应的用户传递的值。

    - **ctx->put_object("creator", creator);** 通过合约上下文的 **put_object** 方法，我们可以向链上写入数据。

    - **ctx->ok("initialize succeed");** 用于返回合约的执行结果，如果合约执行失败则调用 **ctx->error** 。

通过上面的代码分析我们得到了如下知识

- 一个合约有多个方法组成，如counter合约的 **initialize** ， **increase** , **get** 方法。
- **initialize** 是每个合约必须实现的方法，这个合约方法会在部署合约的时候自动执行。
- 每个合约方法有一个 **Context** 对象，通过这个对象我们能获取到很多有用的方法，如获取用户参数等。
- 通过 **Context** 对象的 **ok** 或者 **error** 方法我们能给调用方反馈合约的执行情况:成功或者失败。

更多的c++语言合约例子在超级链项目的 **core/contractsdk/cpp/example** 里面寻找。


3. 部署wasm合约

    将编译好的合约二进制文件（以counter为例）放到目录node/data/blockchain/${chain name}/wasm/下，这里我们默认的链名 ${chain name}=xuper

    部署合约的操作需要由合约账号完成，部署操作同样需要支付手续费，操作前需要确保合约账号下有足够的余额

    示例中我们的环境里创建了一条名为xuper的链，包含一个合约账号 **XC1111111111111111@xuper** 
    
    .. only:: html

        账号的acl查询如下：

        .. figure:: /images/checkacl.gif
            :alt: 查询acl
            :align: center

    为部署合约，我们需要事先准备一个符合权限的地址列表（示例中将其保存在 data/acl/addrs 文件），这里因为acl里只有一个AK，我们只需在文件中添加一行（如果acl中需要多个AK，那么编辑文件，每行填写一个即可）

    .. code-block:: bash

        echo "XC1111111111111111@xuper/dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN" > data/acl/addrs

    然后我们按照以下命令来部署wasm合约counter

    .. code-block:: bash

        xchain-cli wasm deploy --account XC1111111111111111@xuper --cname counter -m -a '{"creator": "someone"}' -A data/acl/addrs -o tx.output --keys data/keys --name xuper -H localhost:37101 counter

    此命令看起来很长，但是其中很多参数都有默认值，我们先来看一下参数的含义：

    - ``wasm deploy`` ：此为部署wasm合约的命令参数，不做过多解释
    - ``--account XC1111111111111111@xuper`` ：此为部署wasm合约的账号（只有合约账号才能进行合约的部署）
    - ``--cname counter`` ：这里的counter是指部署后在链上的合约名字，可以自行命名（但有规则，长度在4～16字符）
    - ``-m`` ：意为多重签名的方式，目前版本的xchain部署wasm合约都需要以这种方式
    - ``-a '{"creator": "someone"}'`` ：此为传入合约的参数，供合约Initialize方法使用（此参数并非必须，只不过此处的counter合约需要传一个"creator"参数，参见contractsdk/cpp/example/counter.cc）
    - ``-A data/acl/addrs`` ：此即为需要收集签名的列表，默认路径为data/acl/addrs，如不是则需要显式传入（注意权重要满足acl要求）
    - ``-o tx.output`` ：此为输出的tx文件，可不传，默认文件名为tx.out
    - ``--keys data/keys`` ：此为部署发起者的密钥地址，可不传，默认值即为data/keys（部署发起者也要进行签名）
    - ``--name xuper`` ：此为区块链名称，默认为xuper，如果创建链名称不是xuper则需要显式传入
    - ``-H localhost:37101`` ：xchain服务的地址，默认是本机的37101端口，如不是则需要显式传入
    - 最后的counter是合约编译好的文件（编译完成默认是counter.wasm）


    在此处，我们大部分参数取的是默认值，所以命令参数不必这么多了

    .. code-block:: bash

        xchain-cli wasm deploy --account XC1111111111111111@xuper --cname counter -m -a '{"creator": "someone"}' counter

    .. only:: html

        运行效果如下

        .. figure:: /images/deploywasm.gif
            :alt: 发起wasm合约部署
            :align: center

    运行时会提示手续费的数目，使用 --fee 参数传入即可

    然后收集所需AK的签名，因为示例中我们只有一个AK（同时也是发起者），所以只需要签名一次

    .. code-block:: bash

        xchain-cli multisig sign --tx tx.out --output sign.out --keys data/keys

    这里的 ``--output`` ``--keys`` 参数也有默认值（输出到sign.out文件，密钥位于data/keys），可以不加。运行后我们即可获得此AK的签名

    .. only:: html

        运行效果如下

        .. figure:: /images/signtx.gif
            :alt: 对tx签名
            :align: center

    收集完发起者和acl需要的签名后，我们即可发送交易，完成合约部署了

    .. code-block:: bash

        xchain-cli multisig send --tx tx.out sign.out sign.out

    这里 multisig send 为发送多重签名的命令参数， ``--tx`` 是交易文件，后边的两个参数分别为发起者的签名和acl的签名（acl中有多个AK时，用逗号连接多个签名文件）。运行命令可得到交易上链后的id，我们也可以使用以下命令来查询部署结果

    .. code-block:: bash

        xchain-cli account contracts --account XC1111111111111111@xuper

    会显示此合约账号部署过的所有合约

    .. only:: html

        运行效果如下

        .. figure:: /images/sendtx.gif
            :alt: 发送部署交易
            :align: center


2. 编译合约 - C++

    对于C++合约，已提供编译脚本，位于 contractsdk/cpp/build.sh，需要注意的是，脚本依赖从hub.baidubce.com拉取的docker镜像，请在编译前确认docker相关环境是可用的


