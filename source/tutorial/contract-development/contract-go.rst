Go合约
^^^^^^^^^^^^

以counter合约为例来看如何编写一个go合约。

合约样例
>>>>>>>>>>>>>

代码在 **contractsdk/go/example/counter/counter.go**

.. code-block:: go
    :linenos:
	
    package main
    import (
        "strconv"
        "github.com/xuperchain/xuperchain/core/contractsdk/go/code"
        "github.com/xuperchain/xuperchain/core/contractsdk/go/driver"
    )
    type counter struct{}
    func (c *counter) Initialize(ctx code.Context) code.Response {
        creator, ok := ctx.Args()["creator"]
        if !ok {
            return code.Errors("missing creator")
        }
        err := ctx.PutObject([]byte("creator"), creator)
        if err != nil {
            return code.Error(err)
        }
        return code.OK(nil)
    }
    func (c *counter) Increase(ctx code.Context) code.Response {
        key, ok := ctx.Args()["key"]
        if !ok {
            return code.Errors("missing key")
        }
        value, err := ctx.GetObject(key)
        cnt := 0
        if err == nil {
            cnt, _ = strconv.Atoi(string(value))
        }
        cntstr := strconv.Itoa(cnt + 1)
        err = ctx.PutObject(key, []byte(cntstr))
        if err != nil {
            return code.Error(err)
        }
        return code.OK([]byte(cntstr))
    }
    func (c *counter) Get(ctx code.Context) code.Response {
        key, ok := ctx.Args()["key"]
        if !ok {
            return code.Errors("missing key")
        }
        value, err := ctx.GetObject(key)
        if err != nil {
            return code.Error(err)
        }
        return code.OK(value)
    }
    func main() {
        driver.Serve(new(counter))
    }


go合约的整体框架结构跟c++合约一样，在表现形式上稍微有点不一样：

- c++合约使用 **DEFINE_METHOD** 来定义合约方法，go通过结构体方法来定义合约方法。
- c++通过 **ctx->ok** 来返回合约数据，go通过返回 **code.Response** 对象来返回合约数据。
- go合约需要在main函数里面调用 **driver.Serve** 来启动合约。

更多的go语言合约例子在超级链项目的 **core/contractsdk/go/example** 里面寻找。

合约编译
>>>>>>>>>>>

Go合约使用如下命令来编译合约

.. code-block:: go
    :linenos:
	
    GOOS=js GOARCH=wasm go build -o hello.wasm


合约部署
>>>>>>>>>>>>>
Go合约部署唯一跟c++合约不一样的地方在于 **--runtime** 参数，完整命令如下

.. code-block:: bash
    :linenos:
	
    $ ./xchain-cli wasm deploy --account XC1111111111111111@xuper --cname hello  --fee 5200000 --runtime go ./hello-go/hello.wasm


Go合约的调用跟c++合约参数一致。


4. 合约调用

    调用native合约。针对不同语言实现的native合约，调用方式相同。通过合约名直接发起合约调用和查询

    .. code-block:: bash

        # 调用golang native合约，Increase方法，golangcounter为合约名
        xchain-cli native invoke --method Increase -a '{"key":"test"}' golangcounter --fee 10
        # 调用结果
        # contract response: 1
        # The gas you cousume is: 6
        # The fee you pay is: 10
        # Tx id: b387e2247780a5f5da1070a931b37c4fc7f1b68c072768053a43cffe36f2e0fb

        # 调用golang native合约，Get方法，golangcounter为合约名
        xchain-cli native query --method Get -a '{"key":"test"}' golangcounter
        # 调用结果
        # contract response: 1

        # 调用java native合约，increase方法，javacounter为合约名
        xchain-cli native invoke --method increase -a '{"key":"test"}' javacounter --fee 10
        # 调用结果
        # contract response: 1
        # The gas you cousume is: 6
        # The fee you pay is: 10
        # Tx id: 4b46d9b1292481dcac3b504d5f8031e4eff44d8514c9508f121145cfa141d9db

        # 调用java native合约，get方法，javacounter为合约名
        xchain-cli native query --method get -a '{"key":"test"}' javacounter
        # 调用结果
        # contract response: 1146398290725d36631aa70f731bc3174e6484a9a

3. 部署合约

    部署native合约。针对不同语言实现的合约，主要通过 ``--runtime`` 字段进行区分

    .. code-block:: bash

        # 部署golang native合约
        xchain-cli native deploy --account XC1111111111111111@xuper -a '{"creator":"XC1111111111111111@xuper"}' --fee 15587517 --runtime go counter --cname golangcounter
        # 部署结果
        # contract response: ok
        # The gas you cousume is: 14311874
        # The fee you pay is: 15587517
        # Tx id: af0d46f6df2edba4d9d9d07e1db457e5267274b1c9fe0611bb994c0aa7931933

        # 部署java native合约
        xchain-cli native deploy --account XC1111111111111111@xuper --fee 15587517 --runtime java counter-0.1.0-jar-with-dependencies.jar --cname javacounter
        # 部署结果
        # contract response: ok
        # The gas you cousume is: 14311876
        # The fee you pay is: 15587517
        # Tx id: 875d2c9129973a1c64811d7a5a55ca80743102abc30d19f012656fa52ee0f4f7

    - ``--runtime go`` ：表示部署的是golang native合约
    - ``--runtime java``：表示部署的是java native合约

1. 编译合约 - Golang

    编译native合约时，只要保持环境和编译XuperChain源码时一致即可，我们还是以contractsdk/go/example中的counter合约为例

    .. code-block:: bash

        cd contractsdk/go/example/counter
        go build
        # 产出二进制文件counter，用于合约部署

部署native合约
--------------

如果本地搭建超级链环境，在部署、调用native合约之前，请先查看`conf/xchain.yaml` 中native一节，确保native合约功能开启。

.. code-block:: yaml
    :linenos:

    # 管理native合约的配置
    native:
        enable: true

        # docker相关配置
        docker:
            enable:false
            # 合约运行的镜像名字
            imageName: "docker.io/centos:7.5.1804"
            # cpu核数限制，可以为小数
            cpus: 1
            # 内存大小限制
            memory: "1G"
        # 停止合约的等待秒数，超时强制杀死
        stopTimeout: 3

