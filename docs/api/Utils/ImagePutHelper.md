---
title: ImagePutHelper
author: ruchuby
order: -1
date: 2023-04-14
---

::: warning
本文内容列举翻译API内容，仅供参考。
:::

具体使用请参考：

- [简单、高效、实用的图片操作库 - AutoAHK](https://www.autoahk.com/archives/37246)
- [ImagePut —— 裁剪、缩放 & 其他选项](../../dev/others/image-put-doc-1.md)
- [ImagePut —— 输入类型 & 输出函数](../../dev/others/image-put-doc-2.md)

## ImagePutBase64(image, extension := "", quality := "")

将图像转换为指定格式的文件并且返回一个Base64编码的字符串。

- 参数
    - \{Image\} `image`: 需要被转换的图像
    - \{String\} `extension`: 文件格式, 选项为: `bmp`, `gif`, `jpg`, `png`, `tiff`
    - \{String\} `quality`: `jpg`文件质量的等级，整数类型，0-100

- 返回值
    - \{String\} Base64编码的字符串

## ImagePutBitmap(image)

将图像转换为一个GDI+位图并且返回一个指针。

- 参数
    - \{Image\} `image`: 需要被转换的图像

- 返回值
    - \{Pointer\} GDI+位图的指针

## ImagePutBuffer(image)

将图像转换为一个GDI+位图并且返回一个包含GDI+作用域的缓冲区对象。

- 参数
    - \{Image\} `image`: 需要被转换的图像

- 返回值
    - \{BitmapBuffer\} 包含GDI+作用域的缓冲区对象

## ImagePutClipboard(image)

将图像复制到剪贴板并且返回剪贴板的所有内容。

- 参数
    - \{Image\} `image`: 需要被复制的图像

- 返回值
    - \{String\} 包含剪贴板的所有内容的字符串

## ImagePutCursor(image, xHotspot := "", yHotspot := "")

将图像设为光标并且返回变量A_Cursor。

- 参数
    - \{Image\} `image`: 需要被设为光标的图像
    - \{String\} `xHotspot`: X点击点，范围为0-width。
    - \{String\} `yHotspot`: Y点击点，范围为0-height。

- 返回值
    - \{Variable\} 变量A_Cursor

## ImagePutDC(image, alpha := "")

将图像放到设备上下文并且返回句柄。

- 参数
    - \{Image\} `image`: 需要被放到设备上下文的图像
    - \{String\} `alpha`: Alpha通道的颜色，RGB格式，例如 0xFFFFFF。

- 返回值
    - \{Handle\} 句柄

## ImagePutDesktop(image)

将图像放在桌面图标后面并且返回字符串"desktop"。

- 参数
    - \{Image\} `image`: 需要被放在桌面图标后面的图像

- 返回值
    - \{String\} "desktop"

## ImagePutExplorer(image, default := "")

将图像保存在最近活动的文件浏览器窗口中。

- 参数
    - \{Image\} `image`: 需要被保存最近活动的文件浏览器窗口中的图像
    - \{String\} `default`: 默认路径选项。

## ImagePutFile(image, filepath := "", quality := "")

将图像保存为文件并返回文件路径。

- 参数
    - \{Object\} `image`: 要保存的图像对象。
    - \{String\} `filepath`: 文件路径和扩展名，默认为空字符串 |  string   ->   *.bmp, *.gif, *.jpg, *.png, *.tiff
    - \{Number\} `quality`: JPEG 图像质量等级，默认为空字符串 |  integer  ->   0 - 100

- 返回值
    -  \{String\} 文件路径字符串。

## ImagePutFormData(image, boundary := "ImagePut-abcdef")

将图像以多部分表单数据的形式返回二进制 SafeArray COM 对象。

- 参数
    - \{Object\} `image`: 图像对象。
    - \{String\} `boundary`: 内容类型，默认为 "ImagePut-abcdef"。

- 返回值
    -  \{Object\} 返回图像的二进制 SafeArray COM 对象。

## ImagePutHBitmap(image, alpha := "")

将图像保存为设备无关位图，并返回句柄。

- 参数
    - \{Object\} `image`: 要保存的图像对象。
    - \{String\} `alpha`: 在 Alpha 通道中的颜色（rgb 值），默认为空字符串。 | RGB      ->   0xFFFFFF

- 返回值
    -  \{Number\} 设备无关位图处理后的句柄。

## ImagePutHex(image, extension := "", quality := "")

将图像保存为文件格式，并返回十六进制编码字符串。

- 参数
    - \{Object\} `image`: 要保存的图像对象。
    - \{String\} `extension`: 文件格式编码，默认为空字符串。 |  string   ->   bmp, gif, jpg, png, tiff
    - \{Number\} `quality`: JPEG 图像质量等级，默认为空字符串。 |  integer  ->   0 - 100

- 返回值
    -  \{String\} 十六进制编码字符串。

## ImagePutHIcon(image)

将图像处理为图标，并返回句柄。

- 参数
    - \{Object\} `image`: 要进行处理的图像对象。

- 返回值
    -  \{Number\} 图标处理成功后的句柄。

## ImagePutRandomAccessStream(image, extension := "", quality := "")

将图像保存为文件格式，并返回指向 RandomAccessStream 的指针。

- 参数
    - \{Object\} `image`: 要进行处理的图像对象。
    - \{String\} `extension`: 文件格式编码，默认为空字符串。 |  string   ->   bmp, gif, jpg, png, tiff
    - \{Number\} `quality`: JPEG 图像质量等级，默认为空字符串。 |  integer  ->   0 - 100

- 返回值
    -  \{Object\} RandomAccessStream 指针。

## ImagePutSafeArray(image, extension := "", quality := "")

将图像保存为文件格式，并返回 SafeArray COM 对象。

- 参数
    - \{Object\} `image`: 要进行处理的图像对象。
    - \{String\} `extension`: 文件格式编码，默认为空字符串。 |  string   ->   bmp, gif, jpg, png, tiff
    - \{Number\} `quality`: JPEG 图像质量等级，默认为空字符串。 |  integer  ->   0 - 100

- 返回值
    -  \{Object\} SafeArray COM 对象。

## ImagePutScreenshot(image, screenshot := "", alpha := "")

将图像放置在共享屏幕设备上，并返回坐标数组。

- 参数
    - \{Object\} `image`: 要进行处理的图像对象。
    - \{String\} `screenshot`: 屏幕坐标数组，默认为空字符串。 |  array    ->   [x,y,w,h] or [0,0]
    - \{String\} `alpha`: 在 Alpha 通道中的颜色（rgb 值），默认为空字符串。 | RGB      ->   0xFFFFFF

- 返回值
    -  \{Array\} 坐标数组。

## ImagePutStream(image, extension := "", quality := "")

将图像保存为文件格式，并返回指向 stream 的指针。

- 参数
    - \{Object\} `image`: 要进行处理的图像对象。
    - \{String\} `extension`: 文件格式编码，默认为空字符串。 |  string   ->   bmp, gif, jpg, png, tiff
    - \{Number\} `quality`: JPEG 图像质量等级，默认为空字符串。 |  integer  ->   0 - 100

- 返回值
    -  \{Object\} stream 指针。

## ImagePutURI(image, extension := "", quality := "")

将图像保存为文件格式，并返回 URI 字符串。

- 参数
    - \{Object\} `image`: 要进行处理的图像对象。
    - \{String\} `extension`: 文件格式编码，默认为空字符串。 |  string   ->   bmp, gif, jpg, png, tiff
    - \{Number\} `quality`: JPEG 图像质量等级，默认为空字符串。 |  integer  ->   0 - 100

- 返回值
    -  \{String\} URI 字符串。

## ImagePutWallpaper(image)

将图像作为桌面壁纸，并返回字符串 "wallpaper"。

- 参数
    - \{Object\} `image`: 要进行处理的图像对象。

- 返回值
    -  \{String\} "wallpaper" 字符串。

## ImagePutWICBitmap(image)

将图像处理为 WICBitmap，并返回接口指针。

- 参数
    - \{Object\} `image`: 要进行处理的图像对象。

- 返回值
    -  \{Object\} WICBitmap 接口指针。

## ImagePutWindow(image, title := "", pos := "", style := 0x82C80000, styleEx := 0x9, parent := "")

将图像放置在窗口中并返回窗口句柄。

- 参数
    - \{Object\} `image`: 要进行处理的图像对象。
    - \{String\} `title`: 窗口标题，默认为空字符串。
    - \{String\} `pos`: 窗口坐标数组，默认为空字符串。 |  array    ->   [x,y,w,h] or [0,0]
    - \{Number\} `style`: 窗口样式，默认为 0x82C80000。
    - \{Number\} `styleEx`: 窗口附加样式，默认为 0x9.
    - \{Object\} `parent`: 窗口父对象，默认为空字符串。

- 返回值
    -  \{Number\} 窗口句柄。

## ImageShow(image, title := "", pos := "", style := 0x90000000, styleEx := 0x80088, parent := "")

在窗口中显示图像，并返回窗口句柄。

- 参数
    - \{Object\} `image`: 要进行处理的图像对象。
    - \{String\} `title`: 窗口标题，默认为空字符串。
    - \{String\} `pos`: 窗口坐标数组，默认为空字符串。 |  array    ->   [x,y,w,h] or [0,0]
    - \{Number\} `style`: 窗口样式，默认为 0x90000000。
    - \{Number\} `styleEx`: 窗口附加样式，默认为 0x80088.
    - \{Object\} `parent`: 窗口父对象，默认为空字符串。

- 返回值
    -  \{Number\} 窗口句柄。

## ImageDestroy(image)

销毁图像对象。

- 参数
    - \{Object\} `image`: 要进行销毁的图像对象。

- 返回值
    - 无返回值。

## ImageWidth(image)

获取图像的宽度。

- 参数
    - \{Object\} `image`: 要获取宽度的图像对象。

- 返回值
    -  \{Number\} 图像的宽度。

## ImageHeight(image)

获取图像的高度。

- 参数
    - \{Object\} `image`: 要获取高度的图像对象。

- 返回值
    -  \{Number\} 图像的高度。