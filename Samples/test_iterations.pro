pro test_iterations
compile_opt idl2

ratan_file = 's:\Projects\MatlabGM\Data\RATAN_AR11312_20111010_090044_az0_SPECTRA__shablon.dat'
;hmi_file = 'S:\Projects\IDL\ASlibrary\Utils\Models\11312_hmi.M_720s.20111010_085818.W121N24CR.CEA.NAS_750.sav'
hmi_file = 's:\University\Work\11312_for_2022\HMI\11312_hmi.M_720s.20111010_085818.W121N23CR.CEA.NAS.sav'

; -------- RATAN ----------
get_lun, unit
spectr_ratan_read_spectra, unit, ratan_file, mainstr, parstr, freqs, arc_pos, right, left, quiet, pos_frfr, frfr 
free_lun, unit ; now: freqs, arc_pos, right,left[p, f], mainstr.ratan_p

freqsR = freqs*1d9
right *= 1d-4
freqsL = freqs*1d9
left *= 1d-4

; -------- HMI ----------
restore, hmi_file ; GX-box

; -------- parameters ----------
selected_point = 4 ; RATAN position
visstep = 2 ; map step, arcsec
NT = 5e15
Hx = [0.1, 0.5, asu_linspace(0.9, 1.5, 7), asu_linspace(1.7, 3.5, 10), asu_linspace(4, 10, 7), 12, 14, 16]*1d8
Tc = dblarr(n_elements(Hx)+1) + 1d6
params = rif_get_params(n_elements(Hx), n_elements(freqs))
params.wTemp = 100
params.Hmin = 2e8

; -------- preparing ----------
ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ результат: размер и смещение радиокарты
    , posangle = mainstr.ratan_p $  
    , freefree = 0 $ ; no free-free considered
    , arcbox = arcbox $ ; вернет границы радиокарты в угл. секундах
    , field = field $ ; вернет полное поле на фотосфере, как мы видим его с Земли
     )
model_mask = reo_get_model_mask(ptr, box.base.Bz, box.base.ic)

; -------- calculation ----------
map_pos = floor((arc_pos[selected_point] - base[0]*mainstr.solar_r)/visstep)
obsR = transpose(right[selected_point, *])
obsL = transpose(left[selected_point, *])

reo_get_flocculae, ptr, freqsR, freqsL, model_mask, [4, 5], map_pos, params, flocR, flocL

obsR -= flocR
idx = where(obsR le 0, /NULL)
if idx ne !NULL then obsR[idx] = 0 
obsL -= flocL
idx = where(obsL le 0, /NULL)
if idx ne !NULL then obsL[idx] = 0 

Ht1 = [1, Hx];
Ht2 = [Hx, 5d9];
Hc = (Ht1+Ht2)/2;

asu_plt_winplot, 0, 'test', [1920, 1080]
!p.multi =[0, 2, 2]
grayit = 'D5D5D5'x
thick_main = 3

cnt = 0
n_iter = 1000
residR = dblarr(n_iter)
residL = dblarr(n_iter)
prevR = list()
prevL = list()
prevT = list()
nextT = Tc
viewmask = model_mask eq 6 or model_mask eq 7
for k = 0, n_iter-1 do begin ; step-by-step
    nextT = rif_iteration_step(ptr, freqsR, obsR, freqsL, obsL, Ht1, Ht2, Hc, nextT, NT, map_pos, params, calcR, calcL $
                             , calcD = calcD, freefree = 0, no_gst = 0, viewmask = viewmask $
                              )
    ; ------------ plot --------------------------------                          
    plot, freqsR, obsR, /nodata
    for p = 0, prevR.Count()-1 do begin
        oplot, freqsR, prevR[p], color = grayit
    endfor 
    oplot, freqsR, obsR, color = '000000'x, thick = thick_main
    oplot, freqsR, calcR, color = '0000FF'x, thick = thick_main
    
    plot, freqsL, obsL, color = '000000'x
    for p = 0, prevR.Count()-1 do begin
        oplot, freqsL, prevL[p], color = grayit
    endfor 
    oplot, freqsL, obsL, color = '000000'x, thick = thick_main
    oplot, freqsL, calcL, color = 'FF0000'x, thick = thick_main
    
    plot, Hc, nextT, /ylog, xrange = [params.Hmin, 1e9], yrange = [1e4, 1e7], /nodata
    for p = 0, prevT.Count()-1 do begin
        oplot, Hc, prevT[p], color = grayit
    endfor 
    oplot, Hc, nextT, color = '0000FF'x, thick = thick_main
    
    residR[cnt] = sqrt(total((obsR-calcR)^2))/total(obsR)
    residL[cnt] = sqrt(total((obsL-calcL)^2))/total(obsL)
    if cnt gt 1 then begin
        plot, residR[0:cnt-1]+residL[0:cnt-1], /ylog, yrange = [0.001, 1], color = '000000'x
        oplot, residR[0:cnt-1], color = '0000FF'x
        oplot, residL[0:cnt-1], color = 'FF0000'x
    endif else begin
        plot, [0,1], [0,1], color = '000000'x, /nodata
    endelse    
    wait, 0.01

    prevR.Add, calcR
    prevL.Add, calcL
    prevT.Add, nextT
    
    cnt++
endfor

end
