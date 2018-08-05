#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# 仅支持Ubuntu 16.04

if grep -Eqi "xenial" /etc/os-release; then

# 读取链接，传参，默认链接是我自己的

echo -e "Please input your alexaMaster url:"
read -p "alexaMaster url(Default url is belong to molly):" alexaurl

[ -z "${alexaurl}" ] && alexaurl="https://www.alexamaster.net/Master/102724"

expr ${alexaurl} + 1 &>/dev/null

# 将自动运行alexamaster的脚本文件写入root根目录

cat > /root/runalexamaster.sh<<-EOF
#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

### BEGIN INIT INFO
# Provides:          MollyLau
# Required-start:    \$local_fs \$remote_fs \$network \$syslog
# Required-Stop:     \$local_fs \$remote_fs \$network \$syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the autorunfirefox.sh daemon
# Description:       starts autorunfirefox.sh using start-stop-daemon
### END INIT INFO

ffproc_name="/usr/lib/firefox/firefox" # 定义 firefox 进程名称

ffproc_num(){ # 检查进程数量
        ffPID_Num=\`ps -ef | grep \$ffproc_name | grep -v grep | wc -l\`
        return \$ffPID_Num
}

ffproc_num # 执行检查进程数

ffPID_Num=\$? # 获取进程数量

if [ \$ffPID_Num -eq 0 ]; then     
        export DISPLAY=localhost:1
        firefox --profile ~/.alexa/alexa --new-tab '${alexaurl}' &
fi
EOF

# 开启 VNC 服务器连接

tightvncserver :1

# 设置时区，用于安排服务器在凌晨每天重启一次

zonefiledir=/usr/share/zoneinfo/
zoneconfdir=/etc/localtime

Shanghai=$zonefiledir"Asia/Shanghai"
Tokyo=$zonefiledir"Asia/Tokyo"
Kolkata=$zonefiledir"Asia/Kolkata"
Sydney=$zonefiledir"Australia/Sydney"
LosAngeles=$zonefiledir"America/Los_Angeles"
NewYork=$zonefiledir"America/New_York"
Chicago=$zonefiledir"America/Chicago"
Phoenix=$zonefiledir"America/Phoenix"
London=$zonefiledir"Europe/London"
Rome=$zonefiledir"Europe/Rome"
Moscow=$zonefiledir"Europe/Moscow"

tzconfig=(
	$Shanghai
	$Tokyo
	$Kolkata
	$Sydney
	$LosAngeles
	$NewYork
	$Chicago
	$Phoenix
	$London
	$Rome
	$Moscow
)

timezone=(
	Shanghai
	Tokyo
	Kolkata
	Sydney
	LosAngeles
	NewYork
	Chicago
	Phoenix
	London
	Rome
	Moscow
)

echo -e "Please select your timezone:"
for ((i=1;i<=${#tzconfig[@]};i++ )); do
        hint="${timezone[$i-1]}"
        echo -e "${i} ${hint}"
done

read -p "Which timezone you want to select(Default: Shanghai):" pick
[ -z "$pick" ] && pick=1
expr ${pick} + 1 &>/dev/null
if [ $? -ne 0 ]; then
    echo -e "Input error, please input a number"
    continue
fi
if [[ "$pick" -lt 1 || "$pick" -gt ${#tzconfig[@]} ]]; then
    echo -e "Input error, please input a number between 1 and ${#timezone[@]}"
    continue
fi

systemtimezone=${tzconfig[$pick-1]}

selecttimezone=${timezone[$pick-1]}

echo "timezone = ${selecttimezone}"

ln -sf $systemtimezone $zoneconfdir

# swap优化

fallocate -l 1.5G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# 判断计划任务是否开启，避免多次运行添加多条

	if grep -Eqi "runalexamaster" /etc/crontab; then
	echo "Scheduled task has been opened"
else
	echo '*/2 * * * * root bash /root/runalexamaster.sh >/dev/null 2>&1' >> /etc/crontab
	echo '47 3 * * * root /sbin/reboot >/dev/null 2>&1' >> /etc/crontab
	fi

else
echo "Your system doesn't support alexaMaster fast start!(Can only run with Ubuntu 16.04)"
fi
