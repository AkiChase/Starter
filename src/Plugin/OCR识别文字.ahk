/**
 * @Name: OCR识别文字
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-13
 * @Description: OCR识别文字
 */

/*
===Starter Plugin Info==>
{
    "author": "ruchuby",
    "version": "0.0.1",
    "introduction": "OCR识别文字",
    "icon": "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAoZJREFUWEftl0toE1EUhv8ziS1oSWYmIraCgiCCC10pCPUJahF02QZxIyKCQsGN0naCqZmIgrpRELpwa6s7XWhFUbEL0ZWKO0HF4gObO5NAwUc6R+YmU5JY5lES6CJ3k9y55/Hxz8nJubTjwAAjYDHRnqmH48+C7GrPe/f3Z4nofJAPLRmAF5MTFETbrPPevvRuYn7qxptXoA3QViCqAto5sZaXza2Xhcl/P9r5ns9hi7QpRaga4gaA07KSmcesfOrkogBcGtcxaqNRDVHXwDp//en6cWX1bBgIL6eED+PQaKMahTMAXat7TmzauVQmarxFAohpAGsakjm2qcdaDqCNiENMuFdNNE3gWQZtrOxp0Da161EgIiugGuI5gJ2VJDwKRglEV+UO+F409e6WAehDhU1OjN57CeJOZ09Xx3LLLlvfAKiVXwSOWHn9dliISAqoRuEWQMdkIqK7Vk7rd79rGXGZGWerSd/apr6l+QBZ7lDL1m8vMDk4aF3UH7j7lcM/u8tK7Kt35iixvtKF5GQYiNAKaMbMCEMxq0HfAXOD9QniRwE+Xi3Gx7ap7WsqgGqITwDWhQnq2jgU21bKJV8H2YdSIJERaYURurBkjYAnLDOVbgqAahSeALS3GixoNpStXapQLm8oXVr1wQ8iUIFEZmarwsqrsEE1Q4wzMFDtCzeLpn7KF8CdXl2DqUd35Gfj0gwxxsAJ+Zzovp3TDvsF1IbFZlbwZh44HkuVsklR6yP/jBxnl4zoTcULzQOJ7BddKa8oeM4K83aRT70Meq+1r4yBfNHUjUaA9lDaVmDpKeBeQP2qO+rMWDv3LRT3PwX8krf6diwviQEAo5EVqFzP3Wbju/4ByLREuNknZDkAAAAASUVORK5CYII="
}
<==Starter Plugin Info===
*/

#Include ..\Utils\PluginHelper.ah2
PluginHelper.addEntryFunc((*) => Pligin_OCR.main()) ; 添加入口函数等待执行

class Pligin_OCR {
    static clicent := PluginHelper.Utils.WinHttp()
    static baseUrl := "https://aip.baidubce.com/"
    static accessToken := ""
    static apiKey := {
        id: "",
        secret: ""
    }
    static sepIndex := 1
    static autoCopy := 0
    static sepIndexToSep := [A_Space, "`n", ""]
    static menu := Menu()

    static curImg := 0
    static ocrRes := []

    static main() {
        SplitPath(A_LineFile, &name) ; 获取插件id即文件名
        this.name := name

        this.menu.Add("显示", (*) => this.showGui())
        this.menu.Add("设置", (*) => this.setting())
        PluginHelper.pluginMenu.Add("OCR识别文字", this.menu)

        this.loadData()
        this.addToSearchGui()

        this.guiInit()
    }

