监控使用文档
==============

 XuperChain 系统集成了Prometheus开源监控框架，用户可以通过Prometheus+Grafana构建自己应用的监控系统，并且用户还可以根据自己的需求定义自己的监控采集项。下面会介绍目前 XuperChain 默认采集的监控项，并指导用户如何搭建自己本地的 XuperChain 开源监控系统。

XuperChain 监控项
--------------

+-----------------------+--------------------+-----+-----------+
|监控项名称             |监控项含义          |单位 |说明       |
+=======================+====================+=====+===========+
|rpc_flow_out           |当前RPC接口上行流量 |byte |以链为粒度 |
+-----------------------+--------------------+-----+-----------+
|rpc_flow_in            |当前RPC接口下行流量 |byte |以链为粒度 |
+-----------------------+--------------------+-----+-----------+
|p2p_flow_out           |当前p2p网络上行流量 |byte |以链为粒度 |
+-----------------------+--------------------+-----+-----------+
|p2p_flow_in            |当前p2p网络下行流量 |byte |以链为粒度 |
+-----------------------+--------------------+-----+-----------+
|grpc接口默认监控项系列 |                    |     |以链为粒度 |
+-----------------------+--------------------+-----+-----------+

XuperChain 监控系统搭建
--------------------

搭建网络
>>>>>>>>>

搭建网络，节点xchain.yaml配置中打开prometheus 端口，如下所示：

.. code-block:: bash
    
    tcpServer:
      # prometheus监控指标端口, 为空的话就不启动
        metricPort: :37200

使用Prometheus查看监控
>>>>>>>>>>>>>>>>>>>>>>>>

1. prometheus 安装教程:

   a. https://prometheus.io/docs/introduction/first_steps/
#. 配置prometheus 设置endpoint服务:

   a. 修改 prometheus.yml 文件，添加如下配置，指向prometheus端口:

   .. image:: ../images/monitoring-1.png  
       :align: center


#. 启动prometheus:

   a. nohup ./prometheus --config.file=prometheus.yml &
#. 查看流量信息（以流量监控信息为例）：
   
   a. http://localhost:9090/graph
   
   b. p2p_flow_in 

   .. image:: ../images/monitoring-2.png 
       :align: center


   c. p2p_flow_out

   .. image:: ../images/monitoring-3.png
       :align: center


   d. rpc_flow_in

   .. image:: ../images/monitoring-4.png
       :align: center


   e. rpc_flow_out

   .. image:: ../images/monitoring-5.png
       :align: center

使用Grafana查看监控
>>>>>>>>>>>>>>>>>>>>

因为Prometheus的界面看起来非常简单，我们还可以通过Grafana这个非常强大也是最常用的监控展示框架。

使用文档参看： https://grafana.com/grafana/download

使用接口查看监控
>>>>>>>>>>>>>>>>>

Prometheus提供了一种功能查询语言PromQL（Prometheus查询语言），它允许用户实时选择和聚合时间序列数据。同时为了方便外部系统调用，还提供了HTTP API能力。

详情请参考： https://prometheus.io/docs/prometheus/latest/querying/api/

