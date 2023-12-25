---
title: ImagePut —— 输入类型 & 输出函数
icon: image
author: AkiChase
date: 2023-04-16
---

:::warning
本文仅仅翻译[Input Types & Output Functions · iseahound/ImagePut Wiki (github.com)](https://github.com/iseahound/ImagePut/wiki/Input-Types-&-Output-Functions#input-types)，可能存在不准确的地方，仅供参考，请以原 wiki 文档为准。
:::

## 用法

以下示例使用 `"cats.jpg"`。请将您自己的JPEG文件重命名或使用 ImagePut 下载一个。

```ahk
#Include *i ImagePut.ahk
#Include *i ImagePut (for v1).ahk
ImagePutFile({url: "https://picsum.photos/500"}, "cats.jpg")         ; 下载 "cats.jpg"
```

示例

```ahk
ImagePutWindow("cats.jpg")                                           ; 简单调用
ImagePutWindow("cats.jpg", "这是一只可爱的猫！")                    ; 标题: 这是一只可爱的猫！
ImagePutWindow("cats.jpg", "这是一只可爱的猫！", [0, 0])            ; 位置: 屏幕左上角

ImagePutWindow({file: "cats.jpg"})                                   ; 显式输入类型为 "file"
ImagePutWindow({file: "cats.jpg", scale: 2})                         ; 缩放 2 倍
ImagePutWindow({file: "cats.jpg", scale: 2, crop: [0, 0, 300, 300]}) ; 裁剪为 300 x 300

ImagePutWindow({file: "cats.jpg", scale: 2}, "这是一只可爱的猫！")  ; 关键字 + 位置参数
ImagePutWindow({file: "cats.jpg", scale: 2, crop: [0, 0, 300, 300]}, "这是一只可爱的猫！", [0, 0])
```

如果输入类型未知，请将类型设置为 `image`。

```ahk
ImagePutWindow({image: "cats.jpg", scale: 2}, "🐈🐈‍⬛🐈")            ; 未知输入类型 + 关键字参数
```

ImagePutWindow(image, title, pos, style, styleEx, parent) 的说明如下：

- `image` - 输入类型，可以是 [输入类型](#输入类型) 之一，例如 `"cats.jpg"`，或者是一个包装对象，例如 `{file: "cats.jpg"}` 表示输入类型为文件，或 `{image: "cats.jpg"}` 表示自动判断其 [type](输入类型)。
- `title` - 自定义的标题，显示在标题栏上
- `pos` - 一个矩形数组 [x, y, w, h]
- `style` - 窗口样式（很少使用）
- `styleEx` - 扩展窗口样式（很少使用）
- `parent` - 父窗口的句柄（默认情况下为您的 AutoHotkey 脚本的主窗口）

有时您确实希望指定输入类型，例如输入可能不明确的情况下：

```ahk
; 假设我打开一个名为 "cats.jpg" 的图像查看器
ImagePutWindow({window: "cats.jpg"}, "❤️") ; 在这种情况下，指定输入类型为window，因此该窗口优先于任何文件。
```

## 格式

支持的图像格式

- bmp，dib，rle
- jpg, jpeg，jpe，jfif
- gif
- tif，tiff
- png

未来：ico, exe, dll

## 输入类型

**base64** - 带有可选数据 URI 方案的 base64 字符串。可以以 `data:image/png;base64,` 开头。

```ahk
; 透明的绿色像素点。
ImagePutWindow("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==")
```

**bitmap** - 指向 GDI+ 位图的指针。

**buffer** - 具有 `.pBitmap` 属性的任何对象。这可以是由 `ImagePutBuffer` 创建的智能指针。

**clipboard** - 内置的 `ClipboardAll` 变量。

> 注意：在 AutoHotkey v1 中，将 `ClipboardAll` 用作函数参数时，它等于空字符串。

```ahk
ImagePutWindow(ClipboardAll) ; AutoHotkey v1
ImagePutWindow(ClipboardAll) ; or ClipboardAll() AutoHotkey v2
```

**cursor** - 内置变量 `A_Cursor` 或 [任意同类型的值](https://orz707.gitee.io/v2/docs/Variables.htm#Cursor)

**dc** - 设备上下文句柄。应将 hBitmap 选择到设备上下文。

**desktop** - 不区分大小写的字符串 `"desktop"`。

**file** - 图像文件的文件路径。支持的图像格式：bmp、gif、jpg、png、tiff。

```ahk
ImagePutWindow("cats.jpg")
```

**hBitmap** - 指向 GDI 位图的句柄。在转换具有透明度的 hBitmap 时，由于除法的不精确性，会创建外观类似但像素不完美的图像。这是从预乘 ARGB 转换为 ARGB 像素格式的结果。

**hex** - 表示编码图像的十六进制字符串。

**hIcon** - 指向 GDI 图标的句柄。

**monitor** - 监视器号码。数码 `0` 表示整个虚拟屏幕。

```ahk
ImagePutWindow(0) ; 整个屏幕
ImagePutWindow(1) ; 第一个监视器
ImagePutWindow(2) ; 第二个监视器
```

**pdf** - pdf 文件的文件路径。

```ahk
; 处理 PDF 文档。
ImagePutWindow("document.pdf")

; 使用页码。
ImagePutWindow({pdf:"document.pdf", index:2}) ; 第 2 页。

; 处理每一页。
loop
    try ImagePutWindow({pdf:"document.pdf", index:A_Index})
    catch
        break
```

**RandomAccessStream** - 指向 RandomAccessStream 接口的指针。

**screenshot** - `[x,y,w,h]` 数组中的屏幕坐标。或 [WinTitle](https://orz707.gitee.io/v2/docs/misc/WinTitle.htm)。使用 BitBlt。

```ahk
ImagePutWindow([0, 0, 200, 200])

; 将 WinTitle 要求放入方括号中…
ImagePutWindow(["ahk_class notepad"])

; 或者将图像类型声明为截屏。
ImagePutWindow({screenshot: "ahk_class notepad"})

; 这样做可以添加裁剪或缩放：
ImagePutWindow({screenshot: "ahk_class notepad", crop: [0, 0, 100, 100]})
```

**stream** - 指向流接口的指针。这可以是内存流、文件流、IWICStream 或任何继承自 IStream 的内容。

**sprite** - 必须显式声明为：`{sprite:"character.bmp"}`。可以是文件路径或 url。采样左上角像素并将所有该颜色的像素设置为透明。

```ahk
ImagePutWindow({sprite: "character.bmp"})
```

**url** - url 必须以 `https://` 或 `ftp://` 开头。

**wallpaper** - 不区分大小写的字符串 `"wallpaper"`。

**wicBitmap** - 指向 Windows 成像组件位图的指针。

**window** - 与窗口标题匹配的任何字符串。受 [SetTitleMatchMode](https://orz707.gitee.io/v2/docs/commands/SetTitleMatchMode.htm) 影响。使用特殊变量`"A"` 来匹配当前活动窗口。支持 `ahk_id`、`ahk_class`、`ahk_pid` 等。详见[WinTitle](https://orz707.gitee.io/v2/docs/misc/WinTitle.htm)。使用 PrintWindow API。

```ahk
; 窗口标题
ImagePutWindow("Untitled - Notepad")

; 窗口句柄
ImagePutWindow(0x1234)
ImagePutWindow("ahk_id" 0x1234) ; 推荐以安全的方式检查有效 hwnd。

; 窗口类
ImagePutWindow("ahk_class notepad")

; 当前活动窗口
ImagePutWindow("A")

; 如果您遇到窗口捕获问题，请改用截屏。
ImagePutWindow(["Untitled - Notepad"]) ; 类似于 ImagePutWindow([x, y, w, h])

; 或将类型声明为截屏：
ImagePutWindow({screenshot: "Untitled - Notepad", crop: [0, 0, 100, 100]}) ; 使用 BitBlt 进行屏幕捕捉
ImagePutWindow({window: "Untitled - Notepad", crop: [0, 0, 100, 100]})     ; 使用 PrintWindow 进行窗口捕获
```

## 输出函数

### ImagePutBase64(image, extension, quality)

- extension - bmp、dib、rle、jpg、jpeg、jpe、jfif、gif、tif、tiff、png。可以写成 `.gif` 或 `*.gif`。如果可能的话，保留原始扩展名。默认为 PNG。
- quality - 对于 JPEG 图像，0-100 之间的值表示编码的质量。

返回一个 base64 字符串。

```ahk
; 创建一个 base64 字符串。
base64 := ImagePutBase64("cats.jpg")

; 对 png 进行 base64 编码。
base64 := ImagePutBase64("cats.jpg", "png")

; 进一步压缩 jpeg。
base64 := ImagePutBase64("cats.jpg", "jpg", 30)
```

### ImagePutBitmap(image)

返回一个 GDI+ 位图指针。使用完毕后，必须调用 `ImageDestroy()` 来防止 GDI+ 对象泄漏。考虑使用 ImagePutBuffer() 代替。

```ahk
; pToken := Gdip_Startup()            ; 如果已经包含 Gdip_All.ahk，可以使用替代方案
ImagePut.gdiplusStartup()             ; 初始化 GDI+
pBitmap := ImagePutBitmap("cats.jpg") ; 创建一个 pBitmap
ImagePutWindow(pBitmap)               ; 显示图像
ImageDestroy(pBitmap)                 ; 释放位图
```

> 注意：最快的降低开销的方式是调用内部的 ImagePut.from_XXX 函数。

```ahk
pBitmap := ImagePutBitmap("cats.jpg")        ; 1500 fps（与 ImagePutBuffer 的速度相同）
pBitmap := ImagePutBitmap({file:"cats.jpg"}) ; 2600 fps（跳过类型推断）
pBitmap := ImagePut.from_file("cats.jpg")    ; 4356 fps（内置函数）
```

### ImagePutBuffer(image)

返回一个缓冲区对象。这是一个智能指针，当变量释放时，它会自动释放位图。它还包含自己的 GDI+ 范围，因此任何调用 `pToken := Gdip_Startup()` 或 `ImagePut.gdiplusStartup()` 的操作都是不必要的。通过 `buffer.pBitmap` 访问原始指针。

```ahk
; 创建一个缓冲区对象。
buf := ImagePutBuffer("cats.jpg")

; 获取 pBitmap 指针。
ImagePutWindow(buf.pBitmap)

; 获取位图的宽度和高度。
width := buf.width, height := buf.height

; 显示 x、y 像素的颜色。
MsgBox % buf[20, 33] ; 返回 ARGB 值。

; 使用像素搜索找到白色像素。
if xy := buf.PixelSearch(0xFFFFFF)
    MsgBox % xy[1] ", " xy[2]
else
    MsgBox % "再试一次，未找到白色像素！"
```

### ImagePutClipboard(image)

在 AutoHotkey v1 中返回空字符串，在 AutoHotkey v2 中返回 ClipboardAll() 对象。该图像被放置到系统剪贴板两次，一次作为支持透明度的 PNG 流，另一次作为底向上的 hBitmap。

```ahk
; 将文件保存在剪贴板。
ImagePutClipboard("cats.jpg")
```

### ImagePutCursor(image, xHotspot, yHotspot)

- xHotspot、yHotspot - 使用 x 和 y 坐标指定鼠标指针的“单击点”。默认值是图像的中心点。

返回 `"A_Cursor"`。将图像设置为新的鼠标指针。

> 警告！将鼠标指针设置为较大的图像可能会覆盖整个屏幕。

```ahk
; 将一个图像设置为鼠标指针。
ImagePutCursor("cats.jpg", 0, 0) ; 将单击点设置为左上角。
Sleep 20000
ImageDestroy(A_Cursor) ; 相当于：DllCall("SystemParametersInfo", "uint", 20, "uint", 0, "ptr", 0, "uint", 2)
```

### ImagePutDC(image, alpha)

- alpha - 可以指定 RGB 颜色作为透明像素的替换颜色。

返回 GDI 设备上下文句柄。

```ahk
; 使用预先选择的图像创建设备上下文。
hdc := ImagePutDC("cats.jpg")

; 用白色背景替换所有的透明像素。
hdc := ImagePutDC("cats.jpg", 0xFFFFFF)
```

### ImagePutDesktop(image)

返回 `"desktop"`。在桌面图标后面创建一个不可见的窗口，其中包含该图像。

> 警告！这种功能依赖于不受支持和未记录的特性。

```ahk
; 在桌面图标后面显示图像。
ImagePutDesktop("cats.jpg")
```

### ImagePutExplorer(image, default)

- default - 如果未指定，则为 `A_Desktop`。

返回图像的文件路径。将图像保存到用户最近打开的资源管理器窗口。如果找不到该窗口，则默认为默认参数或桌面。如果鼠标指针悬停在桌面上，文件将保存到桌面上。

```ahk
; 此函数适用于从 Figma 复制图像。
; 将剪贴板上的图像粘贴到已打开的资源管理器窗口中。
ImagePutExplorer(ClipboardAll)

; 如果没有打开资源管理器窗口，则将图像放置在用户的文档文件夹中。
ImagePutExplorer(ClipboardAll, A_MyDocuments)
```

### ImagePutFile(image，文件路径，quality)

- filepath - 输出文件路径。可以是文件名或文件夹。

   - 如果省略目录，则默认为当前工作目录。

   - 如果省略文件名，则默认为当前时间。

   - 如果省略扩展名，则默认情况下使用原始编码（如果可用），否则为PNG。

   - 使用以反斜杠结尾的名称，例如`D：\ Pictures \`来区分目录和文件。

   - 创建该路径下的所有文件夹。

   - 可以将输出目录与文件扩展名结合使用，例如 `D:\ Pictures\.gif` ，以将所有图像保存为GIF。

   - 文件名与扩展名匹配，例如“ D：\ Pictures \ gif ”，则假定为扩展名，并且输出文件路径将为“ D：\ Pictures \<Timestamp> .gif”。

   - 如果文件名为 `0` 或 `1` ，则图像将按自然数升序保存。

       - 除时间戳、0 和 1 之外的所有其他文件名都将覆盖同名现有文件。

  - 支持 Linux 风格的前斜杠。

- quality - 对于JPEG图像，表示编码质量的0-100的值。

返回文件路径。

```ahk
; 以其原始大小的5倍保存当前鼠标光标。
filepath := ImagePutFile({cursor: A_Cursor, scale: 5}, "cursor.png")
ImageShow(filepath)

; 使用当前时间戳创建文件。
ImagePutFile("cats.jpg")

; 将文件保存为GIF。
ImagePutFile("cats.jpg", ".gif") ; 或 "gif"

; 在目录中创建文件。
ImagePutFile("cats.jpg", "pics\") ; 必须以反斜杠结尾才能创建新目录。

; 在目录中将文件保存为GIF。
ImagePutFile("cats.jpg", "pics\.gif") ; 或 "pics\gif"

; 使用自然数序列从0或1开始创建文件。
ImagePutFile("cats.jpg", 0) ; 或 "1.gif"
```

### ImagePutHBitmap(image，alpha)

- alpha - 可以指定一个alpha颜色作为透明像素的替换颜色。

返回hBitmap句柄。

hBitmap的像素格式是预乘alpha RGB（pARGB）。因此，预乘ARGB和ARGB之间的任何转换都会引入舍入误差。结果是带有透明度的任何图像在视觉上看起来与原始图像完全相同，但不是像素完美的，导致 `ImageEqual` 失败。没有alpha通道的RGB图像不受影响。

```ahk
; 创建HBitmap。
hBitmap := ImagePutHBitmap("cats.jpg")

; 用白色背景替换任何alpha透明度。
hBitmap := ImagePutHBitmap("cats.jpg", 0xFFFFFF)

; 以下测试将失败，因为图像具有透明度。
hBitmap := ImagePutHBitmap("https://i.imgur.com/PBy1WBT.png")
MsgBox % ImageEqual(hBitmap, "https://i.imgur.com/PBy1WBT.png")
```

### ImagePutHex(image，extension，quality)

- extension - bmp、dib、rle、jpg、jpeg、jpe、jfif、gif、tif、tiff、png。 可以写作 `.gif` 或 `*.gif`。 如果可能，保留原始扩展名。 默认为PNG。
- quality - 对于JPEG图像，表示编码质量的0-100的值。

返回一个十六进制字符串。

```ahk
; 创建一个十六进制字符串。
hex := ImagePutHex("cats.jpg")
```

### ImagePutHIcon(image)

返回hIcon句柄。

```ahk
; 创建hIcon。
hIcon := ImagePutHIcon("cats.jpg")
```

### ImagePutRandomAccessStream(image, extension, quality)

- extension - bmp、dib、rle、jpg、jpeg、jpe、jfif、gif、tif、tiff、png。可以写成 `.gif` 或 `*.gif`。如果可能，会保留原始扩展名。默认为 TIFF 以提高速度。
- quality - 对于 JPEG 图像，表示编码质量的值，范围为 0-100。

返回一个随机访问流的接口指针。

```ahk
; 创建一个 IRandomAccessStream。
pRandomAccessStream := ImagePutRandomAccessStream("cats.jpg")
```

### ImagePutSafeArray(image, extension, quality)

- extension - bmp、dib、rle、jpg、jpeg、jpe、jfif、gif、tif、tiff、png。可以写成 `.gif` 或 `*.gif`。如果可能，会保留原始扩展名。默认为 PNG。
- quality - 对于 JPEG 图像，表示编码质量的值，范围为 0-100。

返回一个 SafeArray COM 对象。适用于将数据发送到 Web API。

```ahk
; 创建一个 SafeArray。
SafeArray := ImagePutSafeArray("cats.jpg")
```

### ImagePutScreenshot(image, alpha)

- alpha - 可以指定 alpha 颜色作为透明像素的替换颜色。

返回一个 `[x,y,w,h]` 数组。直接将图像复制到屏幕的设备上下文中。仅用于临时使用，因为该图像可能会被其他应用程序覆盖。

```ahk
; 将图像临时显示在屏幕上。
ImagePutScreenshot("cats.jpg")
```

### ImagePutStream(image, extension, quality)

- extension - bmp、dib、rle、jpg、jpeg、jpe、jfif、gif、tif、tiff、png。可以写成 `.gif` 或 `*.gif`。如果可能，会保留原始扩展名。默认为 TIFF 以提高速度。
- quality - 对于 JPEG 图像，表示编码质量的值，范围为 0-100。

返回一个流的接口指针。不要调用 `GlobalFree`，当引用计数达到零时，ObjRelease 将释放底层内存。

```ahk
; 创建一个 IStream。
pStream := ImagePutStream("cats.jpg")
```

### ImagePutURI(image, extension, quality)

- extension - bmp、dib、rle、jpg、jpeg、jpe、jfif、gif、tif、tiff、png。可以写成 `.gif` 或 `*.gif`。如果可能，会保留原始扩展名。默认为 PNG。
- quality - 对于 JPEG 图像，表示编码质量的值，范围为 0-100。

返回一个带有 URI 标头的 base64 字符串。与 ImagePutBase64 相同。可用于所有文件，而不仅限于图像。

```ahk
; 创建一个 URI base64 字符串。
URI := ImagePutURI("cats.jpg")
```

### ImagePutWallpaper(image)

返回 `"wallpaper"`。将图像设置为壁纸。您的桌面个性化设置决定图像的拉伸、填充、适应、居中、平铺或扩展。

```ahk
; 设置临时壁纸。
ImagePutWallpaper("cats.jpg")
```

### ImagePutWICBitmap(image)

返回一个指向 WICBitmap 接口的指针。

```ahk
; 创建一个 WICBitmap。
wicBitmap := ImagePutWICBitmap("cats.jpg")
```

### ImagePutWindow(image, title, pos, style, styleEx, parent){#ImagePutWindow}

- title - 在标题栏上显示的字符串。
- pos - 一个带有可选元素的 `[x,y,w,h]` 坐标数组描述初始窗口位置。
- style - 描述窗口样式的十六进制值。
- styleEx - 描述扩展窗口样式的十六进制值。
- parent - 父窗口的 hwnd。默认为 A_ScriptHwnd。

返回一个窗口句柄。在透明背景上的窗口中显示带有标题栏的图像，周围有一条细边框。通过拖动图像移动窗口。右键单击窗口可关闭。按比例缩放以适合主屏幕。

```ahk
; 显示图像。
ImagePutWindow("cats.jpg")
```

## 附加功能

### ImageShow(image, title, pos, style, styleEx, parent)

与 [ImagePutWindow](#ImagePutWindow) 功能相同，但该函数在没有标题栏和边框的情况下显示图像。

```ahk
ImageShow("cats.jpg")
```

### ImageWidth(image), ImageHeight(image)

```ahk
width := ImageWidth("cats.jpg")
height := ImageHeight("cats.jpg")
```

### ImageDestroy(image)

此函数可与上述任何函数的返回值一起使用，以清除任何影响。

```ahk
; Deletes the file.
filepath:= ImagePutFile("cats.jpg", "png")
ImageDestroy(filepath) ; Calls FileDelete

; Cleanup an hBitmap.
hBitmap := ImagePutHBitmap("cats.jpg")
ImageDestroy(hBitmap) ; Calls DeleteObject

; Release a stream.
pStream := ImagePutStream("cats.jpg")
ImageDestroy(pStream) ; Calls ObjRelease

; Restores the cursor.
cursor := ImagePutCursor("cats.jpg")
ImageDestroy(cursor)  ; Same as: DllCall("SystemParametersInfo", "uint", 20, "uint", 0, "ptr", 0, "uint", 2)
```

### ImageEqual(images*)

比较多个图像的像素数据。调用 ImageEqual 并传入一个参数将验证该图像。如果所有图像具有相同的像素值，则返回 True，或在到达第一个不同的图像时返回 False。

```ahk
; Ensure that cats.jpg contains valid pixel data.
ImageEqual("cats.jpg")

; Compares the cursor to a file.
ImageEqual(A_Cursor, "cats.jpg")

; Compares three things.
ImageEqual(A_Cursor, "cats.jpg", [0,0,100,100])
```

> 警告！当使用 ImageEqual 验证指针时，用户要确保它们是有效的！对于整数值而言，在 AutoHotkey v1 和 v2 中，范围为 0-4095 和 0-65535，超出此范围的值将引发关键错误。因此，使用 ImageEqual 检查有效的监视器编号是安全的。

> 注意：对于透明的 hBitmap，调用 ImageEqual 可能会返回 False。这是因为比较预乘 alpha 值会产生浮点精度误差。考虑 136/255 * 138 = 73.6。现在将 73.6 四舍五入为 74。从方程式 136/255 * x = 74 找到 x的值。x 的值为 138.75，并被四舍五入为 139。原来的值 138 是否等于 139？

