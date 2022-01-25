pro jet_csv_to_config, incsv, outdir

tmin = 3600d
tany = 300d

tsum = 0d

file_mkdir, outdir

openr, U, incsv, /get_lun

str = ''
while ~eof(U) do begin
    readf, U, str
    
;                        1;open;  06/01/18 13:00;13:00:13;06/01/18 15:40;8.0;-991.0;7.84;-86.61;;;;;;show;;open;show;south pole, incorrect FOV;;
    expr = stregex(str, '(.+);.*;(.+);.*;(.+);(.+);(.+);.*;.*;.*;.*;.*;.*;.*;.*;.*;.*;.*;.*;.*;', /subexpr,/extract)
    if expr[1] eq '' || fix(expr[1]) eq 0 then continue
    if expr[2] eq '' then continue
    tstart = expr[2] 
    if expr[3] eq '' then continue
    tstop = expr[3] 
    if expr[4] eq '' || expr[5] eq '' then continue
    x = expr[4]
    y = expr[5]
    
    exts = stregex(tstart, '(.+)/(.+)/(.+) (.+):(.+).*', /subexpr,/extract)
    tstart = '20' + exts[3] + '-' + exts[2] + '-' + exts[1] + ' ' + exts[4] + ':' + exts[5]
    exts = stregex(tstop, '(.+)/(.+)/(.+) (.+):(.+).*', /subexpr,/extract)
    tstop = '20' + exts[3] + '-' + exts[2] + '-' + exts[1] + ' ' + exts[4] + ':' + exts[5]
    
;    expr = stregex(str, '(.+);.*;.*;(.+);(.+);.*;(.+);(.+);(.+);(.+);.*;.*;.*;.*;.*;.*;.*;.*;.*;.*;.*;.*;.*;.*;.*;.*', /subexpr,/extract)
;;                        'No'
;;                         N   x  xs ds    ts   xe de   te   x    y
;    ;!                    4;
;    ;                         open;
;    ;                            30/01/18 8:15;
;    ;!                              2018-01-30;
;    ;!                                   8:15:08;
;    ;                                         30/01/18 10:01;
;    ;!                                           2018-01-30;
;    ;!                                                10:01:01;
;    ;!                                                     -954.0;
;    ;!                                                          433.0;
;    ;                                                               1047.7;-87.04;24.24;8:45:00;5 obs 07:45:50 - 11:07:54;LC-No;;;;;open;show;;;;
;    ;
;    if fix(expr[7]) eq '' then continue
;    if expr[1] eq '' || fix(expr[1]) eq 0 then continue
;    if expr[2] eq '' || expr[3] eq 0 then continue
;    tstart = expr[2] + ' ' + expr[3] 
;    if expr[4] eq '' || expr[5] eq 0 then continue
;    tstop = expr[4] + ' ' + expr[5] 
;    if expr[6] eq '' || expr[7] eq 0 then continue
;    x = expr[6]
;    y = expr[7]
    
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
