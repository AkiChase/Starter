class Start {
    /**
     * @description: 运行文件
     */
    static startFile(path, workingDir := "", options := "", beforeRun?) {
        if !(FileExist(path)) {    ;文件不存在
            res := MsgBox("文件不存在:" path "`n是否尝试打开原文件夹?", "文件不存在", 0x40041)
            if (res = "OK") {
                SplitPath(path, , &outDir)
                try Run(outDir)
            }
        } else {
            if !(workingDir)    ;默认使用文件所在文件夹作为工作目录
                SplitPath(path, , &workingDir)

            if (IsSet(beforeRun))
                beforeRun()
            try {
                Run(path, workingDir, options, &outPID)
                return outPID
            }
        }
    }
    
    /**
     * @description: 在文件夹中打开
     */
    static openFileInFolder(path) {
        if (FileExist(path)) {
            try Run('explorer.exe /select,"' path '"')
        } else {
            SplitPath(path, , &outDir)
            try Run(outDir)
        }
    }
}