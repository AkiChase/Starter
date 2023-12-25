/**
 * @Name: 文件搜索
 * @Version: 0.1.2
 * @Author: AkiChase
 * @LastEditors: AkiChase
 * @LastEditTime: 2023-05-11
 * @Description: 调用Everything进行文件搜索
 */

/*
===Starter Plugin Info==>
{
    "author": "AkiChase",
    "version": "0.1.2",
    "introduction": "调用Everything进行文件搜索",
    "icon": "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAACXBIWXMAAAsSAAALEgHS3X78AAAE60lEQVRYhb2W628UVRjGf+fszG67oReE1lBJW26FBkovKxIDIgZvNJCoCX41IZEYEqipIcaELySKklRLxBRDSPwDNFE0BmnUFLBNrSyuy8UCUkqBVMvSQlnc3bmc8cN06W7L7rYIPF8m875n5nnmPc953xH8D2wD34IAK6SkWjjMBnAchh2b3v4QPa0Qy/UOcT/ErQFWah6aNa9vo2Ml8u+5SOoJ2zQPK5O9TSGOPhABu5cwq7iQ/Ug2eTVYOAcqSmBWAfh97ppYAm5EYeA6/DUIcRNsm+9vKd7cGWTwvgW01lKne/lO15lbNw/q54GuZX/GsiF8GYIXwTAZsg1ebQrRNW0BH9dR6/NytCCfosYAzC6cqmwXI1E4fBJGovxrG7yQKiKngN1LmFVYQKjAz9zXnoYZedMjTyJmwNfdMBIlcnOEup0XuAaQo4hQXMh+6WHu+obJ5HHDLfGlf+DmHTdW5IeKUqitHPcFQL4XGgPwZRezi4v5AngRwJONvDXASk2jtWEBVJWl5/qH4FAPDERQd+J02jZf2Q6dsQSJv2+K8rNXkIX5rkGTyPOCJuHqMAueL6X7yCAXs1ZA89Ds1VzDTST/4SRYit/icTbvCHM6Nb+nzlnkOBz8Mcwah3Txyyog1A+2TTNwRGYi3wY+ARsXzkl3e9yAn8JgK0709fDsRHKAd0NcOGXzvLLp6DgN0fh4ziNhcRkIKda11TAzo4CxDpdfUZIeD1+GuIlK2GzO1ukOBDFjCTZbaEaoLz1XXgJSOB5DZ1VGAVJSDel7CK7hHEXXO0FOZXo2iR1hLjmW1X5pKD2efKeUVGcUkOztqU4G1+2OQ08u8iSUQ080DqY9HvPp7lYA/owCnGw9QqCmKkAwttaZFAcgowAcboDb21NR5AcBgSkLEAT8vnQjGxZYCjRBPHMFbHrBHSypqCwFIcWaluVU5SJ/fxFPSN27vrI0PT58272ait6MAvpD9CD1xMD19PjySvBqjifPx8EtAfQs/LKomANSGXkT+8hABJSDGobOjAJaIWab5uELg+5US8Lvg7VLQXp4pkZy5MNaKic+u2cxZftW8K3HQ+Pqaij0j+eUgnPXAMWxXUEiWTuhUnyaMHklfBka5o/HF5W5nuo4zXOFunbus6esduXQI0AJQUDq3vVSGXmrq2Fpefo7/7zqNiZbsRdyDCMhqQGIjE7OVZVB2WPwe5/l7R9iQzTOhmSFKksM6uenfznAaAy6z4Nt80tTkEOQ5ajtC/AWHtrmP454qf7uuc0I0waczD8pCRO++RUio9ySMRq2nqIPMlRguuQAepa5ejvm/pBERjEsm01vj5HDPSqQjdxxoOsczPC5Uy2XMKXcPe8+D3GDW7bN601B2lPXpAnIRX78LJy54t77fe5UKx/7KfWNHUjDcs/5QMR1ezTu7rknzhtbU758koCpkls2LSg6hGS7kGKdFI4H3PUCt8OBe85RHLMVe5OGuxcEQNtKtiiHz+flILctPtp2gveSubYaZho6q6SkWgh3eHlg2FT0DkPnriCRTMR3BbQspyrfL89UlihtOuQPClL30ihQ2tplj54cQErhTkSRYsdHRQ4g4wnalYM6ftZ1sGnD0TOPhhzGTLhvBc0IWnSPe68csCw+2H6CnQ+T/K4AgE/qeVLTeBkQlsHPzX/Q+bDJAf4DkxsIASilfOoAAAAASUVORK5CYII="
}
<==Starter Plugin Info===
*/


