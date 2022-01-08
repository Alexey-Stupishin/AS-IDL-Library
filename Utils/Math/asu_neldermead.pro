pro asu_neldermead, func, criteria, bound, context, x, xsol, iter, report = report

reflex = 1
expand = 2
contract = 0.5
shrink = 0.5

; initial simplex x(n+1, n), f(n+1, 1)
sz = size(x)
nsimp = sz[2] + 1
f = dblarr(nsimp)
for k = 0, nsimp-1 do begin
    f[k] = call_function(func, x[k, *], context)
endfor

iter = 0L
while ~call_function(criteria, x, f) do begin
    iter++
    fL = 1d300
    fG = 0
    fH = 0
    kH = -1
    kL = -1
    for k = 0, nsimp-1 do begin
        if f[k] gt fH then begin
            fH = f[k]
            kH = k
        endif
        if f[k] lt fL then begin
            fL = f[k]
            kL = k
        endif
    endfor
    for k = 0, nsimp-1 do begin
        if k eq kH then begin
            continue
        endif
        if f[k] gt fG then begin
            fG = f[k]
        endif
    endfor
    
    if n_elements(report) ne 0 then call_procedure, report, x[kL, *]
    
    xL = x[kL, *]
    xH = x[kH, *]
    x0 = (total(x, 1) - xH)/(nsimp-1)
    
    call_procedure, bound, (1+reflex)*x0 - reflex*xH, xR
    fR = call_function(func, xR, context)
    
    if fR lt fL then begin ; good direction
        call_procedure, bound, expand*xR + (1-expand)*x0, xE
        fE = call_function(func, xE, context)
        if fE lt fL then begin ; good expand, use it
            x[kH, *] = xE
            xR = xE
            f[kH] = fE
        endif else begin ; bad expand, use reflexed
            x[kH, *] = xR
            f[kH] = fR
        endelse
    endif else begin ; bad direction
        if fR lt fG then begin ; reflexed is better than G, H
            x[kH, *] = xR
            f[kH] = fR
        endif else begin ; collapse
            if fR lt fH then begin
                x[kH, *] = xR
                f[kH] = fR
            endif
            xC = contract*xH + (1-contract)*x0    
            fC = call_function(func, xC, context)
            if fC lt fH then begin
                x[kH, *] = xC
                f[kH] = fC
            endif else begin ; total collapse
                for k = 0, nsimp-1 do begin
                    x[k, *] = (x[k, *] + xL)*shrink
                endfor
            endelse
        endelse
    endelse
endwhile

xsol = xL

end
