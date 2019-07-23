
指令介绍(API)
=============

节点rpc接口
-----------

详细见：pb/xchain.proto

=================================================================================================  ==================
API                                                                                                功能
=================================================================================================  ==================
rpc createAccount(AccountInput) returns (AccountOutput)                                            创建公私钥对
rpc GenerateTx(TxData) returns (TxStatus)                                                          生成交易
rpc PostTx(TxStatus) returns (CommonReply)                                                         对一个交易进行验证并转发给附近网络节点
rpc BatchPostTx(BatchTxs) returns (CommonReply)                                                    对一批交易进行验证并转发给附近网络节点
rpc QueryAcl(AclStatus) returns (AclStatus)                                                        查询合约账号/合约方法的Acl
rpc QueryTx(TxStatus) returns (TxStatus)                                                           查询一个交易
rpc GetBalance(AddressStatus) returns (AddressStatus)                                              查询可用余额
rpc GetFrozenBalance(AddressStatus) returns (AddressStatus)                                        查询被冻结的余额
rpc SendBlock(Block) returns (CommonReply)                                                         将当前区块为止的所有区块上账本
rpc GetBlock(BlockID) returns (Block)                                                              从当前账本获取特定区块
rpc GetBlockChainStatus(BCStatus) returns (BCStatus)                                               获取账本的最新区块数据
rpc ConfirmBlockChainStatus(BCStatus) returns (BCTipStatus)                                        判断某个区块是否为账本主干最新区块
rpc GetBlockChains(CommonIn) returns (BlockChains)                                                 获取所有的链名
rpc GetSystemStatus(CommonIn) returns (SystemsStatusReply)                                         获取系统状态
rpc GetNetUrl(CommonIn) returns (RawUrl)                                                           获取区块链网络中某个节点的url
rpc GenerateAccountByMnemonic(GenerateAccountByMnemonicInput) returns (AccountMnemonicInfo)        创建一个带助记词的账号
rpc CreateNewAccountWithMnemonic(CreateNewAccountWithMnemonicInput) returns (AccountMnemonicInfo)  通过助记词恢复账号
rpc MergeUTXO (TxData) returns (CommonReply)                                                       将同一个地址的多个余额项合并
rpc SelectUTXOV2 (UtxoInput) returns(UtxoOutput)                                                   查询一个地址/合约账户对应的余额是否足够
rpc QueryContract(QueryContractRequest) returns (QueryContractResponse)                            查询合约数据
=================================================================================================  ==================


开发者接口
----------

详细见：contractsdk/pb/contract.proto

====================================================================  ===============
API                                                                   功能
====================================================================  ===============
rpc PutObject(PutRequest) returns (PutResponse)                       产生一个读加一个写
rpc GetObject(GetRequest) returns (GetResponse)                       生成一个读请求
rpc DeleteObject(DeleteRequest) returns (DeleteResponse)              产生一个读加一个特殊的写
rpc NewIterator(IteratorRequest) returns (IteratorResponse)           对迭代的key产生读
rpc QueryTx(QueryTxRequest) returns (QueryTxResponse)                 查询交易
rpc QueryBlock(QueryBlockRequest) returns (QueryBlockResponse)        查询区块
rpc ContractCall(ContractCallRequest) returns (ContractCallResponse)  合约调用
rpc Ping(PingRequest) returns (PingResponse)                          探测是否存活
====================================================================  ===============
