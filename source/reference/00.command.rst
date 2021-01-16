
指令介绍(API)
=============

节点rpc接口
-----------

详细见： `core/pb/xchain.proto <https://github.com/xuperchain/xuperchain/blob/master/core/pb/xchain.proto>`_

=================================================================================================  ==================
API                                                                                                功能
=================================================================================================  ==================
rpc QueryTx(TxStatus) returns (TxStatus)                                                           查询一个交易
rpc GetBalance(AddressStatus) returns (AddressStatus)                                              查询可用余额
rpc GetFrozenBalance(AddressStatus) returns (AddressStatus)                                        查询被冻结的余额
rpc GetBalanceDetail(AddressBalanceStatus) returns (AddressBalanceStatus)                          查询余额状态细节
rpc GetBlock(BlockID) returns (Block)                                                              从当前账本获取特定id的区块
rpc GetBlockByHeight(BlockHeight) returns (Block)                                                  从当前账本获取特定高度的区块
rpc GetBlockChains(CommonIn) returns (BlockChains)                                                 获取系统中所有的链名
rpc GetBlockChainStatus(BCStatus) returns (BCStatus)                                               获取指定账本的最新区块数据
rpc GetSystemStatus(CommonIn) returns (SystemsStatusReply)                                         获取系统状态
rpc GetNetUrl(CommonIn) returns (RawUrl)                                                           获取区块链网络中某节点的neturl
rpc GetAccountByAK(AK2AccountRequest) returns (AK2AccountResponse)                                 查询包含指定地址的所有合约账号
rpc SelectUTXO(UtxoInput) returns (UtxoOutput)                                                     选择指定地址/合约账号的utxo
rpc SelectUTXOBySize(UtxoInput) returns (UtxoOutput)                                               按个数选择地址/合约账号的utxo
rpc PreExec(InvokeRPCRequest) returns (InvokeRPCResponse)                                          预执行智能合约
rpc PreExecWithSelectUTXO(PreExecWithSelectUTXORequest) returns (PreExecWithSelectUTXOResponse)    预执行智能合约并选择出需要的utxo
rpc PostTx(TxStatus) returns (CommonReply)                                                         对一个交易进行验证并转发给附近网络节点
rpc QueryACL(AclStatus) returns (AclStatus)                                                        查询合约账号/合约方法的Acl
rpc QueryUtxoRecord(UtxoRecordDetail) returns (UtxoRecordDetail)                                   查询账号的utxo细节
rpc GetAccountContracts(GetAccountContractsRequest) returns (GetAccountContractsResponse)          获取合约账号下部署的智能合约
=================================================================================================  ==================


开发者接口
----------

C++接口详细可参见： `core/contractsdk/cpp/xchain/xchain.h <https://github.com/xuperchain/xuperchain/blob/master/core/contractsdk/cpp/xchain/xchain.h>`_

====================================================================  ===============
API                                                                   功能
====================================================================  ===============
map<string, string>& args()                                           获取传入合约的参数表
string& arg(string& name)                                             获取传入合约的指定参数值
string& initiator()                                                   获取发起此合约调用的账号
int auth_require_size()                                               获取授权此合约调用的账号数
string& auth_require(int idx)                                         获取授权此合约调用的指定账号
bool get_object(string& key, string* value)                           进行一次读操作
bool put_object(string& key, string& value)                           进行一次写操作
bool delete_object(string& key)                                       进行一次删除操作
bool query_tx(string &txid, Transaction* tx)                          查询指定id的交易内容
bool query_block(string &blockid, Block* block)                       查询指定id的区块内容
void ok(string& body)                                                 构造状态码为成功的返回
void error(string& body)                                              构造状态码为失败的返回
string& transfer_amount()                                             获取合约调用操作中的转账数额
unique_ptr<Iterator> new_iterator(string& start, string& limit)       获得遍历合约存储的迭代器
call(module, contract, method, args ... )                             调用其他合约
====================================================================  ===============

Golang接口详细可参见： `core/contractsdk/go/code/context.go <https://github.com/xuperchain/xuperchain/blob/master/core/contractsdk/go/code/context.go>`_

=====================================================================  ==============================
API                                                                    功能
=====================================================================  ==============================
Args() map[string][]byte                                               获取传入合约的参数表
Initiator() string                                                     获取发起此合约调用的账号
AuthRequire() []string                                                 获取授权此合约调用的账号
PutObject(key []byte, value []byte) error                              进行一次写操作
GetObject(key []byte) ([]byte, error)                                  进行一次读操作
DeleteObject(key []byte) error                                         进行一次删除操作
NewIterator(start, limit []byte) Iterator                              获得遍历合约存储的迭代器
QueryTx(txid string) (\*pb.Transaction, error)                         查询指定id的交易内容
QueryBlock(blockid string) (\*pb.Block, error)                         查询指定id的区块内容
Transfer(to string, amount \*big.Int) error                            进行转账操作
TransferAmount() (\*big.Int, error)                                    获取合约调用操作中的转账数额
Call(module, contract, method string, args ... ) (\*Response, error)   调用其他合约
=====================================================================  ==============================
