---
layout: post
title: C++ 组件之 Glog
tags: [c++, glog]
categories: [c++ arsenal]
---

`Glog`是google开源的用于应用程序日志的项目，它提供了类似C++流风格的日志API，以及各种辅助的宏，支持自定义日志级别，条件日志，DEBUG日志等，使用非常灵活，另外也支持`Gflags`类型的日志参数配置文件。

<!-- more -->
* TOC
{:toc}

## Glog日志宏总览

`Glog`的内容比较多，我们在使用的时候，都是使用一些宏来进行日志的输出:

- `LOG`系列宏，内置日志级别的日志处理
- `VLOG`系列宏，自定义日志级别的日志处理
- `CHECK`系列宏，按条件终止程序
- `SYSLOG`系列宏，syslog系统日志处理
- `PLOG`、`PCHECK`系列宏，perror风格日志，设置errno状态并输出到日志中
- `RAW_LOG`、`RAW_VLOG`、`RAW_CHECK`线程安全的低级日志处理
- `*_IF`、`*_EVERY_N`、`*_IF_EVERY_N`等条件日志宏，按照条件记录日志
- `DLOG`、`DVLOG`、`DCHECK`、`RAW_DLOG`、`RAW_DCHECK`对应的debug模式的系列宏


## Glog内置日志级别

`Glog`有4种内置日志级别，INFO, WARNING, ERROR, FATAL 数值越大级别越高(severity):
```c++
// The recommended semantics of the log levels are as follows:
//
// INFO:
//   Use for state changes or other major events, or to aid debugging.
// WARNING:
//   Use for undesired but relatively expected events, which may indicate a
//   problem
// ERROR:
//   Use for undesired and unexpected events that the program can recover from.
//   All ERRORs should be actionable - it should be appropriate to file a bug
//   whenever an ERROR occurs in production.
// FATAL:
//   Use for undesired and unexpected events that the program cannot recover
//   from. 

// DFATAL is FATAL in debug mode, ERROR in normal mode
#ifdef NDEBUG
#define DFATAL_LEVEL ERROR
#else
#define DFATAL_LEVEL FATAL
#endif
```

## LOG系列日志宏

**代码实例**

