class SearchGui {
    static gui := unset
    static edit := unset
    static listView := unset
    static menu := unset
    static menuRow := 0
    static imgListID := 0
    static autoHideFunc := this.autoHide.Bind(this)

    static imgPathToImgListIndex := Map()

    static init() {
        this.gui := Gui("Owner AlwaysOnTop -Resize -Caption", "Starter")
        this.gui.BackColor := "FFFFFF"
        this.gui.SetFont("s20 q5 c333333", "NSimSun")
        this.gui.SetFont(, "雅痞-简")    ;优先使用更好看的字体
        this.gui.MarginY := 0

        this.edit := this.gui.AddEdit("x10 y10 h30 w450 -E0x200")
        this.setEditplaceholder('Hi, Starter')
        this.edit.Focus()

        search(edit, info) {    ;防抖
            static f := this.search.Bind(this)
            SetTimer(f, 0)
            SetTimer(f, -50)
        }
        this.edit.OnEvent("Change", search)    ; 文本变动事件

        this.gui.OnEvent("DropFiles", this.dropAddItem)    ; 文件拖入事件

        this.gui.AddPicture("x460 y10 w30 h30", GlobalData.imgDir "\Starter.png")
        this.listView := this.gui.Add("ListView", "x10 y50 w510 r8 -Multi -hdr -E0x200 Count" GlobalData.programData.Length, [""])
        this.listView.SetFont("s14 w700 c444444")
        this.gui.Show("Hide y" Round(A_ScreenHeight / 5))
        this.reloadSearchList()
        this.search(true)

        this.gui.AddButton("Default Hidden").OnEvent("Click", (*) => this.startSelectedFile())

        ; 鼠标双击运行
        this.listView.OnEvent("DoubleClick", (_lv, rowNum) => this.startSelectedFile(rowNum))
        ; 菜单栏
        this.listView.OnEvent("ContextMenu", (_lv, rowNum, *) => this.showMenu(rowNum))

        this.hotkeyInit()
        this.MenuInit()
    }

    static MenuInit() {
        this.menu := Menu()
        this.menu.Add("启动选中项`t(&R)", (*) => this.startSelectedFile(this.menuRow))
        this.menu.Add("文件夹中打开`t(&O)", (*) => this.openSelectedFileInFolder(this.menuRow))
        this.menu.Add("编辑选中项`t(&E)", (*) => this.toEditGui(this.menuRow))
        this.menu.Add("删除选中项`t(&X)", (*) => this.deleteItem(this.menuRow))

        this.menu.SetIcon("1&", GlobalData.imgDir "\grey-run.png")
        this.menu.SetIcon("2&", GlobalData.imgDir "\grey-folder.png")
        this.menu.SetIcon("3&", GlobalData.imgDir "\grey-edit.png")
        this.menu.SetIcon("4&", GlobalData.imgDir "\grey-delete.png")
    }


    static hotkeyInit() {
        ; 激活
        Hotkey("~CapsLock Up", key => (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 300) ? this.showGui() : 0)

        ;===仅当窗口激活时有效===
        HotIfWinActive("ahk_id " this.gui.Hwnd)
        ; 清空、隐藏
        Hotkey("+Esc", key => StrLen(this.edit.Value) ? this.clearSearchWords() : this.hideGui())
        ; 文件夹中显示
        Hotkey("~Left Up", key => (A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 250) ? this.openSelectedFileInFolder() : 0)
        ; 上下移动焦点行
        Hotkey("Down", key => this.focusNextRow())
        Hotkey("Up", key => this.focusNextRow(true))
        HotIf()
    }

    ; 超时自动隐藏
    static autoHide() {
        if (!WinActive(this.gui)) {
            this.hideGui()
        }
    }

    ; 跳转至编辑界面
    static toEditGui(rowNum) {
        if (GlobalData.searchResult !== GlobalData.programData) {
            selectedItem := GlobalData.searchResult[rowNum]
            for index, item in GlobalData.programData {
                if (item == selectedItem) {
                    rowNum := index
                    break
                }
            }

        }
        this.hideGui()
        EditGui.showGui(rowNum)
    }

    ; 显示gui
    static showGui(refresh := false) {
        if (refresh) {
            this.edit.Value := ""
            this.search()
        } else
            this.gui.Show()
        this.edit.Focus()
        IME_SET(0)
        SetTimer(this.autoHideFunc, 1000)
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
        item := GlobalData.searchResult[rowNum]
        GlobalData.searchResult.RemoveAt(rowNum)
        if (GlobalData.searchResult != GlobalData.programData) {    ; 当并非直接指向时还须再删除
            for index, oriItem in GlobalData.programData {
                if (item == oriItem)
                    GlobalData.programData.RemoveAt(index)
            }
        }
        this.listView.Delete(rowNum)

        ;重置listView和gui高度
        LVHeight := Round((GlobalData.searchResult.Length >= 8 ? 8 : GlobalData.searchResult.Length) * 26.4)    ; 此处不需要DPI缩放计算
        this.listView.Move(, , , LVHeight)
        this.listView.ModifyCol(1, "480")
        WinMove(, , 500 * (A_ScreenDPI / 96), Round((LVHeight + 55) * (A_ScreenDPI / 96)), this.gui)
        Critical('Off')
    }

