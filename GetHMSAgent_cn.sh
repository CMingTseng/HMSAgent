#!/bin/bash

echo "Hello world"
echo      "**************************************************************************************************************"
echo      "*                                                                                                            *"
echo      "*    此工具作用为：从全量的 HMSAgent 代码，根据您的选择删除不需要的代码                                      *"
echo      "*    目前全量代码包括  游戏、支付、华为帐号、社交、Push                                                      *"
echo      "*                                                                                                            *"
echo      "*    1、如果由于pc环境问题导致脚本执行不成功，请用文本打开脚本，按脚本注释手动删除相关代码                   *"
echo      "*                                                                                                            *"
echo      "*    2、请确保本脚本所在路径不包含空格                                                                       *"
echo      "*                                                                                                            *"
echo      "*    3、接入游戏时必须接入支付                                                                               *"
echo      "*                                                                                                            *"
echo      "**************************************************************************************************************"

function recursive_copy_file()
{
   dirlist=$(ls "$1")
   for name in ${dirlist[*]}
   do
       if [ -f "$1/$name" ]; then
           # 如果是文件，并且$2不存在该文件，则直接copy
            if [ ! -f "$2/$name" ]; then
                cp "$1/$name" "$2/$name"
            fi
        elif [ -d "$1/$name" ]; then
            # 如果是目录，并且$2不存在该目录，则先创建目录
            if [ ! -d "$2/$name" ]; then
                mkdir -p "$2/$name"
            fi
            # 递归拷贝
            recursive_copy_file "$1/$name" "$2/$name"
        fi
    done
}

# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME

Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
    fi
else
    JAVACMD="java"
    which java >/dev/null 2>&1 || die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
Please set the JAVA_HOME variable in your environment to match the
location of your Java installation."
fi

echo ${JAVACMD} 


CURPATH="$( cd "$( dirname "$0"  )" && pwd)/"
echo "${CURPATH}hmsagents/src/main/java/"

MANIFEST_CONFIG_NAME="AppManifestConfig.xml"
echo "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"

rm -rf  "${CURPATH}copysrc"
mkdir "${CURPATH}copysrc/"
mkdir "${CURPATH}copysrc/java/" 
recursive_copy_file "${CURPATH}hmsagents/src/main/java/"  "${CURPATH}copysrc/java/" 
cp "${CURPATH}config/${MANIFEST_CONFIG_NAME}"  "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"

echo ""
echo "请输入应用的包名:"
read PACKAGE_NAME
if  [ "$PACKAGE_NAME" != "" ] ; then
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m replace  -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "\${PACKAGE_NAME}"  "${PACKAGE_NAME}"
fi
echo ""
echo "请输入appid，来源于开发者联盟（http://developer.huawei.com/consumer/cn）上申请应用分配的appid:"
read APPID
if  [ "$APPID" != "" ] ; then
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m replace  -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "\${APPID}"  "${APPID}"
fi
echo ""
echo "请输入cpid，来源于开发者联盟（http://developer.huawei.com/consumer/cn）上申请应用分配的cpid 或 支付id:"
read CPID
if  [ "$CPID" != "" ] ; then
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m replace    -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "\${CPID}"  "${CPID}"
fi


"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine   -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "MyApplication"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine   -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "drawable/ic_launcher"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "GameActivity"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "PayActivity"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "HwIDActivity"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "SnsActivity"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock   -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "PushActivity"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m replace  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "package=\"com.huawei.hmsagent\""  ""
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m replace   -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "android:name=\"com.huawei.hmsagent.HuaweiPushRevicer\""  "android:name=\"\${请将此处双引号内的内容替换成您创建的Receiver类}\""

NEEDGAME="";
NEEDPAY="";
NEEDHWID="";
NEEDSNS="";
NEEDPUSH="";

echo ""
if [ "$NEEDGAME" == "" ] ; then
echo "您的应用是否是 “游戏” （1表示是， 0表示否）："
read NEEDGAME
fi
# 不需要集成游戏则：
if  [ "$NEEDGAME" == "0" ] ; then
# 删除com/huawei/android/hms/agent/game 文件夹及内容
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar"  -m delFile -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/game"

# 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 .game. 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".game."