```c++
#include <iostream>
#include "glog/logging.h"

int main(int argc, char* argv[]) {
    std::cout << "Hello Glog!" << std::endl;

    FLAGS_log_dir = "logs";
    google::InitGoogleLogging(argv[0]);

    std::string str;
    LOG_TO_STRING(ERROR, &str) << "LOG_TO_STRING(INFO, &str)";
    std::cout << str << std::endl;

    LOG(INFO) << "log_info";
    LOG(WARNING) << "log_warning";
    LOG(ERROR) << "log_error";
    LOG(FATAL) << "log_fatal";

    return 0;
}
```
```shell
$ ./tglog
Hello Glog!
E20210914 19:51:10.599162 282009088 main.cpp:11] LOG_TO_STRING(INFO, &str)
LOG_TO_STRING(INFO, &str)
E20210914 19:51:10.601150 282009088 main.cpp:16] log_error
F20210914 19:51:10.601172 282009088 main.cpp:17] log_fatal
*** Check failure stack trace: ***
    @        0x10bcf0aef  google::LogMessageFatal::~LogMessageFatal()
    @        0x10bced539  google::LogMessageFatal::~LogMessageFatal()
    @        0x10bcd1e51  main
    @     0x7fff203ddf3d  start
    @                0x1  (unknown)
[1]    67144 abort      ./tglog

$ ls -g ./logs
total 64
lrwxr-xr-x  1 staff   52  9 14 19:51 tglog.ERROR -> tglog.devmac.jtcheng.log.ERROR.20210914-195110.67144
lrwxr-xr-x  1 staff   52  9 14 19:51 tglog.FATAL -> tglog.devmac.jtcheng.log.FATAL.20210914-195110.67144
lrwxr-xr-x  1 staff   51  9 14 19:51 tglog.INFO -> tglog.devmac.jtcheng.log.INFO.20210914-195110.67144
lrwxr-xr-x  1 staff   54  9 14 19:51 tglog.WARNING -> tglog.devmac.jtcheng.log.WARNING.20210914-195110.67144
-rw-r--r--  1 staff  369  9 14 19:50 tglog.devmac.jtcheng.log.ERROR.20210914-195027.67091
-rw-r--r--  1 staff  369  9 14 19:51 tglog.devmac.jtcheng.log.ERROR.20210914-195110.67144
-rw-r--r--  1 staff  235  9 14 19:50 tglog.devmac.jtcheng.log.FATAL.20210914-195027.67091
-rw-r--r--  1 staff  235  9 14 19:51 tglog.devmac.jtcheng.log.FATAL.20210914-195110.67144
-rw-r--r--  1 staff  488  9 14 19:50 tglog.devmac.jtcheng.log.INFO.20210914-195027.67091
-rw-r--r--  1 staff  488  9 14 19:51 tglog.devmac.jtcheng.log.INFO.20210914-195110.67144
-rw-r--r--  1 staff  430  9 14 19:50 tglog.devmac.jtcheng.log.WARNING.20210914-195027.67091
-rw-r--r--  1 staff  430  9 14 19:51 tglog.devmac.jtcheng.log.WARNING.20210914-195110.67144

$ cat ./logs/tglog.INFO
Log file created at: 2021/09/14 19:51:10
Running on machine: devmac
Running duration (h:mm:ss): 0:00:00
Log line format: [IWEF]yyyymmdd hh:mm:ss.uuuuuu threadid file:line] msg
E20210914 19:51:10.599162 282009088 main.cpp:11] LOG_TO_STRING(INFO, &str)
I20210914 19:51:10.601125 282009088 main.cpp:14] log_info
W20210914 19:51:10.601132 282009088 main.cpp:15] log_warning
E20210914 19:51:10.601150 282009088 main.cpp:16] log_error
F20210914 19:51:10.601172 282009088 main.cpp:17] log_fatal

$ cat ./logs/tglog.FATAL
Log file created at: 2021/09/14 19:51:10
Running on machine: devmac
Running duration (h:mm:ss): 0:00:00
Log line format: [IWEF]yyyymmdd hh:mm:ss.uuuuuu threadid file:line] msg
F20210914 19:51:10.601172 282009088 main.cpp:17] log_fatal
```
分析运行结果:
- FATAL级别的日志，会在该日志记录之后退出程序，并打印调用栈
- 默认情况下`stderrthreshold=2`会拷贝ERROR与FATAL级别的日志到stderr
- 默认日志文件格式: 
  - 文件权限0644
  - 创建对应的符号链接来跟踪最新的日志文件(当前使用的日志文件)
  - 文件名: `<appName>.<hostName><userName>.log.<severityLevel>.<date>-<time>.<pid>`
- 日志文件头包含一些非日志信息
- 高级别的日志会复制到所有相对低级别的日志文件中

## VLOG系列日志宏

**代码实例**