    ; 拖拽添加
    static dropAddItem(args*) {
        fileList := args[2]
        for filePath in fileList {
            SplitPath(filePath, , , , &fileNameNoExt)
            GlobalData.programData.Push([filePath, filePath, 0, fileNameNoExt, ChineseFirstChar(fileNameNoExt)])
        }
        SearchGui.reloadSearchList(false, false)    ;重载列表，但不重置图片列表且不保存
        SearchGui.search()
        GlobalData.storeProgramData()    ;此处再保存
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
            if (GlobalData.searchResult[rowNum][3] < 999)
                GlobalData.searchResult[rowNum][3]++

            Start.startFile(GlobalData.searchResult[rowNum][1])
            this.hideGui()
        }
    }

    ; 在文件夹中显示选中文件
    static openSelectedFileInFolder(rowNum := -1) {
        if (rowNum == -1)    ;说明需要获取焦点所在行
            rowNum := this.listView.GetNext(, "F")
        if (rowNum) {
            if (GlobalData.searchResult[rowNum][3] < 999)
                GlobalData.searchResult[rowNum][3]++

            Start.openFileInFolder(GlobalData.searchResult[rowNum][1])
            this.hideGui()
        }
    }

    ; 清空搜索框
    static clearSearchWords() {
        this.edit.Value := ""
        this.search()
    }

    ; 隐藏主界面
    static hideGui() {
        SetTimer(this.autoHideFunc, 0)
        this.edit.Value := ""
        this.gui.hide()
        this.search(true, false)    ; 重绘 隐藏但不重排
    }

    ; 设置搜索框占位符
    static setEditplaceholder(text) {
        DllCall("User32.dll\SendMessageW", "Ptr", this.edit.Hwnd, "Uint", (0x1500 + 1), "Ptr", True, "WStr", text)
    }

    ; 重新加载搜索列表
    static reloadSearchList(reloadTL := true, allowStore := true) {
        this.setEditplaceholder("正在加载搜索列表...")
        this.edit.Value := ""    ;清空搜索框
        this.listView.Delete()    ;清空搜索列表


        general := ["error.png", "autohotkey.png", "img.png", "folder.png", "program.png", "txt.png"]
        if (reloadTL) {
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

        ; 为每个项目载入图标
        changeFlag := false
        for item in GlobalData.programData {
            item[3] := Integer(item[3])    ; 转为整数

            if (InStr(FileExist(item[2]), "D")) {    ;文件夹类型
                item[2] := GlobalData.imgDir "\folder.png"
            } else if (!this.imgPathToImgListIndex.Has(item[2])) {    ;未载入则添加进字典中
                ext := SubStr(item[1], -4)    ;对原文件类型进行判断
                if (ext = '.lnk') {    ;快捷方式则转为其指向文件
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
        ; 若有变动则保存programData
        if (allowStore and changeFlag)
            GlobalData.storeProgramData()
        if (reloadTL and oldImgListID)
            DllCall("ImageList_Destroy", "Uint", oldImgListID)
        this.setEditplaceholder('Hi, Starter')
    }

    ; 搜索
    static search(hide := false, sortFlag := true) {
        keyword := this.edit.Value
        if (StrLen(keyword)) {
            GlobalData.searchResult := []
            ;匹配（任意关键词包含搜索内容时匹配）
            for item in GlobalData.programData {
                loop item.Length - 3 {    ;依次对关键词（包括显示名称）进行判断，忽略大小写
                    k := item[3 + A_Index]
                    if (InStr(k, keyword)) {
                        GlobalData.searchResult.Push(item)
                        break
                    }
                }
            }
        } else    ;搜索词为空时显示所有
            GlobalData.searchResult := GlobalData.programData

        ;排序(优先级降序，其次按显示名称)
        if (sortFlag)
            QuickSort(GlobalData.searchResult, (itemA, itemB) => itemB[3] == itemA[3] ? StrCompare(itemA[4], itemB[4]) : itemB[3] - itemA[3])

        ;显示新列表
        this.listView.Opt("-Redraw")    ;禁用重绘
        this.listView.Delete()
        for item in GlobalData.searchResult {
            if (!FileExist(item[1]))    ; 文件不存在则使用error图标
                this.listView.Add("Icon" this.imgPathToImgListIndex[GlobalData.imgDir "\error.png"], "  " item[4])
            else
                this.listView.Add("Icon" this.imgPathToImgListIndex[item[2]], "  " item[4])
        }
        this.listView.Modify(1, "Select Focus Vis")    ;聚焦第一行
        ;重置listView和gui高度
        LVHeight := Round((GlobalData.searchResult.Length >= 8 ? 8 : GlobalData.searchResult.Length) * 26.4)    ; 此处不需要DPI缩放计算
        this.listView.Move(, , , LVHeight)
        this.listView.ModifyCol(1, "480")
        this.listView.Opt("Redraw")

        WinMove(, , 500 * (A_ScreenDPI / 96), Round((LVHeight + 55) * (A_ScreenDPI / 96)), this.gui)
        if (hide)
            this.gui.Hide()
    }
}