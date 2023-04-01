/**
 * @Name: PluginHelper
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-03-29
 * @Description: 插件API封装
 */

class PluginHelper {
    static funcList := []
    static pluginMenu := Menu()

    static init() {
        TrayMenu.menu.Insert("用户数据`t(&D)", "插件功能`t(&F)", this.pluginMenu) ; 插件托盘菜单
        for f in this.funcList ; 执行入口函数
            f()
    }

    /**
     * @description: 添加插件入口函数到执行队列，基本功能初始化后执行
     * @param f 插件入口函数
     */
    static addEntryFunc(f) {
        this.funcList.Push(f)
    }

    /**
     * @description: 获取插件图标hBitmap
     * @param pluginName 插件名称, 即文件名
     * @return 有图标返回hBitmap, 无图标则返回0
     */
    static getPluginIcon(pluginName) {
        for info in PluginGui.pluginList {
            if (pluginName == info["name"])
                return info["iconHBitmap"]
        }
        return 0
    }
}