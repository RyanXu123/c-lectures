# C 语言参考源索引（备课用 · 2026-10-09 建）

主人原话：「不只是翁恺,还有 github 上的教程 海纳百川嘛」。
这份是**查的地方**的清单——备课先来这里挑源，讲义里只写一条主线，不把源堆给主人看。

## 一、权威规范（"标准到底保证什么"以这两位为准）

| 源 | 地址 | 说明 |
|---|---|---|
| C 标准 / POSIX 规范 | `https://pubs.opengroup.org/onlinepubs/9699919799/functions/<函数>.html` | 本机可直连（2026-10-09 实测）。写"标准保证什么"用这个，原话最硬 |
| Linux man-pages | `https://man7.org/linux/man-pages/man3/<函数>.3.html` | 本机可直连。查边界 / 未定义行为 / 示例最快 |
| ISO C 标准草案 | `https://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf` | 要抠字眼才翻，PDF 大 |

**抓不到的地方**：`cppreference.com`（含中文版）走 Cloudflare 挑战页，curl 返回 `Just a moment...`，别白费劲。

## 二、实现手册（"这函数怎么被用"的官方教程味）

| 源 | 地址 | 说明 |
|---|---|---|
| glibc 手册 | `https://sourceware.org/glibc/manual/latest/html_node/<Node>.html` | 本机可直连。按用途分节点：`String-Length` / `Copying-Strings-and-Arrays` / `Concatenating-Strings` / `String_002fArray-Comparison` |

注意：`www.gnu.org/software/libc/manual/html_node/...` 这种链接会跳到"格式下载页"，抓不到正文；走 sourceware 那个。

## 三、课程（主人跟的那两套，用来对表顺序）

B 站分 P 就是大纲，抓法（2026-10-09 实测通）：

```
curl -s -H "User-Agent: Mozilla/5.0" -H "Referer: https://www.bilibili.com/" ^
  "https://api.bilibili.com/x/web-interface/view?bvid=<BV号>"
```

- 翁恺（浙大）`BV1dr4y1n7vA`：100 P。字符串函数在**第 10 章 10.2**（p93 strlen / p94 strcmp / p95 strcpy）。
- 鹏哥 `BV17a7K64ELH`：200 P。**p135~144【字符串函数】专题**；另 p107 strlen 模拟实现、p112 冒泡、p127 sizeof 与 strlen 对比、p145~147【内存函数】。

## 四、代码库 / 书单（GitHub，主人清单里那几个）

| 源 | 地址 | 用途 |
|---|---|---|
| TheAlgorithms/C | `https://github.com/TheAlgorithms/C` | 想看某个算法/函数的另一种写法时翻它 |
| free-programming-books | `https://github.com/EbookFoundation/free-programming-books` | 找免费 C 教材（中文书单在 C 语言那一节） |
| Awesome-Embedded | `https://github.com/nhivp/Awesome-Embedded` | 嵌入式方向以后用 |

## 五、查法顺序（备课照走）

1. 先想清这玩意的**活**是什么（用途/场景）；
2. 去**规范**那一栏确认"标准保证什么"（别背具体数值）；
3. 去 **glibc 手册 / man-pages** 找边界与未定义行为；
4. 看**课程**里这块排在哪一集（顺序跟教程对齐）；
5. 写示例、**本机实跑**、把真实输出贴进讲义；
6. 讲义末尾记一句"这一讲参考了什么"，方便下次接着查。