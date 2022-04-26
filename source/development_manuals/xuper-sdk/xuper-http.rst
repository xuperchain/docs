.. include:: ../_static/substitutions.rst

XuperChain http 接口使用说明
===========================

XuperChain为方便用户深度使用 XuperChain 的各项功能，提供了多语言版本的SDK（`JS <https://github.com/xuperchain/xuper-sdk-js>`_，`Golang <https://github.com/xuperchain/xuper-sdk-go>`_，`C# <https://github.com/xuperchain/xuper-sdk-csharp>`_，`Java <https://github.com/xuperchain/xuper-java-sdk>`_，`Python <https://github.com/xuperchain/xuper-python-sdk>`_），这里我们以Golang为例来介绍一下XuperChain的http接口使用方式。

.. note::
  目前官方提供的SDK中，golang语言版本的功能最为全面，其他语言的功能弱一些，我们非常欢迎社区朋友一起建设SDK，参与贡献会获得开放网络的资源，可用于购买开放网络的服务。



http接口介绍
-----------

查看XuperChain的 `proto文件 <https://github.com/xuperchain/xuperchain/blob/v3.10/core/pb/xchain.proto>`_ ，可以在service定义中获取所有支持的http接口


GetBalance
>>>>>>>>>>

此接口用于查询指定地址中的余额

http方法：``POST``

请求URL：``/v1/get_balance``

header：``Content-Type:application/json``

**参数说明**

+----------+---------------+
| 参数结构 | AddressStatus |
+----------+---------------+
| 返回结构 | AddressStatus |
+----------+---------------+

.. raw:: html

   <details>
   <summary><span>AddressStatus</span></summary></br>

.. code-block:: protobuf
   :linenos:

   message AddressStatus {
       Header header = 1;
       string address = 2;
       repeated TokenDetail bcs = 3;
   }

.. raw:: html

   </details>
   </br>

.. raw:: html

  <details>
  <summary><span>TokenDetail</span></summary></br>

.. code-block:: protobuf
    :linenos:

    message TokenDetail {
        string bcname = 1;
        string balance = 2;
        XChainErrorEnum error = 3;
    }

.. raw:: html

  </details>
  </br>

.. raw:: html

  <details>
  <summary><span>Header</span></summary></br>

.. code-block:: protobuf
    :linenos:

    message Header {
        string logid = 1;
        string from_node = 2;
        XChainErrorEnum error = 3;
    }

.. raw:: html

  </details>
  </br>

**请求示例**

- *其中的 address 字段为需要查询的地址，传入string即可*
- *其中的 bcs 字段为需要查询的链名，因为XuperChain支持平行链的功能，此字段为列表，亦可传入多个链名*
- *Header中的logid是回复中也会携带的id，用来对应请求或追溯日志使用的，一般用 xupercore/lib/utils/utils.go 生成一个全局唯一id*
- *Header中的from_node一般不需要填写，error字段也是返回中携带的错误内容，发请求时不需填写*
- *请求时只需传入 bcname 字段，例如 "xuper"，其余字段为返回时携带的，balance即为对应平行链上的余额*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_balance"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.AddressStatus{}
    params.Bcs = []*pb.TokenDetail{}
    tokenDetail := new(pb.TokenDetail)
    tokenDetail.Bcname = "xuper"
    params.Bcs = append(params.Bcs, tokenDetail)
    params.Address = "TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY"

    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))



GetBalanceDetail
>>>>>>>>>>>>>>>>

此接口用于查询指定地址中的余额详细情况

http方法：``POST``

请求URL：``/v1/get_balance_detail``

header：``Content-Type:application/json``

**参数说明**

+----------+----------------------+
| 参数结构 | AddressBalanceStatus |
+----------+----------------------+
| 返回结构 | AddressBalanceStatus |
+----------+----------------------+

.. raw:: html

  <details>
  <summary><span>AddressBalanceStatus</span></summary></br>

.. code-block:: protobuf
    :linenos:

    message AddressBalanceStatus {
        Header header = 1;
        string address = 2;
        repeated TokenFrozenDetails tfds = 3;
    }

.. raw:: html

  </details>
  </br>

**请求示例**

