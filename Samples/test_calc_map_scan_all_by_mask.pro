pro test_calc_map_scan_all_by_mask
compile_opt idl2

resolve_routine,'asu_atm_add_profile',/compile_full_file, /either

dirpath = file_dirname((ROUTINE_INFO('test_calc_map_scan_all_by_mask', /source)).path, /mark)
filename = dirpath + '12470_hmi.M_720s.20151216_085809.W85N12CR.CEA.NAS(_1000).sav' 
restore, filename ; GX-box

visstep = 0.5 ; arcsec - шаг видимой сетки радиокарты
posangle = 13.6 ; позиционный угол: 
freq = 10e9 ; Hz - частота

ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ результат: размер и смещение радиокарты
    , posangle = posangle $  
    , freefree = 1 $ ; consider free-free
    , arcbox = arcbox $ ; вернет границы радиокарты в угл. секундах
    , field = field $ ; вернет полное поле на фотосфере, как мы видим его с Земли
    , dll_location = 's:\Projects\Physics\ProgramD64\agsGeneralRadioEmission.dll' $
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

;-----------------------------------------------------------------
; Инициализация фотосферного профиля по маске: "базовая" атмосфера ("Спокойное Солнце"),
; будет применена для всех пикселей маски, для которых не задан собственный атмосферный профиль
H =    [1,   2e8,   2.3e8, 3.0e8, 5.0e9]
Temp = [1e4, 1e4,   1.0e6, 1.2e6, 2.5e6]
Dens = 1e16/Temp
mask_set = asu_atm_init_profile(H, Temp, Dens)

; добавим атмосферный профиль для полутени (индекс в маске = 6)
HP =    [1,   1.5e8, 1.8e8, 2.5e8, 5.0e9]
TempP = [1e4,   1e4, 0.8e6, 1.0e6, 2.0e6]
DensP = 1e16/TempP
mask_set = asu_atm_add_profile(mask_set, 6, HP, TempP, DensP)

; добавим атмосферный профиль для тени (индекс в маске = 7)
HU =    [1,   1.0e8, 1.3e8, 2.0e8, 5.0e9]
TempU = [1e4,   1e4, 0.7e6, 0.9e6, 2.0e6]
DensU = 1e16/Temp
mask_set = asu_atm_add_profile(mask_set, 7, HU, TempU, DensU)

; загрузим заданные профили в библиотеку ...
rc = reo_set_atmosphere_mask_set(ptr, mask_set, model_mask)
 
; ... , посчитаем радиокарты ...  
rc = reo_calculate_map_atm( $
      ptr, freq $
    , FluxR = FluxR $
    , FluxL = FluxL $
    )

; ... , нарисуем их ...    
if max(FluxR) gt 0 then begin    
    cR = contour(alog10(FluxR), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (umbra)', /FILL)
endif
if max(FluxL) gt 0 then begin    
    cL = contour(alog10(FluxL), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (umbra)', /FILL)
end

; ... , и посчитаем и нарисуем сканы    
rcr = reo_convolve_map(ptr, FluxR, freq, scanR)
rcr = reo_convolve_map(ptr, FluxL, freq, scanL)
plot, scanR
oplot, scanL

rc = reo_uninit(ptr)
    
end