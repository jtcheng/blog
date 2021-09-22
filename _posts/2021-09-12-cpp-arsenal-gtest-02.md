---
layout: post
title: C++ 组件之 Gtest(2)
tags: [c++, gtest, gmock]
categories: [c++ arsenal]
---

`mock`是原型设计与测试开发领域比较重要的一块内容，`Gtest`是google开源的一款跨平台的C++测试框架项目，里面包含的`gmock`是一个非常好用的原型设计与测试工具，它可以模拟接口设计，模拟模块之间的交互过程，对指定的类进行测试等。

<!-- more -->
* TOC
{:toc}

## Gmock权威资料

Gmock的官方文档其实写得挺好的，使用的时候可以多多参考:
- [Gmock github][1]
- [Gmock reference][2]

## Mock测试的步骤与宏总览

1. 使用`MOCK_METHOD`宏来定义感兴趣的mock对象方法
2. 使用`ON_CALL`,`EXPECT_CALL`宏来预先定义所有mock方法的预期行为
  - 使用`Matchers`在运行时匹配mock方法的入参，进而严格调用最佳匹配的mock方法(类似于函数重载决议)
  - 使用`Cardinalities`来指定mock方法的调用次数
  - 使用`Sequences`与`Expectations`来控制多个mock方法之间的执行顺序
  - 使用`Actions`定义mock方法的具体执行内容(类似于方法的函数体)
  - 使用`RetiresOnSaturation`来终止当前的`EXPECT_CALL`参与后续的mock方法匹配
3. 调用mock方法并断言结果，这时候会进行mock方法匹配决议，优先使用最近的模式匹配

## Mock接口类

A. 定义(或者使用已存在的)接口类:

```c++
// generator.h
#pragma once

class Generator {
public:
  virtual ~Generator() = default; // need be virtual
  virtual int generate(int lo, int hi) const = 0;
};
```
B. mock接口类方法:

```c++
// mock_generator.h
#pragma once

#include "generator.h"
#include "gmock/gmock.h"

class MockGenerator : public Generator {

public:
  MOCK_METHOD(int, generate, (int, int), (const, override));
};
```
C. 测试mock方法:

```c++
#include "mock_generator.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"

using ::testing::_;
using ::testing::Ge;
using ::testing::InSequence;
using ::testing::Lt;
using ::testing::Return;
using ::testing::WithArgs;

TEST(GeneratorTest, generate1) {
  // MockGenerator defGenerator;
  ::testing::NiceMock<MockGenerator> niceGenerator;
  // ::testing::NaggyMock<MockGenerator> naggyGenerator;
  // ::testing::StrictMock<MockGenerator> strictGenerator;

  // #1: arg1 >= 10, arg1 < arg2 and return (arg1 + arg2 / 2)
  ON_CALL(niceGenerator, generate(Ge(10), _)).With(Lt()).WillByDefault(WithArgs<0, 1>([](int lo, int hi) {
    return (lo + hi / 2);
  }));

  EXPECT_CALL(niceGenerator, generate(_, _)).WillOnce(Return(10));   // #a: use self action (override)
  EXPECT_CALL(niceGenerator, generate(20, _)).RetiresOnSaturation(); // #b: use default action from #1

  EXPECT_EQ(30, niceGenerator.generate(20, 21)); // match #b
  EXPECT_EQ(10, niceGenerator.generate(20, 21)); // match #a
}

TEST(GeneratorTest, generate2) {
  MockGenerator defGenerator;
  {
    InSequence seq;
    EXPECT_CALL(defGenerator, generate(10, 20)).Times(2).WillRepeatedly(Return(20));
    EXPECT_CALL(defGenerator, generate(20, 30)).WillOnce(Return(35));
  }
  auto seq_call = [&]() {
    // must call as order defined in seq
    EXPECT_EQ(20, defGenerator.generate(10, 20));
    EXPECT_EQ(20, defGenerator.generate(10, 20));
    EXPECT_EQ(35, defGenerator.generate(20, 30));
  };
  seq_call();
}

int main(int argc, char **argv) {
  //::testing::InitGoogleTest(&argc, argv);
  ::testing::InitGoogleMock(&argc, argv);
  return RUN_ALL_TESTS();
}
```

`MOCK_METHOD`宏解读:
```c++
MOCK_METHOD(return_type, method_name, (args...), (specs...));
```
其实就对应着一个方法的完整签名:
- `return_type`: 方法返回类型
- `method_name`: 方法名称
- `(args...)`: 方法参数，没有可以空着`()`
- `(specs...)`: 方法修饰符，没有可以空着`()`
- 对于复杂类型(类型中包含`,`)，需要添加括号防止歧义:`(return_type)``((args)...)`

`ON_CALL`宏解读:
```c++
ON_CALL(mock_object, method_name(matchers...))
    .With(multi_argument_matcher)  // Can be used at most once
    .WillByDefault(action);        // Required
```
用来定义mock方法调用时候的默认行为:
- `matchers...`: 对方法的每个对应参数执行参数筛选匹配，如果为`_`，就是接收任意符合类型的参数
- `With`: 也是一个matcher，对方法的所有参数集中执行参数筛选匹配(所有的参数组成了一个tuple)
- `WillByDefault`: 定义一个默认的行为

