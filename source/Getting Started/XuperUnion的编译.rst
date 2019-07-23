
XuperUnion的编译
================

准备环境
^^^^^^^^

- 安装go语言编译环境，版本为1.11以上

    - 下载地址：`golang <https://golang.org/dl/>`_

- 安装git

    - 下载地址：`git <https://git-scm.com/download>`_

编译步骤
^^^^^^^^

- 使用git下载源码到本地

    - git clone xuperunion 地址

- 执行命令

.. code-block:: console
    :linenos:

    cd src/github.com/xuperchain/xuperunion
    make

- 得到产出xchain和xchain-cli

常见问题
^^^^^^^^

- 配置go语言环境变量

.. code-block:: console
    :linenos:

    export GOROOT=.../gotool/go
    export PATH=$GOROOT/bin:$PATH

- GOPATH问题报错

- go1.11版本之后无需关注

    - 在1.11版本之前需要配置。配置成以下形式：
    - 比如代码路径xxx/baidu/blockchain/xuperunion/src/baidu.com/xchain/xxx
    - export GOPATH=xxx/baidu/xuper/xuperunion

- gcc版本

    - 升级到4或5以上