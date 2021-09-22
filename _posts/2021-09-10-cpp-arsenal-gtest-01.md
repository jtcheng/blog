---
layout: post
title: C++ 组件之 Gtest(1)
tags: [c++, gtest]
categories: [c++ arsenal]
---

`Gtest`是google开源的一款跨平台的C++测试框架项目，它提供了一套优秀的C++单元测试解决方案，简单易用，功能完善，非常适合在项目中使用以保证代码质量，另外也支持`Gflags`类型的测试参数配置。

<!-- more -->
* TOC
{:toc}

## Gtest权威资料

Gtest的官方文档其实写得挺好的，使用的时候可以多多参考:
- [Gtest github][1]
- [Gtest reference][2]

## 测试断言

- `ASSERT_*`系列的断言，当检查点失败时，退出当前正在运行的函数(可以是一个测试用例中的辅助测试函数)
- `EXPECT_*`系列的断言，当检查点失败时，继续往下执行，写测试用例时推荐使用`EXPECT_*`系列断言
- 还有一些其他的不太常用的测试断言，比如`SUCCEED`，`FALL`等
- `EXPECT_THAT`结合`Gmock Matcher`可以实现复杂的断言

## 简单测试用例TEST

简单测试用例定义: `TEST(TestSuiteName, TestName) {}`
- `TestSuiteName`测试套件名称，必须是C++语言的有效标识符，但是不能包含`_`
- `TestName`测试用例名称，必须是C++语言的有效标识符，但是不能包含`_`
- 测试套件可以包含一组相关的测试用例，不同的测试套件可以包含同名的测试用例
- 测试断言，可以追加(`<<`)自定义的消息

**代码实例**
```c++
// tgtest_test.cpp
#include <vector>
#include <string>
#include "gtest/gtest.h"
#include "gmock/gmock.h"

TEST(String, StringEndsWith) {
  using ::testing::EndsWith;
  std::string s{"hello, gtest"};
  EXPECT_THAT(s, EndsWith("gtest"));
}

TEST(Vector, VectorEq) {
  std::vector<int> x{1,2,3,4};
  std::vector<int> y{1,2,3,4};

  ASSERT_EQ(x.size(), y.size()) << "Vectors x and y are of unequal length";

  for (int i = 0; i < x.size(); ++i) {
    EXPECT_EQ(x[i], y[i]) << "Vectors x and y differ at index " << i;
  }
}

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```

**执行结果**
```shell
$ ./tgtest
[==========] Running 2 tests from 2 test suites.
[----------] Global test environment set-up.
[----------] 1 test from String
[ RUN      ] String.StringStartwith
[       OK ] String.StringStartwith (0 ms)
[----------] 1 test from String (0 ms total)

[----------] 1 test from Vector
[ RUN      ] Vector.VectorEq
[       OK ] Vector.VectorEq (0 ms)
[----------] 1 test from Vector (0 ms total)

[----------] Global test environment tear-down
[==========] 2 tests from 2 test suites ran. (0 ms total)
[  PASSED  ] 2 tests.
```

## 复杂测试用例TEST_F

- 测试程序级别的`Set-Up`与`Tear-Down`
- 测试套件级别的`Set-Up`与`Tear-Down`
- 测试用例级别的`Set-Up`与`Tear-Down`

**代码实例**

测试程序级别的`Set-Up`与`Tear-Down`

```c++
// tgtest_test.cpp
class Env1 : public ::testing::Environment {
public:
  Env1() { std::cout << "program-level: Env1::Env1()\n"; }
  ~Env1() override { std::cout << "program-level: Env1::~Env1()\n"; }

  // Per-test-program set-up
  void SetUp() override { std::cout << "program-level: Env1::SetUp()\n"; }
  // Per-test-program tear-down
  void TearDown() override { std::cout << "program-level: Env1::TearDown()\n"; }
};
```

