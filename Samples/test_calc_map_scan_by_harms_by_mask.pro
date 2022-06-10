function test_calc_map_scan_by_harms_by_mask_get_s, s, Flux, harms
compile_opt idl2

sz = size(Flux)
res = dblarr(sz[1], sz[2])
idx = where(harms eq s, count)
if count ne 0 then begin
    res[idx] = Flux[idx]
endif

return, res        

end

;----------------------------------------------------------------------
pro test_calc_map_scan_by_harms_by_mask
compile_opt idl2

resolve_routine,'asu_atm_add_profile',/compile_full_file, /either

dirpath = file_dirname((ROUTINE_INFO('test_calc_map_scan_by_harms_by_mask', /source)).path, /mark)

filename = dirpath + '12470_hmi.M_720s.20151218_094609.W85N13CR.CEA.NAS_(1000).sav'
restore, filename ; GX-box
posangle = asu_ratan_position_angle_by_date(-10, box.index.date_obs) ; позиционный угол
model_mask = decompose(box.base.bz, box.base.ic) ; see Fontenla 2009. e.g. 7 - umbra, 6 - penumbra etc.
model = 0

;test_calc_map_load_model, 's:\Projects\IDL\BigSamples\mod_dipole_30_largeFOV2.sav', 1.1d, 950d, 0, 0.43d, 0.045d, box, model_mask, model
;test_calc_map_load_model, 's:\Projects\IDL\BigSamples\mod_dipole_30_largeFOV2.sav', 1.0d, 950d, 0, 1.1d, 1.1d, box, model_mask, model

visstep = 0.3d ; arcsec - шаг видимой сетки радиокарты
freqs = asu_linspace(4, 18, 53)*1d9 ; Hz - частоты

ptr = reo_prepare_calc_map(box, visstep, M, base, posangle = posangle, arcbox = arcbox, field = field, version_info = version_info $
                         , model = model $
                         , freefree = 0 $
                          ) 

if ptr eq 0 then begin ; Чтобы акулы не укусили:
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info

;H =    [1,   2d8,   2.3d8, 3.0d8, 5.0d9]
;Temp = [1d4, 1d4,   1.0d6, 1.2d6, 2.5d6]
;Dens = 1d16/Temp
H =    [  1, 1e8, 1.2e8, 2e10]
Temp = [4e3, 4e3, 2e6,   2e6]
Dens = 3d15/Temp
mask_set = asu_atm_init_profile(H, Temp, Dens)

;HP =    [1,   1.5d8, 1.8d8, 2.5d8, 5.0d9]
;TempP = [1d4,   1d4, 0.8d6, 1.0d6, 2.0d6]
;DensP = 1d16/TempP
;mask_set = asu_atm_add_profile(mask_set, 6, HP, TempP, DensP)
;
;HU =    [1,   1.0d8, 1.3d8, 2.0d8, 5.0d9]
;TempU = [1d4,   1d4, 0.7d6, 0.9d6, 2.0d6]
;DensU = 1d16/TempU
;mask_set = asu_atm_add_profile(mask_set, 7, HU, TempU, DensU)

rc = reo_set_atmosphere_mask_set(ptr, mask_set, model_mask)

; до этого все, как ранее
;  
; контролируемые величины оптической толщины (они и умолчательно такие, здесь явно указаны
; для нагладности и возможности написать комментарий/ну и пообщаться, что ли). В результатах расчета
; будут сохранены высоты и номера гармоник, на которых достигается заданная оптическая толщина.
; Нас в первую очередь будут интересовать те высоты/гармоники, где tau = 1
; Гармоники 2, 3, 4
; Тормозное для чистоты не учитываем
taus = [1d, 25d]
harmonics = [2, 3, 4]

tt = systime(/seconds)
; для всех частот:
nfreqs = n_elements(freqs)
allharms = [0, harmonics] ; добавим к списку гармоник 0, для оптически тонкого излучения
nharms = n_elements(allharms)
maxR = dblarr(nharms, nfreqs)
totR = dblarr(nharms, nfreqs)
maxL = dblarr(nharms, nfreqs)
totL = dblarr(nharms, nfreqs)
for frind = 0, nfreqs-1 do begin 
    ; Посчитаем радиокарты и структуру набора оптической толщины вдоль луча зрения:  
    rc = reo_calculate_map_atm(ptr, freqs[frind], FluxR = FluxR, FluxL = FluxL $
                             , tau_ctrl = taus $
                             , harmonics = harmonics $
                             , depthR = depthR, heightsR = heightsR, fluxesR = fluxesR, sR = shR $
                             , depthL = depthL, heightsL = heightsL, fluxesL = fluxesL, sL = shL $
                              )
    for hind = 0, nharms-1 do begin 
        ; радиокарты только тех пикселей, где опт. толщина достигает 1 на h-гармонике
        ; (функция описана в нвчале файла)
        resR = test_calc_map_scan_by_harms_by_mask_get_s(allharms[hind], FluxR, shR)
        resL = test_calc_map_scan_by_harms_by_mask_get_s(allharms[hind], FluxL, shL)
        ; Cканы    
        rcr = reo_convolve_map(ptr, resR, freqs[frind], scanR)
        rcr = reo_convolve_map(ptr, resL, freqs[frind], scanL)
        ; Максимумы и полные потоки
        maxR[hind, frind] = max(scanR)
        totR[hind, frind] = total(scanR)*visstep
        maxL[hind, frind] = max(scanL)
        totL[hind, frind] = total(scanL)*visstep
    endfor
endfor
print, 'performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)

colors = ['FF00FF'x, '0000FF'x, 'FF0000'x, '00FF00'x]
winsize = [800, 650]
cnt = 0
xrange = [min(freqs)*0.95, max(freqs)*1.05]
asu_plt_winplot, cnt, 'Right spectra', winsize
yrange = [0, max(total(maxR, 1))*1.05]
plot, freqs, total(maxR, 1), xrange = xrange, yrange = yrange, xstyle = 1, xtitle = 'Frequency, Hz', ytitle = 'Flux, s.f.u./arcsec', thick = 2
for hind = 0, nharms-1 do begin
    oplot, freqs, maxR[hind, *], color = colors[hind], thick = 2
endfor    
asu_plt_winplot, cnt, 'Right spectra, Total', winsize
yrange = [0, max(total(totR, 1))*1.05]
plot, freqs, total(totR, 1), xrange = xrange, yrange = yrange, xstyle = 1, xtitle = 'Frequency, Hz', ytitle = 'Flux, s.f.u.', thick = 2
for hind = 0, nharms-1 do begin
    oplot, freqs, totR[hind, *], color = colors[hind], thick = 2
endfor    
asu_plt_winplot, cnt, 'Left spectra', winsize
yrange = [0, max(total(maxL, 1))*1.05]
plot, freqs, total(maxL, 1), xrange = xrange, yrange = yrange, xstyle = 1, xtitle = 'Frequency, Hz', ytitle = 'Flux, s.f.u./arcsec', thick = 2
for hind = 0, nharms-1 do begin
    oplot, freqs, maxL[hind, *], color = colors[hind], thick = 2
endfor    
asu_plt_winplot, cnt, 'Left spectra, Total', winsize
yrange = [0, max(total(totL, 1))*1.05]
plot, freqs, total(totL, 1), xrange = xrange, yrange = yrange, xstyle = 1, xtitle = 'Frequency, Hz', ytitle = 'Flux, s.f.u.', thick = 2
for hind = 0, nharms-1 do begin
    oplot, freqs, totL[hind, *], color = colors[hind], thick = 2
endfor    

rc = reo_uninit(ptr)
    
end
    