```c++
// tglog_test_m1.cpp
#include <iostream>
#include "glog/logging.h"

void tglog_test_m1(void) {
    std::cout << std::boolalpha << "tglog_test_m1: VLOG_IS_ON(1): " << VLOG_IS_ON(1) << std::endl;
    std::cout << std::boolalpha << "tglog_test_m1: VLOG_IS_ON(2): " << VLOG_IS_ON(2) << std::endl;
    std::cout << std::boolalpha << "tglog_test_m1: VLOG_IS_ON(3): " << VLOG_IS_ON(3) << std::endl;
    VLOG(1) << "VLOG(1): I'm printed when FLAGS_v >= 1 and current FLAGS_v: " << FLAGS_v;
    VLOG(2) << "VLOG(2): I'm printed when FLAGS_v >= 2 and current FLAGS_v: " << FLAGS_v;
    VLOG(3) << "VLOG(3): I'm printed when FLAGS_v >= 3 and current FLAGS_v: " << FLAGS_v;
}
```
```c++
// tglog_test_m2.cpp
#include <iostream>
#include "glog/logging.h"

void tglog_test_m2(void) {
    std::cout << std::boolalpha << "tglog_test_m2: VLOG_IS_ON(1): " << VLOG_IS_ON(1) << std::endl;
    std::cout << std::boolalpha << "tglog_test_m2: VLOG_IS_ON(2): " << VLOG_IS_ON(2) << std::endl;
    std::cout << std::boolalpha << "tglog_test_m2: VLOG_IS_ON(3): " << VLOG_IS_ON(3) << std::endl;
    VLOG(1) << "VLOG(1): I'm printed when FLAGS_v >= 1 and current FLAGS_v: " << FLAGS_v;
    VLOG(2) << "VLOG(2): I'm printed when FLAGS_v >= 2 and current FLAGS_v: " << FLAGS_v;
    VLOG(3) << "VLOG(3): I'm printed when FLAGS_v >= 3 and current FLAGS_v: " << FLAGS_v;
}
```
```c++
// main.cpp
#include <iostream>
#include "glog/logging.h"

extern void tglog_test_m1(void);
extern void tglog_test_m2(void);

int main(int argc, char* argv[]) {
    std::cout << "Hello Glog!" << std::endl;

    FLAGS_logtostderr = true;
    FLAGS_v = 2;
    FLAGS_vmodule = "*_m1=1,*_?2=3";
    google::InitGoogleLogging(argv[0]);

    std::cout << std::boolalpha << "main: VLOG_IS_ON(1): " << VLOG_IS_ON(1) << std::endl;
    std::cout << std::boolalpha << "main: VLOG_IS_ON(2): " << VLOG_IS_ON(2) << std::endl;
    std::cout << std::boolalpha << "main: VLOG_IS_ON(3): " << VLOG_IS_ON(3) << std::endl;
    VLOG(1) << "VLOG(1): I'm printed when FLAGS_v >= 1 and current FLAGS_v: " << FLAGS_v;
    VLOG(2) << "VLOG(2): I'm printed when FLAGS_v >= 2 and current FLAGS_v: " << FLAGS_v;
    VLOG(3) << "VLOG(3): I'm printed when FLAGS_v >= 3 and current FLAGS_v: " << FLAGS_v;

    tglog_test_m1();

    tglog_test_m2();

    return 0;
}
```
```shell
$ ./tglog
Hello Glog!
main: VLOG_IS_ON(1): true
main: VLOG_IS_ON(2): true
main: VLOG_IS_ON(3): false
I20210914 20:27:53.671315 88657408 main.cpp:22] VLOG(1): I'm printed when FLAGS_v >= 1 and current FLAGS_v: 2
I20210914 20:27:53.671937 88657408 main.cpp:23] VLOG(2): I'm printed when FLAGS_v >= 2 and current FLAGS_v: 2
tglog_test_m1: VLOG_IS_ON(1): true
tglog_test_m1: VLOG_IS_ON(2): false
tglog_test_m1: VLOG_IS_ON(3): false
I20210914 20:27:53.671972 88657408 tglog_m1.cpp:8] VLOG(1): I'm printed when FLAGS_v >= 1 and current FLAGS_v: 2
tglog_test_m2: VLOG_IS_ON(1): true
tglog_test_m2: VLOG_IS_ON(2): true
tglog_test_m2: VLOG_IS_ON(3): true
I20210914 20:27:53.671983 88657408 tglog_m2.cpp:8] VLOG(1): I'm printed when FLAGS_v >= 1 and current FLAGS_v: 2
I20210914 20:27:53.671988 88657408 tglog_m2.cpp:9] VLOG(2): I'm printed when FLAGS_v >= 2 and current FLAGS_v: 2
I20210914 20:27:53.671990 88657408 tglog_m2.cpp:10] VLOG(3): I'm printed when FLAGS_v >= 3 and current FLAGS_v: 2
```
分析运行结果:
- VLOG系列日志宏，总是对应到内置INFO级别的日志
- 自定义的日志级别，VLOG数值越低，级别越高，对应的行为与内置的日志级别的规则相反
- VLOG_IS_ON可以用来判断日志在某个级别是否开启
- vmodule支持简单的通配符来控制各个模块的日志级别
- VLOG系列日志宏，主要用于调试程序，非常灵活

