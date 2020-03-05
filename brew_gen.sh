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

if [ -d release ];then
    echo 'exists'
else
    mkdir release
fi

mv $name-$version.tar.gz release/$name-$version.tar.gz

git add .
git commit -m "new version: ${version}"
git push