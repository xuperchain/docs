.. _tutorial/contract-development-cpp:

C++合约
^^^^^^^^^^^^

预备知识
>>>>>>>>

:ref:`tutorial/cli` 

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

2. 编译合约 

    对于C++合约，已提供编译脚本，位于 contractsdk/cpp/build.sh，需要注意的是，脚本依赖从hub.baidubce.com拉取的docker镜像，请在编译前确认docker
相关环境是可用的

3. 部署wasm合约

    .. code-block:: bash

        xchain-cli wasm deploy --account XC1111111111111111@xuper --cname counter -m -a '{"creator": "someone"}' --name xuper counter