## CHECK系列日志宏

CHECK系列的宏跟标准库里的assert很像，都是检测某个表达式是否为真，为假会退出程序，但是不受NDEBUG的影响。
- 一般的check: `CHECK`,`CHECK_EQ`,`CHECK_NE`,`CHECK_LE`,`CHECK_LT`,`CHECK_GE`,`CHECK_GT`
- 指针非空check: `CHECK_NOTNULL`
- C字符串check: `CHECK_STREQ`,`CHECK_STRNE`,`CHECK_STRCASEEQ`,`CHECK_STRCASENE`
- 数组下标check: `CHECK_INDEX`,`CHECK_BOUND`
- 浮点数check: `CHECK_DOUBLE_EQ`,`CHECK_NEAR`
- 函数返回值(-1)check: `CHECK_ERR`

**代码实例**

```c++
#include <iostream>
#include "glog/logging.h"

int main(int argc, char* argv[]) {
    std::cout << "Hello Glog!" << std::endl;

    FLAGS_logtostderr = true;
    google::InitGoogleLogging(argv[0]);

    CHECK(1 == 42) << "CHECK(1 == 42)";

    return 0;
}
```
```shell
$ ./tglog
Hello Glog!
F20210914 13:20:34.182176 376765952 main.cpp:10] Check failed: 1 == 42 CHECK(1 == 42)
*** Check failure stack trace: ***
    @        0x106f59bdf  google::LogMessageFatal::~LogMessageFatal()
    @        0x106f56629  google::LogMessageFatal::~LogMessageFatal()
    @        0x106f3b266  main
    @     0x7fff203ddf3d  start
    @                0x1  (unknown)
[1]    39986 abort      ./tglog
```

## SYSLOG系列日志宏

可以用来与系统的syslog集成，注意输出日志到syslog会大幅影响性能，尤其是当syslog配置为远程日志输出，在使用之前一定要确定影响，一般来说很少使用。

## perror风格系列日志宏

**代码实例**

```c++
#include <iostream>
#include "glog/logging.h"

int main(int argc, char* argv[]) {
    std::cout << "Hello Glog!" << std::endl;

    FLAGS_logtostderr = true;
    google::InitGoogleLogging(argv[0]);

    LOG(INFO)<< "LOG(INFO)";
    PLOG(INFO)<< "PLOG(INFO)";
    PCHECK(write(1, NULL, 2) >= 0) << "Write NULL failed";

    return 0;
}
```
```shell
$ ./tglog
Hello Glog!
I20210914 14:50:34.725471 417725952 main.cpp:10] LOG(INFO)
I20210914 14:50:34.726279 417725952 main.cpp:11] PLOG(INFO): No such process [3]
F20210914 14:50:34.726297 417725952 main.cpp:12] Check failed: write(1, NULL, 2) >= 0 Write NULL failed: Bad address [14]
*** Check failure stack trace: ***
    @        0x10ce883f3  google::LogMessage::~LogMessage()
    @        0x10ce89709  google::ErrnoLogMessage::~ErrnoLogMessage()
    @        0x10ce6e1c9  main
    @     0x7fff203ddf3d  start
    @                0x1  (unknown)
[1]    47796 abort      ./tglog
```

## Glog低级日志接口宏

可用于要求线程安全的日志，它不分配任何内存，也不加锁，只能输出到stderr，一般用在其他日志宏不能使用的情况下。

