#!/bin/bash

SET=$1

if [ "$SET" = "set" ]; then
    networksetup -setwebproxy Wi-Fi $2 $3
    networksetup -setwebproxy Ethernet $2 $3
    networksetup -setsecurewebproxy Wi-Fi $2 $3
    networksetup -setsecurewebproxy Ethernet $2 $3
elif [ "$SET" = "unset" ]; then
    networksetup -setwebproxystate Wi-Fi off
    networksetup -setwebproxystate Ethernet off
    networksetup -setsecurewebproxystate Wi-Fi off
    networksetup -setsecurewebproxystate Ethernet off
fi
