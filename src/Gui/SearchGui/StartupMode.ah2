class StartupMode {
    static listView := unset
    static menu := unset
    static menuRow := 0
    static imgListID := 0
    static imgPathToImgListIndex := Map()
    static hotkeyHandlerMap := Map()
    static autoHideFunc := this.autoHide.Bind(this)

    static init() {
        this.listView := SearchGui.gui.Add("ListView", "x10 y50 w510 r8 -Multi -hdr -E0x200 Count" GlobalData.startupData.Length, [""])
        this.listView.SetFont("s14 w700 c444444")

        this.reloadSearchList()
        this.search(true)

        ; 鼠标双击运行
        this.listView.OnEvent("DoubleClick", (_lv, rowNum) => this.startSelectedFile(rowNum))
        ; 菜单栏
        this.listView.OnEvent("ContextMenu", (_lv, rowNum, *) => this.showMenu(rowNum))

        ; 启动模式热键处理函数
        this.hotkeyHandlerMap["+Esc"] := () => StrLen(SearchGui.edit.Value) ? this.clearSearchWords() : this.hideGui()
        this.hotkeyHandlerMap["~Left Up"] := () => (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 250) ? this.openSelectedFileInFolder() : 0
        this.hotkeyHandlerMap["Down"] := () => this.focusNextRow()
        this.hotkeyHandlerMap["Up"] := () => this.focusNextRow(true)

        ; 启动模式菜单初始化
        this.MenuInit()
    }

    ; 启动模式列表右键菜单初始化
    static MenuInit() {
        this.menu := Menu()
        this.menu.Add("启动选中项`t(&R)", (*) => this.startSelectedFile(this.menuRow))
        this.menu.Add("文件夹中打开`t(&O)", (*) => this.openSelectedFileInFolder(this.menuRow))
        this.menu.Add("编辑选中项`t(&E)", (*) => this.toStartupEditGui(this.menuRow))
        this.menu.Add("删除选中项`t(&X)", (*) => this.deleteItem(this.menuRow))

        this.menu.SetIcon("1&", GlobalData.imgDir "\grey-run.png")
        this.menu.SetIcon("2&", GlobalData.imgDir "\grey-folder.png")
        this.menu.SetIcon("3&", GlobalData.imgDir "\grey-edit.png")
        this.menu.SetIcon("4&", GlobalData.imgDir "\grey-delete.png")
    }

    ; 跳转至编辑界面
    static toStartupEditGui(rowNum) {
        if (GlobalData.startupSearchResult !== GlobalData.startupData) {
            selectedItem := GlobalData.startupSearchResult[rowNum]
            for index, item in GlobalData.startupData {
                if (item == selectedItem) {
                    rowNum := index
                    break
                }
            }

        }
        this.hideGui()
        StartupEditGui.showGui(rowNum)
    }

    ; 超时自动隐藏
    static autoHide() {
        if (!WinActive(SearchGui.gui)) {
            this.hideGui()
        }
    }

    ; 以启动模式显示gui
    static showGui(refresh := false) {
        SearchGui.toggleMode(0)    ; 按需切换

        if (refresh) {
            SearchGui.edit.Value := ""
            this.search()
        } else
            SearchGui.gui.Show()

        SearchGui.edit.Focus()
        IME_SET(0)
        SetTimer(this.autoHideFunc, 1000)
    }

    ; 启动模式下隐藏主界面
    static hideGui() {
        SetTimer(this.autoHideFunc, 0)
        SearchGui.edit.Value := ""
        SearchGui.gui.hide()
        this.search(true, false)    ; 重绘 隐藏但不重排
    }

    ; 显示菜单
    static showMenu(rowNum) {
        if (rowNum) {
            this.menuRow := rowNum
            this.menu.Show()
        }
    }

    ; 删除项
    static deleteItem(rowNum) {
        Critical('On')    ;防止线程被中断
        item := GlobalData.startupSearchResult[rowNum]
        GlobalData.startupSearchResult.RemoveAt(rowNum)
        if (GlobalData.startupSearchResult != GlobalData.startupData) {    ; 当并非直接指向时还须再删除
            for index, oriItem in GlobalData.startupData {
                if (item == oriItem)
                    GlobalData.startupData.RemoveAt(index)
            }
        }
        this.listView.Delete(rowNum)

        ;重置listView和gui高度
        LVHeight := Round((GlobalData.startupSearchResult.Length >= 8 ? 8 : GlobalData.startupSearchResult.Length) * 26.4)    ; 此处不需要DPI缩放计算
        this.listView.Move(, , , LVHeight)
        this.listView.ModifyCol(1, "480")
        WinMove(, , 500 * (A_ScreenDPI / 96), Round((LVHeight + 55) * (A_ScreenDPI / 96)), SearchGui.gui)
        Critical('Off')
    }

    ; 拖拽添加
    static dropAddItem(args*) {
        fileList := args[2]
        for filePath in fileList {
            SplitPath(filePath, , , , &fileNameNoExt)
            GlobalData.startupData.Push([filePath, filePath, 0, fileNameNoExt, ChineseFirstChar(fileNameNoExt)])
        }

        StartupMode.reloadSearchList(false, false)    ;重载列表，但不重置图片列表且不保存

        if (SearchGui.curMode !== 0)    ; 非启动模式下，转为启动模式
            SearchGui.toggleMode(0)    ; 转换启动模式时会搜索一次
        else
            StartupMode.search()

        GlobalData.storestartupData()    ;此处再保存
    }

    ; 聚焦下一行（循环）
    static focusNextRow(reverse := false) {
        rowNum := this.listView.GetNext(, "F")
        if (reverse) {
            if (rowNum > 1)
                this.listView.Modify(rowNum - 1, "Select Focus Vis")
            else
                this.listView.Modify(this.listView.GetCount(), "Select Focus Vis")
        } else {
            if (rowNum < this.listView.GetCount())
                this.listView.Modify(rowNum + 1, "Select Focus Vis")
            else
                this.listView.Modify(1, "Select Focus Vis")
        }
    }

    ; 运行选中文件
    static startSelectedFile(rowNum := -1) {
        if (rowNum == -1)    ;说明需要获取焦点所在行
            rowNum := this.listView.GetNext(, "F")
        if (rowNum) {
            if (GlobalData.startupSearchResult[rowNum][3] < 999)
                GlobalData.startupSearchResult[rowNum][3]++

            Start.startFile(GlobalData.startupSearchResult[rowNum][1], , , this.hideGui.Bind(this))
        }
    }

    ; 在文件夹中显示选中文件
    static openSelectedFileInFolder(rowNum := -1) {
        if (rowNum == -1)    ;说明需要获取焦点所在行
            rowNum := this.listView.GetNext(, "F")
        if (rowNum) {
            if (GlobalData.startupSearchResult[rowNum][3] < 999)
                GlobalData.startupSearchResult[rowNum][3]++

            Start.openFileInFolder(GlobalData.startupSearchResult[rowNum][1])
            this.hideGui()
        }
    }

    ; 清空搜索框
    static clearSearchWords() {
        SearchGui.edit.Value := ""
        this.search()
    }

    ; 重新加载搜索列表图标资源
    static reloadSearchList(reloadIL := true, allowStore := true) {
        SearchGui.setEditplaceholder("正在加载搜索列表...")
        SearchGui.edit.Value := ""    ;清空搜索框
        this.listView.Delete()    ;清空搜索列表

        if (reloadIL) {
            general := ["error.png", "autohotkey.png", "img.png", "folder.png", "program.png", "txt.png"]
            this.imgPathToImgListIndex := Map()    ;重置图片路径与序号映射
            oldImgListID := 0
            if (this.imgListID)
                oldImgListID := this.imgListID    ;标记需要删除旧图片列表
            this.imgListID := DllCall("ImageList_Create", "Int", 32, "Int", 32, "Int", 32, "Int", 1, "Int", 1)    ;创建新图片列表
            this.listView.SetImageList(this.imgListID, 1)
            ; 载入通用图标
            for img in general
                this.imgPathToImgListIndex[GlobalData.imgDir "\" img] := IL_Add(this.imgListID, GlobalData.imgDir "\" img)
        }

        ; 为每个项目按需载入图标
        changeFlag := false
        for item in GlobalData.startupData {
            item[3] := Integer(item[3])    ; 转为整数

            if (InStr(FileExist(item[2]), "D")) {    ;文件夹类型
                item[2] := GlobalData.imgDir "\folder.png"
            } else if (!this.imgPathToImgListIndex.Has(item[2])) {    ;未载入则添加进字典中
                ext := SubStr(item[1], -4)    ;对原文件类型进行判断
                if (ext = '.lnk' and FileExist(item[1])) {    ;快捷方式则转为其指向文件
                    FileGetShortcut(item[1], &target)
                    item[2] := target
                    ext := SubStr(target, -4)
                }

                index := IL_Add(this.imgListID, item[2])
                if (!index)    ; 图片载入失败
                {
                    img := "program.png"    ;默认图标
                    switch ext, 0 {
                        case ".ahk", ".ah2": img := "autohotkey.png"
                        case ".jpg", ".jpeg", ".png", ".ico": img := "img.png"
                        case ".txt": img := "txt.png"
                    }
                    changeFlag := true
                    item[2] := GlobalData.imgDir "\" img    ;使用默认图片
                }
                else
                    this.imgPathToImgListIndex[item[2]] := index
            }
            ; 否则图标已加载
        }
        ; 若有变动则保存startupData
        if (allowStore and changeFlag)
            GlobalData.storestartupData()
        if (reloadIL and oldImgListID)
            DllCall("ImageList_Destroy", "Uint", oldImgListID)
        SearchGui.setEditplaceholder('Hi, Starter')
    }

    ; 搜索即重置列表显示匹配的内容
    static search(hide := false, sortFlag := true) {
        keyword := SearchGui.edit.Value
        if (StrLen(keyword)) {
            GlobalData.startupSearchResult := []
            ;匹配（任意关键词包含搜索内容时匹配）
            for item in GlobalData.startupData {
                loop item.Length - 3 {    ;依次对关键词（包括显示名称）进行判断，忽略大小写
                    k := item[3 + A_Index]
                    if (InStr(k, keyword)) {
                        GlobalData.startupSearchResult.Push(item)
                        break
                    }
                }
            }
        } else    ;搜索词为空时显示所有
            GlobalData.startupSearchResult := GlobalData.startupData

        ;排序(优先级降序，其次按显示名称)
        if (sortFlag)
            QuickSort(GlobalData.startupSearchResult, (itemA, itemB) => itemB[3] == itemA[3] ? StrCompare(itemA[4], itemB[4]) : itemB[3] - itemA[3])

        ;显示新列表
        this.listView.Opt("-Redraw")    ;禁用重绘
        this.listView.Delete()
        for item in GlobalData.startupSearchResult {
            if (!FileExist(item[1]))    ; 文件不存在则使用error图标
                this.listView.Add("Icon" this.imgPathToImgListIndex[GlobalData.imgDir "\error.png"], "  " item[4])
            else
                this.listView.Add("Icon" this.imgPathToImgListIndex[item[2]], "  " item[4])
        }
        ;重置listView和gui高度
        LVHeight := Round((GlobalData.startupSearchResult.Length >= 8 ? 8 : GlobalData.startupSearchResult.Length) * 26.4)    ; 此处不需要DPI缩放计算
        this.listView.Move(, , , LVHeight)
        this.listView.ModifyCol(1, "480")
        this.listView.Modify(1, "Select Focus Vis")    ;聚焦第一行

        this.listView.Opt("Redraw")

        WinMove(, , 500 * (A_ScreenDPI / 96), Round((LVHeight + 55) * (A_ScreenDPI / 96)), SearchGui.gui)
        if (hide)
            SearchGui.gui.Hide()
    }
}