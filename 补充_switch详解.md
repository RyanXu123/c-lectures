# 补充 · switch 详解（第 14 讲的加长版）

> 起因：主人说"你当时只是粗略地讲了一下 switch，现在给我详细讲讲"。
> 第 14 讲那份讲对了骨架（`switch` / `case` / `break` / `default` / 穿透），
> 这一份把它没展开的地方全摊开——**每条结论后面都挂着实测，不是本座背的书**。
> 探针文件都在 `cpp-demo\_teacher\_tmp\sw_*.c`，可以自己编一遍看报错原文。

---

## 一、先定位：它管的是哪一种题

代码里的"分岔"有两种形状，别混：

| 形状 | 例子 | 用什么 |
|---|---|---|
| **一个值，等于几就干哪件事** | 输入 1~7，打印星期几 | `switch` |
| **一个量，落在哪个区间** | 温度 > 30 报警、> 60 停炉 | `if / else if` |

`switch` 只会做一件事：**拿一个值，去跟一串固定值一一比相等**。
它不会比大小、不会比范围（标准 C 里不会）、不会比字符串。

一句话记住：**`switch` 是"点名"，不是"划范围"。**

---

## 二、骨架逐字拆

```c
switch (要看的那个值) {
    case 值1:
        做这件事;
        break;
    case 值2:
        做那件事;
        break;
    default:
        都不是的时候做这件;
        break;
}
```

| 部位 | 职责 | 细节 |
|---|---|---|
| `switch ( )` | 括号里就是被判的那个值 | 只放一个表达式；`x`、`x % 3`、`ch` 都行 |
| `case 值:` | "如果等于这个值" | 冒号不能丢；这一行整体叫**标签**，不是语句 |
| `break;` | 这一支到此为止 | 不写就往下穿透 |
| `default:` | 兜底 | 可以不放，也可以放在中间 |

读法还是第 14 讲那句：**拿括号里的值去跟一串 `case` 比，谁相等就从谁那儿开始往下做，
一直做到撞上 `break` 或者撞到 `switch` 的尾巴为止。**

---

## 三、括号里能塞什么

实测（`_tmp\sw_err_float.c`）：把 `double` 塞进去，编译直接停。

```
sw_err_float.c:7:13: error: switch quantity not an integer
    7 |     switch (d) {
      |             ^
```

人话：**`switch` 只认整数。**

| 能塞 | 为什么 |
|---|---|
| `int`、`char` | 都是整数（`char` 本质是一个小整数，`'A'` 就是 65） |
| `enum` 定义的变量 | 枚举在底层就是 0、1、2 这样的整数 |
| `x % 3`、`x + 1` 这类结果是整数的表达式 | 算出来是个整数值 |

| 不能塞 | 报错 |
|---|---|
| `double` / `float` | `switch quantity not an integer` |
| 字符串（`char` 数组） | `switch quantity not an integer` |

浮点要分支，就老老实实回去用 `if`。

---

## 四、`case` 的五条规矩

### 规矩 1：后面必须是**编译期**就能算出来的常量

实测（`_tmp\sw_err_varcase.c`）—— `case c:`（`c` 是变量）：

```
sw_err_varcase.c:9:9: error: case label does not reduce to an integer constant
    9 |         case c:
      |         ^~~~
```

**"编译期可算"的意思是：写代码的时候编译器就把它算成一个确定的数，运行时不许变。**

### 规矩 2：常量**算式**可以

`case 20 + 1:` 完全合法，编译器当场把它算成 21。举一反三：

```c
case 2 * 3:       /* = 6 */
case 'A' + 1:     /* = 66，就是 'B' */
case RED:         /* 枚举常量，等于 0 */
```

这跟规矩 1 不冲突：`20 + 1` 是**写死的**，`c` 是**运行时才知道的**。

### 规矩 3：同一个 `switch` 里，`case` 的值不能重复

实测（`_tmp\sw_err_dup.c`）：

```
sw_err_dup.c:11:9: error: duplicate case value
   11 |         case 2:
      |         ^~~~
sw_err_dup.c:8:9: note: previously used here
    8 |         case 2:
      |         ^~~~
```

它能认出"就是你前面那个 2"，还顺手告诉你在第 8 行写过。

### 规矩 4：几个 `case` 可以**叠着写**，共用同一段代码

这是最实用的写法之一，判"落在几个连续值里"就靠它：

```c
switch (m) {
    case 3:
    case 4:
    case 5:
        printf("m 落在 3~5 里\n");
        break;
    default:
        printf("m 不在 3~5 里\n");
        break;
}
```

`case 3:` 后面什么都没有，就掉进 `case 4:`，再掉进 `case 5:`——
这次"穿透"不是 bug，是**故意**用的，三个入口同一段身子。

### 规矩 5：`case 3 ... 5:` 这种范围写法，**不是标准 C**

实测（`_tmp\sw_range_gcc.c`）：不加 `-pedantic` 编得过、跑得动；
加上就当场报警告——

```
warning: ISO C does not support range expressions in switch statements before C2Y [-Wpedantic]
```

人话：**这是 GCC 送的方便，不是 C 语言的规矩。** 换编译器就不保证有，
交给学长的题别用。要范围就叠 `case` 或者回去用 `if`。

---

## 五、`break` 到底跳出哪儿

这条最容易被想歪。`break` 跳出的是**最近的那一层 `switch`**，不是外面的循环。

实测（`_teacher\demo\p31_switch_more.c` 第 5 段）：`switch` 嵌在 `for` 里面，
`case 2` 那支 `break` 掉之后，**循环没有停**：