- *address字段与GetBalance一样，tfds字段则多了是否冻结的内容，tfds在请求中只需要填充bcname，返回时会有TokenFrozenDetail数组给出正常余额和冻结余额的信息*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_balance_detail"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.AddressBalanceStatus{}
    tokenFrozenDetails := new(pb.TokenFrozenDetails)
    tokenFrozenDetails.Bcname = "xuper"
    params.Tfds = append(params.Tfds, tokenFrozenDetails)
    params.Address = "TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY"
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))



GetFrozenBalance
>>>>>>>>>>>>>>>>

此接口用于查询指定地址中的冻结余额

http方法：``POST``

请求URL：``/v1/get_frozen_balance``

header：``Content-Type:application/json``

**参数说明**

+----------+---------------+
| 参数结构 | AddressStatus |
+----------+---------------+
| 返回结构 | AddressStatus |
+----------+---------------+

.. raw:: html

  <details>
  <summary><span>AddressStatus</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message AddressStatus {
      Header header = 1;
      string address = 2;
      repeated TokenDetail bcs = 3;
  }

.. raw:: html

  </details>
  </br>

**请求示例**

- *address字段与GetBalance一样，tfds字段则多了是否冻结的内容，tfds在请求中只需要填充bcname，返回时会有TokenFrozenDetail数组给出正常余额和冻结余额的信息*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_frozen_balance"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.AddressStatus{}
    params.Bcs = []*pb.TokenDetail{}
    tokenDetail := new(pb.TokenDetail)
    tokenDetail.Bcname = "xuper"
    params.Bcs = append(params.Bcs, tokenDetail)
    params.Address = "TeyyPLpp9L7QAcxHangtcHTu7HUZ6iydY"

    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


GetBlock
>>>>>>>>

此接口用于查询指定id的区块内容

http方法：``POST``

请求URL：``/v1/get_block``

header：``Content-Type:application/json``

**参数说明**

+----------+---------+
| 参数结构 | BlockID |
+----------+---------+
| 返回结构 | Block   |
+----------+---------+

.. raw:: html

  <details>
  <summary><span>BlockID</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message BlockID {
      Header header = 4;
      string bcname = 1;
      bytes blockid = 2;
      bool need_content = 3;  //是否需要内容
  }

.. raw:: html

  </details>
  </br>

**请求示例**

- *blocked为要查询的区块id，注意是bytes类型，可能需要hex decode*
- *need_content字段为布尔值，表明是否需要详细的区块内容（还是只查询区块是否在链和前驱后继)*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_block"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.BlockID{}
    params.Bcname = "xuper"
    params.Blockid, _ = hex.DecodeString("9a2ba41af3621ce372352491552d75ff5d43e393dfdd98f02b9056bfd2303f97")
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


GetBlockByHeight
>>>>>>>>>>>>>>>>

此接口用于查询指定高度的区块内容

http方法：``POST``

请求URL：``/v1/get_block_by_height``

header：``Content-Type:application/json``

**参数说明**

+----------+-------------+
| 参数结构 | BlockHeight |
+----------+-------------+
| 返回结构 | Block       |
+----------+-------------+

.. raw:: html

  <details>
  <summary><span>BlockHeight</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message BlockHeight {
      Header header = 3;
      string bcname = 1;
      int64 height = 2;
  }

.. raw:: html

  </details>
  </br>

**请求示例**

- *同GetBlock类似，id换成整型的高度即可，返回内容也是类似的*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_block_by_height"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.BlockHeight{}
    params.Bcname = "xuper"
    params.Height = 88
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


GetBlockChainStatus
>>>>>>>>>>>>>>>>>>>

此接口用于查询指定链的当前状态

http方法：``POST``

请求URL：``/v1/get_bcstatus``

header：``Content-Type:application/json``

**参数说明**

+----------+----------+
| 参数结构 | BCStatus |
+----------+----------+
| 返回结构 | BCStatus |
+----------+----------+

.. raw:: html

  <details>
  <summary><span>BCStatus</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message BCStatus {
      Header header = 1;
      string bcname = 2;
      LedgerMeta meta = 3;
      InternalBlock block = 4;
      UtxoMeta utxoMeta = 5;
      repeated string branchBlockid = 6;
  }

.. raw:: html

  </details>
  </br>

**请求示例**

- *传入参数只需填充header，bcname即可*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_bcstatus"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.BCStatus{}
    params.Bcname = "xuper"
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


