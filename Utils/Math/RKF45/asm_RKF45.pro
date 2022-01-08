function asm_RKF45, funcname, funcpar, boundname, boundpar, v, t, step, h, dir = dir, absErr = absErr, relErr = relErr, absBoundAchieve = absBoundAchieve ; in/out
              
if n_elements(dir) eq 0 then dir = 1L              
if n_elements(absErr) eq 0 then absErr = 0d              
if n_elements(relErr) eq 0 then relErr = 1d-9              
if n_elements(absBoundAchieve) eq 0 then absBoundAchieve = 0              

; cpp:
; None = 0, EndByStep = 1, End = 2, EndByCond = 3, EndNoMove = 4, 
; TooManyCalcs = 11, WrongErrBound = 12, TooLittleStep = 13, TooManyExits = 14, WrongCall = 15}  Status;

; IDL
sOK = 0
sEndByCond = 3
sEndNoMove = 4
sTooLittleStep = 13

u26 = 26d * asm_epsilon()

nfe = 0L

t = t * 1d
dt = step * 1d
tOut = t + dt
v = v * 1d
h = h * 1d

status = call_function(funcname, funcpar, dir, t, v, vp)

if h eq 0 then begin ; calc initial step
    ht = abs(dt)
    bH = 0
    tol = relErr*abs(v) + absErr
    yp = abs(vp)
    for k = 0, n_elements(v)-1 do begin
        if tol[k] gt 0d then begin
            bH = 1
            if yp[k]*ht^5 gt tol[k] then ht = (tol[k]/yp[k])^0.2d
        endif    
    endfor    

    if ~bH then ht = 0d

    h = abs(t)
    if abs(dt) gt h then h = abs(dt)
    h *= u26
    h = max([h, ht])
endif

if h*dt lt 0 then h = -h

;kop = 0L
;if abs(h) ge 2*abs(dt) then kop++
;check kop gt maxkop CagmRKF45::Status::TooManyExits &

if abs(dt) le u26 then begin ; too close to the end; extrapolate to the end
    v += dt*vp
    result = v
    return, sOK
endif

bOutput = 0
scale = 2d/relErr
ae = scale*absErr

bNearBound = 0
nearBoundH = 0d
esttol = 0d
isnext = 0

while 1 do begin ; step by step...

    bHFailed = 0
    hmin = u26*abs(t);  // min. possible step

    dt = tOut - t;
    if abs(dt) lt 2d*abs(h) then begin
     
        if abs(dt) gt abs(h) then begin
            h = 0.5d*dt;
        endif else begin ; next successful step will terminate integration up to tOut
            bOutput = 1
            h = dt
        endelse
    endif
    
    res = 0
    while 1 do begin
        ; NB! m_nfe > MAX_NFE CagmRKF45::Status::TooManyCalcs
        status = asm_RKF45_fehl(funcname, funcpar, t, h, dir, v, vp, s, ee)
        nfe += 5
        cond = status eq 0 ? 0 : call_function(boundname, boundpar, v)
        
        if status ne 0 || cond ne 0 then begin ; near boundary
            bNearBound = TRUE
            nearBoundH = h
            mult = status lt 2 ? 0.9d : (status lt 4 ? 0.81d : (status lt 8 ? 0.45d : (status lt 16 ? 0.34 : 0.22)))
            h *= mult;
            
            if abs(h) le absBoundAchieve then return, isnext ? sEndByCond : sEndNoMove;
        endif else begin
            et = abs(v) + abs(s) + ae
            ; NB! any et le 0 ???
            ee /= et
            eeoet = max(ee)

            esttol = abs(h)*eeoet*scale / 752400d;
            if esttol le 1d then break ; success

            ; unsuccessful step   
            bHFailed = 1
            bOutput = 0
                
            mult = esttol lt 59049d ? 0.9d / esttol^0.2d : 0.1 ; next step, decrease up to 0.1
            h *= mult
            if abs(h) le hmin then return, sTooLittleStep
        endelse
    endwhile
    
    ; success
    isnext = 1
    t += h
    v = s
    status = call_function(funcname, funcpar, dir, t, v, vp)
    nfe++

    mult = 5d ; next step, increase up to 5
    if esttol gt 1.889568d-4 then mult = 0.9d/esttol^0.2d
    if bHFailed && mult gt 1.0 then mult = 1d
    if bNearBound && mult gt 1.3 && abs((nearBoundH - h) / nearBoundH) lt 0.2d then mult = 1.3d
    ht = mult*abs(h)
    if ht lt hmin then ht = hmin
    h = ht * (h < 0 ? -1 : 1)

    if bOutput then begin ; next step?
        t = tOut
        return,  sOK
    endif    
endwhile

end