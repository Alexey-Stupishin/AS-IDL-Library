pro reo_samples_calc_map_profile
compile_opt idl2

resolve_routine,'asu_get_dipole_model',/compile_full_file, /either
modpath = file_dirname((ROUTINE_INFO('asu_get_dipole_model', /functions, /source)).path, /mark)

;filename = modpath + '12470_hmi.M_720s.20151218_125809.W86N13CR.CEA.NAS.sav' 
filename = modpath + '11312_hmi.M_720s.20111010_085818.W121N24CR.CEA.NAS_750.sav' 
restore, filename ; GX-box

;---------------------------------------------------------------------------------------
; параметры моделирования: -------------------------------------------------------------
Height =    [1,   1e8, 1.1e8, 2e10] ; cm - высота над фотосферой
Temperature = [1e4, 1e4, 2e6,   2e6] ; K - температуры на соответствующих высотах
Density = 3e15/Temperature ; cm^{-3} - плотности электронов там же

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
;taus = 10^asu_linspace(-2, 1, 208) ; от 0.01 до 10, 208 штук
taus = 10^asu_linspace(-5, 2, 300)

;---------------------------------------------------------------------------------------
; вычисление радиокарт и высотных профилей ---------------------------------------------
rc = reo_calculate_map( $
      ptr, Height, Temperature, Density, freq $
    , FluxR = FluxR $
    , FluxL = FluxL $
    , tau_ctrl = taus $
    , harmonics = [2, 3, 4] $
    , depthR = depthR, heightsR = heightsR, fluxesR = fluxesR, sR = shR $
    , depthL = depthL, heightsL = heightsL, fluxesL = fluxesL, sL = shL $
    )
    
; а как набирается оптическая толщина по лучу зрения над точкой радиокарты, например
x = 180 ; 130
y = 120 ; 90
; ?

; посмотрим, сколько контрольных точек оптической толщины насчиталось в правой поляризации:
dR = depthR[x, y]
; и для каждой контролируемой величины (в правой поляризации) получим:
hR = reo_get_los_profile(depthR, heightsR, x, y) ; высоты
fR = asu_fluxpixel2temp(reo_get_los_profile(depthR, fluxesR, x, y), freq, visstep) ; температуры
sR = reo_get_los_profile(depthR, shR, x, y) ; номера гармоник
tR = taus[0:dR-1] ; на соответствующих контролируемых оптических толлщинах 

; и то же самое в левой:
dL = depthL[x, y]
hL = reo_get_los_profile(depthL, heightsL, x, y) ; высоты
fL = asu_fluxpixel2temp(reo_get_los_profile(depthL, fluxesL, x, y), freq, visstep) ; температуры
sL = reo_get_los_profile(depthL, shL, x, y) ; номера гармоник
tL = taus[0:dL-1] ; на соответствующих контролируемых оптических толлщинах

; ну и нарисуем что получилось:
; радиокарты:
winsize = [800, 650]
cnt = 0
asu_plt_wincont, cnt, 'Right Map', winsize
;contour, alog10(FluxR), NLEVELS=100, /isotropic, /FILL
tvplot, FluxR
asu_plt_wincont, cnt, 'Left Map', winsize
;contour, alog10(FluxL), NLEVELS=100, /isotropic, /FILL
tvplot, FluxL

; профили над точкой [x, y] по лучу зрения:
asu_plt_winplot, cnt, 'Profile, Right', winsize
plot, [0], xrange = [min(hR)*0.95, max(hR)*1.05], yrange = minmax(taus), /ylog, xtitle = 'Height, cm', ytitle = 'opt.thickness, -'
oplot, hR, tR ; набранная оптическая толщина как функция высоты (R)
; за счет какой гармоники набирается оптическая толщина - указано цветом (2-я - красным, 3-я - синим, 4-я, если есть - зеленым):
reo_plot_harmonics, 2, sR, hR, tR, '0000FF'x
reo_plot_harmonics, 3, sR, hR, tR, 'FF0000'x
reo_plot_harmonics, 4, sR, hR, tR, '00FF00'x

