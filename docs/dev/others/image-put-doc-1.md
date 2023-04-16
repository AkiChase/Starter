---
title: ImagePut —— 裁剪、缩放 & 其他选项
icon: image
author: ruchuby
date: 2023-04-16
---

:::warning
本文仅仅翻译[Crop, Scale, & Other Flags · iseahound/ImagePut Wiki (github.com)](https://github.com/iseahound/ImagePut/wiki/Crop,-Scale,-&-Other-Flags)，可能存在不准确的地方，仅供参考，请以原 wiki 文档为准。
:::

# 剪裁、缩放和其他标志

### 用法

指定为对象键以覆盖所有可能的输入。`image`

```
ImagePutWindow({image: "cats.jpg", scale: 2})
```

或使用 [特定的数据类型](./image-put-doc-2.md#输入类型)，例如：`file`

```
ImagePutWindow({file: "cats.jpg", scale: 2})
```

### 剪裁 Crop

传递一个 [x、y、w、h] 数组。所有四个成员都是必需的。

```
; 剪裁到从 (100, 100) 处开始的 250 x 250 像素的图像。
ImagePutWindow({image: "cats.jpg", crop: [100, 100, 250, 250]})
```

任何负值都会被解释为“从边缘开始”。宽度和高度分别对应右边和下边。

```
; 从每个边缘裁剪 10 像素。
ImagePutWindow({image: "cats.jpg", crop: [-10, -10, -10, -10]})
```

如果这些值中有任何一个是百分比，它们应该作为字符串输入。

```
; 从每个边缘裁剪 10%。
ImagePutWindow({image: "cats.jpg", crop: ["-10%", "-10%", "-10%", "-10%"]})
```

指定的剪裁数组比原始文件大不会发生什么。将忽略超出边界的值。

### 缩放 Scale

传递一个正实数。缩放算法使用 GDI+ HighQualityBicubic。

```
; 缩放倍数为2.5倍。
ImagePutWindow({image: "cats.jpg", scale: 2.5})
```

要缩放到特定的宽度和高度，请使用 2 成员数组。宽度和高度必须是整数值。

```
; 调整大小为640 x 480。
ImagePutWindow({image: "cats.jpg", scale: [640, 480]})
```

要计算缺失的边，请使用大小数组，并将参数替换为任何字符串。这将保持原始纵横比。

```
; 缩放高度为480像素。
ImagePutWindow({image: "cats.jpg", scale: ["", 480]})
ImagePutWindow({image: "cats.jpg", scale: ["auto", 480]}) ; 更易于理解。
```

### 解码 Decode

当设置为 true 时，禁用快速流转换。影响：pdf、url、file、stream、randomaccessstream、base64 和 hex。默认值为 false。

启用此标志将删除原始文件编码，包括原始文件格式的任何压缩增益。这可能有助于验证像素数据的内容，否则将保持未检查状态。会降低转换速度。

```
; 图像将解码为像素数据并重新编码为 PNG。
str := ImagePutBase64({image: "cats.jpg", decode: True})

; 设置全局解码标志。
ImagePut.decode := True ; 默认值为 false。
```

### 验证 Validate

立即通过将位图加载到内存中检查像素数据。将来，这可能会检查流数据的标头。

如果调用：`ImagePutBitmap`

- 如果启用，则对位图调用：`GdipValidateImage`。
- 强制将图像加载到内存中。（糟糕：增加了峰值内存使用量。）
- 避免返回对图像数据的引用。（好：防止多个引用导致数据竞争。）
- 避免通过读取时复制或写入时复制实现延迟渲染。（好：立即加载图像数据可防止将意外修改复制。）
- 附带的一项副作用是立即将图像加载到内存中，意味着对原始图像数据的任何修改都不会被复制过来。
- 修复了一种罕见的错误，即位图克隆的位图克隆（2 层引用）在从流中解码图像时可能会导致数据竞争。
- 当返回 GDI+ 位图时，建议将此标志设置为 true，因为在位图的立即创建之后的任何时候调用都会导致秘密失败。`validate``GdipValidateImage``GdipValidateImage`

默认值为 false，这意味着在需要时拉取像素数据，以节省内存并加快速度。除非满足上述条件，否则不需要将此标志设置为 true。

```
; 立即将 cats.jpg 加载到内存中。
pBitmap := ImagePutBitmap({image: "cats.jpg", validate: true})

; 设置全局验证标志。
ImagePut.validate := True ; 默认值为 false。
```
