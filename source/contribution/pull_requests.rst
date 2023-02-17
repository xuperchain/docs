代码提交指南
========

XuperChain 欢迎任何形式的贡献（包括但不限于贡献新feature，完善文档，参加线下活动，提Issue)。

对于想给 XuperChain 贡献代码的开发者，在这里以 "给 https://github.com/xuperchain/xuperchain 提交代码" 为例来详细解释代码提交流程

Fork 代码
---------

首先访问 https://github.com/xuperchain/xuperchain ，fork代码到自己的代码仓库

   .. image:: ../images/github.png  
       :align: center

Clone代码到本地
---------------

假设 fork 的代码仓库路径为 https://github.com/icexin/xuperchain

.. code-block:: bash


    git clone https://github.com/icexin/xuperchain.git


此时再设置一个 "upstream" 的remote地址，方便同步原始仓库地址的更新

.. code-block:: bash

    git remote add upstream https://github.com/xuperchain/xuperchain.git


同步代码并建立新分支
--------------------
每次要提交PR的时候都要新建一个分支，这样可以同时开发多个feature，分支基于upstream的master建立


.. code-block:: bash

    # 拉取原始仓库的最新代码
    git fetch upstream

    # 建立新分支
    git checkout -b new_feature upstream/master

之后就可以在这个分支上开发代码了


提交代码
--------
当完成编写代码之后就可以提交带代码了，注意这里是提交到origin（remote），也就是自己的代码仓库 https://github.com/icexin/xuperchain

.. code-block:: bash

    $ git push origin new_feature

    Counting objects: 3, done.
    Delta compression using up to 2 threads.
    Compressing objects: 100% (3/3), done.
    Writing objects: 100% (3/3), 286 bytes | 286.00 KiB/s, done.
    Total 3 (delta 2), reused 0 (delta 0)
    remote: Resolving deltas: 100% (2/2), completed with 2 local objects.
    remote:
    remote: Create a pull request for 'new_feature' on GitHub by visiting:
    remote:      https://github.com/icexin/xuperunion/pull/new/new_feature
    remote:
    To https://github.com/icexin/xuperunion.git
    * [new branch]      new_feature -> new_feature


创建PR
------
代码提交后，可通过输出信息中的链接（如：https://github.com/icexin/xuperunion/pull/new/new_feature）或 自己的代码仓库，在浏览器打开创建PR的页面。

填写信息，创建 PR。

   .. image:: ../images/pull_request.png  
       :align: center


.. note::

    如果解决了某个 Issue 的问题，请在该 PR 的中填写：`Fixes #issue_number`。
    这样当该 PR 被合并后，会自动关闭对应的 Issue。
    可参考 `Closing issues via commit messages <https://help.github.com/articles/closing-issues-via-commit-messages>`_ 。

提交修改补丁
----------------
在review的过程中，评审人会提出修改意见，您可以继续在new_feature分支上添加commit，再push，就会在当前的PR上进行更新

.. code-block:: bash

    git add -u
    git commit -m 'some fix'
    git push origin new_feature


在持续修改过程中，关于评审人意见，推荐遵循以下约定。

- 评审人的每个意见都回复：

  - 对评审意见同意且按其修改完的，给个简单的Done即可；

  - 对评审意见不同意的，请给出您自己的反驳理由。

合入代码
--------
如果代码的 CI 通过，评审人也没有反对意见，代码可以合入master分支。

您也可以相应删除本地和远端的new_feature分支。

.. code-block:: bash

    git branch -D new_feature

.. note::

    你也可以点击 star 收藏该仓库以便后续快速找到该仓库

       .. image:: ../images/star.png  
        :align: center