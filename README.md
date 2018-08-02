# Alexamaster 一键启动脚本使用指南
# Alexamaster onkey start user guide
<br />
<br />

## 前言
## Introduce
<br />
<br />

像我这样的人呢，越穷，还图便宜，剁手了一堆小鸡，又没有那么多实际用处，结果除了挂梯子，只好拿来吃灰，正好看到狗仔小分队大佬的博客：http://xiaofd.win/earn-money-alexamaster-onekey.html 上介绍了一种挂机的方法。
<br />
<br />
它的原理是注册账号后，获得一个链接，同一IP（电脑）访问这个链接，这个链接上的Script脚本就会模拟用户浏览网站的操作，定时自动打开各种网站的链接，为这些网站刷访问量，提升它们的alexa排名。
<br />
<br />
作为回报，挂机者也会获得一些收益，挂机获得的是点数，然后攒到一定数量，就可以兑换成美刀提现，虽然收益不咋地（一台机器挂一个月大概能赚1美刀），但总聊胜于无，能勉强给小鸡的费用回本就不错了。
<br />
<br />
大佬的那个脚本已经自动配置了vnc环境，预装firefox，浏览器插件，浏览器参数优化等操作。
<br />
<br />
但是，但是，便宜的vps一般配置不咋地，256M起步，512M主流，1GB的很少见，甚至128M的都有，现代浏览器在这些小鸡上跑，还是挺费劲的，尤其是长时间运行，越来越复杂的网页特效、JS脚本，会让机器不堪重负，很容易出现爆内存（溢出）浏览器进程自动被关闭的问题，其实只要手动重启一下就好了，然后就这样循环往复。
<br />
<br />
可是，我手上这么多小鸡，精力也是有限的，哪能随时盯着它们，比如半夜两三点爬起来，打开VNC，看看浏览器进程是不是挂掉了，所以就写了个脚本，定时查看系统里的firefox进程是否存在，如果不存在，立马就让firefox重新启动，一除各位挂机之忧。
<br />
<br />
<br />

## 特色功能
<br />
<br />

- 运行平台判断，<b>仅适用于Ubuntu 16.04</b>（由狗仔小分队大佬的脚本决定），其他系统不予支持，否则自动退出；

<br />

- 下载运行脚本后，输入挂机链接回车确认，即可完成部署，无需其他操作；
<br />

- 每隔2分钟自动检测firefox进程是否存在，如果不在了就立马重新启动浏览器，无需人工值守。
<br />
<br />
<br />

## Special features
<br />
<br />

- Can only used by <b>Ubuntu Xenial</b>(determined by xiaofd.win's original shell), doesn't support other system.；
<br />

- Once download and run it, you only need to input your alexamaster url instead of other operations；
<br />

- Check whether firefox process is running every 2 minutes, if it have been killed, this shell will wake it up automatically.
<br />
<br />
<br />

## 使用方法
## How to use
<br />
<br />
<b>1. 如果还没有部署VNC+firefox，请先下载：</b>
<br />
<br />
If you didn't deploy VNC and firefox, you should download it before.
<br />
<br />
<pre><code>wget xiaofd.github.io/vncam.sh</code></pre>
<br />
<br />
<b>1.1</b> 运行：
<br />
<br />
Execute it:
<br />
<br />
<pre><code>bash vncam.sh -p 'xiaofd.github.io/others/passwd-d10086' -u 'https://www.alexamaster.net/Master/102724'</code></pre>
<br />
<br />
<b>1.2</b> “passwd-”后面的“d10086”是VNC连接的默认密码，安装完毕后，可输入：
<br />
<br />
The "d10086" after "passwd-" is default VNC connection password, you can input following command when finished installation
<br />
<br />
<pre><code>vncpasswd</code></pre>
直接修改VNC登录密码
<br />
<br />
Modify VNC login password
<br />
<br />
<br />
VNC连接默认端口号是：5901
<br />
<br />
The default port of VNC is 5901
<br />
<br />
<br />
<br />
<b>1.3</b> 启动vnc桌面：
<br />
<br />
Switch on VNC desktop:
<br />
<br />
<pre><code>tightvncserver :1</code></pre>
<br />
<br />
<b>1.4</b> 手动启动firefox挂机（<b>使用我的脚本后不必再用此命令操作</b>）：
<br />
<br />
Start manually to hang up during system running(<b>if you use my shell, don't execute these following two commands</b>):
<br />
<br />
<pre><code>export DISPLAY=localhost:1</code></pre>
<pre><code>firefox --profile ~/.alexa/alexa --new-tab 'https://www.alexamaster.net/Master/102724' &</code></pre>
<br />
<br />
<b>2. 使用此脚本驻入系统服务，开启自动挂机：</b>
<br />
<br />
Download shell and run it to keep hanging!
<br />
<br />
<pre><code>wget --no-check-certificate -O alexamaster.sh https://git.io/fNKQt && chmod +x alexamaster.sh && bash ./alexamaster.sh</code></pre>
<br />
<br />
<b>2.1</b> 如何修改Alexamaster挂机url？
<br />
<br />
How to change a new Alexamaster url?
<br />
<br />
<pre><code>bash /root/runalexamaster.sh</code></pre>
<br />
<br />
<b>2.2</b> 如何卸载该服务？
<br />
<br />
How to uninstall it?
<br />
<br />
<pre><code>rm -rf /root/alexamaster.sh /root/runalexamaster.sh</code></pre>
<br />
<br />
