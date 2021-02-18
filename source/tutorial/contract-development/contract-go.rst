.. _tutorial/contract-development-go:


Go合约
^^^^^^^^^^^^
预备知识
>>>>>>>>

:ref:`tutorial/cli`

.. note::

    请先完成 :ref:`tutorial/cli`  中的教程，以确设置对应账号和权限
    
1.合约样例
>>>>>>>>>>>


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


2.合约编译
>>>>>>>>>>>

.. code-block:: bash
    :linenos:

    # 编译为 wasm 合约
    GOOS=js GOARCH=wasm go build -o hello.wasm

    # 编译为 native 合约
    go build -o hello



3. 部署合约
>>>>>>>>>>>

    .. code-block:: bash

        #  native合约
        xchain-cli native deploy --account XC1111111111111111@xuper -a '{"creator":"XC1111111111111111@xuper"}' --fee 15587517 --runtime go counter --cname counter

        # 部署 wasm 合约
        xchain-cli wasm deploy --account XC1111111111111111@xuper --cname counter -m -a '{"creator": "someone"}' counter


4. 合约调用
>>>>>>>>>>>
    .. code-block:: bash

        $ xchain-cli native invoke --method Increase -a '{"key":"demo"}' countr --fee 10
        contract response: 1
        The gas you cousume is: 6
        The fee you pay is: 10
        Tx id: b387e2247780a5f5da1070a931b37c4fc7f1b68c072768053a43cffe36f2e0fb

        $ xchain-cli native query --method Get -a '{"key":"demo"}' counter
        contract response: 1