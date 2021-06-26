pro scenario1

dllPath = 'CallSample.dll' ; or full path to the DLL

; Create execution object
data = CALL_EXTERNAL(dllPath, 'CreateEx', 40, /ALL_VALUE) ; returns 0 if something go wrong; otherwise, returns handle for consequent calls;
                                              ; process will be automatically finished after 40 seconds from start
if data ne 0 then begin
  data = ulong64(data)
  
  ; Start execution
  rc = CALL_EXTERNAL(dllPath, 'StartEx', data, /ALL_VALUE) ; returns 0 if something go wrong; otherwise, returns 1
  if rc ne 0 then begin

    ; do some work or just wait, say, 20 seconds
    elapsedTime = CALL_EXTERNAL(dllPath, 'GetStateEx', data, /ALL_VALUE) ; returns 20
    isActive = CALL_EXTERNAL(dllPath, 'IsActiveEx', data, /ALL_VALUE);  returns 1
    
    ; do some work for a long time (another more that 20 seconds), process should be automatically finished
    elapsedTime = CALL_EXTERNAL(dllPath, 'GetStateEx', data, /ALL_VALUE) ; returns 40, time for automatic finish
    isActive = CALL_EXTERNAL(dllPath, 'IsActiveEx', data, /ALL_VALUE);  returns 0 - long time is elapsed, execution process terminated automatically
    
    ; rc = CALL_EXTERNAL(dllPath, 'FinishEx', data, /ALL_VALUE) ; we do not need to call it in this scenario, process finished automatically

  end
  
  rc = CALL_EXTERNAL(dllPath, 'DeleteEx', data, /ALL_VALUE, /UNLOAD) ; anyway, destroy the execution object 
                                                                     ; and unload the library (if necessary)

end

end
