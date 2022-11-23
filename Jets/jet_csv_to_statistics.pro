function jet_csv_to_statistics, csvfile

pattern = '(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+)'

openr, U, csvfile, /get_lun
str = ''
cnt = 0
while ~eof(U) do begin
    readf, U, str
    expr = stregex(str, pattern, /subexpr,/extract)
    if isa(expr, /array) && n_elements(expr) eq 27 then cnt++
endwhile
close, U
free_lun, U

stat = {id:'', detN:0L, t_start:'', t_max:'', t_end:'', duration:0d, card_total:0L, card_max:0L $
      , asp_jet:0d, asp_l2w:0d, asp_max:0d, asp_l2w_max:0d $
      , speed_jet:0d, speed_max:0d, speed_mean:0d, speed_med:0d, speed_base:0d $
      , length:0d, width_mean:0d $
      , q25:0d, q50:0d, q75:0d $
      , x_from:0d, x_to:0d, y_from:0d, y_to:0d $
      , distance:0d}
stats = replicate(stat, cnt)

openr, U, csvfile, /get_lun
cnt = 0
while ~eof(U) do begin
    readf, U, str
    
    expr = stregex(str, pattern, /subexpr,/extract)
    
    if isa(expr, /array) && n_elements(expr) eq 27 then begin
        ; 0 - id
        ; 1-3 - times
        ; 4 - ndet - lon
        ; 5 - duration xx'yy"
        ; 6,7 - cards, long
        ; 8-11 - aspects, dbl 4 fields)
        ; 12-16 - speeds, long (5 fields)
        ; 17-18 - length, av.width
        ; 19-21 - quartiles, dbl, (3)
        ; 22-25 - coords, dbl (4)
        
        stats[cnt].id = expr[1]
        stats[cnt].detN = expr[5]
        stats[cnt].t_start = expr[2]
        stats[cnt].t_max = expr[3]
        stats[cnt].t_end = expr[4]
        durex = stregex(expr[6], '([0-9]*)[^0-9]([0-9]*).*', /subexpr,/extract)
        stats[cnt].duration = long(durex[1])*60 + long(durex[2])
        stats[cnt].card_total = long(expr[7])
        stats[cnt].card_max = long(expr[8])
        stats[cnt].asp_jet = double(expr[9])
        stats[cnt].asp_l2w = double(expr[10])
        stats[cnt].asp_max = double(expr[11])
        stats[cnt].asp_l2w_max = double(expr[12])
        stats[cnt].speed_jet = double(expr[13])
        stats[cnt].speed_max = double(expr[14])
        stats[cnt].speed_mean = double(expr[15])
        stats[cnt].speed_med = double(expr[16])
        stats[cnt].speed_base = double(expr[17])
        stats[cnt].length = double(expr[18])
        stats[cnt].width_mean = double(expr[19])
        stats[cnt].q25 = double(expr[20])
        stats[cnt].q50 = double(expr[21])
        stats[cnt].q75 = double(expr[22])
        stats[cnt].x_from = double(expr[23])
        stats[cnt].x_to = double(expr[24])
        stats[cnt].y_from = double(expr[25])
        stats[cnt].y_to = double(expr[26])
        stats[cnt].distance = sqrt((stats[cnt].x_to+stats[cnt].x_from)^2 + (stats[cnt].y_to+stats[cnt].y_from)^2)/2d
        
        cnt++
    endif
endwhile

close, U
free_lun, U

return, stats

end
