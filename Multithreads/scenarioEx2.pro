pro scenario2

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
    
    ; we decide to finish execution prematurely
    rc = CALL_EXTERNAL(dllPath, 'FinishEx', data, /ALL_VALUE) ; query to prematurely finishing; note that this call is asynchronous! 
                                                              ; wait while IsActiveEx(...) eq 0
    
    isActive = CALL_EXTERNAL(dllPath, 'IsActiveEx', data, /ALL_VALUE) ; if returns 1 - finishing process is not completed yet
                                                                      ; (store data can take some time)

    ; wait some time
    
    isActive = CALL_EXTERNAL(dllPath, 'IsActiveEx', data, /ALL_VALUE) ; returns 0 - finishing process is at last completed
                                                                      ; we can destroy the object

  end
  
  rc = CALL_EXTERNAL(dllPath, 'DeleteEx', data, /ALL_VALUE, /UNLOAD) ; anyway, destroy the execution object 
                                                                     ; and unload the library (if necessary)

end

end