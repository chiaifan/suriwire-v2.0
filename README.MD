# Suriwire v2.0

**Suriwire 是一种在wireshark运行Suricata的插件，它允许您将Suricata警报和协议信息显示为协议分析的元素。Suriwirev2.0是基于 [suriwire](https://github.com/regit/suriwire "suriwire")编写，支持windows平台。增加Run Suricata功能**
![image](https://github.com/chiaifan/suriwire-v2.0/blob/master/image/suriwire.alret.png)
Suriwirev2.0 解析的事件:

* Alerts
* HTTP
* fileinfo
* TLS
* SSH
目前支持wireshark过滤器操作，例如，suricata.alert.sid
![image](https://github.com/chiaifan/suriwire-v2.0/blob/master/image/suriwire.alret.png)

## Install
1. 安装[Suicata](https://suricata-ids.org/ "Suicata")的主机
2. 复制suriwire.lua或将其链接到wireshark插件目录。`wireshark/plugins/`。
3. 复制dkjson.lua到wireshark安装
4. 编写wireshark安装目录init.lua，末尾添加dofile(DATA_DIR.."dkjson.lua")

## 使用
1. wirehshark 编辑->首选项，找到suricata协议，配置suricata程序路径，配置suricata的yaml文件，配置需要解析告警日志文件。
2. wireshark 工具->suricata->Run Suricata
3. 填写需要解析pcap文件
4. wireshark 工具->suricata->Activate
## 感谢
本项目基于suriwire编写: https://github.com/regit/suriwire