测试套件级别的`Set-Up`与`Tear-Down`与测试用例级别的`Set-Up`与`Tear-Down`
```c++
// tgtest_test.cpp
class VectorTest : public ::testing::Test {
// for TEST_P the protected should change to public for method access
protected:
  VectorTest() { std::cout << "testsuite-level: VectorTest::VectorTest()\n"; }
  ~VectorTest() override { std::cout << "testsuite-level: VectorTest::~VectorTest()\n"; }

  // Per-test-suite set-up
  static void SetUpTestSuite() {
    shared_vi_ = new std::vector<int>{1, 2, 3, 4};
    std::cout << "testsuite-level: VectorTest::SetUpTestSuite()\n";
  }
  // Per-test-suite tear-down
  static void TearDownTestSuite() {
    delete shared_vi_;
    shared_vi_ = nullptr;
    std::cout << "testsuite-level: VectorTest::TearDownTestSuite()\n";
  }

  // Per-test set-up
  void SetUp() override { std::cout << "test-level: VectorTest::SetUp()\n"; }
  // Per-test tear-down
  void TearDown() override { std::cout << "test-level: VectorTest::TearDown()\n"; }

  static std::vector<int> *shared_vi_;
};
std::vector<int> *VectorTest::shared_vi_ = nullptr;
```

测试用例
```c++
// tgtest_test.cpp
TEST_F(VectorTest, VectorLen) {
  std::cout << "VectorTest_VectorEq(): begin\n";
  std::vector<int> x{1, 2, 3, 4};

  ASSERT_EQ(x.size(), shared_vi_->size());
  std::cout << "VectorTest_VectorLen(): end\n";
}

TEST_F(VectorTest, VectorCap) {
  std::cout << "VectorTest_VectorCap(): begin\n";

  ASSERT_GE(shared_vi_->capacity(), shared_vi_->size());
  std::cout << "VectorTest_VectorCap(): end\n";
}
```

测试主方法
```c++
// tgtest_test.cpp
int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  ::testing::AddGlobalTestEnvironment(new Env1());
  //::testing::AddGlobalTestEnvironment(new Env2()); // 可以有多个
  return RUN_ALL_TESTS();
}
```

**执行结果**(调整了下输出)
```shell
$ ./tgtest
program-level: Env1::Env1()
[==========] Running 2 tests from 1 test suite.
[----------] Global test environment set-up.
program-level: Env1::SetUp()

    [----------] 2 tests from VectorTest
    testsuite-level: VectorTest::SetUpTestSuite()
        [ RUN      ] VectorTest.VectorLen
        testsuite-level: VectorTest::VectorTest()
            test-level: VectorTest::SetUp()
                VectorTest_VectorEq(): begin
                VectorTest_VectorLen(): end
            test-level: VectorTest::TearDown()
        testsuite-level: VectorTest::~VectorTest()
        [       OK ] VectorTest.VectorLen (0 ms)

        [ RUN      ] VectorTest.VectorCap
        testsuite-level: VectorTest::VectorTest()
            test-level: VectorTest::SetUp()
                VectorTest_VectorCap(): begin
                VectorTest_VectorCap(): end
            test-level: VectorTest::TearDown()
        testsuite-level: VectorTest::~VectorTest()
        [       OK ] VectorTest.VectorCap (0 ms)
    testsuite-level: VectorTest::TearDownTestSuite()
    [----------] 2 tests from VectorTest (0 ms total)

[----------] Global test environment tear-down
program-level: Env1::TearDown()
[==========] 2 tests from 1 test suite ran. (0 ms total)
[  PASSED  ] 2 tests.
program-level: Env1::~Env1()
```


## 参数化测试

### 值参数化测试用例TEST_P

