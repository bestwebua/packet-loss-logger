# ICMP Packet Loss Logger

## Description
Simple terminal ICMP packet loss logger by Vladislav Trotsenko (https://github.com/bestwebua).<br>
Build with using net/ping gem (https://github.com/djberg96/net-ping).

### Requirements
```
>= Ruby 1.9.3
>= gem net-ping 2.0.2
```

#### Installation
Please note, this script should run with superadmin permissions (this is features of net/ping gem work. CentOS example without preinstalled Ruby:
- - -
##### Installing environment
```bash
yum groupinstall -y development
curl -L get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm reload
rvm install 2.1.0
ruby --version  #To check your current default interpreter, run the following:
gem install net-ping
mkdir etc/packet_loss_logger && cd $_
culr -O https://raw.githubusercontent.com/bestwebua/MyRubyFirstSteps/master/my/packet_loss_logger/pll.rb
```
- - -
##### Running ICMP Packet Loss Logger
For execution in background I have used screen. To create a screen and start working with it run this command, where 'pll' - the name of a screen. It may be any name, like screen1, test1, etc.
```bash
$ screen -S pll
```
To start the script, run pll.rb with next pattern: `[host_name] [packet_size_in_bytes] [runtime format: 1s, 1m , 1h or 1d]`
```bash
$ ruby etc/packet_loss_logger/pll.rb google.com 1000 1m
```
- - -
##### How to use the screen?
To exit screen, use the `<ctrl> + <a> & <d>` keys. All processes running in your screen are still being executed. To return to your screen or to any other screen, use:
```bash
$ screen -r
```
or list your screens:
```bash
$ screen -ls
```
and select and activate one of the screen that you need:
```bash
$ screen -r <id>
```
When you no longer need a screen session, you can kill it. To do this, login into your screen and press `<ctrl> + <d>`.
- - -
##### Reading the ICMP Packet Loss Log
```bash
$ cat etc/packet_loss_logger/log.txt
```
- - -