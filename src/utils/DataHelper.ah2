class DataHelper {
    static Join(sep, arr) {
        for item in arr
            str .= item . sep
        return SubStr(str, 1, -StrLen(sep))
    }

    ;加载数据
    static loadData(path) {
        out := []
        Loop read, path    ;不使用StrSplit
        {
            if (StrLen(A_LoopReadLine))
                out.Push(StrSplit(A_LoopReadLine, "¢"))
        }
        return out
    }

    ;保存数据到文件
    static storeData(data, path) {
        content := ""
        for item in data {
            row := this.Join("¢", item)
            content .= row "`n"
        }
        f := FileOpen(path, "w", "UTF-8-RAW")
        f.Write(SubStr(content, 1, -1))
        f.Close()
    }

    static loadJSON(path) {
        json := FileRead(path)
        return Jxon_Load(&json)
    }

    static storeJSON(json, path) {
        f := FileOpen(path, "w")
        f.Write(Jxon_Dump(json, 2))
        f.Close()
    }
}