**代码实例**
```c++
#include "gmock/gmock.h"
#include "gtest/gtest.h"
#include <string>

// 1. define a fixture class
class StringTest : public ::testing::TestWithParam<const char *> {};

// 2 define a value parameterized test
TEST_P(StringTest, endsWith) {
  using ::testing::EndsWith;
  EXPECT_THAT(GetParam(), EndsWith("gtest"));
}

// 3. instantiate the parameterized value test suite
INSTANTIATE_TEST_SUITE_P(MyStringTest, StringTest, ::testing::Values("01gtest", "02 gtest"),
                         [](const ::testing::TestParamInfo<StringTest::ParamType> &info) {
                           std::string name = info.param;
                           std::replace_if(
                               name.begin(), name.end(), [](char c) { return !std::isalnum(c); }, '_');
                           return name;
                         });

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```
**执行结果**:
```shell
$ ./tgtest
[==========] Running 2 tests from 1 test suite.
[----------] Global test environment set-up.
[----------] 2 tests from MyStringTest/StringTest
[ RUN      ] MyStringTest/StringTest.endsWith/01gtest
[       OK ] MyStringTest/StringTest.endsWith/01gtest (0 ms)
[ RUN      ] MyStringTest/StringTest.endsWith/02_gtest
[       OK ] MyStringTest/StringTest.endsWith/02_gtest (0 ms)
[----------] 2 tests from MyStringTest/StringTest (0 ms total)

[----------] Global test environment tear-down
[==========] 2 tests from 1 test suite ran. (0 ms total)
[  PASSED  ] 2 tests.
```

### 类型参数化测试用例TYPED_TEST_P

用来测试基于类型的代码，比如模板数据类型的函数等。 另外，还有一个`TYPED_TEST`，也是用来测试类型的，没有这个灵活好用，不介绍了。

**代码实例**
```c++
// tgtest_test.cpp
#include "gtest/gtest.h"
#include <type_traits>

// 1. define a fixture class template
template <typename T>
class IntegralTest : public ::testing::Test {
public:
  T value_;
};

// 2. declare that you will define a type-parameterized test suite
TYPED_TEST_SUITE_P(IntegralTest);

// 3.1 define a type-parameterized test
TYPED_TEST_P(IntegralTest, isIntegral) {
  TypeParam n = this->value_;
  EXPECT_TRUE(std::is_integral_v<decltype(n)>);
}
// 3.1 define a type-parameterized test
TYPED_TEST_P(IntegralTest, isSigned) {
  TypeParam n = this->value_;
  EXPECT_TRUE(std::is_signed_v<decltype(n)>);
}

// 4. register all test
REGISTER_TYPED_TEST_SUITE_P(IntegralTest, isIntegral, isSigned);

// 5. instantiate the parameterized types test suite
using MyTypes = ::testing::Types<char, int, long>;
INSTANTIATE_TYPED_TEST_SUITE_P(MyTypeTest, IntegralTest, MyTypes);

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```
**执行结果**:
```shell
$ ./tgtest
[==========] Running 6 tests from 3 test suites.
[----------] Global test environment set-up.
[----------] 2 tests from MyTypeTest/IntegralTest/0, where TypeParam = char
[ RUN      ] MyTypeTest/IntegralTest/0.isIntegral
[       OK ] MyTypeTest/IntegralTest/0.isIntegral (0 ms)
[ RUN      ] MyTypeTest/IntegralTest/0.isSigned
[       OK ] MyTypeTest/IntegralTest/0.isSigned (0 ms)
[----------] 2 tests from MyTypeTest/IntegralTest/0 (0 ms total)

[----------] 2 tests from MyTypeTest/IntegralTest/1, where TypeParam = int
[ RUN      ] MyTypeTest/IntegralTest/1.isIntegral
[       OK ] MyTypeTest/IntegralTest/1.isIntegral (0 ms)
[ RUN      ] MyTypeTest/IntegralTest/1.isSigned
[       OK ] MyTypeTest/IntegralTest/1.isSigned (0 ms)
[----------] 2 tests from MyTypeTest/IntegralTest/1 (0 ms total)

[----------] 2 tests from MyTypeTest/IntegralTest/2, where TypeParam = long
[ RUN      ] MyTypeTest/IntegralTest/2.isIntegral
[       OK ] MyTypeTest/IntegralTest/2.isIntegral (0 ms)
[ RUN      ] MyTypeTest/IntegralTest/2.isSigned
[       OK ] MyTypeTest/IntegralTest/2.isSigned (0 ms)
[----------] 2 tests from MyTypeTest/IntegralTest/2 (0 ms total)

[----------] Global test environment tear-down
[==========] 6 tests from 3 test suites ran. (0 ms total)
[  PASSED  ] 6 tests.
```

## 死亡测试

