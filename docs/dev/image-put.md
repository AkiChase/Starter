---
title: ImagePut
icon: image
author: ruchuby
date: 2023-04-14
---

> ImagePut 是 iseahound 写的一个图片操作库，大部分常见图片操作都可以用极为简单的方式实现。

- [简单、高效、实用的图片操作库 —— ImagePut 轻松实现截图、转换、缩放、裁剪等各种功能 - AutoAHK](https://www.autoahk.com/archives/37246)
- [ImagePut —— 裁剪、缩放 & 其他选项](./others/image-put-doc-1.md)
- [ImagePut —— 输入类型 & 输出函数](./others/image-put-doc-2.md)

**Starter** 也引入了这个强大的图片操作库，并将其主要API访问方式添加到了 `PluginHelper.Utils.ImagePutHelper` 工具类中，参考[ImagePutHelper](../api/utils/ImagePutHelper.md)

可以通过这个工具类调用 `ImagePut`，完成你需要的图片相关操作。

在此给出[OCR识别文字](../plugin/ocr.md)插件中的部分代码作为示例：

```ahk {14,15}
; ocr识别 image为ImagePut类型
static ocr(image) {
    oldTitle := this.gui.Title
    this.gui.Title := "正在进行文字识别..."
    ; accessToken是否过期判断
    if (!this.accessToken)
        if (this.accessToken := this.genAccessToken()) {
            this.storeData()
        } else {
            this.gui.Title := oldTitle
            return
        }

    ; 使用 ImagePutURI 将图片直接转化为 base64 用于上传图片
    base64 := PluginHelper.Utils.ImagePutHelper.ImagePutURI(image, "jpg", 100)

    if (res := this.baiduOcr(base64)) {
        out := []
        ; 根据模式选择拼接方式 目前使用换行符拼接
        for words in res["words_result"]
            out.Push(words["words"])
        this.ocrRes := out
        this.gui.Title := oldTitle
        return true
    }
    this.gui.Title := oldTitle
    return false
}
```



