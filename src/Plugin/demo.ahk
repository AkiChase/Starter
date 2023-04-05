/**
 * @Name: demo.ahk
 * @Version: 0.0.4
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-05
 * @Description: 插件示例
 */

/*
===============================================
Starter通过解析 Starter Plugin Info 和
Starter Plugin Info 之间的内容来加载插件
信息，无此内容的文件将被忽略，格式见下方。

icon: 插件列表中的图标，请填入无头部的base64图片
===============================================

===Starter Plugin Info==>
{
    "author": "ruchuby",
    "version": "0.0.4",
    "introduction": "An example of Starter Plugin",
    "icon": "iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAgNJREFUWEft1UuozVEUx/HPHRmaMFBMTDwmYiJSQimUMqAoAwNRQoSSR3kVxfWIIjISojwGiiLKgBkTYSADZGAkE2VAS3vXdvr/z/2fc27nls6a/fde+7e+e62113/IGNvQGMc3APivMnALE1NPLWraW6OVgZl4k4Jew/p+A+zBiRR0LW72G+A5FuArpuFHPwHm4mUKeAUbmwYPvyY9sAlTsL9G+Eixtwr3kt9RfMKldkAjAZzFNhxrA/Aas/Axpf9XAbAP57C9DqIOIOp4AUvSwbjlwQqRqHvUP+w8thY+h3EgfT/BFrxv1agCiDRG8EnJ+TM240EFQM5QbC3Dw8JnBS5iclqLBg2Iu6VOK0DUOW6b7XZqqu81KfyAqXiLmAWtNh6XsbrYiKxEf/y1EuA64g1n24nTNYFjeSGepf2T2N3GdweGi/0bWNcrwFVsSKIxejNMFUcjgDjYSQm+YQJeYU7N7TsqQdZo0oTxOh6nA1HP3O0lR1dNmAVan+Fx7C3U48+XG2teMQlLgEPF0+3oGZYi+ZmdQdQx20+MwwvMr0l/ngNdDaJSM0bx9AJgKR4lh+iZmJJVFgBfeh3FVcJ3EH0SNhsxiru2kf4FVcK/0+JTLO46cjrYKcDyYiTvwql+A9zHyhR0Bt71GyDSHhZDaE2vweN8pyUYjZj/aAwABhn4A2ymYyH5RzvQAAAAAElFTkSuQmCC"
}
<==Starter Plugin Info===
*/


#Include ..\Utils\PluginHelper.ah2
PluginHelper.addEntryFunc((*) => Plugin_Demo.main()) ; 添加入口函数等待执行

; 使用类，避免变量名、函数名污染
class Plugin_Demo {
    static menu := Menu()
    ; static gui:=unset
    ; static edit:=unset

    static guiInit() {
        g := Gui(, "插件基本示例1")
        g.BackColor := "FFFFFF"
        g.AddText(, "一个简单的Gui示例")

        SplitPath(A_LineFile, &pluginName)
        ; MsgBox(PluginHelper.getPluginHIcon(pluginName))
        g.AddPicture("w50 h50", "hIcon:*" . PluginHelper.getPluginHIcon(pluginName))
        this.edit := g.AddEdit("w200 h100", "输入文本~")
        g.Show("Hide")
        this.gui := g
    }

    static showGui() {
        this.gui.Show()
    }

