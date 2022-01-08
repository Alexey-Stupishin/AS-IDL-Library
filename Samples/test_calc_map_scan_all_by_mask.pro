pro test_calc_map_scan_fill_by_mask, Hf, Tf, Df, dh, addT, NT, H, Temp, Dens

length = n_elements(Hf)
n_add = n_elements(addT)
H = dblarr(length+n_add)
H[0:-(n_add+1)] = Hf
Temp = dblarr(length+n_add)
Temp[0:-(n_add+1)] = Tf
Dens = dblarr(length+n_add)
Dens[0:-(n_add+1)] = Df
for k = 0, n_add-1 do begin
    H[-(n_add-k)] = H[-(n_add-k+1)] + dh[k]
    Temp[-(n_add-k)] = addT[k]
    Dens[-(n_add-k)] = NT/Temp[-(n_add-k)]
endfor

end

;--------------------------------------------------------------------------------------
pro test_calc_map_scan_all_by_mask
dirpath = file_dirname((ROUTINE_INFO('test_calc_map_scan_all_by_mask', /source)).path, /mark)
filename = dirpath + '12470_hmi.M_720s.20151218_125809.W86N13CR.CEA.NAS_1000.sav' 
restore, filename ; GX-box

visstep = 0.5 ; arcsec - шаг видимой сетки радиокарты
posangle = 0 ; позиционный угол: 
freq = 10e9 ; Hz - частота

ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ результат: размер и смещение радиокарты
    , posangle = posangle $  
    , freefree = 1 $ ; consider free-free
    , arcbox = arcbox $ ; вернет границы радиокарты в угл. секундах
    , field = field $ ; вернет полное поле на фотосфере, как мы видим его с Земли
    , dll_location = 's:\Projects\Physics104_291\ProgramD64\agsGeneralRadioEmission.dll' $
    , version_info = version_info $ ; когда, где и в какой версии библиотеки мы работаем - для контроля
    )

if ptr eq 0 then begin ; что-то пошло не так ...
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info

;---------------------------------------------------------------------------------------
; Построение маски с учетом поля и излучения в континууме ------------------------------

model_mask = decompose(box.base.bz, box.base.ic); see Fontenla 2009. e.g. 7 - umbra, 6 - penumbra etc.

;; (условно) спокойное Солнце (1-3):
;HQ =    [1, 5e9]
;TempQ = [1e6, 1e6] ;suppose no eny emission, since quiet Sun was already subtracted
;DensQ = 1e15/TempQ
;mask_set = asu_atm_add_profile(!NULL,    1, HQ, TempQ, DensQ)
;mask_set = asu_atm_add_profile(mask_set, 2, HQ, TempQ, DensQ)
;mask_set = asu_atm_add_profile(mask_set, 3, HQ, TempQ, DensQ)
; 
;; Plage+Facula (4-5):
;;length = asu_get_fontenla2009(7, Hf, Tf, Df)
;;test_calc_map_scan_fill_by_mask, Hf, Tf, Df, [1e7, 1e8, 3e9], [1e6, 2e6, 2e6], 1e16, H, Temp, Dens
;HF =    [1,   3e8, 4e8, 6e8, 5e9]
;TempF = [1e4, 1e4, 1e6, 2e6, 2e6]
;DensF = 1e16/TempF
;mask_set = asu_atm_add_profile(mask_set, 4, HF, TempF, DensF)
;mask_set = asu_atm_add_profile(mask_set, 5, HF, TempF, DensF)
; 
;; Penumbra (6):
;HP =    [1,   2e8,   3e8,   5e8, 5e9]
;TempP = [1e4, 1e4, 0.8e6, 1.2e6, 2e6]
;DensP = 1e16/TempP
;mask_set = asu_atm_add_profile(mask_set, 6, HP, TempP, DensP)
; 
;; Umbra (7):
;HU =    [1,   1e8,   1.5e8,   2e8, 5e9]
;TempU = [1e4, 1e4,   0.7e6, 1.0e6, 2e6]
;DensU = 1e16/TempU
;mask_set = asu_atm_add_profile(mask_set, 7, HU, TempU, DensU)

;-----------------------------------------------------------------
HU =    [1,   1e8,   1.5e8,   2e8, 5e9]
TempU = [1e4, 1e4,   0.7e6, 1.0e6, 2e6]
DensU = 1e16/TempU
mask_set = asu_atm_add_profile(!NULL, 1, HU, TempU, DensU)
mask_set = asu_atm_add_profile(mask_set, 2, HU, TempU, DensU)
mask_set = asu_atm_add_profile(mask_set, 3, HU, TempU, DensU)
mask_set = asu_atm_add_profile(mask_set, 4, HU, TempU, DensU)
mask_set = asu_atm_add_profile(mask_set, 5, HU, TempU, DensU)
mask_set = asu_atm_add_profile(mask_set, 6, HU, TempU, DensU)
mask_set = asu_atm_add_profile(mask_set, 7, HU, TempU, DensU)
;-----------------------------------------------------------------

;-----------------------------------------------------------------
;HU =    [1,   0.8e8,   1.1e8,   1.6e8, 5e9]
;TempU = [1e4,   1e4,     1e6,     2e6, 2e6]
;DensU = 1e16/TempU
;mask_set = asu_atm_add_profile(!NULL,    1, HU, TempU, DensU)
;HU =    [1,   1.1e8,   2.1e8, 5e9]
;TempU = [1e4,   1e4,     2e6, 3e6]
;DensU = 1e16/TempU
;mask_set = asu_atm_add_profile(mask_set, 2, HU, TempU, DensU)
;HU =    [1,   1.1e8,   1.6e8, 5e9]
;TempU = [1e4,   1e6,     2e6, 3e6]
;DensU = 1e16/TempU
;mask_set = asu_atm_add_profile(mask_set, 3, HU, TempU, DensU)
;
;model_mask = dblarr(3,3)
;model_mask[*,0] = [2, 1, 3]
;model_mask[*,1] = [1, 3, 2]
;model_mask[*,2] = [2, 3, 1]
;-----------------------------------------------------------------

rc = reo_set_atmosphere_mask_set(ptr, mask_set, model_mask)
returnCode = reo_set_int(ptr, 'cycloMap.nThreadsInitial', 1)
returnCode = reo_set_int(ptr, 'Debug.AtPoint.ZoneTrace.i', 100)
returnCode = reo_set_int(ptr, 'Debug.AtPoint.ZoneTrace.j', 100)
returnCode = reo_set_int(ptr, 'Debug.AtPoint.ZoneTrace.GyroLayerProfile', 1)
 
rc = reo_calculate_map_atm( $
      ptr, freq $
    , FluxR = FluxRu $
    , FluxL = FluxLu $
    )
    
if max(FluxRu) gt 0 then begin    
    cR = contour(alog10(FluxRu), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (umbra)', /FILL)
endif
rcr = reo_convolve_map(ptr, FluxRu, freq, scanRu)
if max(FluxLu) gt 0 then begin    
    cL = contour(alog10(FluxLu), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (umbra)', /FILL)
end

rc = reo_uninit(ptr)
    
end