ListLines False
#SingleInstance Force
FileEncoding("UTF-8-RAW")

#Include .\utils\ChineseFirstChar.ah2
#Include .\utils\JXON.ah2
#Include .\utils\IME.ah2
#Include .\utils\QuickSort.ah2
#Include .\utils\DataHelper.ah2
#Include .\utils\Start.ah2

#Include .\utils\GlobalData.ah2
GlobalData.init()

#Include .\Gui\TrayMenu.ah2
TrayMenu.init()

#Include .\Gui\SearchGui.ah2
SearchGui.init()

#Include .\Gui\EditGui.ah2
EditGui.init()

#Include .\Gui\BootGui.ah2
BootGui.init()

OnExit((*) => GlobalData.storeProgramData())    ;退出时保存数据

;@Ahk2Exe-IgnoreBegin
!q:: {
    Send("^s")
    Reload()
}
;@Ahk2Exe-IgnoreEnd