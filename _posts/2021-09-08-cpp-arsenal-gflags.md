---
layout: post
title: C++ 组件之 Gflags
tags: [C++, gflags]
categories: [C++ arsenal]
---

`Gflags`是google开源的用于处理命令行参数的项目，相对`getopt`，更强大，更易使用，而且`Gflags`的参数可以按需分散就近定义到多个源文件中，不用集中在main函数文件中，使用非常灵活，另外`Gflags`也能很好的支持参数配置文件。

<!-- more -->
* TOC
{:toc}

## 命令行flags

一般来说，命令行flags可以分为接收参数与不接收参数两类，为了方便处理以及形式上的统一，约定使用下面的格式:
- `--variable` 或者 `--novariable` 表示不接收参数的flag，表示布尔类型
  - `--variable` 等价于(不区分大小写):

    `--variable=true`,`--variable=t`,`--variable=yes`,`--variable=y`,`--variable=1`
  - `--novariable` 等价于(不区分大小写):

    `--variable=false`,`--variable=f`,`--variable=no`,`--variable=n`,`--variable=0`
- `--variable=value` 表示接收参数的flag

## 命令行flags声明与定义

`Gflags`中7个flag宏，分别对应7种C++数据类型:

**flag声明** 类似于`extern`flags变量
```c++
#define DECLARE_bool(name)
#define DECLARE_int32(name)
#define DECLARE_uint32(name)
#define DECLARE_int64(name)
#define DECLARE_uint64(name)
#define DECLARE_double(name)
#define DECLARE_string(name)
```
**flag定义**
```c++
#define DEFINE_bool(name, val, txt)
#define DEFINE_int32(name, val, txt)
#define DEFINE_uint32(name,val, txt)
#define DEFINE_int64(name, val, txt)
#define DEFINE_uint64(name,val, txt)
#define DEFINE_double(name, val, txt)
#define DEFINE_string(name, val, txt)
```

**内置flag** 不能再次定义，默认就可以直接使用
```c++
// gflags_completions.cc, 命令行自动补齐相关
DEFINE_string(tab_completion_word, "",
              "If non-empty, HandleCommandLineCompletions() will hijack the "
              "process and attempt to do bash-style command line flag "
              "completion on this value.");
DEFINE_int32(tab_completion_columns, 80,
             "Number of columns to use in output for tab completion");
```

```c++
// gflags_reporting.cc, 报告帮助信息相关
DEFINE_bool  (help,        false, "show help on all flags [tip: all flags can have two dashes]");
DEFINE_bool  (helpfull,    false, "show help on all flags -- same as -help");
DEFINE_bool  (helpshort,   false, "show help on only the main module for this program");
DEFINE_string(helpon,      "",    "show help on the modules named by this flag value");
DEFINE_string(helpmatch,   "",    "show help on modules whose name contains the specified substr");
DEFINE_bool  (helppackage, false, "show help on all modules in the main package");
DEFINE_bool  (helpxml,     false, "produce an xml version of help");
DEFINE_bool  (version,     false, "show version and build info and exit");
```

```c++
// gflags.cc
// flag参数来源相关
DEFINE_string(flagfile,   "", "load flags from file");
DEFINE_string(fromenv,    "", "set flags from the environment"
                              " [use 'export FLAGS_flag1=value']");
DEFINE_string(tryfromenv, "", "set flags from the environment if present");
// 输入未定义的flag行为
DEFINE_string(undefok,    "", "comma-separated list of flag names that it is okay to specify "
                              "on the command line even if the program does not define a flag "
                              "with that name.  IMPORTANT: flags in this list that have "
                              "arguments MUST use the flag=value format");
```

## Gflags 使用案例

`Gflags`使用起来比较简单，更多的信息可以参考官方文档:
- [Gflags github][1]
- [Gflags reference][2]

### 1. 声明flags
```c++
// tgflags.h
#pragma once

#include <gflags/gflags.h>

// Declare name and age
DECLARE_string(name);
DECLARE_uint32(age);

// Declare daemon or not
DECLARE_bool(daemon);
```

### 2. 定义，验证，使用flags
```c++
// tgflags.cpp
#include <iostream>
#include <fmt/format.h>
#include "tgflags.h"

static bool ValidateAge(const char* flagname, std::uint32_t name) {
   return (name > 0 && name < 120);
}

DEFINE_string(name, "jtcheng", "your name");

DEFINE_uint32(age, 33, "your age");
DEFINE_validator(age, &ValidateAge);

void tgflags_test(void) {
    std::cout << fmt::format("{}: your name: {} and age: {}\n", __func__, FLAGS_name, FLAGS_age);
}

// check a flag is set or not
bool tgflags_isset(const char* flagname) {
    return !gflags::GetCommandLineFlagInfoOrDie(flagname).is_default;
}
```