    static guiInit() {
        this.gui := g := Gui(, "OCR识别文字")
        g.BackColor := "FFFFFF"
        g.SetFont("s14 q5 c333333", "NSimSun")
        g.SetFont(, "雅痞-简")    ;优先使用更好看的字体

        g.AddGroupBox("x10 y10 w400 h500", "粘贴、选择、拖入图片")
        this.gPic := g.AddPicture("x15 y40 w380 h460")

        chooseFile(*) {
            res := FileSelect("3", , "请选择进行图片识别的文件")
            if (res)
                this.ocrFromFile(res)
        }
        this.gPic.OnEvent("Click", chooseFile)

        this.gResEdit := g.AddEdit("x420 y20 w370 h300")

        addRadio(i, text) {
            r := g.AddRadio(Format("x450 y{} {}", 325 + 30 * i, i = this.sepIndex ? "Checked" : ""), text)
            r.OnEvent(
                "Click",
                (*) => (
                    this.gResEdit.Value := this.join(this.sepIndexToSep[i], this.ocrRes*),
                    this.sepIndex := i,
                    A_Clipboard := this.gResEdit.Value
                )
            )
        }
        for i, v in ["空格连接", "换行连接", "直接连接"] {
            addRadio(i, v)
        }

        g.AddCheckbox("x450 yp+30 " . (this.autoCopy ? "Checked" : ""), "自动复制").OnEvent("Click",
            (c, *) => this.autoCopy := c.Value)

        run(*) {
            if (this.curImg) {
                if (this.ocr(this.curImg)) {
                    this.gResEdit.Value := this.join(this.sepIndexToSep[this.sepIndex], this.ocrRes*)
                    if (this.autoCopy)
                        A_Clipboard := this.gResEdit.Value
                }
            } else
                PluginHelper.Utils.tip(this.name, "请拖入或导入剪切板图片！", 2000)
        }

        importFromClipboard(*) {
            if (DllCall("IsClipboardFormatAvailable", "uint", 2)) {
                ; 位图
                this.curImg := PluginHelper.Utils.ImagePutHelper.ImagePutBuffer(ClipboardAll())
                this.gPic.Value := "hBitmap:" PluginHelper.Utils.ImagePutHelper.ImagePutHBitmap(this.curImg)
                if (this.ocr(this.curImg)) {
                    this.gResEdit.Value := this.join(this.sepIndexToSep[this.sepIndex], this.ocrRes*)
                    if (this.autoCopy)
                        A_Clipboard := this.gResEdit.Value
                }
            } else if (DllCall("IsClipboardFormatAvailable", "uint", 15) && !InStr(A_Clipboard, "`r`n")) {
                ; 单个文件
                this.ocrFromFile(A_Clipboard)
            } else
                Send("^v")
        }

        HotIfWinActive("ahk_id " this.gui.Hwnd)
        Hotkey("$^v", importFromClipboard)
        HotIf()


        g.SetFont("s12")
        g.AddButton("x600 y350 w120 h25", "重新识别").OnEvent("Click", run)
        g.AddButton("xp yp+30 w120 h25", "复制文本").OnEvent("Click", (*) => A_Clipboard := this.gResEdit.Value)
        g.AddButton("xp yp+30 w120 h25", "复制并退出").OnEvent("Click", (*) => (A_Clipboard := this.gResEdit.Text, g.Hide()))
        g.AddButton("xp yp+30 w120 h25", "设置界面").OnEvent("Click", (*) => this.setting())
        g.OnEvent("Close", (*) => g.Hide())

        dropHandler(guiObj, ctrl, fileList, *) {
            if (fileList.Length == 1) {
                this.ocrFromFile(fileList[1])
            }
        }
        g.OnEvent("DropFiles", dropHandler)
        g.Show("w800 Hide")
    }

    ; 根据文件进行ocr识别
    static ocrFromFile(filePath) {
        try {
            this.curImg := PluginHelper.Utils.ImagePutHelper.ImagePutBuffer(filePath)
            this.gPic.Value := "hBitmap:" PluginHelper.Utils.ImagePutHelper.ImagePutHBitmap(this.curImg)
            if (this.ocr(this.curImg)) {
                this.gResEdit.Value := this.join(this.sepIndexToSep[this.sepIndex], this.ocrRes*)
                if (this.autoCopy)
                    A_Clipboard := this.gResEdit.Value
            }
        } catch {
            PluginHelper.Utils.tip(this.name, "不支持当前文件格式！", 2000)
            return
        }
    }

    static showGui(image?) {
        if (IsSet(image)) {
            this.curImg := image
            this.gPic.Value := "hBitmap:" PluginHelper.Utils.ImagePutHelper.ImagePutHBitmap(this.curImg)
            if (this.ocr(this.curImg)) {
                this.gResEdit.Value := this.join(this.sepIndexToSep[this.sepIndex], this.ocrRes*)
                if (this.autoCopy)
                    A_Clipboard := this.gResEdit.Value
            }
        }
        this.gui.Show()
    }

    static addToSearchGui() {
        matchHandler(obj, searchText, pastedContentType, pastedContent, *) {
            if (pastedContentType == "bitmap") {
                obj.buf := pastedContent
                return (PluginHelper.Utils.strStartWith("OCR识别文字", searchText)
                    || PluginHelper.Utils.strStartWith("OCRSBWZ", searchText)) ? 2 : 1
            }
            return 0
        }

        PluginHelper.addPluginToIntelligentMode(
            this.name,
            "OCR识别当前图片",
            matchHandler,
            (obj, searchText) => (this.showGui(obj.buf), PluginHelper.hideSearchGui())
            , , PluginHelper.getPluginHIcon(this.name)
        )

        PluginHelper.addPluginToStartupMode(
            this.name,
            "OCR识别文字",
            ["OCR识别文字", "OCRSBWZ"],
            (obj, searchText) => (this.showGui(), PluginHelper.hideSearchGui())
            , , , PluginHelper.getPluginHIcon(this.name)
        )
    }

