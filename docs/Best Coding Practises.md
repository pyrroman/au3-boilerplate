# Best coding practises

###### [AutoIt Wiki Best coding practises](http://www.autoitscript.com/wiki/Best_coding_practices)

## Using handles instead of direct calls/writes

```autoit
Global $hDLL=DllOpen("some.dll")
Global $hFILE=FileOpen("some.file")

For $i=1 to 1000
  DllCall($hDLL)
  FileWrite($hFILE, "something")
Next

FileClose($hFILE)
DllClose($hDLL)
```

is always a bit faster than

```autoit
For $i=1 to 1000
  DllCall("some.dll")
  FileWrite("some.file", "something")
Next
```