```c++
#include <iostream>
#include "glog/logging.h"
#include "glog/raw_logging.h"

int main(int argc, char* argv[]) {
    std::cout << "Hello Glog!" << std::endl;

    FLAGS_logtostderr = true;
    google::InitGoogleLogging(argv[0]);

    RAW_LOG(INFO,"RAW_LOG(INFO): %d", 42);
    RAW_VLOG(0,"RAW_LOG(INFO): %d", 42);
    RAW_CHECK(42 < 24, "RAW_CHECK(42 < 24, message)");

    return 0;
}
```
```shell
$ ./tglog
Hello Glog!
I00000000 00:00:00.000000 279748096 main.cpp:11] RAW: RAW_LOG(INFO): 42
I00000000 00:00:00.000000 279748096 main.cpp:12] RAW: RAW_LOG(INFO): 42
F00000000 00:00:00.000000 279748096 main.cpp:13] RAW: Check 42 < 24 failed: RAW_CHECK(42 < 24, message)
    @        0x10d3d7258  main
    @     0x7fff203ddf3d  start
    @                0x1  (unknown)
[1]    65928 abort      ./tglog
```

## Glog条件日志宏

**LOG系列条件日志宏**
- `LOG_IF(severity, condition)`
- `LOG_EVERY_N(severity, n)`
- `LOG_FIRST_N(severity, n)`
- `LOG_IF_EVERY_N(severity, condition, n)`
- `LOG_ASSERT(condition)`等价于`LOG_IF(FATAL, !(condition))`

注意`google::COUNTER`只能用在`xxxx_N`的宏里面，用在别的地方没有意义。

```c++
#include <iostream>
#include "glog/logging.h"

int main(int argc, char* argv[]) {
    std::cout << "Hello Glog!" << std::endl;

    FLAGS_logtostderr = true;
    google::InitGoogleLogging(argv[0]);

    for (int i = 0; i < 6; ++i) {
        LOG_IF(INFO, i > 3) << "LOG_IF(INFO, i > 3)  i: " << i << " COUNTER: " << google::COUNTER;;
    }

    std::cout << std::endl;
    for (int i = 0; i < 6; ++i) {
        LOG_FIRST_N(INFO, 2) << "LOG_FIRST_N(INFO, 2) i: " << i << " COUNTER: " << google::COUNTER;
    }

    std::cout << std::endl;
    for (int i = 0; i < 6; ++i) {
        LOG_EVERY_N(INFO, 3) << "LOG_EVERY_N(INFO, 3) i: " << i << " COUNTER: " << google::COUNTER;
    }

    std::cout << std::endl;
    for (int i = 0; i < 6; ++i) {
        LOG_IF_EVERY_N(INFO, (i >= 3), 2) << "LOG_IF_EVERY_N(INFO, (i >= 3), 2) i: " << i << " COUNTER: " << google::COUNTER;
    }

    return 0;
}
```
```shell
$ ./tglog
Hello Glog!
I20210913 17:00:19.371788 288361984 main.cpp:11] LOG_IF(INFO, i > 3)  i: 4 COUNTER: 0
I20210913 17:00:19.372444 288361984 main.cpp:11] LOG_IF(INFO, i > 3)  i: 5 COUNTER: 0

I20210913 17:00:19.372457 288361984 main.cpp:16] LOG_FIRST_N(INFO, 2) i: 0 COUNTER: 1
I20210913 17:00:19.372463 288361984 main.cpp:16] LOG_FIRST_N(INFO, 2) i: 1 COUNTER: 2

I20210913 17:00:19.372469 288361984 main.cpp:21] LOG_EVERY_N(INFO, 3) i: 0 COUNTER: 1
I20210913 17:00:19.372474 288361984 main.cpp:21] LOG_EVERY_N(INFO, 3) i: 3 COUNTER: 4

I20210913 17:00:19.372480 288361984 main.cpp:26] LOG_IF_EVERY_N(INFO, (i >= 3), 2) i: 3 COUNTER: 4
I20210913 17:00:19.372486 288361984 main.cpp:26] LOG_IF_EVERY_N(INFO, (i >= 3), 2) i: 5 COUNTER: 6
```

条件日志宏的使用方式都是一样的，下面列出其他的条件日志宏(可以看到宏的组织也不好很好，不是完整的):

**VLOG系列条件日志宏**
- `VLOG_IF(verboselevel, condition)`
- `VLOG_EVERY_N(verboselevel, n)`
- `VLOG_IF_EVERY_N(verboselevel, condition, n)`