### 3. 定义，使用flags
```c++
// main.cpp
#include <iostream>
#include <fmt/format.h>
#include "tgflags.h"

extern void tgflags_test(void);
extern bool tgflags_isset(const char* flagname);

// name of the flag: daemon
// default value: true
// help string: app start as daemon or not
DEFINE_bool(daemon, true, "app start as daemon or not");

int main(int argc, char *argv[]) {
    std::cout << "Hello Gflags!" << std::endl;

    // usage and version
    gflags::SetUsageMessage("./tgflags");
    gflags::SetVersionString("v0.0.1");

    // parse command line flags: the last argument is called "remove_flags"
    // remove_flags = true, remove the flags
    // remove_flags = false, keeps the flags, maybe reorder the args and flags
    gflags::ParseCommandLineFlags(&argc, &argv, true);

    std::cout << std::boolalpha << FLAGS_daemon << std::endl;
    std::cout << fmt::format("{}: your name: {} and age: {}\n", __func__, FLAGS_name, FLAGS_age);

    tgflags_test();

    std::cout << std::boolalpha << tgflags_isset("name") << std::endl;
    std::cout << std::boolalpha << tgflags_isset("age") << std::endl;

    return 0;
}
```

### 4. 使用默认flags
```shell
$ ./tgflags
Hello Gflags!
true
main: your name: jtcheng and age: 33
tgflags_test: your name: jtcheng and age: 33
false
false
```

### 5. 使用命令行flags
```shell
$ ./tgflags --nodaemon --age=42
Hello Gflags!
false
main: your name: jtcheng and age: 42
tgflags_test: your name: jtcheng and age: 42
false
true

# for boolean
$  ./tgflags --daemon=false --age=42
Hello Gflags!
false
main: your name: jtcheng and age: 42
tgflags_test: your name: jtcheng and age: 42
false
true
```

### 6. 使用环境变量flags
```shell
$ echo $SHELL
/bin/zsh

$ export FLAGS_age=42
$ export FLAGS_daemon=false

$ ./tgflags --fromenv=age,daemon
Hello Gflags!
false
main: your name: jtcheng and age: 42
tgflags_test: your name: jtcheng and age: 42
false
true
```

### 7. 使用flags配置文件
```shell
$ cat t.conf
# startup as daemon or not
--nodaemon
# your age
--age=42

$ ./tgflags --flagfile=./t.conf
Hello Gflags!
false
main: your name: jtcheng and age: 42
tgflags_test: your name: jtcheng and age: 42
false
true
```

### 8. flag值的保存与恢复
```c++
#include <iostream>
#include "tgflags.h"

DEFINE_bool(daemon, true, "app start as daemon or not");

int main(int argc, char *argv[]) {
    std::cout << "Hello Gflags!" << std::endl;

    gflags::ParseCommandLineFlags(&argc, &argv, true);

    std::cout << std::boolalpha << FLAGS_daemon << std::endl;
    // change the daemon flag just in below scope
    // when FlagSaver destroyed, all the value will be restores
    {
        gflags::FlagSaver fs;
        gflags::SetCommandLineOption("daemon", "false");
        std::cout << std::boolalpha << FLAGS_daemon << std::endl;
    }
    // the damon flag value will be restores here
    std::cout << std::boolalpha << FLAGS_daemon << std::endl;

    return 0;
}
// $ ./tgflags
// Hello Gflags!
// true
// false
// true
```

### 9. Help信息
```shell
$ ./tgflags --help
Hello Gflags!
tgflags: ./tgflags
# ... 内置flags的信息，不关心
  Flags from /Users/jtcheng/work/workspaces/cpp/arsenal/src/tgflags/main.cpp:
    -daemon (app start as daemon or not) type: bool default: true

  Flags from /Users/jtcheng/work/workspaces/cpp/arsenal/src/tgflags/tgflags.cpp:
    -age (your age) type: uint32 default: 33
    -name (your name) type: string default: "jtcheng"

$ ./tgflags --version
Hello Gflags!
tgflags version v0.0.1
```

[1]: https://github.com/gflags/gflags
[2]: https://gflags.github.io/gflags
