
智能合约SDK使用说明
===================

XuperUnion为方便用户开发属于自己的智能合约，提供了一整套SDK套件，即XuperCDT（XuperChain Crontract Development Toolkit），包含C++语言和Go语言

C++接口API
----------

get_object
^^^^^^^^^^

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

put_object
^^^^^^^^^^

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

delete_object
^^^^^^^^^^^^^

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

query_tx
^^^^^^^^

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

query_block
^^^^^^^^^^^

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

table
^^^^^

定义表格
""""""""

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

初始化表格
""""""""""

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

put
"""

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

find
""""

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

scan
""""

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

del
"""

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


Go接口API
---------

GetObject
^^^^^^^^^

func GetObject(key []byte) ([]byte, error)

输入

+------+-------------+
| 参数 | 说明        |
+======+=============+
| key  | 查询的key值 |
+------+-------------+

输出

+------------+--------------------------------+
| 参数       | 说明                           |
+============+================================+
| value, nil | key值查询成功，返回value值     |
+------------+--------------------------------+
| _, 非nil   | key值不存在                    |
+------------+--------------------------------+

PutObject
^^^^^^^^^

func PutObject(key []byte, value []byte) error

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
| nil   | 存入db成功 |
+-------+------------+
| 非nil | 存入db失败 |
+-------+------------+

DeleteObject
^^^^^^^^^^^^

func DeleteObject(key []byte) error

输入

+------+-----------------+
| 参数 | 说明            |
+======+=================+
| key  | 将要删除的key值 |
+------+-----------------+
	
输出

+-------+-----------+
| 参数  | 说明      |
+=======+===========+
| nil   | 删除成功  |
+-------+-----------+
| 非nil | 删除失败  |
+-------+-----------+

QueryTx
^^^^^^^

func QueryTx(txid string) (\*pb.Transaction, error)

输入

+------+--------------+
| 参数 | 说明         |
+======+==============+
| txid | 待查询的txid |
+------+--------------+

输出

+----------+---------------------------------------+
| 参数     | 说明                                  |
+==========+=======================================+
| tx, nil  | 查询交易成功, 得到此txid的transaction |
+----------+---------------------------------------+
| _, 非nil | 查询交易失败                          |
+----------+---------------------------------------+

QueryBlock
^^^^^^^^^^

func QueryBlock(blockid string) (\*pb.Block, error)

输入

+---------+-----------------+
| 参数    | 说明            |
+=========+=================+
| blockid | 待查询的blockid |
+---------+-----------------+

输出

+------------+-------------------------------------+
| 参数       | 说明                                |
+============+=====================================+
| block, nil | 查询block成功, 得到此blockid的block |
+------------+-------------------------------------+
| _, 非nil   | 查询block失败                       |
+------------+-------------------------------------+

NewIterator
^^^^^^^^^^^

func NewIterator(start, limit []byte) Iterator

输入

+-------+------------------+
| 参数  | 说明             |
+=======+==================+
| start | 关键字           |
+-------+------------------+
| limit | 数据项的最大数量 |
+-------+------------------+

输出

+----------+-----------------+
| 参数     | 说明            |
+==========+=================+
| Iterator | Interator的接口 |
+----------+-----------------+

样例

.. code-block:: go
    :linenos:

    Key() []byte
    Value() []byte
    Next() bool
    Error() error
    // Iterator 必须在使用完毕后关闭
    Close()

