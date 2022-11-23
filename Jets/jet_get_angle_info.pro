function jet_get_angle_info, frames

stats = {n:0L, ang_min:0d, ang_max:0d, ang_mean:0d, ang_med:0d, ang_std:0d}

card_lim = 150
asp_lim = 4.5d
basp_lim = 4.5d
wasp_lim = 12d
max_lim = 45d
ang_lim = 30d

nang = 0
ang = dblarr(frames.Count())
maxa = -1d
maxb = -1d
maxw = -1d
idxa = 0
idxb = 0
idxw = 0
for f = 0, frames.Count()-1 do begin
    frame = frames[f]
    if frame.card eq 0 then continue
    
    if frame.card gt card_lim && frame.aspect gt asp_lim && frame.baspect gt basp_lim && frame.waspect gt wasp_lim then begin
        ang[nang] = frame.beta /!DTOR
        if frame.aspect gt maxa then begin
            maxa = frame.aspect
            idxa = nang 
        endif    
        if frame.baspect gt maxb then begin
            maxb = frame.baspect
            idxb = nang 
        endif    
        if frame.waspect gt maxw then begin
            maxw = frame.waspect
            idxw = nang
        endif
        
        nang++ 
    endif    
endfor

if nang gt 0 then begin
    jw = ang[idxw]
    sgnw = jw lt 0 ? -1 : 1
    
    ja = ang[idxa]
    jb = ang[idxb]
    if abs(ja-jw) gt 90 then ja += sgnw * 180d
    if abs(jb-jw) gt 90 then jb += sgnw * 180d
    if abs(ja-jw) lt 30 && abs(jb-jw) lt max_lim then begin
        j = dblarr(nang)
        cntn = 0
        for k = 1, nang-1 do begin
            if abs(ang[k]-jw) gt 90d then begin
                ang[k] += sgnw*180d
            endif    
            if abs(ang[k]-jw) lt ang_lim then begin
                j[cntn] = ang[k]
                cntn++
            endif    
        endfor
        
        jj = j[0:cntn-1]
        idx = where(jj lt 0, count)
        if count gt 0 then jj += 180 
        
        if cntn gt 0 then begin
            stats.n = cntn
            stats.ang_min = min(jj)
            stats.ang_max = max(jj)
            stats.ang_mean = mean(jj)
            stats.ang_med = median(jj)
            if cntn gt 1 then stats.ang_std = stddev(jj)
        endif    
    endif            
endif

return, stats

end
