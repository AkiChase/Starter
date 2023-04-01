/**
 * GetSelectedText(clipWaitSec := 1, &outType := unset)
 * @param clipWaitSec 剪切板等待选中内容的时间
 * @param &outType 返回选中内容的类型, bitmap:位图, file:文件, text:文本, unknow:未知类型, timeout:剪切板等待超时
 * 
 * AHK v2.x
 * Created by ruchuby on 2023.2.21
 * 获取选中内容的文本和内容类型
 */

GetSelectedText(clipWaitSec := 1, &outType := unset) {
    seleted := ""
    ClipSaved := ClipboardAll()

    A_Clipboard := ""
    Send("^c")
    if (ClipWait(clipWaitSec)) {
        if (DllCall("IsClipboardFormatAvailable", "uint", 2))    ; 位图
            outType := "bitmap"
        else if (DllCall("IsClipboardFormatAvailable", "uint", 15))    ; 文件
            outType := "file"
        else    ; 文本或未知
            outType := DllCall("IsClipboardFormatAvailable", "uint", 1) ? "text" : "unknow"
        seleted := A_Clipboard
    } else
        outType := "timeout"    ; 超时

    A_Clipboard := ClipSaved
    return seleted
}