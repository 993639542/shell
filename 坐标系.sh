#! /bin/bash



echo "前景色:"
for i in $(seq 0 7)
do
    #$[30+i] ==》 30 31.。。37
    echo -en "\033[$[30+i]m${i}\033[0m"
done
echo


echo "背景色:"
for i in $(seq 0 7)
do
    echo -en "\033[$[40+i]m${i}\033[0m"
done
echo

echo  -e "\033[34;47mhello king\033[0m"


echo '坐标系控制\033[y;xH:'
for i in $(seq 0 7)
do
    echo -en "\033[$[40+i]m\033[$[10+i];40H${i}\033[0m"
done
echo