通常在测试过程中，我们需要考虑各种边界输入，有的输入可能会直接导致程序崩溃，我们需要检查程序是否按照预期的方式崩溃，这也就是所谓的“死亡测试”，gtest的死亡测试能做到在一个安全的环境下执行崩溃的测试案例，同时又对崩溃结果进行验证。

- 测试套件名称定义为`*DeathTest`，如果需要可以通过`using or typedef`来定义别名
- gtest有限的支持正则表达式，用来匹配程序崩溃信息
- 死亡测试断言:`ASSERT/EXPECT_DEATH`,`ASSERT/EXPECT_EXIT`,`ASSERT/EXPECT_DEBUG_DEATH`

**代码实例**
```c++
#include "gtest/gtest.h"

void NullPointer() {
  int *p = nullptr;
  *p = 42;
}

TEST(PointerDeathTest, NullPointer) { EXPECT_DEATH(NullPointer(), ""); }

TEST(ExitDeathTest, Exit) { EXPECT_EXIT(exit(1), testing::ExitedWithCode(1), ""); }

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
```
```shell
$ ./tgtest
[==========] Running 2 tests from 2 test suites.
[----------] Global test environment set-up.
[----------] 1 test from PointerDeathTest
[ RUN      ] PointerDeathTest.NullPointer
[       OK ] PointerDeathTest.NullPointer (438 ms)
[----------] 1 test from PointerDeathTest (438 ms total)

[----------] 1 test from ExitDeathTest
[ RUN      ] ExitDeathTest.Exit
[       OK ] ExitDeathTest.Exit (62 ms)
[----------] 1 test from ExitDeathTest (62 ms total)

[----------] Global test environment tear-down
[==========] 2 tests from 2 test suites ran. (501 ms total)
[  PASSED  ] 2 tests.
```

## Gtest扩展

我们可以通过三个层次的`Set-Up`与`Tear-Down`来实现复杂的测试用例，我们也可以通过扩展gtest来实现同样的效果，这个机制与`JUnit5`是一致的。
我们可以通过继承`::testing::EmptyTestEventListener`来override一些callbacks来实现行为注入。

**代码实例**

