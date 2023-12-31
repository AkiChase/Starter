/**
 * @Name: SchTaskDel.ah2
 * @Version: 0.0.1
 * @Author: AkiChase
 * @LastEditors: AkiChase
 * @LastEditTime: 2023-12-31
 * @Description: 删除登录启动计划任务
 */


; 创建 Schedule.Service COM 对象
scheduleService := ComObject("Schedule.Service")
; 连接到本地计算机
scheduleService.Connect()
; 获取 TaskFolder 对象
rootFolder := scheduleService.GetFolder("\")
rootFolder.DeleteTask("Starter", 0)