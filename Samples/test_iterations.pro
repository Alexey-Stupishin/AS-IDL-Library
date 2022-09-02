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
Tc = dblarr(n_elements(Hx)) + 1d6
params = rif_get_params(n_elements(Hx), n_elements(freqs))
params.wTemp = 50
params.Hmin = 1.2e8

; -------- preparing ----------
ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ результат: размер и смещение радиокарты
    , posangle = mainstr.ratan_p $  
    , freefree = 0 $ ; no free-free considered
    , arcbox = arcbox $ ; вернет границы радиокарты в угл. секундах
    , field = field $ ; вернет полное поле на фотосфере, как мы видим его с Земли
    , dll_location = 's:\Projects\Physics\ProgramD64\agsGeneralRadioEmission.dll' $
    
;    , cycloMap_nThreadsInitial = 1 $
;    , Debug_AtPoint_ZoneTrace_i = 45 $
;    , Debug_AtPoint_ZoneTrace_j = 37 $
;    , Debug_AtPoint_ZoneTrace_GyroLayerProfile = 1 $
     )
model_mask = reo_get_model_mask(ptr, box.base.Bz, box.base.ic)

; -------- calculation ----------
map_pos = floor((arc_pos[selected_point] - base[0]*mainstr.solar_r)/visstep)
obsR = transpose(right[selected_point, *])
obsL = transpose(left[selected_point, *])

reo_get_flocculae, ptr, freqsR, freqsL, model_mask, [4, 5], map_pos, params, RB, LB

Ht1 = [1, Hx];
Ht2 = [Hx, 5d9];
Hc = (Ht1+Ht2)/2;

while 1 do begin
    nextT = rif_iteration_step(ptr, freqsR, obsR, freqsL, obsL, Ht1, Ht2, Hc, Tc, NT, map_pos, params, calcR, calcL, calcD = calcD)
    window, 0
    device, decompose = 1
    plot, obsR
    oplot, calcR, color = '00FF00'x
    window, 1
    device, decompose = 1
    plot, alog10(Tc)
    
    Tc = nextT
endwhile

end