    ; ocr识别 image为ImagePut类型
    static ocr(image) {
        oldTitle := this.gui.Title
        this.gui.Title := "正在进行文字识别..."
        if (!this.accessToken)
            if (this.accessToken := this.genAccessToken()) {
                this.storeData()
            } else {
                this.gui.Title := oldTitle
                return
            }

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

    static join(sep, params*) {
        if (params.Length) {
            for index, param in params
                str .= param . sep
            return StrLen(sep) ? SubStr(str, 1, -StrLen(sep)) : str
        }
        return ""
    }

    ; 设置界面
    static setting() {
        g := Gui(, "OCR设置")
        g.BackColor := "FFFFFF"
        g.SetFont("s14 q5 c333333", "NSimSun")
        g.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        g.AddText(, "百度OCR API ID")
        idEdit := g.AddEdit("w300 h30", this.apiKey.id)
        g.AddText(, "百度OCR SECRET")
        secretEdit := g.AddEdit("w300 h30", this.apiKey.secret)
        g.AddText(, "其他选项 ↓ ")
        g.AddText(, "● " . ["空格连接", "换行连接", "直接连接"][this.sepIndex])
        if (this.autoCopy)
            g.AddText(, "● 自动复制")

        f(*) {
            this.apiKey.id := idEdit.Value, this.apiKey.secret := secretEdit.Value
            this.storeData()
            g.Hide()
        }
        g.AddButton("x135 yp+50", "保存").OnEvent("Click", f)
        g.OnEvent("Close", (*) => g.Hide())
        g.Show()
    }

    ; 保存数据
    static storeData() {
        SplitPath(A_LineFile, , &dir)
        dataPath := dir "\OCR识别文字配置.txt"
        f := FileOpen(dataPath, "w")
        f.Write(Jxon_Dump(Map("id", this.apiKey.id, "secret", this.apiKey.secret,
            "accessToken", this.accessToken, "autoCopy", this.autoCopy, "sepIndex", this.sepIndex)))
        f.Close()
    }

    ; 加载数据
    static loadData() {
        SplitPath(A_LineFile, , &dir)
        dataPath := dir "\OCR识别文字配置.txt"
        if (FileExist(dataPath)) {
            content := FileRead(dataPath)
            config := Jxon_Load(&content)
            if (Type(config) == "Map") {
                this.apiKey.id := config.Has("id") ? config["id"] : ""
                this.apiKey.secret := config.Has("secret") ? config["secret"] : ""
                this.accessToken := config.Has("accessToken") ? config["accessToken"] : ""
                this.autoCopy := config.Has("autoCopy") ? config["autoCopy"] : 1
                this.sepIndex := config.Has("sepIndex") ? config["sepIndex"] : 1
            }
        }
    }

    ; 对base64内容进行ocr识别
    static baiduOcr(base64) {
        url := Format("{}rest/2.0/ocr/v1/general_basic?access_token={}", this.baseUrl, this.accessToken)
        return this.post(url, "image=" UrlEncode(base64), "application/x-www-form-urlencoded")
    }

    ; 生成access_token
    static genAccessToken() {
        if !(this.apiKey.id || this.apiKey.secret) {
            PluginHelper.Utils.tip(this.name, "请进入设置界面填写百度OCR接口密钥")
            return ""
        }
        url := Format("{}oauth/2.0/token?grant_type=client_credentials&client_id={}&client_secret={}",
            this.baseUrl, this.apiKey.id, this.apiKey.secret)
        if (res := this.post(url))
            return res["access_token"]
        return ""
    }
    ; post请求
    static post(url, data?, contentType := "application/json") {
        try {
            opt := "Method:POST`nTimeout:10`nCharset:UTF-8"
            headers := "Content-Type: " contentType "`nAccept: application/json"
            res := this.clicent.Download(url, opt, headers, data?)
            if (!res := Jxon_Load(&res))
                return 0
            ; 请求错误
            if (res.Has("error_description")) {
                ; 生成access_token失败
                PluginHelper.Utils.tip(this.name, res["error_description"] "`n生成access_token失败`n请重试或检查插件设置")
                return 0
            } else if (res.Has("error_code") && (res["error_code"] = 110 || res["error_code"] = 111)) {
                ; access_token非法或者过期
                if (this.accessToken := this.genAccessToken()) { ; 重新生成access_token
                    this.storeData()
                    ; 使用新access_token的url
                    url := Format("{}rest/2.0/ocr/v1/general_basic?access_token={}", this.baseUrl, this.accessToken)
                    return this.post(url, data, contentType) ; 重新提交ocr请求
                }
                return 0
            } else if (res.Has("error_msg")) {
                ; OCR接口调用失败
                PluginHelper.Utils.tip(this.name, res["error_msg"] "`n请重试或检查插件设置")
                return 0
            }
            return res
        } catch Error as e {
            if (this.clicent.Error.Has("Message"))
                PluginHelper.Utils.tip(this.name, this.clicent.Error["Message"] "`n请重试或检查插件设置")
            else
                PluginHelper.Utils.tip(this.name, "未知错误")
        }
        return 0
    }
}