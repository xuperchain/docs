共识使用
==========================
整体介绍
-----------
XuperChain目前提供的共识算法包括:

Single
^^^^^^^
 单节点矿工机制。在集群中仅有一个固定角色的矿工，该矿工负责生产区块，其余节点从其同步账本。

PoW
^^^^^^
 类似于Bitcoin种的PoW机制。在集群中每个节点都以矿工身份进行挖矿，并且从其他节点同步区块。

 
TDPoS和XPoS
^^^^^^^^^^^^
 XuperChain自研的类DPoS算法。节点可向系统抵押治理Token以投票给自身支持的候选人节点，系统按照治理Token抵押总数排序，选取指定数量的节点作为候选人节点，候选人组按照时间片进行矿工轮转。XPoS在TDPoS基础上，增加了底层Chained-BFT组件，确保系统在指定区块高度下账本不可回滚，保证业务数据落盘。

PoA和XPoA
^^^^^^^^^^^^^
 XuperChain自研的类PoA算法，适合联盟链场景，节点可使用专有合约进行权益转移，按照业务要求对联盟链中共识节点进行说明，候选人节点根据专有合约进行变更，变更需要联盟中指定节点进行签名。XPoA在PoA基础上，增加了底层Chained-BFT组件，确保系统在指定区块高度下账本不可回滚，保证业务数据落盘。

变更矿工方法
-----------------
 XuperChain支持矿工的灵活变更，目前矿工的确定主要通过设置指定的候选人集合，矿工根据指定时间片在候选人集合中轮转产生。目前支持该变更方法的共识为TDPoS类共识(指TDPoS和XPoS)和PoA类共识(之PoA和XPoA)。

- `TDPoS类共识使用 <consensus/consensus_dpos_manual.html#xuperchain>`_ 

- `PoA类共识使用 <consensus/consensus_poa_manual.html#xuperchain>`_

.. toctree::
	:titlesonly:
	:includehidden:

	consensus/consensus_dpos_manual.rst
	consensus/consensus_poa_manual.rst


