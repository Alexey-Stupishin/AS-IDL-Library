function reo_map_scan_part_by_harms_get_s, s, Flux, harms
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
pro reo_map_scan_part_by_harms
compile_opt idl2

resolve_routine,'asu_get_dipole_model',/compile_full_file, /either
modpath = file_dirname((ROUTINE_INFO('asu_get_dipole_model', /functions, /source)).path, /mark)

;--------------------------------------------------------------------------------
;filename = modpath + 'dip_140_05_16e8_3000.sav'
;restore, filename ; GX-box
;posangle = 0
;model = 1
;--------------------------------------------------------------------------------
filename = modpath + '11312_hmi.M_720s.20111010_085818.W121N24CR.CEA.NAS_750.sav' 
restore, filename ; GX-box
posangle = asu_ratan_position_angle_by_date(0, box.index.date_obs)
model = 0
;--------------------------------------------------------------------------------

visstep = 0.3d ; arcsec - шаг видимой сетки радиокарты
freqs = asu_linspace(4, 18, 29)*1d9 ; Hz - частоты

ptr = reo_prepare_calc_map(box, visstep, M, base, posangle = posangle, arcbox = arcbox, field = field, version_info = version_info $
                         , model = model $
                         , freefree = 0 $
                          ) 

if ptr eq 0 then begin ; Чтобы акулы не укусили:
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info

restore, 'd:\SSW\packages\my_packages\detsad\harmoniks\11312_p1_r1.sav'
;Height =    [  1, 1e8, 1.2e8, 2e10]
;Temperature = [4e3, 4e3, 2e6,   2e6]
;Density = 1d16/Temperature

taus = [1, 100]
harmonics = [2, 3, 4]

tt = systime(/seconds)
nfreqs = n_elements(freqs)
allharms = [0, harmonics] ; добавим к списку гармоник 0, для оптически тонкого излучения
nharms = n_elements(allharms)
maxR = dblarr(nharms, nfreqs)
totR = dblarr(nharms, nfreqs)
maxL = dblarr(nharms, nfreqs)
totL = dblarr(nharms, nfreqs)
for frind = 0, nfreqs-1 do begin 
    rc = reo_calculate_map(ptr, Height, Temperature, Density, freqs[frind], FluxR = FluxR, FluxL = FluxL $
                             , tau_ctrl = taus $
                             , harmonics = harmonics $
                             , depthR = depthR, heightsR = heightsR, fluxesR = fluxesR, sR = shR $
                             , depthL = depthL, heightsL = heightsL, fluxesL = fluxesL, sL = shL $
                              )
    for hind = 0, nharms-1 do begin 
        ; радиокарты только тех пикселей, где опт. толщина достигает 1 на h-гармонике
        ; (функция описана в нвчале файла)
        resR = reo_map_scan_part_by_harms_get_s(allharms[hind], FluxR, shR[*, *, 0])
        resL = reo_map_scan_part_by_harms_get_s(allharms[hind], FluxL, shL[*, *, 0])
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

asu_plt_winplot, cnt, 'Right spectra, %', winsize
yrange = [0d, 110d]
totals = total(maxR, 1)
plot, freqs, replicate(100d, nfreqs), xrange = xrange, yrange = yrange, xstyle = 1, xtitle = 'Frequency, Hz', ytitle = 'Flux, s.f.u./arcsec', thick = 2
for hind = 0, nharms-1 do begin
    oplot, freqs, maxR[hind, *]/totals*100d, color = colors[hind], thick = 2
endfor    
asu_plt_winplot, cnt, 'Left spectra, %', winsize
yrange = [0d, 110d]
totals = total(maxL, 1)
plot, freqs, replicate(100d, nfreqs), xrange = xrange, yrange = yrange, xstyle = 1, xtitle = 'Frequency, Hz', ytitle = 'Flux, s.f.u./arcsec', thick = 2
for hind = 0, nharms-1 do begin
    oplot, freqs, maxL[hind, *]/totals*100d, color = colors[hind], thick = 2
endfor    

rc = reo_uninit(ptr)
    
end
    