```
5) 第 1 轮  没命中
5) 第 1 轮的后半段还在跑
5) 第 2 轮  命中 2，这一支 break 掉
5) 第 2 轮的后半段还在跑
5) 第 3 轮  没命中
5) 第 3 轮的后半段还在跑
```

三轮全跑完，每轮 `switch` 后面的那行 `printf` 也都执行了。
所以：**`switch` 里的 `break` 只把 `switch` 拆掉，外面的循环照旧。**

---

## 六、`default` 的三件事

1. **可有可无。** 一个都不写，`switch` 照样编、照样跑。
2. **位置随意。** 放中间、放最后都行，它不靠位置决定优先级——该轮到它才轮到它。
3. **不写 `break;` 照样会往下掉。** 第 14 讲已经用 `p20_default_proof.c` 证明过：
   把 `default` 挪到 `case 100` 前面、`break` 不写，实测多打了一行"掉到 case 100 里了"。
   它不是自动停下，是"后面正好是尾巴，没地方可掉"。

---

## 七、在 `switch` 里定义变量：能写，但要长个心眼

先说实测结论：`case 2:` 下面直接写 `int y = 10;`，**C 里是合法的**
（`_tmp\sw_err_decl.c`，gcc 编过、跑出 10，零警告）。
第 14 讲那种"标签后面必须跟语句"的说法，是 C++ 的规矩，别拿它吓自己。

真正的坑在**下一步**：这支声明的变量，被别的 `case` 拿去用了。

实测（`_tmp\sw_skip_init.c`）：`case 1` 里声明 `int y = 10;`，`case 2` 里写 `r = y;`，
输入让程序走 `case 2`——

```
warning: 'y' is used uninitialized [-Wuninitialized]
r = 0
```

`case 1` 那行 `int y = 10;` **根本没执行过**（人是从 `case 2` 那扇门进来的），
所以 `y` 是个空盒子；这次打出 0 是运气，换个编译器可能是一串垃圾数。
同一份文件用 `g++` 编，直接拒绝：

```
error: jump to case label
note:   crosses initialization of 'int y'
```

**修法：每一支用花括号圈起来，各管各的盒子。** 实测（`_tmp\sw_brace_ok.c`）：

```c
switch (x) {
    case 1: {
        int y = 10;
        r = y;
        break;
    }
    case 2: {
        int y = 20;
        r = y;
        break;
    }
    default: {
        r = -1;
        break;
    }
}
```

`-Wall -Wextra` 零警告，`g++` 也过，输出 `r = 20`。
**所以现在的习惯就一条：`case` 里要声明变量，当场给它套上 `{ }`。**

---

## 八、`switch` 和 `if / else if` 怎么挑

| | `switch` | `if / else if` |
|---|---|---|
| 判什么 | 一个值**等于**哪几个常量 | 任意条件：大小、区间、逻辑组合 |
| `case` 写什么 | 常量（`3`、`'A'`、`RED`） | 任意表达式 |
| 命中之后 | 从命中的往下**做**（要 `break` 拦） | **命中即止**，后面全跳 |
| 适合 | 值是一个一个数出来的，种类固定 | 温度、分数段、多个变量一起看 |

第 14 讲那条判据照旧有效：**"挨着走一遍"用循环，"固定的几种情况"用 `switch`。**

---

## 九、常见报错原文 → 人话

| 编译器说的 | 它在说 |
|---|---|
| `switch quantity not an integer` | 括号里塞了小数或字符串，只能放整数 |
| `case label does not reduce to an integer constant` | `case` 后面写了变量，只能写常量 |
| `duplicate case value` | 同一个值写了两个 `case` |
| `jump to case label crosses initialization` | 一支里声明的变量被另一支用了，给它套花括号 |
| `warning: label 'defalt' defined but not used` | `default` 拼错了，编译器把它当普通标签，那支永远不执行 |
| `ISO C does not support range expressions` | 用了 `case 3 ... 5:`，那是 GCC 扩展 |

---

## 十、速记

1. `switch` 是**点名**，只认整数和常量，范围判断回去找 `if`；
2. `case` 后面只能写**编译期算得出来**的常量（算式行、变量不行）；
3. 值不能重复；要共用一段就把 `case` 叠起来写；
4. `break` 只跳出**最近这一层 `switch`**，外面循环不受影响；
5. `default` 可选、位置随意、不写 `break` 照样掉；
6. `case` 里声明变量 → 当场套花括号。

---

## 十一、动手

**1.** 跑 `_teacher\demo\p31_switch_more.c`，对着五段输出看代码，把每一段"为什么是这个结果"讲给自己听。

**2.** 把 `_tmp` 里五个错误探针挨个编一遍（`gcc -Wall -Wextra -o test.exe sw_err_float.c`），
   看报错原文跟第九节那张表对不对得上。**先猜再编**。

**3.** 改 `sw_skip_init.c`：先按原样编一次看警告，再加上花括号编一次，两个输出对比。

**4.** 写一个：输入一个大写字母，用 `switch` 判断它是元音（A E I O U）还是辅音，别的不算。
   （提示：元音那五支可以叠着写。）

**5.** 小测：`switch (x) { case 1: case 2: printf("小\n"); }` 这句里，
   如果 `x` 是 1，会打印几次？为什么？

**6.** 小测：为什么 `case 20 + 1:` 合法，`case c:`（`c` 是变量）不合法？
   用"编译的时候知不知道它是几"来回答。