GetBlockChains
>>>>>>>>>>>>>>

此接口用于查询当前节点上有哪些链

http方法：``POST``

请求URL：``/v1/get_bcchains``

header：``Content-Type:application/json``

**参数说明**

+----------+-------------+
| 参数结构 | CommonIn    |
+----------+-------------+
| 返回结构 | BlockChains |
+----------+-------------+

.. raw:: html

  <details>
  <summary><span>CommonIn</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message CommonIn {
    Header header = 1;
    ViewOption view_option = 2;
  }

.. raw:: html

  </details>
  </br>

**请求示例**

- *CommonIn结构很简单，只有header字段，返回的BlockChains也仅有一个链名的string数组*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_bcchains"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.CommonIn{}
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))



GetSystemStatus
>>>>>>>>>>>>>>>

此接口用于查询当前节点的运行状态

http方法：``POST``

请求URL：``/v1/get_sysstatus``

header：``Content-Type:application/json``

**参数说明**

+----------+--------------------+
| 参数结构 | CommonIn           |
+----------+--------------------+
| 返回结构 | SystemsStatusReply |
+----------+--------------------+

.. raw:: html

  <details>
  <summary><span>CommonIn</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message CommonIn {
    Header header = 1;
    ViewOption view_option = 2;
  }

.. raw:: html

  </details>
  </br>

**请求示例**

- *此接口相当于先查询了GetBlockChains，在用GetBlockChainStatus查询每个链的状态*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_sysstatus"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.CommonIn{}
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


QueryACL
>>>>>>>>

此接口用于查询指定合约账号的ACL内容

http方法：``POST``

请求URL：``/v1/query_acl``

header：``Content-Type:application/json``

**参数说明**

+----------+-----------+
| 参数结构 | AclStatus |
+----------+-----------+
| 返回结构 | AclStatus |
+----------+-----------+

