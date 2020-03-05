#!/bin/bash

echo "输入版本"
read version

name="itc-cli"

if [ "$version" == "" ];then
    echo "请输入版本！！！"
    exit 1
fi

swift build -c release --disable-sandbox

cp .build/release/${name} $name

tar zcvf $name-${version}.tar.gz $name

rm $name