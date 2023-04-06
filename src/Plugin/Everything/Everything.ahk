/**
 * @Name: Everything.ahk
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-06
 * @Description: Everything文件搜索基本功能封装，请自行安装、运行Everything
 */

; example====================================
; Everything.loadLibrary()
; Everything.setRequestFlags(0x00000004 | 0x00000010 | 0x00000020 | 0x00000040) ;名称路径|大小|创建日期|修改日期
; Everything.setSort(Everything.CONSTANT_SETSORT.EVERYTHING_SORT_PATH_ASCENDING)

; ;语法见 https://www.voidtools.com/zh-cn/support/everything/searching/
; Everything.setSearch("file: AutoHotkey.exe") ;仅搜索文件: AutoHotkey.exe
; if (!Everything.query()) {
;   MsgBox("检索失败, 状态码:" Everything.getLastError())
;   return
; }
; num := Everything.getNumResults()
; loop num > 5 ? 5 : num {
;   i := A_Index - 1
;   MsgBox(Everything.getResultFullPathName(i)
;     . "`n文件大小: " Round(Everything.getResultSize(i) / 1024) "Kb"
;     . "`n创建时间: " Everything.getResultDateCreated(i)
;     . "`n修改时间: " Everything.getResultDateModified(i))
; }
; Everything.freeLibrary()
;===========================================


class Everything {
  /**
   * @description: 加载函数库加快调用速度
   */
  static loadLibrary(dllPath?) {
    if (!IsSet(dllPath)) {
      ; 库文件同目录下
      dllPath := RegExReplace(A_LineFile, "[^\\]+$", A_PtrSize = 8 ? "Everything64.dll" : "Everything32.dll")
    }
    this.hModule := DllCall("LoadLibrary", "Str", dllPath, "Ptr")
    this.dllPath := dllPath
  }

  static CONSTANT_SETREQUESTFLAGS := {
    EVERYTHING_REQUEST_FILE_NAME: 0x00000001,
    EVERYTHING_REQUEST_PATH: 0x00000002,
    EVERYTHING_REQUEST_FULL_PATH_AND_FILE_NAME: 0x00000004,
    EVERYTHING_REQUEST_EXTENSION: 0x00000008,
    EVERYTHING_REQUEST_SIZE: 0x00000010,
    EVERYTHING_REQUEST_DATE_CREATED: 0x00000020,
    EVERYTHING_REQUEST_DATE_MODIFIED: 0x00000040,
    EVERYTHING_REQUEST_DATE_ACCESSED: 0x00000080,
    EVERYTHING_REQUEST_ATTRIBUTES: 0x00000100,
    EVERYTHING_REQUEST_FILE_LIST_FILE_NAME: 0x00000200,
    EVERYTHING_REQUEST_RUN_COUNT: 0x00000400,
    EVERYTHING_REQUEST_DATE_RUN: 0x00000800,
    EVERYTHING_REQUEST_DATE_RECENTLY_CHANGED: 0x00001000,
    EVERYTHING_REQUEST_HIGHLIGHTED_FILE_NAME: 0x00002000,
    EVERYTHING_REQUEST_HIGHLIGHTED_PATH: 0x00004000,
    EVERYTHING_REQUEST_HIGHLIGHTED_FULL_PATH_AND_FILE_NAME: 0x00008000,
  }

  /**
   * @description: 设置搜索需要返回哪些结果的选项
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_setrequestflags/
   * @param flags 可通过|(按位或运算叠加选项) 
   * EVERYTHING_REQUEST_FILE_NAME                            :=0x00000001
   * EVERYTHING_REQUEST_PATH                                 :=0x00000002
   * EVERYTHING_REQUEST_FULL_PATH_AND_FILE_NAME              :=0x00000004
   * EVERYTHING_REQUEST_EXTENSION                            :=0x00000008
   * EVERYTHING_REQUEST_SIZE                                 :=0x00000010
   */
  static setRequestFlags(flags) {
    DllCall(this.dllPath "\Everything_SetRequestFlags", "int", flags) ; 可通过|(按位或运算叠加选项)
  }

  static CONSTANT_SETSORT := {
    EVERYTHING_SORT_NAME_ASCENDING: 1,
    EVERYTHING_SORT_NAME_DESCENDING: 2,
    EVERYTHING_SORT_PATH_ASCENDING: 3,
    EVERYTHING_SORT_PATH_DESCENDING: 4,
    EVERYTHING_SORT_SIZE_ASCENDING: 5,
    EVERYTHING_SORT_SIZE_DESCENDING: 6,
    EVERYTHING_SORT_EXTENSION_ASCENDING: 7,
    EVERYTHING_SORT_EXTENSION_DESCENDING: 8,
    EVERYTHING_SORT_TYPE_NAME_ASCENDING: 9,
    EVERYTHING_SORT_TYPE_NAME_DESCENDING: 10,
    EVERYTHING_SORT_DATE_CREATED_ASCENDING: 11,
    EVERYTHING_SORT_DATE_CREATED_DESCENDING: 12,
    EVERYTHING_SORT_DATE_MODIFIED_ASCENDING: 13,
    EVERYTHING_SORT_DATE_MODIFIED_DESCENDING: 14,
    EVERYTHING_SORT_ATTRIBUTES_ASCENDING: 15,
    EVERYTHING_SORT_ATTRIBUTES_DESCENDING: 16,
    EVERYTHING_SORT_FILE_LIST_FILENAME_ASCENDING: 17,
    EVERYTHING_SORT_FILE_LIST_FILENAME_DESCENDING: 18,
    EVERYTHING_SORT_RUN_COUNT_ASCENDING: 19,
    EVERYTHING_SORT_RUN_COUNT_DESCENDING: 20,
    EVERYTHING_SORT_DATE_RECENTLY_CHANGED_ASCENDING: 21,
    EVERYTHING_SORT_DATE_RECENTLY_CHANGED_DESCENDING: 22,
    EVERYTHING_SORT_DATE_ACCESSED_ASCENDING: 23,
    EVERYTHING_SORT_DATE_ACCESSED_DESCENDING: 24,
    EVERYTHING_SORT_DATE_RUN_ASCENDING: 25,
    EVERYTHING_SORT_DATE_RUN_DESCENDING: 26
  }
  /**
   * @description: 设置搜索结果排序方式
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_setsort/
   * @param mode 方式编号 默认文件路径升序排序:EVERYTHING_SORT_PATH_ASCENDING:=3
   * 文件路径升序排序:EVERYTHING_SORT_PATH_ASCENDING:=3
   * 创建时间升序排序:EVERYTHING_SORT_DATE_CREATED_ASCENDING:=11
   * 修改时间降序排序:EVERYTHING_SORT_DATE_MODIFIED_DESCENDING:=14
   */
  static setSort(mode := this.CONSTANT_SETSORT.EVERYTHING_SORT_PATH_ASCENDING) {
    DllCall(this.dllPath "\Everything_SetSort", "int", mode)
  }

