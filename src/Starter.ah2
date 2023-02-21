ListLines False
#SingleInstance Force
FileEncoding("UTF-8-RAW")

#Include .\utils\ChineseFirstChar.ah2
#Include .\utils\MapArrClone.ah2
#Include .\utils\GetSelectedText.ah2
#Include .\utils\JXON.ah2
#Include .\utils\WinHttp.ah2
#Include .\utils\IME.ah2
#Include .\utils\QuickSort.ah2
#Include .\utils\DataHelper.ah2
#Include .\utils\Start.ah2

#Include .\utils\GlobalData.ah2
GlobalData.init()

#Include .\Gui\TrayMenu.ah2
TrayMenu.init()

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



OnExit((*) => GlobalData.onExitHandler())    ;退出时保存数据

;@Ahk2Exe-IgnoreBegin
^!q:: {
    Send("^s")
    Reload()
}
;@Ahk2Exe-IgnoreEnd