# 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 HuaweiGame.GAME_API 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiGame.GAME_API"

# 删除com/huawei/android/hms/agent/HMSAgent.java中名称为 Game 的类
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delBlock -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Game"

# 删除com/huawei/android/hms/agent/HMSAgent.java中包含 .game. 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/HMSAgent.java" ".game."

else
	NEEDPAY="1";
	NEEDHWID="0";
fi


if [ "$NEEDPAY" == "" ] ; then
echo "您是否需要集成 “支付” （1表示需要， 0表示不需要）："
read NEEDPAY
fi
# 不需要集成支付则：
if  [ "$NEEDPAY" == "0" ] ; then
# 删除com/huawei/android/hms/agent/pay 文件夹及内容
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar"  -m delFile -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/pay"

# 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 .pay. 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".pay."

# 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 HuaweiPay.PAY_API 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiPay.PAY_API"

# 删除com/huawei/android/hms/agent/HMSAgent.java中名称为 Pay 的类
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delBlock -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Pay"

# 删除com/huawei/android/hms/agent/HMSAgent.java中包含 .pay. 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".pay."

# 只有集成游戏或支付才有cpid
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "cpid"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "pay"
fi


if [ "$NEEDHWID" == "" ] ; then
echo "您是否需要集成 “华为帐号” （1表示需要， 0表示不需要）："
read NEEDHWID
fi
# 不需要集成华为帐号则：
if  [ "$NEEDHWID" == "0" ] ; then
# 删除com/huawei/android/hms/agent/hwid 文件夹及内容
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar"  -m delFile -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/hwid"

# 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 .hwid. 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".hwid."

# 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 HuaweiId 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiId"

# 删除com/huawei/android/hms/agent/HMSAgent.java中名称为 Hwid 的类
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delBlock -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Hwid"

# 删除com/huawei/android/hms/agent/HMSAgent.java中包含 .hwid. 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".hwid."

# 删除manifest文件华为帐号配置
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "account"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "HMSSignInAgentActivity"
fi


if [ "$NEEDSNS" == "" ] ; then
echo "您是否需要集成 “社交” （1表示需要， 0表示不需要）："
read NEEDSNS
fi
# 不需要集成社交则：
if  [ "$NEEDSNS" == "0" ] ; then
# 删除com/huawei/android/hms/agent/sns 文件夹及内容
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar"  -m delFile -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/sns"

# 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 .sns. 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".sns."

# 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 HuaweiSns.API 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiSns.API"

# 删除com/huawei/android/hms/agent/HMSAgent.java中名称为 Sns 的类
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delBlock -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Sns"

# 删除com/huawei/android/hms/agent/HMSAgent.java中包含 .sns. 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".sns."
fi


if [ "$NEEDPUSH" == "" ] ; then
echo "您是否需要集成 “Push” （1表示需要， 0表示不需要）："
read NEEDPUSH
fi
# 不需要集成Push则：
if  [ "$NEEDPUSH" == "0" ] ; then
# 删除com/huawei/android/hms/agent/push 文件夹及内容
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar"  -m delFile -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/push"

# 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 .push. 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  ".push."

# 删除com/huawei/android/hms/agent/common/ApiClientMgr.java中包含 HuaweiPush.PUSH_API 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/common/ApiClientMgr.java"  "HuaweiPush.PUSH_API"

# 删除com/huawei/android/hms/agent/HMSAgent.java中名称为 Push 的类
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delBlock -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  "class Push"

# 删除com/huawei/android/hms/agent/HMSAgent.java中包含 .push. 的行
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delLine -codeformat utf-8 -linechar rn  "${CURPATH}copysrc/java/com/huawei/android/hms/agent/HMSAgent.java"  ".push."

# 删除manifest文件push配置
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "PUSH"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "push"
"$JAVACMD"  -jar "${CURPATH}tool/tools.jar" -m delXmlBlock  -codeformat utf-8 -linechar rn   "${CURPATH}copysrc/${MANIFEST_CONFIG_NAME}"  "Push"
fi

echo  " "
echo " "
echo "脚本同级目录下的 copysrc 里面即为抽取后的代码，可将里面的代码拷贝的您的工程代码中"
echo "按回车键结束"
read
