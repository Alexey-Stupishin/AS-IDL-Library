pro jet_addpoc_found, path, wave
compile_opt idl2

csvs = FILE_SEARCH(path, wave + '.csv')

for k = 0, n_elements(csvs) do begin
    csv = csvs[k]
    lastsep = STRPOS(csv, path_sep(), /REVERSE_SEARCH)
    if lastsep lt 0 then continue
    sav = csv[0:lastsep] + wave + '.sav' 
    if FILE_TEST(sav, /READ) then continue
    restore, sav, /RELAXED_STRUCTURE_ASSIGNMENT
    
    t = found_candidates[k]
;       CLUST_N         INT              2
;       POS             LONG                 1
;       LENGTH          LONG               196
;       TOTAL_CARD      LONG            570052
;       MAX_CARD        LONG             14394
;       TOTAL_ASP       DOUBLE           2.3082267
;       MAX_ASP         DOUBLE           8.1702658
;       MAX_BASP        DOUBLE           5.3438574
;       MAX_WASP        DOUBLE           20.715977
;       TOTAL_WASP      DOUBLE           10.149641
;       TOTAL_SPEED     DOUBLE           4.9165597
;       MAX_SPEED       DOUBLE           534.30688
;       AV_SPEED        DOUBLE           83.229558
;       MED_SPEED       DOUBLE           44.855035
;       FROM_START_SPEED
;                       DOUBLE           133.57672
;       TOTAL_LNG       DOUBLE           369.36366
;       AV_WIDTH        DOUBLE           36.391796
;       FRAMES          OBJREF    <ObjHeapVar9(LIST)>
;       QUARTILES       DOUBLE    Array[3]

        frames = t.frames
        accs = dblarr(frames.Count())
        prevs = !NULL
        prevf = !NULL
        jet_angle = dblarr(frames.Count())
        nangles = 0
        dblim = machar(/DOUBLE)
        xlim = [dblim.xmax, -dblim.xmax]
        ylim = [dblim.xmax, -dblim.xmax]
        for f = 0, frames.Count()-1 do begin
            frame = frames[f]
            if frame.card eq 0 then continue
;               POS             LONG                 1
;               CARD            LONG                95
;               X               LONG      Array[95]
;               Y               LONG      Array[95]
;               BETA            DOUBLE    Array[1]
;               ASPECT          DOUBLE    Array[1]
;               BASPECT         DOUBLE           1.6972784
;               WASPECT         DOUBLE           6.4974340
;               ROTX            DOUBLE    Array[95]
;               ROTY            DOUBLE    Array[95]
;               CLUST           INT              2
;               SPEED          DOUBLE          0.00000000
               
            ; for acc
            acc = 0
            if f ge 1 then begin
                if prevs ne !NULL then begin
                    acc = (frame.speed - prevs)/12d/(f-prevf)
                endif    
                prevs = frame.speed 
                prevf = f 
            endif
             
            ; beta
            
            isangle = 0
            angle = 0
            if frame.card gt 50 && frame.aspect gt 2.9d && frame.baspect gt 2.6d && frame.waspect gt 9.5d then begin
                isangle = 1
                angle = vbeta / !DTOR
                jet_angle[nangles] = angle
            endif
            
            ; for angles
            xlim[0] = min([xlim[0], min(frame.x)])                     
            xlim[1] = max([xlim[1], max(frame.x)])                     
            ylim[0] = min([ylim[0], min(frame.y)])                     
            ylim[1] = max([ylim[1], max(frame.y)])                     
        endfor    

;        pos_angle = dblarr(frames.Count())
; read csv
; write upd csv
    
endfor

end