#Include ..\Utils\PluginHelper.ah2
#Include .\Everything\Everything.ahk


PluginHelper.addEntryFunc((*) => Plugin_文件搜索.main()) ; 添加入口函数等待执行

class Plugin_文件搜索 {
    static sortM := Menu(), cotM := Menu(), menu := Menu()
    static pageSize := 15

    static _sortModeList := [
        Everything.CONSTANT_SETSORT.EVERYTHING_SORT_PATH_ASCENDING,
        Everything.CONSTANT_SETSORT.EVERYTHING_SORT_PATH_DESCENDING,
        Everything.CONSTANT_SETSORT.EVERYTHING_SORT_NAME_ASCENDING,
        Everything.CONSTANT_SETSORT.EVERYTHING_SORT_NAME_DESCENDING,
        Everything.CONSTANT_SETSORT.EVERYTHING_SORT_SIZE_ASCENDING,
        Everything.CONSTANT_SETSORT.EVERYTHING_SORT_SIZE_DESCENDING,
        Everything.CONSTANT_SETSORT.EVERYTHING_SORT_DATE_MODIFIED_ASCENDING,
        Everything.CONSTANT_SETSORT.EVERYTHING_SORT_DATE_MODIFIED_DESCENDING
    ]
    static _sortMode := Everything.CONSTANT_SETSORT.EVERYTHING_SORT_PATH_ASCENDING
    static sortMode {
        get => this._sortMode
        set {
            i := this._arrayFind(this._sortModeList, this._sortMode)
            this.sortM.Uncheck(i "&")
            this._sortMode := this._sortModeList[Value]
            this.sortM.Check(Value "&")
            Everything.setSort(this._sortMode)
        }
    }

    static _cotModeList := ["path", "name", "size", "date"]
    static _cotMode := "path"
    static cotMode {
        get => this._cotMode
        set {
            i := this._arrayFind(this._cotModeList, this._cotMode)
            this.cotM.Uncheck(i "&")
            this._cotMode := this._cotModeList[Value]
            this.cotM.Check(Value "&")
        }
    }

    static main() {
        SplitPath(A_LineFile, &name) ; 获取插件id即文件名
        this.name := name

        Everything.loadLibrary()
        Everything.setMax(this.pageSize) ;每次搜索数量
        Everything.setRequestFlags(
            Everything.CONSTANT_SETREQUESTFLAGS.EVERYTHING_REQUEST_FULL_PATH_AND_FILE_NAME |
            Everything.CONSTANT_SETREQUESTFLAGS.EVERYTHING_REQUEST_SIZE |
            Everything.CONSTANT_SETREQUESTFLAGS.EVERYTHING_REQUEST_DATE_MODIFIED
        )
        ;名称和路径|大小|修改日期

        this.menuInit()
        this.addToSearchGui()
    }