`EXPECT_CALL`宏解读:
```c++
EXPECT_CALL(mock_object, method_name(matchers...))
  .With(multi_argument_matcher)  // Can be used at most once and must be the first clause
  .Times(cardinality)            // Can be used at most once
  .InSequence(sequences...)      // Can be used any number of times
  .After(expectations...)        // Can be used any number of times
  .WillOnce(action)              // Can be used any number of times
  .WillRepeatedly(action)        // Can be used at most once
  .RetiresOnSaturation();        // Can be used at most once
```
提前创建一个预期，给后续的mock方法使用:
- `mock_object`: mock对象
- `method_name`: mock对象的方法
- `matchers...`: 对方法的每个对应参数执行参数筛选匹配，如果为`_`，就是接收任意符合类型的参数
- `With`: 也是一个matcher，对方法的所有参数集中执行参数筛选匹配(所有的参数组成了一个tuple)
- `Times`: 方法期望执行的次数
- `InSequence`: 控制多个方法的执行顺序(序列)
- `After`: 类似于InSequence，但是用起来略微复杂
- `WillOnce`: 方法执行时候的返回值
- `WillRepeatedly`: 方法反复执行时候的返回值
- `RetiresOnSaturation`: 使得一个方法不再去匹配后续的执行

`ON_CALL`与`EXPECT_CALL`:
- ON_CALL主要用来定义mock方法被调用时的默认行为(action)，对调用次数方式等没有限制
- EXPECT_CALL除了定义mock方法被调用时的行为外，还定义了mock方法被调用方式的一些预期行为，比如入参匹配，次数，执行顺序等
- EXPECT_CALL可以与ON_CALL配合使用，使用来自ON_CALL定义的默认行为，或者使用自己定义的行为

## Mock保护与私有方法

接口的`public`,`protected`,`private`方法都是可以mock的，只要把它们对应的`MOCK_METHOD`都放到mock类的`public`下就行了。

## Mock重载方法

mock重载方法的时候，我们需要指明重载方法的签名:
- const修饰的重载方法: `EXPECT_CALL(Const(mock_object)...)`可以得到常量mock对象
- 参数个数不同的重载方法: 为mock方法指定全部入参
- 参数类型不同的重载方法: 为mock方法指定全部入参类型
  - `Matcher<type>()`
  - `TypedEq<type>`
  - `An<type>()`,`A<type>()`
- 可以使用`using baseclass::method_name`来导入基类的所有重载方法，然后仅仅mock感兴趣的重载方法

## Mock类模板

mock类模板与mock一个一般的类差不多，就是多了个模板参数而已，注意下面的例子里面用到了`After`来控制mock方法的调用顺序。

**代码实例**
```c++
// generator.h
#pragma once

template <typename T>
class Generator {
public:
  virtual ~Generator() = default;
  virtual T generate(T lo, T hi) const = 0;
};
```
```c++
#pragma once

#include "generator.h"
#include "gmock/gmock.h"

template <typename T>
class MockGenerator : public Generator<T> {

public:
  MOCK_METHOD(T, generate, (T, T), (const, override));
};
```
```c++
#include "mock_generator.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"

using ::testing::Expectation;
using ::testing::Return;

TEST(GeneratorTest, generate) {
  MockGenerator<int> defGenerator;
  Expectation exp1 = EXPECT_CALL(defGenerator, generate(10, 20)).Times(2).WillRepeatedly(Return(20));
  EXPECT_CALL(defGenerator, generate(20, 30)).After(exp1).WillOnce(Return(35));

  auto seq_call = [&]() {
    // must call as order defined as after
    EXPECT_EQ(20, defGenerator.generate(10, 20));
    EXPECT_EQ(20, defGenerator.generate(10, 20));
    EXPECT_EQ(35, defGenerator.generate(20, 30));
  };
  seq_call();
}

int main(int argc, char **argv) {
  //::testing::InitGoogleTest(&argc, argv);
  ::testing::InitGoogleMock(&argc, argv);
  return RUN_ALL_TESTS();
}
```

## Mock非虚方法

与mock虚方法类似，就是不需要继承与override了，创建一个签名类似的独立的mock类，然后结合mock类模板的方式来实例化具体的mock对象。

## Mock自由函数

这个比较简单，将感兴趣的自由函数放到一个接口类下面，然后就使用mock接口类的方式来mock具体的自由函数。

## 其他

A. flag参数:
- `--gmock_catch_leaked_mocks=false`
- `--gmock_verbose=info | warning | error`
- `--gmock_default_mock_behavior=0 | 1 | 2`(0: NiceMocks, 1: NaggyMocks, 2: StrictMocks)

B. Matchers

使用的时候参考具体的文档，合理使用`With`来定义各种各样的Matchers

C. Actions

使用的时候参考具体的文档，合理使用`WillOnce`,`WillRepeatedly`,`WillByDefault`来定义各种各样的Actions

D. Cardinalities

使用的时候参考具体的文档，合理使用`Times`来定义各种各样的Cardinalities

E. Expectation Order

使用的时候参考具体的文档，合理使用`InSequence`与`After`来定义各种各样的Expectation Order

[1]: https://github.com/google/googletest
[2]: https://google.github.io/googletest