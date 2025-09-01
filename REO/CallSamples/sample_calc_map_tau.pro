pro sample_calc_map_tau
;
; Using 
; 
;---------------------------------------------------------------------------------------
; загрузка GX-box ----------------------------------------------------------------------
;     пример из поставляемого пакета:
resolve_routine,'asu_get_anchor_module_dir',/compile_full_file, /either
dirpath = file_dirname((ROUTINE_INFO('asu_get_anchor_module_dir', /source, /functions)).path, /mark)
filename = dirpath + '..\Samples\12470_hmi.M_720s.20151216_085809.W85N12CR.CEA.NAS(_1000).sav' 
 
restore, filename ; GX-box

;---------------------------------------------------------------------------------------
; параметры моделирования: -------------------------------------------------------------
H =    [1,   1e8, 1.1e8, 2e10] ; cm - высота над фотосферой
Temp = [1e4, 1e4, 2e6,   2e6] ; K - температуры на соответствующих высотах
Dens = 3e15/Temp ; cm^{-3} - плотности электронов там же

visstep = 0.5 ; arcsec - шаг видимой сетки радиокарты

posangle = 0 ; позиционный угол: 
             ; для нулевого азимута РАТАН-600 равен позиционному углу Солнца
             ; для ненулевого азимута РАТАН-600 может быть получен утилитой asu_ratan_position_angle
freq = 4e9 ; Hz - частота
harmonics = [2, 3, 4] ; 
tau_levels = 10^linspace(-2, 1, 208) ; значения оптической толщины, на которых мы хотим
                                     ; 

;---------------------------------------------------------------------------------------
; подготовка библиотеки, установка магнитного поля и разметка радиокарты ---------------
;   
ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ результат: размер и смещение радиокарты
    , posangle = posangle $  
    , freefree = 0 $ ; no free-free considered
    , arcbox = arcbox $ ; вернет границы радиокарты в угл. секундах
    , field = field $ ; вернет полное поле на фотосфере, как мы видим его с Земли
;    , /model $
    , version_info = version_info $ ; когда, где и в какой версии библиотеки мы работаем - для контроля
    )

if ptr eq 0 then begin ; что-то пошло не так ...
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info


;---------------------------------------------------------------------------------------
; нарисуем полное поле на фотосфере, как мы видим его с Земли --------------------------
; (это не совсем то, что получено со спутника; данные наблюдений преобразованы в систему координат,
; связанную с фотосферой АО, а потом опять в систему наблюдателя, но уже с другим шагом сетки, да еще
; и повернутые на позиционный угол РАТАНа)
Bph = sqrt(field.bx^2 + field.by^2 + field.bz^2)
cB = contour(Bph, RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Photosphere Field', /FILL)

;---------------------------------------------------------------------------------------
; вычисление радиокарт --------------------------------------------------------
rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , harmonics = harmonics $
    , tau_ctrl = tau_levels $
    , depthR = depthR, FluxR = FluxR, tauR = tauR, heightsR = heightsR, fluxesR = fluxesR, sR = sR $
    , depthL = depthL, FluxL = FluxL, tauL = tauL, heightsL = heightsL, fluxesL = fluxesL, sL = sL $
    )
    
; ну и нарисуем что получилось:
; радиокарты ...
cR = contour(alog10(FluxR), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map', /FILL)
cL = contour(alog10(FluxL), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map', /FILL)

rc = reo_uninit(ptr)
    
end