    static main() {
        SplitPath(A_LineFile, &name) ; 获取插件id即文件名
        this.name := name

        ; 创建Gui的简单示例
        this.guiInit()

        ; 创建托盘菜单项的示例
        this.menu.Add("显示面板", (*) => this.showGui())
        this.menu.Add("弹出编辑框文本", (*) => PluginHelper.Utils.tip("弹出消息", this.edit.Value, 1500))
        this.menu.Add("其他", (*) => PluginHelper.Utils.tip("提示", "自定义其他的功能吧！", 1500))
        ; PluginHelper是方便插件规范调用Starter API的静态类
        ; 插件原则上都只能通过PluginHelper暴露的API对Staarter APi进行合理的调用
        ; 插件相关菜单最好加入pluginMenu菜单项，更加规范
        PluginHelper.pluginMenu.Add("demo.ahk", this.menu)

        ; 添加插件项到启动模式搜索界面
        ; 定义一个新的菜单，用于右键插件项时显示（菜单是可选的属性）
        m := Menu()
        m.Add("demo menu item", (*) => PluginHelper.Utils.tip(this.name, "demo menu item", 1000))

        ;#region 定义插件模式
        search(that, searchText) {
            that.pluginSearchResult := []
            if (searchText) {
                ; 搜索结果
                for item in that.pluginSearchData {
                    if (InStr(item.title, searchText))
                        that.pluginSearchResult.Push(item)
                }
            } else ; 搜索内容为空时显示所有
                that.pluginSearchResult := that.pluginSearchData

            ; 搜索结果按标题排序
            PluginHelper.Utils.QuickSort(that.pluginSearchResult, (itemA, tiemB) => StrCompare(itemA.title, tiemB.title))
            ;重置列表
            that.listView.Opt("-Redraw")    ;禁用重绘
            that.listView.Delete()
            ; 添加搜索结果到列表(带图标), 若不带图标则不需要loadImgs函数
            for item in that.pluginSearchResult {
                that.listView.Add("Icon" that.imgPathToImgListIndex[item.iconPath], "  " item.title)
            }

            that.resizeGui() ;根据搜索结果数量调整gui尺寸 并启用重绘
        }

        ; 加载图标的函数，用于搜索结果中 that.listView.Add("Icon" n,...)
        loadImgs(that) {
            defaultHIcon := LoadPicture(A_AhkPath, "Icon1", &_)
            that.imgPathToImgListIndex["default"] := IL_Add(that.imgListID, "HICON:" defaultHIcon)

            for item in that.pluginSearchData {
                if (!that.imgPathToImgListIndex.Has(item.iconPath)) {
                    index := IL_Add(that.imgListID, "HICON:*" hIcon)
                    ; 加载失败则使用默认图标
                    that.imgPathToImgListIndex[item.iconPath] := index ? index : that.imgPathToImgListIndex["default"]
                }
            }
        }

        ; 右键菜单栏初始化处理函数
        menuInit(that) {
            m := Menu()
            m.Add("显示当前行号", (*) => PluginHelper.Utils.tip("demo.ahk", that.focusedRow, 1500))
            m.Add("显示当前标题", (*) => PluginHelper.Utils.tip("demo.ahk", that.pluginSearchResult[that.focusedRow].title, 1500))
            that.menu := m
        }

        hIcon := PluginHelper.getPluginHIcon("demo.ahk")
        data := []
        loop 15 {
            data.Push({ title: Format("{:03}", A_Index), iconPath: hIcon })
        }
        ;#endregion

        ; 定义插件项被双击或者回车时执行的处理函数, 函数有两个参数 that: 指向插件项, searchText: 搜索框搜索的内容
        fn(that, searchText) {
            PluginMode.showPluginMode( ; 启动插件模式
                data,
                search,
                (that, rowNum) => rowNum > 0 ?
                    PluginHelper.Utils.tip(this.name, that.pluginSearchResult[rowNum].title, 1500) : 0,
                (that, rowNum) => rowNum > 0 ?
                    PluginHelper.Utils.tip(this.name, "double Left" that.pluginSearchResult[rowNum].title, 1500) : 0,
                    loadImgs,
                    (that) => PluginHelper.Utils.tip(this.name, "列表触底通知：可以通过这种方式异步加载数量过大的列表", 1000, true),
                    menuInit, ,
                    "输入搜索内容吧！"
                )
        }
        ; 添加这个插件项到启动模式搜索界面，更详细的用法见PluginHelper.ahk
        PluginHelper.addPluginToStartupMode(
            this.name,
            "插件示例-启动插件模式",
            ["plugin demo", "CJSL"],
            fn, ,  ; 使用显式定义的函数
            m
        )
        ; 可以添加多个插件项，但每个插件的插件项应当具有相同的name，不同的title
        PluginHelper.addPluginToStartupMode(
            this.name,
            "插件示例-项目2",
            ["plugin demo", "CJSL"],
            (that, searchText) => (PluginHelper.Utils.tip(that.title, "搜索框内容:" searchText, 1000), PluginHelper.hideSearchGui()),
            (that, searchText) => PluginHelper.Utils.tip(that.title, "搜索框内容:" searchText, 1000), ,  ; 使用匿名函数作为双击left的处理函数
            ; 定义该插件项显示的图标HICON，此处用base64ToHICON方法将base64图片载入得到HICON
            PluginHelper.Utils.base64ToHICON("iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAnBJREFUWEfVlj9oFEEUxt+bLa6wF0whQcRCENOo2EUQYy/xZmb3sDKCoK0RhURQSFoFwdhcuNuZPY+AXKU22gmKiI2FAREbwUrwrI6dJxN2wv3Z21vZDWe2291vv/fbNx9vBmHKF065Pvy/AEKI60R0EhGPFekSEX1BxE9a68dpPqkdEEI0AcAvUjjl21BrHQw/HwGoVqsXGGMvE+E3ItosAoKIVwBg1noYYxZardarfr8RACHEDQB4aEWe5800m80fRQCCIDgax/F24nFTa/0oE4BzvoqIK1aktS4lpEIIsn5EdC+KotX9CyClXDLGzGQtCWNs2/O8541G44/TldIBKeUcEX3MkwfG2OkwDN+XCsA5n0XECADOTID4UKlUztfr9V+lAuT583GaUpZg6gC1Wu1Ar9dbdENlHJANYbfb7XQ6nd+lLoHv+6eMMe/ydIKIzkVR9KZUgCAIDsVxfBsATmRB2M0niqJr/Zr9mwHbymRP+BmG4ec87Xca3/ePx3F80N4j4uuJo1hKeYSI1gDABm3kQsR1pdRyHggp5RoR3RqjbSPislLq6w6cE3HOnyDi0oQCT7XWmRohxAYAXJ2Qkw2Xk12A/qAAwG6Ckxbav7mYmA68Syk0nzx7QUTrQ+/nh3faVIDhLdOaCCHuA8CdPEsAAA+01neHtWlbfW4AayalXDDGnM2CYIy9VUq5E9WAtDBAzr8fK+OcryDizoHEHXb+qQMlAIyctnKFsGjhvu8zQ/hs3AwoEcBZtbXWlwfmgJRykYiqAHBpDwr2W24hYksp1R4AcAo7EY0xh/cCgjH23U1A51/KsbsI7NQB/gIoe4UwRdVGRAAAAABJRU5ErkJggg==")
        )

        ; 添加这个插件项到智能模式搜索界面，更详细的用法见PluginHelper.ahk
        PluginHelper.addPluginToIntelligentMode(
            this.name,
            "插件示例-智能模式项目",
            [[".+", "$0"], ["(demo|sl|示例)\s+(?<query>.*)", "${query}"]], ;一种是任意字符匹配，一种是前缀匹配，都用正则实现
            (that, content) => PluginHelper.Utils.tip(that.title, "传递内容:" content, 1000)
        )

        ; PluginHelper.Utils.tip("插件已加载", "demo.ahk")
        ; 该插件入口函数执行完毕
    }
}