.. raw:: html

  <details>
  <summary><span>AclStatus</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message AclStatus {
      Header header = 1;
      string bcname = 2;
      string accountName = 3;
      string contractName = 4;
      string methodName = 5;
      bool confirmed = 6;
      Acl acl = 7;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

- *请求中仅需填充header，bcname，accountName即可，其余为返回内容*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/query_acl"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.AclStatus{}
  	params.Bcname = "xuper"
  	params.AccountName = "XC1234567812345678@xuper"
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


QueryTx
>>>>>>>>

此接口用于查询指定id的交易内容

http方法：``POST``

请求URL：``/v1/query_tx``

header：``Content-Type:application/json``

**参数说明**

+----------+----------+
| 参数结构 | TxStatus |
+----------+----------+
| 返回结构 | TxStatus |
+----------+----------+

.. raw:: html

  <details>
  <summary><span>TxStatus</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message TxStatus {
      Header header = 1;
      string bcname = 2;
      bytes txid = 3;
      TransactionStatus status = 4;  //当前状态
      int64 distance = 5;  //离主干末端的距离（如果在主干上)
      Transaction tx = 7;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

- *请求中仅需填充header，bcname，txid字段*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/query_tx"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.TxStatus{}
  	params.Bcname = "xuper"
  	params.Txid, _ = hex.DecodeString("1511fc468949eaf63bc2a7c35d81d4b5fb9690ec1e1874e7645ea8cc660864d7")
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


SelectUTXO
>>>>>>>>>>

此接口用于获取账号可用的utxo列表

http方法：``POST``

请求URL：``/v1/select_utxos_v2``

header：``Content-Type:application/json``

**参数说明**

+----------+------------+
| 参数结构 | UtxoInput  |
+----------+------------+
| 返回结构 | UtxoOutput |
+----------+------------+

.. raw:: html

  <details>
  <summary><span>UtxoInput</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message UtxoInput {
      Header header = 1;
      // which bcname to select
      string bcname = 2;
      // address to select
      string address = 3;
      // publickey of the address
      string publickey = 4;
      // totalNeed refer the total need utxos to select
      string totalNeed = 5;
      // userSign of input
      bytes userSign = 7;
      // need lock
      bool needLock = 8;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

- *请求中只需填充header，bcname，address，totalNeed，needLock，其中needLock表示是否需要锁定utxo（适用于并发执行场景）*
- *UtxoOutput中的返回即可在组装交易时使用，具体组装交易的过程可参考文档下方*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/select_utxos_v2"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.UtxoInput{}
  	params.Bcname = "xuper"
  	params.Address = "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN"
  	params.NeedLock = true
  	params.TotalNeed = "50"
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


SelectUTXOBySize
>>>>>>>>>>>>>>>>

此接口用于获取账号中部分utxo，填满交易后便不在继续获取

http方法：``POST``

请求URL：``/v1/select_utxo_by_size``

header：``Content-Type:application/json``

**参数说明**

+----------+------------+
| 参数结构 | UtxoInput  |
+----------+------------+
| 返回结构 | UtxoOutput |
+----------+------------+

.. raw:: html

  <details>
  <summary><span>UtxoInput</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message UtxoInput {
      Header header = 1;
      // which bcname to select
      string bcname = 2;
      // address to select
      string address = 3;
      // publickey of the address
      string publickey = 4;
      // totalNeed refer the total need utxos to select
      string totalNeed = 5;
      // userSign of input
      bytes userSign = 7;
      // need lock
      bool needLock = 8;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

- *使用过程和SelectUTXO基本相同，仅少了totalNeed字段。适用拥有太多utxo，一次SelectUtxo内容超过交易容纳上限时使用*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/select_utxo_by_size"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.UtxoInput{}
  	params.Bcname = "xuper"
  	params.Address = "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN"
  	params.NeedLock = true
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


PreExec
>>>>>>>

此接口用于在节点上进行合约的预执行操作，返回预执行后的请求和回复

http方法：``POST``

请求URL：``/v1/preexec``

header：``Content-Type:application/json``

**参数说明**

+----------+-------------------+
| 参数结构 | InvokeRPCRequest  |
+----------+-------------------+
| 返回结构 | InvokeRPCResponse |
+----------+-------------------+

.. raw:: html

  <details>
  <summary><span>InvokeRPCRequest</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message InvokeRPCRequest {
      Header header = 1;
      string bcname = 2;
      repeated InvokeRequest requests = 3;
      string initiator = 4;
      repeated string auth_require = 5;
  }


.. raw:: html

  </details>
  </br>

.. raw:: html

  <details>
  <summary><span>InvokeRequest</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message InvokeRequest {
      string module_name = 1;
      string contract_name = 2;
      string method_name = 3;
      map<string, bytes> args = 4;
      repeated ResourceLimit resource_limits = 5;
      string amount = 6;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

- *其中必填字段有module_name，contract_name，method_name，args*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/preexec"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.InvokeRPCRequest{}
    params.Bcname = "xuper"
    //需要先部署合约，才可以调用。
    var invokeRequest = &pb.InvokeRequest{}
    invokeRequest.ModuleName = "evm"
    invokeRequest.ContractName = "Cafe20"
    invokeRequest.MethodName = "mint"
    invokeRequest.Args = map[string][]byte{
    	"creator":[]byte("alice"),
    }
    params.Requests = append(params.Requests, invokeRequest)
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


PreExecWithSelectUTXO
>>>>>>>>>>>>>>>>>>>>>

此接口用于在节点上进行消耗资源的合约预执行操作，内部是由一个PreExec加上一个SelectUTXO实现的，预执行并选择出需要消耗数额的utxo

http方法：``POST``

请求URL：``/v1/preexec_select_utxo``

header：``Content-Type:application/json``

**参数说明**

+----------+-------------------------------+
| 参数结构 | PreExecWithSelectUTXORequest  |
+----------+-------------------------------+
| 返回结构 | PreExecWithSelectUTXOResponse |
+----------+-------------------------------+

.. raw:: html

  <details>
  <summary><span>PreExecWithSelectUTXORequest</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message PreExecWithSelectUTXORequest {
      Header header = 1;
      string bcname = 2;
      string address = 3;
      int64 totalAmount = 4;
      SignatureInfo signInfo = 6;
      bool needLock = 7;
      InvokeRPCRequest request = 5;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

- *把预执行的请求结构放在了SelectUTXO结构中*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/preexec_select_utxo"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.PreExecWithSelectUTXORequest{}
    var invokeRPCRequest = &pb.InvokeRPCRequest{}
    params.Bcname = "xuper"
    var invokeRequest = &pb.InvokeRequest{}
    invokeRequest.ModuleName = "evm"
    invokeRequest.ContractName = "Cafe20"
    invokeRequest.MethodName = "mint"
    invokeRequest.Args = map[string][]byte{
    	"creator":[]byte("alice"),
    }
    invokeRPCRequest.Requests = append(invokeRPCRequest.Requests, invokeRequest)
    params.Request = invokeRPCRequest
    params.Address = "dpzuVdosQrF2kmzumhVeFQZa1aYcdgFpN"
    params.TotalAmount = 193
    // sign start
    // 假设alice 是一个account， 使用 crypto 获取 alice 的私钥，然后进行签名
    cryptoClient := crypto.GetCryptoClient()
    privateKey, err := cryptoClient.GetEcdsaPrivateKeyFromJsonStr(alice.PrivateKey)
    if err != nil{
    	return nil,err
    }
    sign, err := cryptoClient.SignECDSA(privateKey, digestHash)
    if err != nil{
    	return nil,err
    }
    signInfo := &pb.SignInfo{
    	Address: alice.Address,
    	PublicKey: alice.PublicKey,
    	Sign:      sign,
    }
    params.SignInfo = signInfo
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


PostTx
>>>>>>

此接口用于提交交易，是大部分操作都需要的最终环节

http方法：``POST``

请求URL：``/v1/post_tx``

header：``Content-Type:application/json``

**参数说明**

+----------+-------------+
| 参数结构 | TxStatus    |
+----------+-------------+
| 返回结构 | CommonReply |
+----------+-------------+

.. raw:: html

  <details>
  <summary><span>TxStatus</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message Transaction {
      // txid is the id of this transaction
      bytes txid = 1;
      // the blockid the transaction belong to
      bytes blockid = 2;
      // Transaction input list
      repeated TxInput tx_inputs = 3;
      // Transaction output list
      repeated TxOutput tx_outputs = 4;
      // Transaction description or system contract
      bytes desc = 6;
      // Mining rewards
      bool coinbase = 7;
      // Random number used to avoid replay attacks
      string nonce = 8;
      // Timestamp to launch the transaction
      int64 timestamp = 9;
      // tx format version; tx格式版本号
      int32 version = 10;
      // auto generated tx
      bool autogen = 11;

      repeated TxInputExt tx_inputs_ext = 23;
      repeated TxOutputExt tx_outputs_ext = 24;
      repeated InvokeRequest contract_requests = 25;

      // 权限系统新增字段
      // 交易发起者, 可以是一个Address或者一个Account
      string initiator = 26;
      // 交易发起需要被收集签名的AddressURL集合信息，包括用于utxo转账和用于合约调用
      repeated string auth_require = 27;
      // 交易发起者对交易元数据签名，签名的内容包括auth_require字段
      repeated SignatureInfo initiator_signs = 28;
      // 收集到的签名
      repeated SignatureInfo auth_require_signs = 29;
      // 节点收到tx的时间戳，不参与签名
      int64 received_timestamp = 30;
      // 统一签名(支持多重签名/环签名等，与initiator_signs/auth_require_signs不同时使用)
      XuperSignature xuper_sign = 31;
      // 可修改区块链标记
       ModifyBlock modify_block = 32;
      // HD加解密相关信息
      HDInfo HD_info = 33;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

- *Transaction属于XuperChain中比较核心的结构*

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/post_tx"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    // 一般 TxStatus 都是自动拼装的，无需手动拼接，感兴趣的请自行查阅 go sdk 相关源代码
    var params = &pb.TxStatus{}
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


QueryUtxoRecord
>>>>>>>>>>>>>>>

此接口用于查询合约账户的utxo情况

http方法：``POST``

请求URL：``/v1/query_utxo_record``

header：``Content-Type:application/json``

**参数说明**

+----------+------------------+
| 参数结构 | UtxoRecordDetail |
+----------+------------------+
| 返回结构 | UtxoRecordDetail |
+----------+------------------+

.. raw:: html

  <details>
  <summary><span>UtxoRecordDetail</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message UtxoRecordDetail {
    Header header = 1;
    string bcname = 2;
    string accountName = 3;
    UtxoRecord openUtxoRecord = 4;
    UtxoRecord lockedUtxoRecord = 5;
    UtxoRecord frozenUtxoRecord = 6;
    int64 displayCount = 7;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/query_utxo_record"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.UtxoRecordDetail{}
    params.Bcname = "xuper"
    params.AccountName = "XC1234567812345678@xuper"
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


QueryContractStatData
>>>>>>>>>>>>>>>>>>>>>

此接口用于查询链上的合约账户与合约数

http方法：``POST``

请求URL：``/v1/query_contract_stat_data``

header：``Content-Type:application/json``

**参数说明**

+----------+--------------------------+
| 参数结构 | ContractStatDataRequest  |
+----------+--------------------------+
| 返回结构 | ContractStatDataResponse |
+----------+--------------------------+

.. raw:: html

  <details>
  <summary><span>ContractStatDataRequest</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message ContractStatDataRequest {
    Header header = 1;
    string bcname = 2;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/query_contract_stat_data"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.ContractStatDataRequest{}
    params.bcname = "xuper"
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


GetAccountContracts
>>>>>>>>>>>>>>>>>>>

此接口用于查询合约账号下所有的合约

http方法：``POST``

请求URL：``/v1/get_account_contracts``

header：``Content-Type:application/json``

**参数说明**

+----------+-----------------------------+
| 参数结构 | GetAccountContractsRequest  |
+----------+-----------------------------+
| 返回结构 | GetAccountContractsResponse |
+----------+-----------------------------+

.. raw:: html

  <details>
  <summary><span>GetAccountContractsRequest</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message GetAccountContractsRequest {
    Header header = 1;
    string bcname = 2;
    string account = 3;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_account_contracts"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.GetAccountContractsRequest{}
  	params.Bcname = "xuper"
  	params.Account = "XC1234567812345678@xuper"
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


GetAccountByAK
>>>>>>>>>>>>>>

此接口用于查询普通账号的合约账号

http方法：``POST``

请求URL：``/v1/get_account_by_ak``

header：``Content-Type:application/json``

**参数说明**

+----------+--------------------+
| 参数结构 | AK2AccountRequest  |
+----------+--------------------+
| 返回结构 | AK2AccountResponse |
+----------+--------------------+

.. raw:: html

  <details>
  <summary><span>AK2AccountRequest</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message AK2AccountRequest {
    Header header = 1;
    string bcname = 2;
    string address = 3;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_account_by_ak"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.AK2AccountRequest{}
  	params.Bcname = "xuper"
  	params.Account = "gH2XKGrne4mL5y37vwChzvmLDEWkXnuB8"
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))


GetAddressContracts
>>>>>>>>>>>>>>>>>>>

此接口用于查询普通账号部署的合约

http方法：``POST``

请求URL：``/v1/get_address_contracts``

header：``Content-Type:application/json``

**参数说明**

+----------+--------------------------+
| 参数结构 | AddressContractsRequest  |
+----------+--------------------------+
| 返回结构 | AddressContractsResponse |
+----------+--------------------------+

.. raw:: html

  <details>
  <summary><span>AddressContractsRequest</span></summary></br>

.. code-block:: protobuf
  :linenos:

  message AddressContractsRequest {
    Header header = 1;
    string bcname = 2;
    string address = 3;
    bool need_content = 4;
  }


.. raw:: html

  </details>
  </br>

**请求示例**

.. code-block:: go
    :linenos:

    var host = "http://127.0.0.1:37301/v1/get_address_contracts"
    uri, err := url.Parse(host)
    if err != nil {
    	fmt.Println(err)
    }
    var params = &pb.AddressContractsRequest{}
  	params.Bcname = "xuper"
  	params.Account = "gH2XKGrne4mL5y37vwChzvmLDEWkXnuB8"
    sendBody, err := json.Marshal(params)
    if err != nil {
    	fmt.Println(err)
    }
    sendData := string(sendBody)
    client := &http.Client{}
    request, err := http.NewRequest("POST", uri.String(), strings.NewReader(sendData))
    if err != nil {
    	fmt.Println(err)
    }
    request.Header.Set("Content-Type", "application/json")
    response, err := client.Do(request)
    defer response.Body.Close()
    result, err := ioutil.ReadAll(response.Body)
    if err != nil {
    	fmt.Println(err)
    }
    fmt.Println(string(result))