asu_plt_winplot, cnt, 'Temperature, Right', winsize
plot, [0], xrange = [min(hR)*0.95, max(hR)*1.05], yrange = minmax(fR), /ylog, xtitle = 'Height, cm', ytitle = 'T, K'
oplot, hR, fR ; набранная оптическая толщина как функция высоты (R)
; за счет какой гармоники набирается оптическая толщина - указано цветом (2-я - красным, 3-я - синим, 4-я, если есть - зеленым):
reo_plot_harmonics, 2, sR, hR, fR, '0000FF'x
reo_plot_harmonics, 3, sR, hR, fR, 'FF0000'x
reo_plot_harmonics, 4, sR, hR, fR, '00FF00'x

; и то же для левой поляризации:
asu_plt_winplot, cnt, 'Profile, Left', winsize
plot, [0], xrange = [min(hL)*0.95, max(hL)*1.05], yrange = minmax(taus), /ylog, xtitle = 'Height, cm', ytitle = 'opt.thickness, -'
oplot, hL, tL ; набранная оптическая толщина как функция высоты (L)
reo_plot_harmonics, 2, sL, hL, tL, '0000FF'x
reo_plot_harmonics, 3, sL, hL, tL, 'FF0000'x
reo_plot_harmonics, 4, sL, hL, tL, '00FF00'x

asu_plt_winplot, cnt, 'Temperature, Left', winsize
plot, [0], xrange = [min(hL)*0.95, max(hL)*1.05], yrange = minmax(fL), /ylog, xtitle = 'Height, cm', ytitle = 'T, K'
oplot, hL, fL ; набранная оптическая толщина как функция высоты (L)
; за счет какой гармоники набирается оптическая толщина - указано цветом (2-я - красным, 3-я - синим, 4-я, если есть - зеленым):
reo_plot_harmonics, 2, sL, hL, fL, '0000FF'x
reo_plot_harmonics, 3, sL, hL, fL, 'FF0000'x
reo_plot_harmonics, 4, sL, hL, fL, '00FF00'x

; дополнительно можем посмотреть, как меняется полное поле и угол к лучу зрения над той же точкой:
; вычислим все профили над радиокартой:
rc = reo_get_field_los(ptr, depthFLOS, HFLOS, BFLOS, cosFLOS)

; получим профили поля и угла над точкой [x, y] по лучу зрения:
hB = reo_get_los_profile(depthFLOS, HFLOS, x, y) ; высоты
BB = reo_get_los_profile(depthFLOS, BFLOS, x, y) ; поле
cosB = reo_get_los_profile(depthFLOS, cosFLOS, x, y) ; угол

; и нарисуем:
asu_plt_winplot, cnt, 'Magnetic Field', winsize
yrange = [0, max(BB)*1.05]
plot, [0], xrange = [0, max(hB)*1.05], yrange = yrange, xtitle = 'Height, cm', ytitle = 'Mag. Field, G'
oplot, hB, BB, thick = 2
; укажем высоты, соответствующие центрам гироуровней (теми же цветами)
reo_plot_harmonic_heights, hB, BB, freq, 2, yrange, '0000FF'x
reo_plot_harmonic_heights, hB, BB, freq, 3, yrange, 'FF0000'x
reo_plot_harmonic_heights, hB, BB, freq, 4, yrange, '00FF00'x

asu_plt_winplot, cnt, 'cos(angle)', winsize
yrange = [min(cosB), max(cosB)]
yrange[0] *= yrange[0] lt 0 ? 1.05 : 0.95 
yrange[0] = -1 > yrange[0] < 1 
yrange[1] *= yrange[1] gt 0 ? 1.05 : 0.95 
yrange[1] = -1 > yrange[1] < 1 
plot, [0], xrange = [0, max(hB)*1.05], yrange = yrange, xtitle = 'Height, cm', ytitle = 'cos(angle), -'
oplot, hB, cosB, thick = 2
; укажем высоты, соответствующие центрам гироуровней (теми же цветами)
reo_plot_harmonic_heights, hB, BB, freq, 2, yrange, '0000FF'x
reo_plot_harmonic_heights, hB, BB, freq, 3, yrange, 'FF0000'x
reo_plot_harmonic_heights, hB, BB, freq, 4, yrange, '00FF00'x
    
rc = reo_uninit(ptr)

;TB = interpol(Temp, H, hB)
;DB = interpol(Dens, H, hB)
;save, filename='c:\temp\prof.sav', hB, BB, cosB, TB, DB

end
