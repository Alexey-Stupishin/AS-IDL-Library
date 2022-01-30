function jet_addpoc_found_csv, csvfile

pattern = '(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+)'

openr, U, csvfile, /get_lun
cnt = 0
str = ''
while ~eof(U) do begin
    readf, U, str
    cnt++
endwhile
close, U
free_lun, U

if cnt eq 1 then return, 0

out = {t_start:'', t_max:'', t_end:'', x_from:0d, x_to:0d, y_from:0d, y_to:0d}
outs = replicate(out, cnt-1)

openr, U, csvfile, /get_lun
cnt = -1
while ~eof(U) do begin
    readf, U, str
    if cnt lt 0 then begin
        cnt++
        continue
    endif
    
    expr = stregex(str, pattern, /subexpr,/extract)
    if isa(expr, /array) && n_elements(expr) eq 26 then begin
        outs[cnt].t_start = expr[1]
        outs[cnt].t_max = expr[2]
        outs[cnt].t_end = expr[3]
        outs[cnt].x_from = double(expr[22])
        outs[cnt].x_to = double(expr[23])
        outs[cnt].y_from = double(expr[24])
        outs[cnt].y_to = double(expr[25])
        cnt++
    end    
endwhile
close, U
free_lun, U

return, outs

end

pro jet_addpoc_found, path, wave, pattern = pattern
compile_opt idl2

stat = {id:'', detN:0L, t_start:'', t_max:'', t_end:'', duration:0d, card_total:0L, card_max:0L $
      , asp_jet:0d, asp_l2w:0d, asp_max:0d, asp_l2w_max:0d, asp_rect_max:0d $
      , speed_jet:0d, speed_max:0d, speed_mean:0d, speed_med:0d, speed_base:0d $
      , length:0d, width_mean:0d $
      , q25:0d, q50:0d, q75:0d $
      , x_from:0d, x_to:0d, y_from:0d, y_to:0d $
      , distance:0d, pos_angle:0d $
      , n_angles:0L, ang_min:0d, ang_max:0d, ang_mean:0d, ang_med:0d, ang_std:0d $
      , n_accs:0L, acc_max:0d, acc_mean:0d, acc_med:0d}
s = replicate(stat, 3100)
      
fileout = 'details'      
      
csvs = FILE_SEARCH(path, wave + '.csv')

openw, U, 'c:\temp\' + fileout + '.csv', /get_lun

