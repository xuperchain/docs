
智能合约SDK使用说明
===================

XuperChain 针对不同语言合约开发了合约 SDK，为用户封装链上能力的访问。

当前提供支持使用C++，GO 或着 JAVA 进行进行智能合约开发。

本文档对C++ 合约编程接口做简要说明，GO 合约文档参考 `go 合约 SDK 注释 <https://github.com/xuperchain/contract-sdk-go>`_ , 
JAVA 合约文档参考 `JAVA 合约SDK注释 <https://github.com/xuperchain/contract-sdk-java>`_

C++接口 API
----------

1. get_object


bool ContextImpl::get_object(const std::string& key, std::string* value)

输入

+-------+----------------------+
| 参数  | 说明                 |
+=======+======================+
| key   | 查询的key值          |
+-------+----------------------+
| value | 根据key查到的value值 |
+-------+----------------------+

输出

+-------+----------------------------+
| 参数  | 说明                       |
+=======+============================+
| true  | key值查询成功，返回value值 |
+-------+----------------------------+
| false | key值不存在                |
+-------+----------------------------+

2. put_object


bool ContextImpl::put_object(const std::string& key, const std::string& value)

输入

+-------+------------------------+
| 参数  | 说明                   |
+=======+========================+
| key   | 存入的key值            |
+-------+------------------------+
| value | 存入key值对应的value值 |
+-------+------------------------+

输出

+-------+------------+
| 参数  | 说明       |
+=======+============+
| true  | 存入db成功 |
+-------+------------+
| false | 存入db失败 |
+-------+------------+

3. delete_object


bool ContextImpl::delete_object(const std::string& key)

输入

+-------+-----------------+
| 参数  | 说明            |
+=======+=================+
| key   | 将要删除的key值 |
+-------+-----------------+

输出

+-------+-----------+
| 参数  | 说明      |
+=======+===========+
| true  | 删除成功  |
+-------+-----------+
| false | 删除失败  |
+-------+-----------+

4. 迭代器

std::unique_ptr<Iterator> new_iterator(const std::string& start, const std::string& limit)

输入

.. list-table:: 迭代器
   :widths: 25 25
   :header-rows: 1

   * - 参数
     - 含义
   * - start
     - 迭代器起始值
   * - limit
     - 迭代器终止值
输出

    返回标准迭代器接口 Iterator

5. 合约调用者

* 获取合约调用的发起者
const std::string& initiator() const
输入

无

输出

合约调用的发起者

* 获取合约的直接调用者

Account& sender() 

输入

无

输出

合约调用者的地址，在跨合约调用中是上一级调用者


6. 合约权限控制信息

* int auth_require_size() const

需要获取鉴权账号的数量

* const std::string& auth_require(int idx) const
第 idx 个需要参与鉴权的账号

4. 跨合约调用
bool call(const std::string& module, const std::string& contract,
                      const std::string& method,
                      const std::map<std::string, std::string>& args,
                      Response* response);
.. list-table:: 跨合约调用
   :widths: 25 25
   :header-rows: 1

   * - 参数
     - 含义
   * - module
     - 调用的模块
   * - contract
     - 调用的合约名
   * - method
     - 调用的合约方法
   * - args
     - 合约调用参数
   * - response
     - 合约调用的返回值


7. 合约日志           

void logf(const char* fmt, ...);

以格式化的方式打印字符串，格式化方式类似 printf

8. 合约事件
bool emit_event(const std::string& name, const std::string& body)

触发一个合约事件，name 是事件名称，body 是事件的描述

9. query_tx

bool ContextImpl::query_tx(const std::string &txid, Transaction* tx)

输入

+------+-------------------------+
| 参数 | 说明                    |
+======+=========================+
| txid | 待查询的txid            |
+------+-------------------------+
| tx   | 得到此txid的transaction |
+------+-------------------------+

输出

+-------+--------------+
| 参数  | 说明         |
+=======+==============+
| true  | 查询交易成功 |
+-------+--------------+
| false | 查询交易失败 |
+-------+--------------+

10. query_block

bool ContextImpl::query_block(const std::string &blockid, Block* block)

输入

+---------+----------------------+
| 参数    | 说明                 |
+=========+======================+
| blockid | 待查询的blockid      |
+---------+----------------------+
| block   | 得到此blockid的block |
+---------+----------------------+

输出

+-------+---------------+
| 参数  | 说明          |
+=======+===============+
| true  | 查询block成功 |
+-------+---------------+
| false | 查询block失败 |
+-------+---------------+

11. 在合约中使用 table

* 定义表格

    .. code-block:: protobuf
        :linenos:

        // 表格定义以proto形式建立，存放目录为contractsdk/cpp/pb
        syntax = "proto3";
        option optimize_for = LITE_RUNTIME;
        package anchor;
        message Entity {
            int64 id = 1;
            string name = 2;
            bytes desc = 3;
        }
        // table名称为Entity，属性分别为id，name，desc

* 初始化表格

    .. code-block:: c++
        :linenos:

        // 定义表格的主键，表格的索引
        struct entity: public anchor::Entity {
            DEFINE_ROWKEY(name);
            DEFINE_INDEX_BEGIN(2)
            DEFINE_INDEX_ADD(0, id, name)
            DEFINE_INDEX_ADD(1, name, desc)
            DEFINE_INDEX_END();
        };
        // 声明表格
        xchain::cdt::Table<entity> _entity;

