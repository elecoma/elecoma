#!/bin/sh

RAILS_ROOT=$(dirname $0)/..
PIDFILE=$RAILS_ROOT/var/run/mail.pid
TARGET=$RAILS_ROOT/script/mail

alive=0

# pid ファイルがあり、そこに書かれたプロセスが存在すれば生きている
if [ -e $PIDFILE ]
then
    pid=$(cat $PIDFILE)
    if [ -e /proc/$pid ]
    then
        alive=1
    fi
fi
# 生きていなければ起動
if [ $alive = 0 ]
then
    $TARGET $* &
fi
