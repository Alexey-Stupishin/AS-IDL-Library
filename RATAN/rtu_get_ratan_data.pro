function rtu_get_ratan_data, filename
compile_opt idl2

header = {version:'none', created:'none', DATE_OBS:'none', TIME_OBS:'none', CDELT1:0d, AZIMUTH:0d $
        , SOL_DEC:0d, SOLAR_R:0d, SOLAR_P:0d, SOLAR_B:0d, RATAN_P:0d, N_POS:0d, N_FREQS:0d, N_POINTS:0d, user_sel_freqs:'', shift:0d}
htypes = [0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,1]        
params = {OTZENTRA:0d, CAL_FREQ:0d, CAL_BY:'none', METHOD:'none', X_FROM:0d, X_TO:0d, X_FRFR:0d, PTS_BY:'none'}
ptypes = [1,1,0,0,1,1,1,0]        
mode = ''
row = 0

taghead = tag_names(header)
tagpar = tag_names(params)
predefined = ['RATAN Spectra-At-Positions Data File ', ' RATAN Selected Scans Data File ', 'generated at ', 'frequencies selected by user for scan ']
predefv = ['version', 'version', 'created', 'user_sel_freqs']

str = ''
line = 0
openr, U, filename, /GET_LUN
while not EOF(U) do begin
    readf, U, str
    expr = stregex(str, '# (.*)',/subexpr,/extract)
    if n_elements(expr) ne 2 || strlen(expr[1]) eq 0 then break
    line++
    predef = 0
    for k = 0, n_elements(predefined)-1 do begin
        if strlen(expr[1]) lt strlen(predefined[k]) then continue
        if strcmp(predefined[k], strmid(expr[1], 0, strlen(predefined[k]))) then begin
            for j = 0, n_elements(taghead)-1 do begin
                if strcmp(taghead[j], predefv[k], /fold_case) then begin
                    predef = 1
                    if k le 1 then mode = k eq 0 ? 'spectra' : 'scans'
                    header.(j) = strmid(expr[1], strlen(predefined[k]))
                    break
                endif
            endfor    
            if predef gt 0 then break    
        endif    
    endfor
    if predef gt 0 then continue    
    expr = stregex(str, '# (.*) = (.*)',/subexpr,/extract)
    if n_elements(expr) ne 3 || strlen(expr[2]) eq 0 then continue

    ispar = 0
    if strlen(expr[1]) gt 4 && strcmp(strmid(expr[1], 0, 4), 'par.', /fold_case) then  ispar = 1

    if ispar then begin
        v = strmid(expr[1], 4)
        for j = 0, n_elements(tagpar)-1 do begin
            if strcmp(tagpar[j], v, /fold_case) then begin
                if ptypes[j] eq 1 then params.(j) = double(expr[2]) else params.(j) = expr[2] 
                break
            endif
        endfor
    endif else begin
        for j = 0, n_elements(taghead)-1 do begin
            v = expr[1]
            p = strpos(v, '-')
            if p ge 0 then v = strmid(v, 0, p) + '_' + strmid(v, p+1)
            if strcmp(taghead[j], v, /fold_case) then begin
                if htypes[j] eq 1 then header.(j) = double(expr[2]) else header.(j) = expr[2] 
                break
            endif
        endfor
    endelse        
endwhile
close, U
FREE_LUN, U

if strcmp(mode, 'spectra') then begin
    data = {mode:mode, header:header, params:params, pos:dblarr(header.n_pos), freqs:dblarr(header.n_freqs) $
          , right:dblarr(header.n_pos, header.n_freqs), left:dblarr(header.n_pos, header.n_freqs), qs:dblarr(header.n_pos, header.n_freqs) $
          , ffpos:0d, ff:dblarr(header.n_freqs)}
    arr = dblarr(header.n_pos*3+2)
endif else begin
endelse

cnt = 0
datfreq = -1
openr, U, filename, /GET_LUN
while not EOF(U) do begin
    if cnt lt line then begin
        readf, U, str
        cnt++
        continue
    endif
    readf, U, arr
    if datfreq lt 0 then begin
        header.shift = arr[0]
        for p = 0, header.n_pos-1 do begin
            data.pos[p] = arr[1+3*p]
        endfor
        data.ffpos = arr[1+3*header.n_pos]
        datfreq = 0
    endif else begin
        data.freqs[datfreq]= arr[0]*1d9
        for p = 0, header.n_pos-1 do begin
            data.right[p, datfreq] = arr[1+3*p]*1d-4
            data.left[p, datfreq] = arr[2+3*p]*1d-4
            data.qs[p, datfreq] = arr[3+3*p]*1d-4
        endfor
        data.ff[datfreq]= arr[1+3*header.n_pos]
        datfreq++
    endelse     
endwhile
close, U
FREE_LUN, U

return, data

end