    static menuInit() {
        that := PluginHelper.getPluginMode() ; 提前获取that, 即 pluginMode
        getFocusItem() {
            return that.pluginSearchResult[that.focusedRow]
        }

        m := this.menu
        m.Add("文件夹中显示`t(&1)", (*) => (PluginHelper.Utils.openFileInFolder(getFocusItem().path), PluginHelper.hideSearchGui(true)))
        m.Add("打开文件`t(&2)", (*) => (PluginHelper.Utils.startFile(getFocusItem().path), PluginHelper.hideSearchGui(true)))
        m.Add("复制路径`t(&3)", (*) => (A_Clipboard := getFocusItem().path, PluginHelper.hideSearchGui(true)))
        m.Add("复制文件`t(&4)", (*) => (PluginHelper.Utils.copyToClipboard(getFocusItem().path), PluginHelper.hideSearchGui(true)))
        m.Add("删除文件`t(&5)", (*) => (FileRecycle(getFocusItem().path), PluginHelper.hideSearchGui(true)))

        m.SetIcon("1&", PluginHelper.imgDir "\folder.ico")
        m.SetIcon("2&", PluginHelper.imgDir "\run.ico")
        m.SetIcon("3&", PluginHelper.imgDir "\link.ico")
        m.SetIcon("4&", PluginHelper.imgDir "\copy.ico")
        m.SetIcon("5&", PluginHelper.imgDir "\delete.ico")

        sm := Menu()
        m.Add("设置`t(&6)", sm)
        m.SetIcon("6&", PluginHelper.imgDir "\setting.ico")

        ; 排序方式
        sortM := this.sortM
        for name in ["路径", "名称", "大小", "修改时间"] {
            sortM.Add(Format("按{}升序`t(&{})", name, A_Index * 2 - 1),
                (_, pos, *) => (this.sortMode := pos, PluginHelper.searchText := PluginHelper.searchText))
            sortM.Add(Format("按{}降序`t(&{})", name, A_Index * 2),
                (_, pos, *) => (this.sortMode := pos, PluginHelper.searchText := PluginHelper.searchText))
        }
        sm.Add("排序方式`t(&1)", sortM)

        ; 显示内容
        cotM := this.cotM
        for name in ["路径", "名称", "大小 - 名称", "大小 - 修改时间"]
            cotM.Add(Format("{}`t(&{})", name, A_Index), (_, pos, *) => (this.cotMode := pos, this.refrushLV(that)))
        sm.Add("显示内容`t(&2)", cotM)

        this.cotMode := 1 ; 选择显示路径
        this.sortMode := 1 ; 选择按路径升序
    }

    static _arrayFind(arr, val) {
        for i, v in arr {
            if (v == val)
                return i
        }
        return 0
    }

    static byteFormat(size, decimalPlaces := 2) {
        static sizeName := ["KB", "MB", "GB", "TB"]
        if (size <= 0)
            return "*"
        sizeIndex := 0
        while (size >= 1024) {
            sizeIndex++
            size /= 1024.0
            if (sizeIndex = 4)
                break
        }
        return (sizeIndex = 0) ? Format("{:." decimalPlaces "f} B", size)
        : Format("{:." decimalPlaces "f} {}", size, sizeName[sizeIndex])
    }

    ; 添加搜索结果到列表
    static addItemsToLV(that, items) {
        for item in items {
            ; 判断图标是否已载入
            ext := item.ext
            if (instr(FileExist(item.path), "D")) {
                icoIndex := that.imgPathToImgListIndex[".folder"]
            } else if (ext = 'lnk' || ext = 'exe' || ext = 'ico') {
                ; exe lnk ico文件图标要根据路径载入
                if (!that.imgPathToImgListIndex.Has(item.path)) {
                    hIcon := PluginHelper.Utils.associatedHIcon(item.path)
                    index := IL_Add(that.imgListID, "HICON:*" hIcon)
                    that.imgPathToImgListIndex[item.path] := index ?
                    index : that.imgPathToImgListIndex[".noImg"] ;加载失败使用默认
                }
                icoIndex := that.imgPathToImgListIndex[item.path]
            } else {
                ; 其他类型按类型载入即可
                if (!that.imgPathToImgListIndex.Has(ext)) {
                    hIcon := PluginHelper.Utils.associatedHIcon(item.path)
                    index := IL_Add(that.imgListID, "HICON:*" hIcon)
                    that.imgPathToImgListIndex[ext] := index ?
                    index : that.imgPathToImgListIndex[".noImg"] ;加载失败使用默认
                }
                icoIndex := that.imgPathToImgListIndex[ext]
            }
            ; 添加
            switch this.cotMode {
                case "path":
                    that.listView.Add("Icon" icoIndex, PluginHelper.Utils.pathStrCompact(item.path, 45)) ;显示压缩的路径
                case "name":
                    that.listView.Add("Icon" icoIndex, item.name)
                case "size":
                    that.listView.Add("Icon" icoIndex, Format("{} - {}", item.size, item.name))
                case "date":
                    that.listView.Add("Icon" icoIndex, Format("{} - {}", item.date, item.name))
            }
        }
    }

