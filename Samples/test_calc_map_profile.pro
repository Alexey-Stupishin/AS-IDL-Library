pro test_calc_map_profile
;
; Набор примеров, иллюстрирующих использование библиотеки расчетов радиокарт
; для детального изучения структуры излучающей области
; Рекомендуется пошаговое выполнение
; 
;---------------------------------------------------------------------------------------
; загрузка GX-box ----------------------------------------------------------------------
;     пример из поставляемого пакета:
dirpath = file_dirname((ROUTINE_INFO('test_calc_map_profile', /source)).path, /mark)
filename = dirpath + '12470_hmi.M_720s.20151218_125809.W86N13CR.CEA.NAS_1000.sav' 
;     либо использовать путь, сохраненный в примере test_mfo_box_load:
;filename = getenv('mfo_NLFFF_filename')
;     либо задать путь к файлу явно
;filename = 'c:\temp\mod_dipole.sav'
 
restore, filename ; GX-box

;---------------------------------------------------------------------------------------
; параметры моделирования: -------------------------------------------------------------
H =    [1,   1e8, 1.1e8, 2e10] ; cm - высота над фотосферой
Temp = [1e4, 1e4, 2e7,   2e7] ; K - температуры на соответствующих высотах
Dens = 3e15/Temp ; cm^{-3} - плотности электронов там же

visstep = 0.5 ; arcsec - шаг видимой сетки радиокарты

posangle = 0 ; позиционный угол: 
             ; для нулевого азимута РАТАН-600 равен позиционному углу Солнца
             ; для ненулевого азимута РАТАН-600 может быть получен утилитой asu_ratan_position_angle
freq = 5.7e9 ; Hz - частота

;---------------------------------------------------------------------------------------
; подготовка библиотеки, установка магнитного поля и разметка радиокарты ---------------
;   
ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ ; результат: размер и смещение радиокарты
    , posangle = posangle $  
    , freefree = 0 $ ; 0 if no free-free considered, 1 otherwise
    , arcbox = arcbox $ ; вернет границы радиокарты в угл. секундах
    , field = field $ ; вернет полное поле на фотосфере, как мы видим его с Земли
    , cycloCalc_LaplasMethod_Use = 0 $ ;  для получения более детального профиля - не использовать метод Лапласа 
;    , /model $
    , version_info = version_info $ ; когда, где и в какой версии библиотеки мы работаем - для контроля
;    , dll_location = 's:\Projects\Physics104_291\ProgramD64\agsGeneralRadioEmission.dll' $
;    , cycloMap_nthreadsinitial = 1 $
;    , debug_atpoint_zonetrace_i = 90 $
;    , debug_atpoint_zonetrace_j = 130 $
;    , debug_atpoint_zonetrace_gyrolayerprofile = 1 $
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
; и повернутые на позиционный угол РАТАНа):
Bph = sqrt(field.bx^2 + field.by^2 + field.bz^2)
;cB = contour(Bph, RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Photosphere Field', /FILL)

;---------------------------------------------------------------------------------------
; набор контролируемых оптических толщин -----------------------------------------------
taus = 10^asu_linspace(-2, 1, 208)
; от 0.01 до 10, 208 штук

;---------------------------------------------------------------------------------------
; вычисление радиокарт и высотных профилей ---------------------------------------------
rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , FluxR = FluxR $
    , FluxL = FluxL $
    , tau_ctrl = taus $
    , harmonics = [2, 3, 4] $
    , depthR = depthR, heightsR = heightsR, fluxesR = fluxesR, sR = shR $
    , depthL = depthL, heightsL = heightsL, fluxesL = fluxesL, sL = shL $
    )
    
; а как набирается оптическая толщина по лучу зрения над точкой радиокарты, например
x = 130
y = 90
; ?

; посмотрим, сколько контрольных точек оптической толщины насчиталось в правой поляризации:
dR = depthR[x, y]
; и для каждой контролируемой величины (в правой поляризации) получим:
hR = reo_get_los_profile(depthR, heightsR, x, y) ; высоты
fR = reo_get_los_profile(depthR, fluxesR, x, y) ; потоки
sR = reo_get_los_profile(depthR, shR, x, y) ; номера гармоник
tR = taus[0:dR-1] ; на соответствующих контролируемых оптических толлщинах 

; и то же самое в левой:
dL = depthL[x, y]
hL = reo_get_los_profile(depthL, heightsL, x, y) ; высоты
fL = reo_get_los_profile(depthL, fluxesL, x, y) ; потоки
sL = reo_get_los_profile(depthL, shL, x, y) ; номера гармоник
tL = taus[0:dL-1] ; на соответствующих контролируемых оптических толлщинах

; ну и нарисуем что получилось:
; радиокарты:
cR = contour(alog10(FluxR), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map', /FILL)
cL = contour(alog10(FluxL), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map', /FILL)

; профили над точкой [130, 90] по лучу зрения:
pR = plot(hR, tR, /ylog) ; набранная оптическая толщина как функция высоты (R)
; за счет какой гармоники набирается оптическая толщина - указано цветом (2-я - красным, 3-я - синим, 4-я, если есть - зеленым):
reo_plot_harmonics, 2, sR, hR, tR, pR, 'Red'
reo_plot_harmonics, 3, sR, hR, tR, pR, 'Blue'
reo_plot_harmonics, 4, sR, hR, tR, pR, 'Green'

; и то же для левой поляризации:
pL = plot(hL, tL, /ylog)
reo_plot_harmonics, 2, sL, hL, tL, pL, 'Red'
reo_plot_harmonics, 3, sL, hL, tL, pL, 'Blue'
reo_plot_harmonics, 4, sL, hL, tL, pL, 'Green'

; дополнительно можем посмотреть, как меняется полное поле и угол к лучу зрения над той же точкой:
; вычислим все профили над радиокартой:
rc = reo_get_field_los(ptr, depthFLOS, HFLOS, BFLOS, cosFLOS)

; получим профили над точкой [130, 90] по лучу зрения:
hB = reo_get_los_profile(depthFLOS, HFLOS, x, y) ; высоты
BB = reo_get_los_profile(depthFLOS, BFLOS, x, y) ; поле
cosB = reo_get_los_profile(depthFLOS, cosFLOS, x, y) ; угол

; и нарисуем:
pB = plot(hB, BB)
pC = plot(hB, cosB)
; укажем высоты, соответствующие центрам гироуровней (теми же цветами)
Byrange = pB.yrange
Cyrange = pC.yrange
reo_plot_harmonic_heights, hB, BB, freq, 2, 'Red', pB, pC, Byrange, Cyrange
reo_plot_harmonic_heights, hB, BB, freq, 3, 'Blue', pB, pC, Byrange, Cyrange
reo_plot_harmonic_heights, hB, BB, freq, 4, 'Green', pB, pC, Byrange, Cyrange
    
rc = reo_uninit(ptr)

;TB = interpol(Temp, H, hB)
;DB = interpol(Dens, H, hB)
;save, filename='c:\temp\prof.sav', hB, BB, cosB, TB, DB

end
