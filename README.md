# 基于Prometheus搭建监控系统

![4197609471](C:\Users\zhulingqi\Desktop\4197609471.png)

## Prometheus介绍与搭建

参照上面的架构图，prometheus不止是监控系统，而且是个时序数据库。

prometheus采集数据的方式分为两种：

1. 如果要采集目标的监控数据，需要在目标处安装数据采集组件，这被称为exporter，它会在目标处收集监控数据，并且暴露一个HTTP接口供promethus查询，promutheus通过pull的方式采集数据。
2. 也可以将需要采集的数据推送到push gateway，prometheus通过pull的方式从push gateway获取数据。

prometheus server的主要作用是负责收集和存储数据指标，支持表达式查询和告警的生成。

### 安装prometheus

1. 开箱即用

   从官网获取最新的版本，https://prometheus.io/download/

   `wget https://github.com/prometheus/prometheus/releases/download/v2.45.4/prometheus-2.45.4.linux-amd64.tar.gz`

   `tar -zxvf prometheus-2.45.4.linux-amd64.tar.`gz

   切换到解压目录，检查Prometheus版本

   `[`root@localhost tmp]# cd prometheus-2.45.4.linux-amd64`
   `[root@localhost prometheus-2.45.4.linux-amd64]# ls`
   `LICENSE  NOTICE  console_libraries  consoles  prometheus  prometheus.yml  promtool`
   `[root@localhost prometheus-2.45.4.linux-amd64]# ./prometheus --version`
   `prometheus, version 2.45.4 (branch: HEAD, revision: dff334450260a50c47b4b4274c3edc6bfb866c60)`
     `build user:       root@6b005e74c4f5`
     `build date:       20240318-10:58:43`
     `go version:       go1.21.8`
     `platform:         linux/amd64`
     tags:             netgo,builtinassets,stringlabels`

   运行Prometheus程序

   `./prometheus --config.file=prometheus.yml`

2. docker方式运行

   `docker run -d -p 9090:9090 -v ~/Docker/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus`

   这里通过 -v 参数将本地的配置文件挂载到容器中。如果不确定容器中Prometheus中默认的配置文件在哪，可以通过docker inspect 命令获取

### 配置Prometheus参数

Prometheus中的默认配置文件 Prometheus.yml 分为四大块：

- global：Prometheus的全局配置，比如 scrape_interval 表示Prometheus多久抓取一次数据，evaluation_interval 表示多久检测一次告警规则。
- alerting：关于alertmanger的配置；
- rule_file：告警规则；
- scrape_configs：定义了Prometheus需要抓取的目标，默认是配置了一个名为 Prometheus 的job，这是因为Prometheus在启动的时候也会通过http接口暴露自身的指标数据，相当于Prometheus自己监控自己。可以访问 http://localhost:9090/metrics 查看Prometheus暴露了哪些指标。

更多的配置参数可以参考https://prometheus.io/docs/prometheus/latest/configuration/configuration/