定义一个`TestListener`来覆盖一些方法，注入期望的行为:
```c++
class VectorTestListener : public ::testing::EmptyTestEventListener {
  void OnTestProgramStart(const ::testing::UnitTest &ut) override {
    std::cout << "VectorTestListener::OnTestProgramStart()\n";
  }

  void OnTestIterationStart(const ::testing::UnitTest &unit_test, int iteration) override {
    std::cout << "VectorTestListener::OnTestIterationStart()\n";
  }

  void OnEnvironmentsSetUpStart(const ::testing::UnitTest &ut) override {
    std::cout << "VectorTestListener::OnEnvironmentsSetUpStart()\n";
  }
  void OnEnvironmentsSetUpEnd(const ::testing::UnitTest &ut) override {
    std::cout << "VectorTestListener::OnEnvironmentsSetUpEnd()\n";
  }

  void OnTestSuiteStart(const ::testing::TestSuite &ts) override {
    std::cout << "VectorTestListener::OnTestSuiteStart()\n";
  }

  void OnTestStart(const ::testing::TestInfo &tinfo) override {
    std::cout << "VectorTestListener::OnTestStart()\n";
  }
  void OnTestPartResult(const ::testing::TestPartResult &tres) override {
    std::cout << "VectorTestListener::OnTestPartResult()\n";
  }
  void OnTestEnd(const ::testing::TestInfo &tinfo) override {
    std::cout << "VectorTestListener::OnTestEnd()\n";
  }

  void OnTestSuiteEnd(const ::testing::TestSuite &ts) override {
    std::cout << "VectorTestListener::OnTestSuiteEnd()\n";
  }

  void OnEnvironmentsTearDownStart(const ::testing::UnitTest &ut) override {
    std::cout << "VectorTestListener::OnEnvironmentsTearDownStart()\n";
  }
  void OnEnvironmentsTearDownEnd(const ::testing::UnitTest &ut) override {
    std::cout << "VectorTestListener::OnEnvironmentsTearDownEnd()\n";
  }

  void OnTestIterationEnd(const ::testing::UnitTest &unit_test, int iteration) override {
    std::cout << "VectorTestListener::OnTestIterationEnd()\n";
  }

  void OnTestProgramEnd(const ::testing::UnitTest &ut) override {
    std::cout << "VectorTestListener::OnTestProgramEnd()\n";
  }
};
```
定义测试用例:
```c++
TEST(VectorTest, VectorLen) {
  std::cout << "VectorTest_VectorEq(): begin\n";
  SUCCEED();
  std::cout << "VectorTest_VectorLen(): end\n";
}

TEST(VectorTest, VectorCap) {
  std::cout << "VectorTest_VectorCap(): begin\n";
  SUCCEED();
  std::cout << "VectorTest_VectorCap(): end\n";
}
```
测试主方法:
```c++
int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  testing::TestEventListeners &listeners = testing::UnitTest::GetInstance()->listeners();
  listeners.Append(new VectorTestListener());
  return RUN_ALL_TESTS();
}
```
**执行结果**(调整了下输出)
```shell
$ ./tgtest
VectorTestListener::OnTestProgramStart()
[==========] Running 2 tests from 1 test suite.
  VectorTestListener::OnTestIterationStart()
    [----------] Global test environment set-up.
    VectorTestListener::OnEnvironmentsSetUpStart()
    VectorTestListener::OnEnvironmentsSetUpEnd()
      VectorTestListener::OnTestSuiteStart()
      [----------] 2 tests from VectorTest
        [ RUN      ] VectorTest.VectorLen
        VectorTestListener::OnTestStart()
          VectorTest_VectorEq(): begin
            VectorTestListener::OnTestPartResult()
          VectorTest_VectorLen(): end
        VectorTestListener::OnTestEnd()
        [       OK ] VectorTest.VectorLen (0 ms)
        [ RUN      ] VectorTest.VectorCap
        VectorTestListener::OnTestStart()
          VectorTest_VectorCap(): begin
            VectorTestListener::OnTestPartResult()
          VectorTest_VectorCap(): end
        VectorTestListener::OnTestEnd()
        [       OK ] VectorTest.VectorCap (0 ms)
      VectorTestListener::OnTestSuiteEnd()
      [----------] 2 tests from VectorTest (0 ms total)

      [----------] Global test environment tear-down
    VectorTestListener::OnEnvironmentsTearDownStart()
    VectorTestListener::OnEnvironmentsTearDownEnd()
  VectorTestListener::OnTestIterationEnd()
[==========] 2 tests from 1 test suite ran. (0 ms total)
[  PASSED  ] 2 tests.
VectorTestListener::OnTestProgramEnd()
```
## 其他

### 忽略测试用例GTEST_SKIP
1. 用在具体的测试用例里面，忽略当前测试用例
2. 用在具体的测试套件类的`SetUp()`里面，忽略当前测试套件里的所有测试用例
3. 用在具体的测试环境类的`SetUp()`里面，忽略当前测试环境里的所有测试用例

### 定义测试上下文SCOPED_TRACE
有时候，在一个测试用例中需要多处调用同一个辅助测试方法，可以使用SCOPED_TRACE来指定有区分度的调用位置上下文(trace)信息，万一测试失败，可以方便的定位具体的调用失败位置。

### 测试程序执行控制

`Gtest`也支持使用命令行参数来控制测试用例的执行，常用的flag有(`./testapp --help`可以显示所有的flags):
- 测试用例选择
  - `--gtest_list_tests`列出所有的测试用例
  - `--gtest_filter=POSITIVE_PATTERNS[-NEGATIVE_PATTERNS]`选择执行满足条件的测试用例
  - `--gtest_also_run_disabled_tests`强制执行`GTEST_SKIP`的测试用例
- 测试执行控制
  - `--gtest_repeat=[COUNT]`重复执行测试用例
  - `--gtest_shuffle`乱序执行测试用例
- 测试结果输出控制
  - `--gtest_output=(json|xml)[:DIRECTORY_PATH/|:FILE_PATH]`测试结果输出控制
- 测试行为控制
  - `--gtest_throw_on_failure`当测试失败的时候，会抛出异常


[1]: https://github.com/google/googletest
[2]: https://google.github.io/googletest