* put


    .. code-block:: c++
        :linenos:

        template <typename T>
        bool Table<T>::put(T t)

    输入

    +------+----------------+
    | 参数 | 说明           |
    +======+================+
    | t    | 待插入的数据项 |
    +------+----------------+

    输出

    +-------+-----------+
    | 参数  | 说明      |
    +=======+===========+
    | true  | 插入成功  |
    +-------+-----------+
    | false | 插入失败  |
    +-------+-----------+

    样例

    .. code-block:: c++
        :linenos:

        // 参考样例 contractsdk/cpp/example/anchor.cc
        DEFINE_METHOD(Anchor, set) {
            xchain::Context* ctx = self.context();
            const std::string& id= ctx->arg("id");
            const std::string& name = ctx->arg("name");
            const std::string& desc = ctx->arg("desc");
            Anchor::entity ent;
            ent.set_id(std::stoll(id));
            ent.set_name(name.c_str());
            ent.set_desc(desc);
            self.get_entity().put(ent);
            ctx->ok("done");
        }

* find

    .. code-block:: c++
        :linenos:

        template <typename T>
        bool Table<T>::find(std::initializer_list<PairType> input, T* t)

    输入

    +-------+--------------+
    | 参数  | 说明         |
    +=======+==============+
    | input | 查询关键字   |
    +-------+--------------+
    | t     | 返回的数据项 |
    +-------+--------------+

    输出

    +-------+-----------+
    | 参数  | 说明      |
    +=======+===========+
    | true  | 查询成功  |
    +-------+-----------+
    | false | 查询失败  |
    +-------+-----------+

    样例

    .. code-block:: c++
        :linenos:

        DEFINE_METHOD(Anchor, get) {
            xchain::Context* ctx = self.context();
            const std::string& name = ctx->arg("key");
            Anchor::entity ent;
            if (self.get_entity().find({{"name", name}}, &ent)) {
                ctx->ok(ent.to_str());
                return;
            }
            ctx->error("can not find " + name);
        }

* scan

    .. code-block:: c++
        :linenos:
        
        template <typename T>
        std::unique_ptr<TableIterator<T>> Table<T>::scan(std::initializer_list<PairType> input)

    输入

    +-------+--------------+
    | 参数  | 说明         |
    +=======+==============+
    | input | 查询关键字   |
    +-------+--------------+

    输出

    +---------------+--------------------+
    | 参数          | 说明               |
    +===============+====================+
    | TableIterator | 符合条件的迭代器   |
    +---------------+--------------------+

    样例

    .. code-block:: c++
        :linenos:

        DEFINE_METHOD(Anchor, scan) {
            xchain::Context* ctx = self.context();
            const std::string& name = ctx->arg("name");
            const std::string& id = ctx->arg("id");
            // const std::string& desc = ctx->arg("desc");
            auto it = self.get_entity().scan({{"id", id},{"name", name}});
            Anchor::entity ent;
            int i = 0;
            std::map<std::string, bool> kv;
            while(it->next()) {
                if (it->get(&ent)) {
                    /*
                    std::cout << "id: " << ent.id()<< std::endl;
                    std::cout << "name: " << ent.name()<< std::endl;
                    std::cout << "desc: " << ent.desc()<< std::endl;
                    */
                    if (kv.find(ent.name()) != kv.end()) {
                        ctx->error("find duplicated key");
                        return;
                    }
                    kv[ent.name()] = true;
                    i += 1;
                } else {
                    std::cout << "get error" << std::endl;
                }
            }
            std::cout << i << std::endl;
            if (it->error()) {
                std::cout << it->error(true) << std::endl;
            }
            ctx->ok(std::to_string(i));
        }

* del


    .. code-block:: c++
        :linenos:

        template <typename T>
        bool Table<T>::del(T t)

    输入

    +------+------------+
    | 参数 | 说明       |
    +======+============+
    | t    | 一个数据项 |
    +------+------------+

    输出

    +-------+-----------+
    | 参数  | 说明      |
    +=======+===========+
    | true  | 删除成功  |
    +-------+-----------+
    | false | 删除失败  |
    +-------+-----------+

    样例

    .. code-block:: c++
        :linenos:

        DEFINE_METHOD(Anchor, del) {
            xchain::Context* ctx = self.context();
            const std::string& id= ctx->arg("id");
            const std::string& name = ctx->arg("name");
            const std::string& desc = ctx->arg("desc");
            Anchor::entity ent;
            ent.set_id(std::stoll(id));
            ent.set_name(name.c_str());
            ent.set_desc(desc);
            self.get_entity().del(ent);
            ctx->ok("done");
        }


12. 在合约中使用 JSON 

  XuperChain SDK 包含了 json 相关的库，可以在合约中方便地使用 json 进行序列化和反序列化。 
  
  在合约中使用 json 的例子如下

.. code:: cpp

    #include "xchain/json/json.h"
    #include "xchain/xchain.h"

    struct Features : xchain::Contract {
    };

    DEFINE_METHOD(Features, json_load_dump) {
        xchain::Context *ctx = self.context();
        const std::string v = ctx->arg("value");
        auto j = xchain::json::parse(v);
        ctx->ok(j.dump());
    }

    DEFINE_METHOD(Features, json_literal) {
        xchain::Context *ctx = self.context();
        xchain::json j = {
                {"int",    3},
                {"float",  3.14},
                {"string", "hello"},
                {"array",  {"hello", "world"}},
                {"object", {{"key", "value"}}},
                {"true",   true},
                {"false",  false},
                {"null",   nullptr},
        };
        ctx->ok(j.dump());
    }

关于 json 库更多的内容可以查看  `文档 <https://github.com/nlohmann/json>`_ 
