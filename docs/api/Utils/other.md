---
title: 其他
author: ruchuby
order: 1
date: 2023-04-14
---

## chineseFirstChar(str)

将文本的中文部分转换为拼音首字母，多音字转换不准确

- 参数
    - \{String\} `str`: 要进行转换的文本

- 返回值
    -  \{String\} 将中文部分转为拼音首字母后的字符串

## strStartWith(ori, sub, caseSense := false)

ori是否以sub开头

- 参数
    - \{String\} `ori`: 进行判断的文本
    - \{String\} `sub`: 开头的文本
    - \{Bool\} `caseSense`: 是否大小写敏感

- 返回值
    -  \{Bool\} `true` 则 ori 以 sub 开头

## pathStrCompact(fullPath, maxChars)

压缩文件路径文本，使其不超过最大字符数

- 参数
    - \{String\} `fullPath`: 文件完整路径
    - \{Number\} `maxChars`: 压缩后最大字符数

- 返回值
    - \{String\} 压缩后的文件路径文本

## copyToClipboard(filePath, cut := false)

复制指向文件的路径到剪切板，可选择进行剪切而不是复制

- 参数
    - \{String\} `filePath`: 指向文件的路径
    - \{Bool\} `cut`: 是否剪切，默认为 `false`

- 返回值
    - 无

## startFile(path, workingDir := "", options := "", beforeRun?)

运行指定路径的文件

- 参数
    - \{String\} `path`: 文件路径
    - \{String\} `workingDir`: 工作目录，见[Run / RunWait - 语法 & 使用 | AutoHotkey v2](https://orz707.gitee.io/v2/docs/commands/Run.htm)
    - \{String\} `options`: 见[Run / RunWait - 语法 & 使用 | AutoHotkey v2](https://orz707.gitee.io/v2/docs/commands/Run.htm)
    - \{[Closure](https://orz707.gitee.io/v2/docs/Functions.htm#closures)\} `beforeRun`: 运行文件前执行的处理函数

- 返回值 \{String\}
    - PID 如果无法确定 PID, 返回空字符串

## openFileInFolder(path)

在资源管理器中显示指定路径的文件

- 参数
    - \{String\} `path`: 文件路径

- 返回值
    - 无

## UrlEncode(str)

对给定字符串进行 URL 编码

- 参数
    - \{String\} `str`: 需要编码的字符串

- 返回值
    - \{String\} URL 编码后的字符串

## UrlDecode(str)

对给定字符串进行 URL 解码

- 参数
    - \{String\} `str`: 需要解码的字符串

- 返回值
    - \{String\} URL 解码后的字符串

## globalMatch(Haystack, NeedleRegEx, StartingPos := 1)

从给定字符串的指定起始位置处查找符合正则表达式的所有子字符串，即正则全局模式

参数可以参考[RegExMatch - 语法 & 使用 | AutoHotkey v2](https://orz707.gitee.io/v2/docs/commands/RegExMatch.htm)

- 参数
    - \{String\} `Haystack`: 给定字符串
    - \{RegExp\} `NeedleRegEx`: 正则表达式对象
    - \{Number\} `StartingPos`: 起始位置，默认为 1

- 返回值
    - \{Array\} 匹配对象数组，参考[匹配对象 - MatchObject](https://orz707.gitee.io/v2/docs/commands/RegExMatch.htm#MatchObject)

## Jxon_Load(src, args*)

将给定 JSON 文本数据加载成为 AutoHotkey 变量

:::warning
对象转换后都会变成 Map 类型
:::

- 参数
    - \{String\} `src`: JSON 文本的引用（因为 AHK 中没有传递引用的概念）
    - `args`：额外参数列表，需要则查看 `src\Utils\JXON.ah2` 源码

- 返回值
    - AutoHotkey 变量

## Jxon_Dump(obj, indent := "", lvl := 1)

将给定的 AutoHotkey 变量转换为 JSON 文本

:::warning
不支持 Object 类型，请使用 Map 类型代替
:::

- 参数
    - \{*\} `obj`：需要转换的 AutoHotkey 变量
    - \{String\} `indent`：缩进用的字符串，默认为空字符串
    - \{Number\} `lvl`：当前递归的深度，默认为 1

- 返回值
    - \{String\} 转换后的 JSON 文本

## WinHttp(args*)

参考 WinHttp 库函数源码，`src\Utils\WinHttp.ah2`

- 参数
    - `args`：参数列表，根据不同的请求类型和参数，具体参数需要参考文档说明

- 返回值
    - \{WinHttp\} WinHttp 对象

## associatedHIcon(filePath)

获取 Windows 中与指定文件关联的图标，并返回一个 hICON 句柄

- 参数
    - \{String\} `filePath`：需要获取关联图标的文件路径

- 返回值
    - \{Int\} 获取到的关联图标的 HICON 句柄

## tip(title, content, time?, unique := false)

在右下角弹出一条 `WiseGui` 通知，可设置标题、内容、计时消失时间、是否唯一，返回该通知的 id

- 参数
    - \{String\} `title`：通知标题
    - \{String\} `content`：通知内容
    - \{Number\} `time`：计时消失时间（单位为毫秒），选填，默认为 0，表示不消失
    - \{Boolean\} `unique`：是否保证唯一（即同一时刻只有一条弹窗），选填，默认为 false

- 返回值
    - \{String\} 该通知窗口的 id（如果 `unique` 为 true，则返回 A_TickCount 值作为 id）

## quickSort(arr, fn)

对给定的数组进行**快速排序**（不生成副本），并返回排序后的数组

```ahk
; 升序排序示例
arr:=[1,9,2,8,3,7]
QuickSort(arr, (a,b)=>a-b)
```

- 参数
    - `arr`：待排序数组
    - `fn`：比较函数，接受两个参数 itemA 和 itemB，返回值为数字类型，表示 itemA 和 itemB 的大小关系。如果 itemA 大于 itemB，返回正数；如果 itemA 小于 itemB，返回负数；如果 itemA 等于 itemB，返回 0。

- 返回值
    - 排序后的数组