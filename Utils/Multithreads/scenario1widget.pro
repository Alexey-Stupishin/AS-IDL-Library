function getStatusDescription, isActive, elapsedTime
; prepare text string to show

  elapsed = STRING(", elapsed ", elapsedTime, " s")
  if isActive eq 1 then begin
    outtext = "is active" + elapsed
  endif else begin
    outtext = "is finished" + elapsed
  endelse
  
  return, outtext 
end

pro wbuttons_event, event
; button callback

common ASYNCCOMMON, dllPath, data, statustext

; do not call external library functions after "Delete" call
if data eq 0 then begin
  WIDGET_CONTROL, statustext, SET_VALUE = "already terminated"
  return
end 

WIDGET_CONTROL, event.id, GET_UVALUE = eventval

case eventval of
  'ISACTIVE' : begin ; request status button pressed
      elapsedTime = CALL_EXTERNAL(dllPath, 'GetState', data, /ALL_VALUE)
      isActive = CALL_EXTERNAL(dllPath, 'IsActive', data, /ALL_VALUE)
      outtext = getStatusDescription(isActive, elapsedTime)
      WIDGET_CONTROL, statustext, SET_VALUE = outtext
      if isActive eq 0 then begin ; if already
        elapsedTime = CALL_EXTERNAL(dllPath, 'Finish', data, /ALL_VALUE)
        data = 0
      end 
    end 

  'FINISH' : begin ; finish button pressed
      elapsedTime = CALL_EXTERNAL(dllPath, 'Finish', data, /ALL_VALUE)
      outtext = getStatusDescription(0, elapsedTime)
      WIDGET_CONTROL, statustext, SET_VALUE = outtext
      data = 0
    end
endcase
end

pro scenario1widget

common ASYNCCOMMON, dllPath, data, statustext 

dllPath = 'CallSample.dll' ; or full path to the DLL

; Start execution
; data = CALL_EXTERNAL(dllPath, 'Start') ; returns 0 if something go wrong; otherwise, returns handle for consequent calls
data = 1 ; !!!!!!!!!! just for test

data = ulong64(data)
if data ne 0 then begin ; create and show widget
  base = WIDGET_BASE(TITLE = 'Asynchronous Call Example', XSIZE = 350, /COLUMN)
  statustext = WIDGET_TEXT(base, VALUE = 'started', YSIZE = 1, /FRAME)
  askbutton = WIDGET_BUTTON(base, VALUE = 'Status', UVALUE = 'ISACTIVE')
  stopbutton = WIDGET_BUTTON(base, VALUE = 'Finish', UVALUE = 'FINISH')
  WIDGET_CONTROL, base, /REALIZE
  XMANAGER, 'wbuttons', base, GROUP_LEADER = GROUP, /NO_BLOCK
endif

end