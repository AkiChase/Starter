/**
 * @Name: Starter
 * @Version: 0.2.0
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-02
 * @Description: 介绍Starter 是一款AHK编写的快速启动工具，旨在方便快捷地启动文件、文件夹，提高电脑的使用效率。
 */
#NoTrayIcon ; 先隐藏图标

ListLines False
#SingleInstance Force
FileEncoding("UTF-8-RAW")

; DEBUG := true

#Include .\Utils\GlobalData.ah2
GlobalData.init()
TraySetIcon(GlobalData.imgDir "\Starter.ico", , true) ; 设置图标

#Include .\Utils\Class_Loader.ah2
#Include .\Utils\LoadIconFromBase64.ah2
#Include .\Gui\PluginGui.ah2
PluginGui.init() ;同时重启以加载插件

#Include .\Utils\ChineseFirstChar.ah2
#Include .\Utils\MapArrClone.ah2
#Include .\Utils\GetSelectedText.ah2
#Include .\Utils\JXON.ah2
#Include .\Utils\WinHttp.ah2
#Include .\Utils\IME.ah2
#Include .\Utils\QuickSort.ah2
#Include .\Utils\DataHelper.ah2
#Include .\Utils\Start.ah2
#Include .\Utils\WiseGuiHelper.ah2
#Include .\Utils\7Zip\SevenZip.ahk

WiseGuiHelper.setTooltipOpt(, , "s14 Bold, 雅痞-简", "s12, 雅痞-简", 225
    , "0x805D6B,0xFFFFFF,0xF5F5DC,*" . LoadPicture(GlobalData.imgDir "\Starter.ico", , &ImageType) ;加*使用副本
    , , , "4,1,1,3", true, , "RollWest@250", "RollEast@250")

#Include .\Gui\BootGui.ah2
BootGui.init()

#Include .\Gui\SearchGui\SearchGui.ah2
#Include .\Gui\SearchGui\StartupMode.ah2
#Include .\Gui\SearchGui\IntelligentMode.ah2
SearchGui.init()

#Include .\Gui\StartupEditGui.ah2
StartupEditGui.init()

#Include .\Gui\IntelligentEditGui.ah2
IntelligentEditGui.init()

#Include .\Gui\AboutGui.ah2
AboutGui.init()

#Include .\Gui\TrayMenu.ah2
TrayMenu.init()

#Include .\Utils\PluginHelper.ah2
PluginHelper.init() ;同时执行所有插件的入口函数


if (!IsSet(DEBUG) || !DEBUG)
    OnExit((*) => GlobalData.onExitHandler())    ;退出时保存数据

;@Ahk2Exe-IgnoreBegin
^!q:: {
    Send("^s")
    Reload()
}
;@Ahk2Exe-IgnoreEnd
