function calc_map_harmon_ratio_Temper_ti2_as_h_eff
end

;----------------------------------------------------------------------------------------
pro calc_map_harmon_ratio_Temper_ti2_as_h

outdir='d:\SSW\packages\my_packages\detsad\harmoniks\'
  
compile_opt idl2

resolve_routine,'asu_get_dipole_model',/compile_full_file, /either
modpath = file_dirname((ROUTINE_INFO('asu_get_dipole_model', /functions, /source)).path, /mark)

;filename = modpath + '12470_hmi.M_720s.20151218_125809.W86N13CR.CEA.NAS.sav' 
filename = modpath + '11312_hmi.M_720s.20111010_085818.W121N24CR.CEA.NAS_750.sav' 
restore, filename ; GX-box

;---------------------------------------------------------------------------------------
; параметры моделирования: -------------------------------------------------------------
;Height =    [1,   1e8, 1.1e8, 2e10] ; cm - высота над фотосферой
;Temperature = [1e4, 1e4, 2e6,   2e6] ; K - температуры на соответствующих высотах
;Density = 3e15/Temperature ; cm^{-3} - плотности электронов там же
restore, 'd:\SSW\packages\my_packages\detsad\harmoniks\11312_p1_r1.sav'
visstep = 0.5 ; arcsec - шаг видимой сетки радиокарты

posangle = asu_ratan_position_angle_by_date(0, box.index.date_obs)
             ; для нулевого азимута РАТАН-600 равен позиционному углу Солнца
             ; для ненулевого азимута РАТАН-600 может быть получен утилитой asu_ratan_position_angle
freq = 5.7e9 ; Hz - частота

harmonics = [2, 3, 4]

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
    , version_info = version_info $ ; когда, где и в какой верс8ии библиотеки мы работаем - для контроля
    )

if ptr eq 0 then begin ; что-то пошло не так ...
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info

; набор контролируемых оптических толщин -----------------------------------------------
taus = [1d, 100d]

;---------------------------------------------------------------------------------------
; вычисление радиокарт и высотных профилей ---------------------------------------------
rc = reo_calculate_map( $
      ptr, Height, Temperature, Density, freq $
    , FluxR = FluxR $
    , FluxL = FluxL $
    , tau_ctrl = taus $
    , harmonics = harmonics $
    , depthR = depthR, heightsR = heightsR, fluxesR = fluxesR, sR = shR $
    , depthL = depthL, heightsL = heightsL, fluxesL = fluxesL, sL = shL $
    )
    
asize = size(fluxesR)
effHR = fltarr(asize[1], asize[2], n_elements(harmonics))
effHL = fltarr(asize[1], asize[2], n_elements(harmonics))
for x = 0, asize[1]-1  do begin 
    for  y = 0, asize[2]-1 do begin
        if depthR[x, y] gt 0 then begin 
            if shR[x, y, 0] gt 0 then begin
                idx = where(harmonics eq shR[x, y, 0])
                effHR[x, y, idx] = heightsR[x, y, 0]
            endif
        endif         
        if depthL[x, y] gt 0 then begin 
            if shL[x, y, 0] gt 0 then begin
                idx = where(harmonics eq shL[x, y, 0])
                if idx eq 0 then begin
                    stophere = 1
                endif
                effHL[x, y, idx] = heightsL[x, y, 0]
            endif
        endif         
    endfor
endfor

save, filename = 's:\University\Work\11312_for_2022\heights_by_harm.sav', effHR, effHL

end
