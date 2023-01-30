pro sample_calc_map_scan
;
; Using 
; 
;---------------------------------------------------------------------------------------
; загрузка GX-box ----------------------------------------------------------------------
;     пример из поставляемого пакета:
resolve_routine,'as_library_data_anchor',/compile_full_file, /either
dirpath = file_dirname((ROUTINE_INFO('as_library_data_anchor', /source)).path, /mark)
filename = dirpath + '12470_hmi.M_720s.20151216_085809.W85N12CR.CEA.NAS(_1000).sav' 
 
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
freq = 5.7e9 ; Hz - частота
freq = 4e9 ; Hz - частота

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
;    
;    , dll_location = 's:\Projects\Physics104_291\ProgramD64\agsGeneralRadioEmission.dll' $
;    , dll_location = 's:\Projects\IDL\ASlibrary\REO\agsGeneralRadioEmission.dll' $
     
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
; вычисление радиокарт и сканов --------------------------------------------------------
rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , harmonics = [2, 3, 4] $
    , FluxR = FluxR $
    , FluxL = FluxL $
    , scanR = scanR $
    , scanL = scanL $
    )
    
; ну и нарисуем что получилось:
; радиокарты ...
cR = contour(alog10(FluxR), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map', /FILL)
cL = contour(alog10(FluxL), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map', /FILL)

; ... и сканы:
xarc = asu_linspace(arcbox[0, 0], arcbox[1, 0], n_elements(scanR))         
pR = plot(xarc, scanR, window_title = 'Right scan')
pL = plot(xarc, scanL, window_title = 'Left scan')

; пересчитаем карты в яркостные температуры:
FluxRT = asu_fluxpixel2temp(FluxR, freq, visstep)
FluxLT = asu_fluxpixel2temp(FluxL, freq, visstep)

;---------------------------------------------------------------------------------------
; вычисление сканов по радиокарте (здесь для примера - скан в более широких границах, 
; дальше будет полезно при расчетах с масками)
; ВАЖНО! сканы отдельно могут быть вычислены только в контексте существующей разметки поля!
; т.е. размер радиокарты должен соответствовать размеру, который вернул вызов reo_prepare_calc_map,
; и позиционирована она относительно диска Солнца будет так же, как и при полном расчете reo_calculate_map    
;---------------------------------------------------------------------------------------
; расширим границы скана: --------------------------------------------------------------
scan_lim = arcbox[*, 0] + [-40.5, 40.7] ; на сорок с копейками арксекунд вправо и влево
print, scan_lim
rcr = reo_convolve_map( $
      ptr, FluxR, freq, scanRCEx $
    , scan_lim = scan_lim $
    )
print, scan_lim
; заметим, что границы скорректированы для подгонки к шагу сетки
rcr = reo_convolve_map( $
      ptr, FluxL, freq, scanLCEx $
    , scan_lim = scan_lim $
    )
print, scan_lim

; ... и нарисуем туда же ---------------------------------------------------------------
xarc = asu_linspace(scan_lim[0], scan_lim[1], n_elements(scanRCEx))         
pRCEx = plot(xarc, scanRCEx, '--g2', OVERPLOT = pR)
pLCEx = plot(xarc, scanLCEx, '--g2', OVERPLOT = pL)

;---------------------------------------------------------------------------------------
; используем маску для работы с разными моделями ---------------------------------------
; NB! Этот раздел отчасти устарел, лучше работать с маской по континууму ---------------
B_threshold = 1800 ; порог 1800 Гаусс

;  выделяем поле больше порога
umbra = Bph ge B_threshold
; ... и считаем потоки (сканы посчитаем потом)
rc = reo_calculate_map( $
      ptr, H, Temp, Dens, freq $
    , viewMask = umbra $
    , FluxR = FluxRu $
    , FluxL = FluxLu $
    )

; выделяем поле меньше порога ...
outumbra = Bph lt B_threshold
; ... и задаем другую модель
Hx =    [1,   2e8, 2.1e8, 2e10] ; cm - высота над фотосферой
Tempx = [1e4, 1e4,   3e6,  3e6] ; K - температуры на соответствующих высотах
Densx = 3e15/Temp ; cm^{-3} - плотности электронов там же
; ... и опять потоки
rc = reo_calculate_map( $
      ptr, Hx, Tempx, Densx, freq $
    , viewMask = outumbra $
    , FluxR = FluxRx $
    , FluxL = FluxLx $
    )
    
; объединим потоки и построим сканы
FluxR = FluxRu + FluxRx    
FluxL = FluxLu + FluxLx
rcr = reo_convolve_map(ptr, FluxR, freq, scanRCm)
rcr = reo_convolve_map(ptr, FluxL, freq, scanLCm)

; и опять все рисуем:
cR = contour(alog10(FluxR), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Right map (2 models)', /FILL)
cL = contour(alog10(FluxL), RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Left map (2 models)', /FILL)
xarc = asu_linspace(arcbox[0, 0], arcbox[1, 0], n_elements(scanRCm))         
pRC = plot(xarc, scanRCm, '-:m4', OVERPLOT = pR)
pLC = plot(xarc, scanLCm, '-:m4', OVERPLOT = pL)

rc = reo_uninit(ptr)
    
end