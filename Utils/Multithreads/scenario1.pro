pro scenario1

dllPath = 's:\Projects\Physics\TestW2\x64\Release\CallSample.dll' ; or full path to the DLL

; Start execution
data = CALL_EXTERNAL(dllPath, 'Start') ; returns 0 if something go wrong; otherwise, returns handle for consequent calls
if data ne 0 then begin

  ; do some work or just wait, say, 20 seconds
  elapsedTime = CALL_EXTERNAL(dllPath, 'GetState', ulong64(data), /ALL_VALUE) ; returns 20
  isActive = CALL_EXTERNAL(dllPath, 'IsActive', ulong64(data), /ALL_VALUE);  returns 1
  
  ; do some work or just wait some time
  elapsedTime = CALL_EXTERNAL(dllPath, 'GetState', ulong64(data), /ALL_VALUE) ; returns < 60, if not finished, 60 otherwise
  isActive = CALL_EXTERNAL(dllPath, 'IsActive', ulong64(data), /ALL_VALUE);  returns 1, if not finished, 0 otherwise
  
  elapsedTime = CALL_EXTERNAL(dllPath, 'Finish', ulong64(data), /ALL_VALUE)

end

end