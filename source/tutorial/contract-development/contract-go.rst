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
