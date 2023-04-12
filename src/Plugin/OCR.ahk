/**
 * @Name: OCR
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-12
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

        g.AddGroupBox("x10 y10 w400 h500", "图片")
        this.gPic := g.AddPicture("x15 y40 w380 h460")
        this.gPic.OnEvent("Click", (*) => this.curImg ? ImagePutWindow(this.curImg, "查看图像") : 0)

        this.gResEdit := g.AddEdit("x420 y20 w370 h350")

        addRadio(i, text) {
            r := g.AddRadio(Format("x450 y{} {}", 355 + 30 * i, i = this.sepIndex ? "Checked" : ""), text)
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

        g.AddCheckbox("x450 yp+27 " . (this.autoCopy ? "Checked" : ""), "自动复制").OnEvent("Click",
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
            if (DllCall("OpenClipboard", "ptr", 0) && DllCall("IsClipboardFormatAvailable", "uint", 2)) {
                DllCall("CloseClipboard")
                this.curImg := ImagePutBuffer(ClipboardAll())
                this.gPic.Value := "hBitmap:" PluginHelper.Utils.ImagePutHelper.ImagePutHBitmap(this.curImg)
                if (this.ocr(this.curImg)) {
                    this.gResEdit.Value := this.join(this.sepIndexToSep[this.sepIndex], this.ocrRes*)
                    if (this.autoCopy)
                        A_Clipboard := this.gResEdit.Value
                }
            } else {
                DllCall("CloseClipboard")
                PluginHelper.Utils.tip(this.name, "当前剪切板内容无法导入", 2000)
            }
        }

        g.SetFont("s12")
        g.AddButton("x600 y380 w120 h25", "重新识别").OnEvent("Click", run)
        b := g.AddButton("xp yp+30 w120 h25 default", "剪切板导入")
        b.OnEvent("Click", importFromClipboard)
        b.Focus()
        g.AddButton("xp yp+30 w120 h25", "复制文本").OnEvent("Click", (*) => A_Clipboard := this.gResEdit.Value)
        g.AddButton("xp yp+30 w120 h25", "复制并退出").OnEvent("Click", (*) => (A_Clipboard := this.gResEdit.Text, g.Hide()))
        g.OnEvent("Close", (*) => g.Hide())

        dropHandler(guiObj, ctrl, fileList, *) {
            if (fileList.Length == 1) {
                try
                    this.gPic.Value := fileList[1]
                catch {
                    PluginHelper.Utils.tip(this.name, "不支持当前文件格式！", 2000)
                    return
                }
                this.curImg := fileList[1]
                if (this.ocr(this.curImg)) {
                    this.gResEdit.Value := this.join(this.sepIndexToSep[this.sepIndex], this.ocrRes*)
                    if (this.autoCopy)
                        A_Clipboard := this.gResEdit.Value
                }
            }
        }
        g.OnEvent("DropFiles", dropHandler)
        g.Show("w800 Hide")
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
            "OCR识别文字",
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
            this.accessToken := this.genAccessToken()

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

        g.AddText(, "连接方式:`t" . ["空格连接", "换行连接", "直接连接"][this.sepIndex])

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
        dataPath := dir "\OCR配置.txt"
        f := FileOpen(dataPath, "w")
        f.Write(Jxon_Dump(Map("id", this.apiKey.id, "secret", this.apiKey.secret, "accessToken", this.accessToken)))
        f.Close()
    }

    ; 加载数据
    static loadData() {
        SplitPath(A_LineFile, , &dir)
        dataPath := dir "\OCR配置.txt"
        if (FileExist(dataPath)) {
            content := FileRead(dataPath)
            config := Jxon_Load(&content)
            this.apiKey.id := config["id"]
            this.apiKey.secret := config["secret"]
            this.accessToken := config["accessToken"]
        }
    }

    ; 对base64内容进行ocr识别
    static baiduOcr(base64) {
        url := Format("{}rest/2.0/ocr/v1/general_basic?access_token={}", this.baseUrl, this.accessToken)
        return this.post(url, "image=" UrlEncode(base64), "application/x-www-form-urlencoded")
    }

    ; 生成access_token
    static genAccessToken() {
        url := Format("{}oauth/2.0/token?grant_type=client_credentials&client_id={}&client_secret={}",
            this.baseUrl, this.apiKey.id, this.apiKey.secret)
        if (res := this.post(url))
            return res["access_token"]
        return 0
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
            if (res.Has("error_description"))
                PluginHelper.Utils.tip(this.name, res["error_description"] "`n请重试或检查插件设置")
            else if (res.Has("error_msg"))
                PluginHelper.Utils.tip(this.name, res["error_msg"] "`n请重试或检查插件设置")

            return res
        } catch Error as e {
            if (this.clicent.Error.Has("Message"))
                PluginHelper.Utils.tip(this.name, this.clicent.Error["Message"] "`n请重试或检查插件设置")
        }
        return 0
    }
}