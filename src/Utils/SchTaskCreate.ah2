/**
 * @Name: SchTaskCreate.ah2
 * @Version: 0.0.1
 * @Author: AkiChase
 * @LastEditors: AkiChase
 * @LastEditTime: 2023-12-31
 * @Description: 创建登录启动计划任务
 */

; A_Args=[ahk_path, script_path, arg]

; 创建 Schedule.Service COM 对象
scheduleService := ComObject("Schedule.Service")

; 连接到本地计算机
scheduleService.Connect()

; 获取 TaskFolder 对象
rootFolder := scheduleService.GetFolder("\")

; 创建任务定义
taskDef := scheduleService.NewTask(0)

; 创建触发器
trigger := taskDef.Triggers.Create(9) ; 表示触发器类型为登录
trigger.Delay := "PT6S"

; 创建操作
action := taskDef.Actions.Create(0) ; 0 表示动作类型为运行程序
action.Path := A_Args[1]
action.Arguments := Format('"{}" "{}"', A_Args[2], A_Args[3])

settings := taskDef.Settings
settings.DisallowStartIfOnBatteries := false
settings.StopIfGoingOnBatteries := false

; 注册任务
registeredTask := rootFolder.RegisterTaskDefinition(
    "Starter",  ; 任务名称
    taskDef,
    6,  ; 6 表示创建或更新任务
    "", "", 3
)