**SYSLOG系列条件日志宏**
- `SYSLOG_IF(severity, condition)`
- `SYSLOG_EVERY_N(severity, n)`
- `SYSLOG_ASSERT(condition)`

**PLOG系列条件日志宏**
- `PLOG_IF(severity, condition)`
- `PLOG_EVERY_N(severity, n)`

## Debug系列日志宏

Debug系列日志宏的使用方式与正常的日志使用方式是一样的，但是会受到NDEBUG的影响，下面列出Debug系列日志宏:

**LOG系列Debug日志宏**
- `DLOG(severity)`
- `DLOG_IF(severity, condition)`
- `DLOG_EVERY_N(severity, n)`
- `DLOG_IF_EVERY_N(severity, condition, n)`
- `DLOG_ASSERT(condition)`

**VLOG系列Debug日志宏**
- `DVLOG(verboselevel)`

**CHECK系列Debug日志宏**
- `DCHECK`,`DCHECK_EQ`,`DCHECK_NE`,`DCHECK_LE`,`DCHECK_LT`,`DCHECK_GE`,`DCHECK_GT`
- `DCHECK_NOTNULL`
- `DCHECK_STREQ`,`DCHECK_STRNE`,`DCHECK_STRCASEEQ`,`DCHECK_STRCASENE`

**RAW_LOG系列Debug日志宏**
- `RAW_DLOG(severity, ...)`
- `RAW_DCHECK(condition, message)`

## 日志选项配置

`Glog`往往与`Gflags`一起使用，我们可以使用flag来配置日志选项，常用的选项如下 (./app --help 可以列出所有的选项):

```shell
--logtostderr (bool, default=false)               // 只是记录日志到stderr
--alsologtostderr (bool, default=false)           // 总是同时记录日志到stderr
--colorlogtostderr (bool default=false)           // stderr日志色彩，不是所有的日志宏都支持
--stderrthreshold (int, default=2)                // 需要拷贝到stderr的日志级别阈值
--minloglevel (int, default=0)                    // 最小日志级别，控制日志输出
--log_dir (string, default="")                    // 指定日志文件目录
--v (int, default=0)                              // 自定义日志级别
--vmodule (string, default="")                    // 自定义日志模块日志级别
--max_log_size (int32. default=1800)              // 超过大小(1800M)，会产生新的日志文件
--log_backtrace_at (string, default="")           // 在本行日志处，附加打印调用栈
--logbuflevel (int32 default=0)                   // 指定需要日志缓冲的日志级别
--logbufsecs (int32 default=30)                   // 指定日志缓冲时间
--stop_logging_if_full_disk (bool, default=false) // 磁盘空间不足，停止记录日志
```

**代码实例**

