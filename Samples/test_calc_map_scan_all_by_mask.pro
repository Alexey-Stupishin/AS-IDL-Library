function test_calc_map_scan_all_by_mask_subtrQS, Flux, FluxFF, threshold
compile_opt idl2

F = Flux
idx = where(F eq 0, count)
if count gt 0 then F[idx] = 1d
FFF = FluxFF
idx = where(FFF eq 0, count)
if count gt 0 then FFF[idx] = 1d

Fratio = F/FFF

Fout = Flux
idx = where(Fratio lt threshold, count)
if count gt 0 then Fout[idx] = 0

return, Fout

end

;----------------------------------------------------------------------
pro test_calc_map_scan_all_by_mask
compile_opt idl2

resolve_routine,'asu_atm_add_profile',/compile_full_file, /either

dirpath = file_dirname((ROUTINE_INFO('test_calc_map_scan_all_by_mask', /source)).path, /mark)
filename = dirpath + '12470_hmi.M_720s.20151216_085809.W85N12CR.CEA.NAS(_1000).sav' 
restore, filename ; GX-box

visstep = 0.5d ; arcsec - шаг видимой сетки радиокарты
posangle = 13.6d ; позиционный угол: 
freq = 10d9 ; Hz - частота

ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-модель и шаг радиокарты 
    , M, base $ результат: размер и смещение радиокарты, для справки, использовать необязательно
    , posangle = posangle $  
    , freefree = 1 $ ; consider free-free
    , arcbox = arcbox $ ; вернет границы радиокарты в угл. секундах
    , field = field $ ; вернет полное поле на фотосфере, как мы видим его с Земли
    , version_info = version_info $ ; когда, где и в какой версии библиотеки мы работаем - для контроля
    )

if ptr eq 0 then begin ; Такого быть не должно, что-то пошло не так ...
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info

;---------------------------------------------------------------------------------------
; Построение маски с учетом поля и излучения в континууме ------------------------------
model_mask = decompose(box.base.bz, box.base.ic) ; see Fontenla 2009. e.g. 7 - umbra, 6 - penumbra etc.

;-----------------------------------------------------------------
; Инициализация фотосферного профиля по маске: "базовая" атмосфера ("Спокойное Солнце"),
; будет применена для всех пикселей маски, для которых не задан собственный атмосферный профиль
H =    [1,   2d8,   2.3d8, 3.0d8, 5.0d9]
Temp = [1d4, 1d4,   1.0d6, 1.2d6, 2.5d6]
Dens = 1d16/Temp
mask_set = asu_atm_init_profile(H, Temp, Dens)

; добавим атмосферный профиль для полутени (индекс в маске = 6)
; (количество точек профиля может отличаться от такового для базовой атмосферы)
HP =    [1,   1.5d8, 1.8d8, 2.5d8, 5.0d9]
TempP = [1d4,   1d4, 0.8d6, 1.0d6, 2.0d6]
DensP = 1d16/TempP
mask_set = asu_atm_add_profile(mask_set, 6, HP, TempP, DensP)

; добавим атмосферный профиль для тени (индекс в маске = 7)
HU =    [1,   1.0d8, 1.3d8, 2.0d8, 5.0d9]
TempU = [1d4,   1d4, 0.7d6, 0.9d6, 2.0d6]
DensU = 1d16/TempU
mask_set = asu_atm_add_profile(mask_set, 7, HU, TempU, DensU)

; загрузим заданные профили в библиотеку ...
rc = reo_set_atmosphere_mask_set(ptr, mask_set, model_mask)
 
; ... , посчитаем радиокарты ...  
rc = reo_calculate_map_atm(ptr, freq, FluxR = FluxR , FluxL = FluxL)

; ... и нарисуем их:    
winsize = [800, 650]
cnt = 0
asu_plt_wincont, cnt, 'Full Right Map', winsize
;contour, alog10(FluxR), NLEVELS=100, /isotropic, /FILL
tvplot, FluxR
asu_plt_wincont, cnt, 'Full Left Map', winsize
;contour, alog10(FluxL), NLEVELS=100, /isotropic, /FILL
tvplot, FluxL

; Попробуем оценить и вычесть спокойное Солнце    
; Нулевое магнитное поле
sz = size(box.bx)
box.bx = dblarr(sz[1], sz[2], sz[3])
box.by = dblarr(sz[1], sz[2], sz[3])
box.bz = dblarr(sz[1], sz[2], sz[3])
ptr = reo_prepare_calc_map(box, visstep , posangle = posangle, freefree = 1)

; Базовая атмосфера везде
mask_set = asu_atm_init_profile(H, Temp, Dens)
rc = reo_set_atmosphere_mask_set(ptr, mask_set, model_mask)

; Радиокарты спокойного Солнца
rc = reo_calculate_map_atm(ptr, freq , FluxR = FluxRFF , FluxL = FluxLFF)

; обнулим все пиксели, в которых поток с учетом циклотрона и структуры
; АО мало (скажем, не более чем на 10%) отличается от потока СС
; (функция описана в начале этого файла):
threshold = 1.1d
FluxRAR = test_calc_map_scan_all_by_mask_subtrQS(FluxR, FluxRFF, threshold)
FluxLAR = test_calc_map_scan_all_by_mask_subtrQS(FluxL, FluxLFF, threshold)

asu_plt_wincont, cnt, 'Right Map, no QS', winsize
;contour, alog10(FluxRAR), NLEVELS=100, /isotropic, /FILL
tvplot, FluxRAR
asu_plt_wincont, cnt, 'Left Map, no QS', winsize
;contour, alog10(FluxLAR), NLEVELS=100, /isotropic, /FILL
tvplot, FluxLAR

; Посчитаем и нарисуем сканы    
rcr = reo_convolve_map(ptr, FluxRAR, freq, scanR)
rcr = reo_convolve_map(ptr, FluxLAR, freq, scanL)

xarc = asu_linspace(arcbox[0, 0], arcbox[1, 0], n_elements(scanR))
asu_plt_winplot, cnt, 'Scans', winsize
plot, [0], xrange = minmax(xarc), yrange = [0, max([scanR, scanL])*1.1d], xtitle = 'arcsec', ytitle = 's.f.u./arcsec'
oplot, xarc, scanR, linestyle = 0, color = '0000FF'x, thick = 2
oplot, xarc, scanL, linestyle = 0, color = 'FF0000'x, thick = 2

rc = reo_uninit(ptr)
    
end