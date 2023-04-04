class Start {
    static startFile(path, workingDir := "", options := "", beforeRun := "") {
        if !(FileExist(path)) {    ;文件不存在
            res := MsgBox("文件不存在:" path "`n是否尝试打开原文件夹?", "文件不存在", 0x40041)
            if (res = "OK") {
                SplitPath(path, , &outDir)
                try Run(outDir)
            }
        } else {
            if !(workingDir)    ;默认使用文件所在文件夹作为工作目录
                SplitPath(path, , &workingDir)

            if (Type(beforeRun) == 'BoundFunc' or Type(beforeRun) == 'Func')
                beforeRun()
            try {
                Run(path, workingDir, options, &outPID)
                return outPID
            }
        }
    }

    static openFileInFolder(path) {
        if (FileExist(path)) {
            try Run('explorer.exe /select,"' path '"')
        } else {
            SplitPath(path, , &outDir)
            try Run(outDir)
        }
    }
}