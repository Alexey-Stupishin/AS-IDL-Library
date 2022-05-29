pro jet_csv_to_config_2, incsv, outdir

tmin = 3600d
tany = 300d

tsum = 0d

file_mkdir, outdir

openr, U, incsv, /get_lun

str = ''
while ~eof(U) do begin
    readf, U, str
    
    expr = stregex(str, 'open;(.+);;(.+);;(.+);(.+);.*;.*', /subexpr,/extract)
    if expr[1] eq '' || fix(expr[1]) eq 0 then continue
    if expr[2] eq '' then continue
    if expr[3] eq '' then continue
    if expr[4] eq '' then continue
    tstart = expr[1] 
    tstop = expr[2] 
    x = expr[3]
    y = expr[4]
    
    to = anytim(tstart)
    ts = to
    te = anytim(tstop)
    
    if te-ts lt tmin then d = (tmin - (te-ts))/2d else d = tany 
    ts -= d
    te += d
    
    tsum += te-ts
    
    tss = anytim(to, out_style = 'UTC_EXT')
    tocc = string(tss.year,tss.month,tss.day,tss.hour,tss.minute,tss.second,format='(%"%04i-%02i-%02i %02i:%02i:%02i")')
    tss = anytim(ts, out_style = 'UTC_EXT')
    tstart = string(tss.year,tss.month,tss.day,tss.hour,tss.minute,tss.second,format='(%"%04i-%02i-%02i %02i:%02i:%02i")')
    tpostf = string(tss.year,tss.month,tss.day,tss.hour,tss.minute,tss.second,format='(%"%04i%02i%02i_%02i%02i%02i")')
    tss = anytim(te, out_style = 'UTC_EXT')
    tstop = string(tss.year,tss.month,tss.day,tss.hour,tss.minute,tss.second,format='(%"%04i-%02i-%02i %02i:%02i:%02i")')
    
    ;struct = {TIME_START:tstart, TIME_STOP:tstop, TIME_REF:tstart, X_CENTER:x, Y_CENTER:y, WIDTH_PIX:300, HEIGHT_PIX:300, WAVES:[171, 193, 211, 304]}
    ;json = JSON_SERIALIZE(struct)

    outname = outdir + path_sep() + 'config' + tpostf + '.json'
    
    ; json_encode() ?????
    
    openw, UW, outname, /get_lun
    printf, UW, '{'
    printf, UW, '    "TIME_START":"' + tstart + '",'
    printf, UW, '    "TIME_STOP":"' + tstop + '",'
    printf, UW, '    "TIME_REF":"' + tstart + '",'
    printf, UW, '    "TIME_OCC":"' + tocc + '",'
    printf, UW, '    "X_CENTER":' + x + ','
    printf, UW, '    "Y_CENTER":' + y + ','
    printf, UW, '    "WIDTH_ARC":300,'
    printf, UW, '    "HEIGHT_ARC":300,'
    printf, UW, '    "WAVES":[171]'
    printf, UW, '}'
    close, UW
    free_lun, UW
endwhile

close, U
free_lun, U

print, 'total ' + asu_compstr(tsum)

end
