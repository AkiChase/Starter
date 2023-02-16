; #Include ..\utils\WinHttp.ah2
; #Include ..\utils\JXON.ah2
; #Include ..\utils\DataHelper.ah2
; #Include ..\utils\GlobalData.ah2

; GlobalData.init()
; if (res := IntelligentEditGui.getFavicon("https://www.baidu.com/s?word=ces")) {
;     if (IntelligentEditGui.DownloadFavicon("百度搜索", res))
;         MsgBox("成功")
;     else
;         MsgBox("失败")
; } else {
;     MsgBox("获取链接失败")
; }

class IntelligentEditGui {


    ; 下载图标
    static DownloadFavicon(title, favicon) {
        filePath := Format("{}\{}.ico", GlobalData.customImgDir, title)
        WinHttp().Download(favicon, , , , filePath)
        return filePath
    }

    ; 获取图标
    static getFavicon(url) {
        if (!RegExMatch(url, "^(https?:\/{2})?([.a-z]*)", &out))    ; 正则提取domain
            return false

        s := WinHttp()
        res := s.Download(Format("https://favicongrabber.com/api/grab/{}", out[2]))
        if (s.StatusCode != 200)
            return false
        res_json := Jxon_Load(&res)

        if (!res_json["icons"].Length)
            return false

        for item in res_json["icons"]
            if (item.Has("type") and item["type"] = "image/x-icon")    ; 只要image/x-icon类型的
                return item["src"]
        return false
    }
}