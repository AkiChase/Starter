/**
 * @Name: PluginHelper
 * @Version: 0.0.3
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-03
 * @Description: 插件API封装
 */

class PluginHelper {
    static funcList := []
    static pluginMenu := Menu()

    static init() {
        TrayMenu.menu.Insert("用户数据`t(&D)", "插件功能`t(&F)", this.pluginMenu) ; 插件托盘菜单
        for f in this.funcList ; 执行入口函数
            f()
        ;加载插件的图标
        StartupMode.pluginLoadImgs()
        IntelligentMode.pluginLoadImgs()
    }

    /**
     * @description: 添加插件入口函数到执行队列，基本功能初始化后执行
     * @param f 插件入口函数
     */
    static addEntryFunc(f) {
        this.funcList.Push(f)
    }

    /**
     * @description: 添加插件项到智能模式列表
     * @param name 插件id, 即文件名
     * @param title 插件项显示标题
     * @param reg 插件项正则替换列表[[exp1,replace1],...]
     * @param runHandler 鼠标双击、回车该插件项时执行的函数
     * (that, content)=>any that指向添加的插件项对象, content为正则替换后的内容
     * @param menu 选填, 右键该插件项显示的菜单
     * @param hIcon 选填, 插件项显示的图标HICON, 默认使用插件的图标
     */
    static addPluginToIntelligentMode(name, title, reg, runHandler, menu?, hIcon?) {
        plugin := { name: name, title: title, reg: reg, runHandler: runHandler }
        for n in ["menu", "hIcon"] {
            if (IsSet(%n%))
                plugin.%n% := %n%
        }
        IntelligentMode.pluginData.Push(plugin)
    }


    /**
     * @description: 添加插件项到启动模式列表
     * @param name 插件id, 即文件名
     * @param title 插件项显示标题
     * @param keywords 插件项关键字
     * @param startHandler 鼠标双击、回车该插件项时执行的函数 (that, searchText)=>any that指向添加的插件项对象
     * @param doubleLeftHandler 选填, 双击Left该插件项时执行的函数 (that, searchText)=>any that指向添加的插件项对象
     * @param menu 选填, 右键该插件项显示的菜单
     * @param hIcon 选填, 插件项显示的图标HICON, 默认使用插件的图标
     */
    static addPluginToStartupMode(name, title, keywords, startHandler, doubleLeftHandler?, menu?, hIcon?) {
        plugin := { name: name, title: title, keywords: keywords, startHandler: startHandler }
        for n in ["doubleLeftHandler", "menu", "hIcon"] {
            if (IsSet(%n%))
                plugin.%n% := %n%
        }
        StartupMode.pluginData.Push(plugin)
    }

    /**
     * @description: 获取插件图标hIcon，使用HICON时请加*以使用副本，避免句柄用后销毁
     * @param pluginName 插件名称, 即文件名
     * @return 有图标返回hIcon, 无图标则返回0
     */
    static getPluginHIcon(pluginName) {
        for info in PluginGui.pluginList {
            if (pluginName == info["name"])
                return info["iconHIcon"]
        }
        return 0
    }

    /**
     * @description: 获取插件图标base64
     * @param pluginName 插件名称, 即文件名
     * @return 有图标返回base64, 无图标则返回0
     */
    static getPluginIconBase64(pluginName) {
        for info in PluginGui.pluginList {
            if (pluginName == info["name"])
                return info["iconBase64"]
        }
        return 0
    }

    /**
     * @description: 隐藏搜索框
     */
    static hideSearchGui() {
        SearchGui.hideGui()
    }

    /**
     * @description: 启动插件模式
     * @param pluginSearchData 用于插件模式搜索的数据
     * @param searchHandler 插件模式搜索处理函数 (that, searchText) => void
     * @param runHandler 插件模式回车、双击任意项时的处理函数 (that, rowNum) => void
     * @param doubleLeftHandler (可选)插件模式双击Left时的处理函数 (that, rowNum) => void
     * @param loadImgsHandler (可选)加载插件模式图片的处理函数 (that) => void
     * @param menuInitHandler (可选)右键显示菜单栏初始化处理函数 (that) => void
     * @param searchText (可选)启动时设置搜索框文本
     * @param placeholder (可选)设置搜索框占位符
     */
    static showPluginMode(pluginSearchData, searchHandler, runHandler, doubleLeftHandler?, loadImgsHandler?, menuInitHandler?, searchText := "", placeholder := "") {
        PluginMode.showPluginMode( ; 启动插件模式
            pluginSearchData, searchHandler, runHandler, doubleLeftHandler?,
            loadImgsHandler?, menuInitHandler?, searchText, placeholder
        )
    }

    class Utils {
        /**
         * @description: 载入文件路径对应的图标为HICON 可以直接关联到图标源头
         */
        static filePathToHICON(filePath) {
            return DllCall("Shell32\ExtractAssociatedIcon", "Ptr", 0, "Str", filePath, "ShortP", 1, "Ptr")
        }

        /**
         * @description: 载入base64图片为HICON
         */
        static base64ToHICON(base64)
        {
            nBytes := Floor((B64Len := StrLen(base64 := RTrim(base64, "="))) * 3 / 4)
            buf := Buffer(nBytes)

            DllCall("Crypt32.dll\CryptStringToBinary", "str", base64, "int", B64Len, "int", 1, "ptr", buf, "uintp", nBytes, "Int", 0, "Int", 0)
            Return DllCall("User32.dll\CreateIconFromResourceEx", "ptr", buf, "int", nBytes, "int", 1, "int", 0x30000, "Int", 0, "Int", 0, "Int", 0, "ptr")
        }

        /**
         * @description: 右下角通知
         * @param title 标题
         * @param content 内容
         * @param time 计时消失时间(选填)
         */
        static tip(title, content, time?) {
            Tip.show(title, content, time?)
        }

        /**
         * @description: 数组快速排序(不生成副本)
         * @param arr 待排序数组
         * @param fn (itemA, itemB)=> number 比较函数
         * @example 
         * ; 升序排序示例
         * arr:=[1,9,2,8,3,7]
         * QuickSort(arr, (a,b)=>a-b)
         */
        static quickSort(arr, fn) {
            return QuickSort(arr, fn)
        }
    }


}