```c++
#include <iostream>
#include "glog/logging.h"

extern void tglog_test_m1(void);
extern void tglog_test_m2(void);

int main(int argc, char* argv[]) {
    std::cout << "Hello Glog!" << std::endl;

    gflags::SetUsageMessage("./tglog");
    gflags::SetVersionString("v0.0.1");
    gflags::ParseCommandLineFlags(&argc, &argv, true);

    google::InitGoogleLogging(argv[0]);

    std::cout << std::boolalpha << "main: VLOG_IS_ON(1): " << VLOG_IS_ON(1) << std::endl;
    std::cout << std::boolalpha << "main: VLOG_IS_ON(2): " << VLOG_IS_ON(2) << std::endl;
    std::cout << std::boolalpha << "main: VLOG_IS_ON(3): " << VLOG_IS_ON(3) << std::endl;
    VLOG(1) << "VLOG(1): I'm printed when FLAGS_v >= 1 and current FLAGS_v: " << FLAGS_v;
    VLOG(2) << "VLOG(2): I'm printed when FLAGS_v >= 2 and current FLAGS_v: " << FLAGS_v;
    VLOG(3) << "VLOG(3): I'm printed when FLAGS_v >= 3 and current FLAGS_v: " << FLAGS_v;

    tglog_test_m1();

    tglog_test_m2();

    return 0;
}
```
```shell
$ cat t.conf
--logtostderr=true
--v=2
--vmodule=*_m1=1,*_?2=3
--log_backtrace_at=tglog_m2.cpp:9

$ ./tglog --flagfile=t.conf
Hello Glog!
main: VLOG_IS_ON(1): true
main: VLOG_IS_ON(2): true
main: VLOG_IS_ON(3): false
I20210914 20:33:03.490805 393313792 main.cpp:19] VLOG(1): I'm printed when FLAGS_v >= 1 and current FLAGS_v: 2
I20210914 20:33:03.491422 393313792 main.cpp:20] VLOG(2): I'm printed when FLAGS_v >= 2 and current FLAGS_v: 2
tglog_test_m1: VLOG_IS_ON(1): true
tglog_test_m1: VLOG_IS_ON(2): false
tglog_test_m1: VLOG_IS_ON(3): false
I20210914 20:33:03.491441 393313792 tglog_m1.cpp:8] VLOG(1): I'm printed when FLAGS_v >= 1 and current FLAGS_v: 2
tglog_test_m2: VLOG_IS_ON(1): true
tglog_test_m2: VLOG_IS_ON(2): true
tglog_test_m2: VLOG_IS_ON(3): true
I20210914 20:33:03.491454 393313792 tglog_m2.cpp:8] VLOG(1): I'm printed when FLAGS_v >= 1 and current FLAGS_v: 2
I20210914 20:33:03.491459 393313792 tglog_m2.cpp:9]  (stacktrace:
    @        0x10e03e00d  main
    @     0x7fff203ddf3d  start
    @                0x2  (unknown)
) VLOG(2): I'm printed when FLAGS_v >= 2 and current FLAGS_v: 2
I20210914 20:33:03.491513 393313792 tglog_m2.cpp:10] VLOG(3): I'm printed when FLAGS_v >= 3 and current FLAGS_v: 2
```

## 其他

`Glog`的内容比较多，使用的时候可以参考官方文档:
- [Glog github][1]

### 编译时删除日志信息

```c++
#define GOOGLE_STRIP_LOG 1 // 低于级别1(VLOG日志的级别总是0)的日志将在编译时删除
#include <glog/logging.h>
```

### 崩溃日志处理器

```c++
google::InstallFailureSignalHandler()
```
**代码实例**

```c++
#include <iostream>
#define GOOGLE_STRIP_LOG 1
#include "glog/logging.h"

static void tglog_test(void) {
    int* pi = nullptr;
    *pi = 42;
}

int main(int argc, char* argv[]) {
    std::cout << "Hello Glog!" << std::endl;

    FLAGS_logtostderr = true;
    google::InitGoogleLogging(argv[0]);
    google::InstallFailureSignalHandler();

    LOG(INFO) << "log_info";
    LOG(WARNING) << "log_warning";
    LOG(ERROR) << "log_error";

    tglog_test();

    return 0;
}
```
```shell
$ ./tglog
Hello Glog!
W20210915 09:47:52.303341 357600768 main.cpp:18] log_warning
E20210915 09:47:52.303925 357600768 main.cpp:19] log_error
*** Aborted at 1631670472 (unix time) try "date -d @1631670472" if you are using GNU date ***
PC: @                0x0 (unknown)
*** SIGSEGV (@0x0) received by PID 78890 (TID 0x115508e00) stack trace: ***
    @     0x7fff20407d7d _sigtramp
    @     0x7fff202e7e03 tzsetwall_basic
    @        0x107b3494a main
    @     0x7fff203ddf3d start
    @                0x1 (unknown)
[1]    78890 segmentation fault  ./tglog
```

分析运行结果:
- 日志级别小于1的日志消失了
- 代码崩溃的地方会打印出调用栈

### 自动删除旧日志

```c++
google::EnableLogCleaner(int overdue_days); // 开启
google::DisableLogCleaner();                // 关闭
```

[1]: https://github.com/google/glog