  /**
   * @description: 设置从对Everything_Query的调用返回的结果偏移量
   * 设置为0以从第一个可用结果开始返回
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_setoffset/
   */
  static setOffset(offset := 0) {
    DllCall(this.dllPath "\Everything_SetOffset", "int", offset)
  }

  /**
   * @description: 设置从Everything_Query返回的最大结果数
   * 设置为0以从第一个可用结果开始返回将其设置为0xffffffff将返回所有结果
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_setmax/
   */
  static setMax(maxCount := 0xffffffff) {
    DllCall(this.dllPath "\Everything_SetMax", "int", maxCount)
  }

  /**
   * @description: 设置搜索内容(未开始搜索), 释放旧搜索并分配新搜索字符串
   * https://www.voidtools.com/zh-cn/support/everything/searching/
   * @param findStr 搜索内容
   */
  static setSearch(findStr) {
    DllCall(this.dllPath "\Everything_SetSearch", "Str", FindStr)
  }

  /**
   * @description: 搜索并等待结果，释放旧的结果列表并分配新的结果列表
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_query/
   * @return 是否搜索成功
   */
  static query() {
    return DllCall(this.dllPath "\Everything_Query", "int", 1)
  }

  /**
   * @description: 返回所有文件和文件夹结果的总数, 0代表出错
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_gettotresults/
   */
  static getTotResults() {
    return DllCall(this.dllPath "\Everything_GetTotResults")
  }

  /**
   * @description: 返回可见(在offset和max限制下的)文件和文件夹结果的数量, 0代表出错
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_getnumresults/
   */
  static getNumResults() {
    return DllCall(this.dllPath "\Everything_GetNumResults")
  }

  /**
   * @description: 返回最后一个错误代码值
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_getlasterror/
   */
  static getLastError() {
    return DllCall(this.dllPath "\Everything_GetLastError")
  }

  /**
   * @description: 检索可见结果(在offset和max限制下)的完整路径和文件名
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_getresultfullpathname/
   */
  static getResultFullPathName(index) {
    size := 255 ;255个字符
    loop 4 { ;最大长度为4095个字符否则截断
      fullname := Buffer(size * 2, 0)
      count := DllCall(this.dllPath "\Everything_GetResultFullPathName", "int", index, "Ptr", fullname.Ptr, "int", size)
      if (count < size - 1)
        return StrGet(fullname)
      size *= 2
    }
    return StrGet(fullname)
  }

  /**
   * @description: 检索可见结果(在offset和max限制下)的大小(byte)
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_getresultsize/
   */
  static getResultSize(index) {
    size := 0
    DllCall(this.dllPath "\Everything_GetResultSize", "int", index, "int64*", &size)
    return size
  }

  /**
   * @description: 检索可见结果(在offset和max限制下)的创建日期
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_getresultdatecreated/
   */
  static getResultDateCreated(index) {
    date := Buffer(8, 0)
    DllCall(this.dllPath "\Everything_GetResultDateCreated", "int", index, "Ptr", date.Ptr)
    return this._getTime(date)
  }

  /**
   * @description: 检索可见结果(在offset和max限制下)的修改日期
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_getresultdatemodified/
   */
  static getResultDateModified(index) {
    date := Buffer(8, 0)
    DllCall(this.dllPath "\Everything_GetResultDateModified", "int", index, "Ptr", date.Ptr)
    return this._getTime(date)
  }

  ; 内部日期转换
  static _getTime(date) {
    static add_hours := DateDiff(A_Now, A_NowUTC, "Hours")
    sec := (NumGet(date, 4, "uint") << 32 | NumGet(date, 0, "uint")) // 10000000
    t := "16010101"
    return DateAdd(DateAdd(t, sec, "Seconds"), add_hours, "Hours")
  }

  /**
   * @description: 将结果列表和搜索状态重置为默认状态，释放相关内存
   * https://www.voidtools.com/zh-cn/support/everything/sdk/everything_reset/
   */
  static reset() {
    DllCall(this.dllPath "\Everything_Reset")
  }

  /**
   * @description: 释放函数库(引用-=1)，减少内存占用(进程退出会直接卸载函数库)
   */
  static freeLibrary() {
    DllCall("FreeLibrary", "Ptr", this.hModule)
  }
}