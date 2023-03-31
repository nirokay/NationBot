import os, strformat, times
import ../typedefs

type LogFile* = enum
    logError = $fileLogError
    logDebug = $fileLogDebug
    logUSage = $fileLogUsage

proc newEntry(filepath, message: string) =
    if not filepath.fileExists():
        try:
            filepath.writeFile("")
        except IOError as e:
            echo &"{e.name}: {e.msg}\nFailed to create new log-file at '{filepath}'! Unlogged error message:\n{message}\n"
            return
    
    let
        timeNow: DateTime = now()
        timeDate: string = timeNow.format("yyyy-MM-dd")
        timeTime: string = timeNow.format("HH:mm:ss (zzz)")   # wacky variable name, so i will keep it 🥴
        msg: string = &"{timeDate} | {timeTime}\n{message}\n\n"
    
    let file: File = filepath.open(fmAppend)
    try:
        file.write(msg)
    except IOError as e:
        echo &"{e.name}: {e.msg}\nFailed to write to log-file at '{filepath}'! Unlogged error message:\n{message}\n"
    finally:
        file.close()


proc entry*(file: LogFile, message: string) = newEntry($file, message)
proc entry*(e: Exception | ref Exception) = newEntry($logError, &"{e.name}: {e.msg}")

