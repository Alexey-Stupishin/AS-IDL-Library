pro test_calc_map_for_kappa
;
; Набор примеров, иллюстрирующих использование библиотеки расчетов радиокарт
; для детального изучения структуры излучающей области
; Рекомендуется пошаговое выполнение
; 
;---------------------------------------------------------------------------------------
; загрузка GX-box ----------------------------------------------------------------------
;     пример из поставляемого пакета:
dirpath = file_dirname((ROUTINE_INFO('test_calc_map_for_kappa', /source)).path, /mark)
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
    , cycloCalc_Distribution_Type = 2 $ ;  2 - каппа-распределение (1 или отсутствует - Максвелл) 
    , version_info = version_info $ ; когда, где и в какой версии библиотеки мы работаем - для контроля
    )

if ptr eq 0 then begin ; что-то пошло не так ...
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info

; зададим частоты спектра
freqs = indgen(14, /DOUBLE) + 4

; и значения каппа
kappas = [6, 8, 10, 20, 50, 100]

colors = ['red', 'green', 'blue', 'cyan', 'magenta', 'black']

winR = window(dimensions = [1200, 600], window_title = 'Right spectra')
winL = window(dimensions = [1200, 600], window_title = 'Left spectra')
hpR = make_array(n_elements(kappas), /OBJ)
hpL = make_array(n_elements(kappas), /OBJ)
for k = 0, n_elements(kappas)-1 do begin
    spectrumR = dblarr(n_elements(freqs))
    spectrumL = dblarr(n_elements(freqs))
    for kf = 0, n_elements(freqs)-1 do begin
        rc = reo_calculate_map( $
              ptr, H, Temp, Dens, freqs[kf]*1e9 $
            , FluxR = FluxR $
            , FluxL = FluxL $
            , scanR = scanR $
            , scanL = scanL $
            , cycloCalc_Distribution_kappaK = kappas[k] $ ;  параметр каппа-распределения 
            )
        ; проверим код возврата (значения кодов описаны в обертке reo_calculate_map)    
        if rc ne 0 then begin
            print, 'Return Code = ', rc
            return
        end
        ; спектр по максимуму сканов      
        spectrumR[kf] = max(scanR)    
        spectrumL[kf] = max(scanL)    
    endfor
    ; ну и нарисуем что получилось:
    winR.SetCurrent
    hpR[k] = plot(freqs, spectrumR, name = 'kappa = ' + strtrim(string(kappas[k]), 2), yrange = [0, 6], color = colors[k], /current)
    winL.SetCurrent
    hpL[k] = plot(freqs, spectrumL, name = 'kappa = ' + strtrim(string(kappas[k]), 2), yrange = [0, 12], color = colors[k], /current)
endfor

; и легенда    
winR.SetCurrent
LR = legend(target = hpR)    
winL.SetCurrent
LL = legend(target = hpL)    
    
rc = reo_uninit(ptr)
    
end
