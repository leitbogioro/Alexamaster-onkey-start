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

ffproc_start(){
	export DISPLAY=localhost:1
	firefox --profile ~/.alexa/alexa --new-tab '${alexaurl}' &
}

ffproc_char="/usr/lib/firefox/firefox" # 定义 firefox 进程关键字

ffproc_num(){ # 检查进程数量
        ffPID_Num=\`ps -ef | grep \$ffproc_char | grep -v grep | wc -l\`
        return \$ffPID_Num
}

ffproc_num # 执行检查进程数

ffPID_Num=\$? # 获取进程数量

ffproc_idle=\`top -b -n 1 | grep firefox | awk '{print \$9}' | cut -f 1 -d "."\` # 检查 firefox 的CPU利用率

# 执行进程检查

if [ \$ffPID_Num -eq 0 ]; then # 如果 firefox 的进程数为0（崩溃），则重新启动
	ffproc_start
fi

# 如果遇到需要点击弹出窗口无后续操作，firefox进程的CPU占用为0，则将进程杀掉并重新启动

if ((\$ffproc_idle == 0 )); then
	pkill firefox
	ffproc_start
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

# 判断是否需要 swap 优化

mem_total=`free -m | grep 'Mem' | awk '{print $2}'`
swap_total=`free -m | grep 'Swap' | awk '{print $2}'`

mem_capacity(){
        if [ $mem_total -le 400 ] && [ $swap_total -le 200 ]; then
                memsize="1"
                return
        fi
        if [ $mem_total -ge 490 ] && [ $mem_total -le 900 ] && [ $swap_total -le 300 ]; then
                memsize="1.5"
                return
        fi
        if [ $mem_total -ge 900 ] && [ $mem_total -le 1850 ] && [ $swap_total -le 500 ]; then
                memsize="2"
                return
        fi
        if [ $mem_total -ge 1850 ] && [ $mem_total -le 3800 ] && [ $swap_total -le 900 ]; then
                memsize="4"
                return
        fi
        if [ $mem_total -ge 3800 ] && [ $swap_total -le 1500 ]; then
                memsize="6"
                return
        fi
}
mem_capacity

mem_opimize(){
		if grep -Eqi "/swapfile none swap sw 0 0" /etc/fstab || [ ! -n "$memsize" ]; then
				echo "Memory has been optimized(code: u)"
		else
				getmemsize="$memsize""G"
				fallocate -l $getmemsize /swapfile
				chmod 600 /swapfile
				mkswap /swapfile
				swapon /swapfile
				echo '/swapfile none swap sw 0 0' >> /etc/fstab
				echo "Memory has been optimized(code: w)"
		fi
}
mem_opimize

# 判断计划任务是否开启，避免多次运行添加多条

if grep -Eqi "runalexamaster" /etc/crontab; then
	echo "Scheduled task has been opened"
else
	echo '*/2 * * * * root bash /root/runalexamaster.sh >/dev/null 2>&1' >> /etc/crontab
	echo '47 3 * * * root /sbin/reboot >/dev/null 2>&1' >> /etc/crontab
fi

# 设置vnc密码

read -n1 -p  "Would you like to set a new VNC passwd(y/n)?" ans
if [[ ${ans} =~ [yY] ]]; then
        echo -e "\n"
        vncpasswd
fi
echo -e "\n"

else
echo "Your system doesn't support alexaMaster fast start!(Can only run with Ubuntu 16.04)"
fi