    ; 刷新列表
    static refrushLV(that) {
        ;重置列表
        that.listView.Opt("-Redraw")    ;禁用重绘
        that.listView.Delete()
        this.addItemsToLV(that, that.pluginSearchResult)
        that.resizeGui() ;根据搜索结果数量调整gui尺寸 并启用重绘
    }

    static addToSearchGui() {
        ; 加载默认图标
        loadImg(that) {
            that.imgPathToImgListIndex[".noImg"] := IL_Add(that.imgListID, PluginHelper.imgDir "\noImg.png")
            that.imgPathToImgListIndex[".folder"] := IL_Add(that.imgListID, PluginHelper.imgDir "\folder.png")
        }

        ; 异步加载列表
        asyncLoading(that) {
            if (that.pluginOtherData.totalNum > that.pluginOtherData.offset + this.pageSize) {  ;未加载完成
                ; 设置偏移量
                that.pluginOtherData.offset += this.pageSize
                Everything.setOffset(that.pluginOtherData.offset)
                ; 搜索
                if (Everything.query()) {
                    visNum := Everything.getNumResults()
                    that.pluginSearchResult.Capacity += visNum ;扩充容量
                    tempList := [], tempList.Capacity := visNum ; 临时储存本次加载内容
                    loop visNum {
                        index := A_Index - 1
                        path := Everything.getResultFullPathName(index)
                        SplitPath(path, &name, , &ext)
                        item := {
                            name: name,
                            path: path,
                            ext: ext,
                            size: this.byteFormat(Everything.getResultSize(index)),
                            date: Everything.getResultDateModified(index)
                        }
                        that.pluginSearchResult.Push(item), tempList.Push(item)
                    }
                    that.listView.Opt("-Redraw")    ;禁用重绘
                    this.addItemsToLV(that, tempList)
                    that.listView.Opt("Redraw")    ;启用重绘

                    if (IsSet(DEBUG) && DEBUG)
                        PluginHelper.Utils.tip(
                            this.name,
                            Format("Everything搜索结果异步载入`n[{}/{}]", that.pluginSearchResult.Length, that.pluginOtherData.totalNum)
                        )
                } else
                    PluginHelper.Utils.tip(this.name, "Everything搜索失败, 错误码:" Everything.getLastError())
            }
        }

        ; 仅带有纯文本时的初始化
        initWithText(that) {
            that.pluginOtherData := {
                totalNum: 0,
                offset: 0
            }
            that.menu := this.menu
        }

        ; 带有文件时的初始化
        initWithFile(that) {
            initWithText(that)
        }

        ; 窗口匹配时的初始化
        initWithWindow(path, that) {
            initWithText(that)
            that.pluginOtherData.path := path
        }

        ;定义插件模式下搜索功能
        searchHandler(that, searchText) {
            that.pluginSearchResult := []
            if (PluginHelper.pastedContentType == "file")
                searchText := Format('"{}" {}', PluginHelper.pastedContent[1], searchText)
            else if (that.pluginOtherData.HasOwnProp("path"))
                searchText := Format('"{}" {}', that.pluginOtherData.path, searchText)
            ; 其他类型不修改searchText

            if (searchText) {
                ; that.pluginSearchResult := [{ name: "文件名", path: "路径", size:"大小", "date":"修改时间" },...]
                Everything.setSearch(searchText)
                that.pluginOtherData.offset := 0
                Everything.setOffset(0)
                if (Everything.query()) {
                    that.pluginOtherData.totalNum := Everything.getTotResults()
                    PluginHelper.Utils.tip(this.name, Format("Everything搜索成功`n共 {} 条结果", that.pluginOtherData.totalNum), 2000)
                    visNum := Everything.getNumResults()
                    that.pluginSearchResult.Capacity := visNum
                    loop visNum {
                        index := A_Index - 1
                        path := Everything.getResultFullPathName(index)
                        SplitPath(path, &name, , &ext)
                        that.pluginSearchResult.Push({
                            name: name,
                            path: path,
                            ext: ext,
                            size: this.byteFormat(Everything.getResultSize(index)),
                            date: FormatTime(Everything.getResultDateModified(index), "yyyy-MM-dd HH:mm:ss")
                        })
                    }
                } else
                    PluginHelper.Utils.tip(this.name, "Everything搜索失败, 错误码:" Everything.getLastError())
            }
            this.refrushLV(that)
        }

        ;定义插件模式下回车、双击处理函数
        runHandler(that, rowNum) {
            if (rowNum) {
                PluginHelper.Utils.startFile(that.pluginSearchResult[rowNum].path)
                PluginHelper.hideSearchGui()
            }
        }

        ; 双击right处理函数
        doubleRightHandler(that, rowNum) {
            if (rowNum > 0) {
                ControlGetPos(&x1, &y1, &w, , that.listView)
                RECT := Buffer(16, 0)
                NumPut("UInt", 0, RECT, 0)
                SendMessage(0x1038, rowNum - 1, RECT.Ptr, , that.listView)
                that.menu.show(x1 + w - 150, y1 + (NumGet(RECT, 4, "UInt") + NumGet(RECT, 12, "UInt")) // 2)
            }
        }

        ; 粘贴文件/位图处理函数
        pasteContentHandler(that, typeName, content?) {
            if (typeName != "file") ;非文件类型都不允许
                return 0
            if (!IsSet(content)) {
                content := A_Clipboard
                if (InStr(content, "`r`n")) ; 不允许多文件
                    return false
                return InStr(FileExist(content), "D") ;仅允许单文件夹
            }
            else { ;粘贴完成后的触发
                PluginHelper.placeholder := "在文件夹内搜索"
                t := PluginHelper.searchText
                PluginHelper.searchText := t ; 直接触发搜索
                PluginHelper.setSearchTextSel(StrLen(t)) ; 游标移动到最后
            }
        }

        dropFilesHandler(that, fileList, pre) {
            if (pre) {
                if (fileList.Length > 1)
                    return false
                return InStr(FileExist(fileList[1]), "D") ;仅允许单文件夹
            } else { ;拖入生效后的触发
                PluginHelper.placeholder := "在文件夹内搜索"
                t := PluginHelper.searchText
                PluginHelper.searchText := t ; 直接触发搜索
                PluginHelper.setSearchTextSel(StrLen(t)) ; 游标移动到最后
            }
        }

        ; 添加插件项到启动模式搜索界面
        PluginHelper.addPluginToStartupMode(
            this.name,
            "文件搜索",
            ["WJSS", "Everything"],
            (obj, searchText) => (
                PluginHelper.showPluginMode( ; 启动插件模式
                    [], ;数据靠search获取，不需要传入
                    searchHandler,
                    runHandler, {
                        doubleRightHandler: doubleRightHandler,
                        loadImgsHandler: loadImg, ; 需要带有图标
                        toBottomHandler: asyncLoading, ; 异步加载
                        initHandler: initWithText, ; 初始化
                        pasteContentHandler: pasteContentHandler, ; 允许粘贴单文件夹
                        dropFilesHandler: dropFilesHandler, ; 允许拖入单文件夹
                        placeholder: "Search on Everything",
                        thumb: PluginHelper.getPluginHIcon(this.name)
                    }
                )
            ), , , PluginHelper.getPluginHIcon(this.name)
        )

        ; 匹配处理函数
        ; 1. 匹配文本 2. 匹配单文件夹，且文件夹存在，并进行优先级细分
        matchHandler(obj, searchText, pastedContentType, pastedContent, workWinInfo, winInfoMatchFlag) {
            if (winInfoMatchFlag) {
                pName := workWinInfo.processName
                cName := workWinInfo.class
                path := workWinInfo.title
                ; 匹配资源管理器 且 标题指向的文件夹存在
                if ((pName == 'explorer.exe' || cName == "CabinetWClass" || cName == "ExploreWClass")
                    && InStr(FileExist(path), "D")
                ) {
                    if (PluginHelper.Utils.strStartWith("Everything", searchText)
                        || PluginHelper.Utils.strStartWith("WJSS", searchText)) {
                        ; 搜索文本为Everything或者WJSS的开头
                        obj.matchData := { type: "window", searchTextFlag: false, path: path }
                        obj.title := "在工作窗口目录内搜索" ; 修改显示标题
                        return 2 ; 更高优先级
                    } else {
                        obj.matchData := { type: "window", searchTextFlag: true, path: path }
                        obj.title := "在工作窗口目录内搜索输入内容" ; 修改显示标题
                        return 1 ; 基本优先级
                    }
                }
            } else {
                if (pastedContentType == 'text' && searchText) {
                    obj.matchData := { type: "text", searchTextFlag: true } ; 标记匹配类型，方便进入插件模式前区分进入方式
                    obj.title := "使用Everything搜索输入内容" ; 修改显示标题
                    return 1 ; 基本优先级
                } else if (pastedContentType == 'file' && pastedContent.Length = 1 && InStr(FileExist(pastedContent[1]), "D")) {
                    if (PluginHelper.Utils.strStartWith("Everything", searchText)
                        || PluginHelper.Utils.strStartWith("WJSS", searchText)) {
                        ; 搜索文本为Everything或者WJSS的开头
                        obj.matchData := { type: "file", searchTextFlag: false } ; 标记最后不要传入searchText
                        obj.title := "使用Everything在文件夹内搜索" ; 修改显示标题
                        return 2 ; 更高优先级
                    } else {
                        obj.matchData := { type: "file", searchTextFlag: true }
                        obj.title := "使用Everything在文件夹内搜索输入内容" ; 修改显示标题
                        return 1 ; 基本优先级
                    }
                }
            }
            return 0 ; 不匹配
        }


        ; 添加插件项到智能模式搜索界面
        PluginHelper.addPluginToIntelligentMode(
            this.name,
            "Everything文件搜索", ; 这个title不重要，会在matchHandler执行时修改
            matchHandler,
            (obj, searchText) => (
                PluginHelper.showPluginMode( ; 启动插件模式
                    [], ;数据靠search获取，不需要传入
                    searchHandler,
                    runHandler, {
                        doubleRightHandler: doubleRightHandler,
                        loadImgsHandler: loadImg, ; 需要带有图标
                        toBottomHandler: asyncLoading, ; 异步加载
                        initHandler:
                            obj.matchData.type == 'text' ?  ; 区分初始化
                            initWithText : obj.matchData.type == 'file' ?
                                initWithFile : initWithWindow.Bind(obj.matchData.path),
                        placeholder:
                            obj.matchData.type == 'text' ?  ; 区分占位符
                            "Search on Everything" : obj.matchData.type == 'file' ?
                                "在文件夹内搜索" : Format('"{}" 内搜索', PluginHelper.Utils.pathStrCompact(obj.matchData.path, 25)),
                        pasteContentHandler: pasteContentHandler, ; 允许粘贴文件
                        searchText: obj.matchData.searchTextFlag ? searchText : "", ; 区分是否要传入搜索文本
                        thumb: PluginHelper.getPluginHIcon(this.name)
                    }
                )
            ), , PluginHelper.getPluginHIcon(this.name)
        )
    }
}