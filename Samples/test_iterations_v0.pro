pro test_iterations
compile_opt idl2

resolve_routine,'asu_atm_add_profile',/compile_full_file, /either

filename = 's:\UData\SDOBoxesOld\11312_hmi.M_720s.20111010_085818.W121N24CR.CEA.NAS.sav' 
restore, filename ; GX-кубик

; данные по РАТАНу в нашей с тобою реализации, на то же время;
ratan = rtu_get_ratan_data('s:\University\Work\11312\RATAN_AR11312_20111010_090044_az0_SPECTRA__lin_appr.dat')
pos = [3,4,5]
nfreq = n_elements(ratan.freqs)
freqs = ratan.freqs[0:*:5]
robs = ratan.right[pos, 0:*:5]
lobs = ratan.left[pos, 0:*:5]
; позиционный угол РАТАН. Вообще полезная утилита 
posangle = asu_ratan_position_angle_by_date(ratan.header.azimuth, box.index.date_obs)

visstep = 1 ; arcsec - шаг видимой сетки радиокарты

;---------------------------------------------------------------------------------------
; подготовка библиотеки, установка магнитного поля и разметка радиокарты ---------------
ptr = reo_prepare_calc_map( $
      box, visstep $ ; GX-кубик и шаг радиокарты 
    , M, base $ результат: размер и позиционирование радиокарты
    , posangle = posangle $  
    , freefree = 0 $
    , arcbox = arcbox $ ; вернет границы радиокарты в угл. секундах
    , field = field $ ; вернет полное поле на фотосфере, как мы видим его с Земли
    , version_info = version_info $ ; когда, где и в какой версии библиотеки мы работаем - для контроля
    )

if ptr eq 0 then begin ; что-то пошло не так, акулы, скажем, укусили  ...
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info ; для контроля
; если хотите нарисовать полное поле на фотосфере, раскомментируйте пару следующих строк  
;Bph = sqrt(field.bx^2 + field.by^2 + field.bz^2)
;cB = contour(Bph, RGB_TABLE = 0, N_LEVELS=30, ASPECT_RATIO=1.0, window_title = 'Photosphere Field', /FILL)

; колдунство, построение маски: 
model_mask = decompose(box.base.bz, box.base.ic) ; see Fontenla 2009. e.g. 7 - umbra, 6 - penumbra etc.

; диапазоны высот, можно варьировать:
Ht1 = [1e-8 ,0.1 ,0.3 ,0.5 ,0.7 ,0.9 ,1.1 ,1.3 ,1.5 ,1.7 ,1.9 ,2.1 ,2.4 ,2.7 ,3.0 ,3.3 ,3.7 ,4.1 ,4.5 ,5.0 ,5.5 ,6.0 ,6.5 ,7.0 ,8.0 , 9 ,10 ,15 ,20 ,50]*1d8
Ht2 = [ 0.1 ,0.3 ,0.5 ,0.7 ,0.9 ,1.1 ,1.3 ,1.5 ,1.7 ,1.9 ,2.1 ,2.4 ,2.7 ,3.0 ,3.3 ,3.7 ,4.1 ,4.5 ,5.0 ,5.5 ,6.0 ,6.5 ,7.0 ,8.0 ,9.0 ,10 ,15 ,20 ,25 ,60]*1d8
; и их центральнае точки
Hc = (Ht1+Ht2)/2d

;---------------------------------------------------------------------------------------
;-----------------------------------------------------------------
; Инициализация фотосферного профиля по маске: "базовая" атмосфера ("Спокойное Солнце"),
; будет применена для всех пикселей маски, для которых не подбирается атмосферный профиль
Tc = dblarr(n_elements(Hc))
Tc[0:10] = 4e3 
Tc[11:-1] = 2e6 
Dens = 1d16/Tc
mask_set = asu_atm_init_profile(Hc, Tc, Dens, fixrange = indgen(n_elements(Hc)-1))

; добавим начальный атмосферный профиль для полутени (индекс в маске = 6)
; (может быть тот же, что и базовый)
mask_set = asu_atm_add_profile(mask_set, 6, Hc, Tc, Dens, fixrange = indgen(6))

; добавим начальный атмосферный профиль для тени (индекс в маске = 7)
; (может быть тот же, что и базовый)
mask_set = asu_atm_add_profile(mask_set, 7, Hc, Tc, Dens, fixrange = indgen(6))

params = rif_get_params()
result = rif_calc_1_iteration_3D(ptr, mask_set, model_mask, freqs, robs, lobs, params)

rc = reo_uninit(ptr)
    
end