cnt = 0
for k = 0, n_elements(csvs)-1 do begin
    csv = csvs[k]
    
    if n_elements(pattern) gt 0 then begin
        expr = stregex(csv, '.*(' + pattern + ').*', /subexpr,/extract)
        if n_elements(expr) ne 2 || expr[1] ne pattern then continue
    endif
        
    tab = jet_addpoc_found_csv(csv)
    if isa(tab, /NUMBER) && tab eq 0 then continue

    lastsep = STRPOS(csv, path_sep(), /REVERSE_SEARCH)
    if lastsep lt 0 then continue
    sav = strmid(csv, 0, lastsep) + path_sep() + wave + '.sav' 
    if ~FILE_TEST(sav, /READ) then continue
    
    restore, sav, /RELAXED_STRUCTURE_ASSIGNMENT
    
    ;g:\BIGData\UData\Jets\Devl_20211231\Jets\20141004_100500_20141004_112500_205_-228_500_500\objects_m2\171.csv 
    ;g:\BIGData\UData\Jets\Devl_20211231\Jets\20141004_100500_20141004_112500_205_-228_500_500\20220109032554\objects_m2\171.csv 
    expr = stregex(csv, '.*([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9][0-9][0-9]_[0-9-]+_[0-9-]+_[0-9][0-9][0-9]+_[0-9][0-9][0-9]).*', /subexpr,/extract)
    id = expr[1]
    
    ;cands_n = list() 
    for c = 0, found_candidates.Count()-1 do begin
        t = found_candidates[c]
        frames = t.frames
        prevs = !NULL
        prevf = !NULL
        accs = dblarr(frames.Count())
        naccs = 0
        dblim = machar(/DOUBLE)
        ;frames_n = list()
        for f = 0, frames.Count()-1 do begin
            frame = frames[f]
            if frame.card eq 0 then continue
               
            ; for acc
            acc = 0
            if f ge 1 then begin
                if prevs ne !NULL then begin
                    acc = abs((frame.speed - prevs)/12d/(f-prevf))
                    accs[naccs] = acc
                    naccs++
                endif    
                prevs = frame.speed 
                prevf = f 
            endif
             
            ;frame_n = create_struct('acc', acc, frames)
            ;frames_n.Add, frame_n
        endfor    
        
        if cnt eq 9 then begin
            stophere = 1
        endif     
        
        ang_info = jet_get_angle_info(frames)

        acc_max = 0
        acc_mean = 0
        acc_med = 0
        if naccs gt 0 then begin
            a = accs[0:naccs-1]
            acc_max = max(a)
            acc_mean = mean(a)
            acc_med = median(a)
        endif     

        xx = (tab[c].x_from+tab[c].x_to)/2d
        yy = (tab[c].y_from+tab[c].y_to)/2d
        distance = norm([xx, yy])
        pos_angle = atan(yy, xx) / !DTOR
        
        s[cnt].id = id
        s[cnt].detN = c + 1
        s[cnt].t_start = tab[c].t_start
        s[cnt].t_max = tab[c].t_max
        s[cnt].t_end = tab[c].t_end
        s[cnt].duration = (t.length-1)*12d
        s[cnt].card_total = t.total_card
        s[cnt].card_max = t.max_card
        s[cnt].asp_jet = t.total_asp
        s[cnt].asp_l2w = t.total_wasp
        s[cnt].asp_max = t.max_asp
        s[cnt].asp_l2w_max = t.max_wasp
        s[cnt].asp_rect_max = t.max_basp
        s[cnt].speed_jet = t.total_speed
        s[cnt].speed_max = t.max_speed
        s[cnt].speed_mean = t.av_speed
        s[cnt].speed_med = t.med_speed
        s[cnt].speed_base = t.from_start_speed
        s[cnt].length = t.total_lng
        s[cnt].width_mean = t.av_width
        s[cnt].q25 = t.quartiles[0]
        s[cnt].q50 = t.quartiles[1]
        s[cnt].q75 = t.quartiles[2]
        s[cnt].x_from = tab[c].x_from
        s[cnt].x_to = tab[c].x_to
        s[cnt].y_from = tab[c].y_from
        s[cnt].y_to = tab[c].y_to
        s[cnt].distance = distance
        s[cnt].pos_angle = pos_angle
        s[cnt].n_angles = ang_info.n
        s[cnt].ang_min = ang_info.ang_min
        s[cnt].ang_max = ang_info.ang_max
        s[cnt].ang_mean = ang_info.ang_mean
        s[cnt].ang_med = ang_info.ang_med
        s[cnt].ang_std = ang_info.ang_std
        s[cnt].n_accs = naccs
        s[cnt].acc_max = acc_max
        s[cnt].acc_mean = acc_mean
        s[cnt].acc_med = acc_med
        
        printf, U, s[cnt].id, s[cnt].detN, s[cnt].t_start, s[cnt].t_max, s[cnt].t_end, s[cnt].duration, s[cnt].card_total, s[cnt].card_max $
              , s[cnt].asp_jet, s[cnt].asp_l2w, s[cnt].asp_max, s[cnt].asp_l2w_max, s[cnt].asp_rect_max $
              , s[cnt].speed_jet, s[cnt].speed_max, s[cnt].speed_mean, s[cnt].speed_med, s[cnt].speed_base $
              , s[cnt].length, s[cnt].width_mean, s[cnt].q25, s[cnt].q50, s[cnt].q75 $
              , s[cnt].x_from, s[cnt].x_to, s[cnt].y_from, s[cnt].y_to $
              , s[cnt].distance, s[cnt].pos_angle, s[cnt].n_angles, s[cnt].ang_min, s[cnt].ang_max, s[cnt].ang_mean, s[cnt].ang_med, s[cnt].ang_std $
              , s[cnt].n_accs, s[cnt].acc_max, s[cnt].acc_mean, s[cnt].acc_med $ 
              , FORMAT = '(%"%s, %d, %s, %s, %s, %d, %d, %d,   %8.2f, %8.2f, %8.2f, %8.2f, %8.2f,  %8.2f, %8.2f, %8.2f, %8.2f, %8.2f,  %8.2f, %8.2f, %8.2f, %8.2f, %8.2f,  %8.2f, %8.2f, %8.2f, %8.2f,  %8.2f, %8.2f, %d, %8.2f, %8.2f, %8.2f, %8.2f, %8.2f,   %d, %8.2f, %8.2f, %8.2f")'

        cnt++
        
        print, string(cnt)
        
        ;t.frames = frames_n
        ;cand_n = create_struct('distance', distance, 'pos_angle', pos_angle, 'ang_min', ang_min, 'ang_max', ang_max, 'ang_mean', ang_mean, 'ang_med', ang_med, 'ang_std', ang_std, t)
        ;cands_n.Add, cand_n
    endfor
endfor

close, U
free_lun, U

stats = s[0:cnt-1]

save, filename = 'c:\temp\' + fileout + '.sav', stats

end
