function test_calc_map_scan_temp_by_harms_fluxes, depth, fluxes, s, harmonics
compile_opt idl2

nharms = n_elements(harmonics)
res = dblarr(nharms)

for is = 0, nharms-1 do begin
    ss = where(s eq harmonics[is], count)
    if count gt 0 then begin
        res[is] = abs(fluxes[ss[-1]] - fluxes[ss[0]])
    endif
endfor    

return, res        

end

;----------------------------------------------------------------------
pro test_calc_map_scan_temp_by_harms
compile_opt idl2

resolve_routine,'asu_get_dipole_model',/compile_full_file, /either
dirpath = file_dirname((ROUTINE_INFO('asu_get_dipole_model', /functions, /source)).path, /mark)
filename = dirpath + 'dip_140_05_16e8_3000.sav'
restore, filename ; GX-box
posangle = 0
model = 1

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

Height =    [  1, 1e8, 1.2e8, 2e10]
Temperature = [4e3, 4e3, 2e6,   2e6]
Density = 1d16/Temperature
taus = 10^asu_linspace(-5, 2, 300)
harmonics = [2, 3, 4]

tt = systime(/seconds)
nfreqs = n_elements(freqs)
nharms = n_elements(harmonics)
totR = dblarr(nharms, nfreqs)
totL = dblarr(nharms, nfreqs)
for frind = 0, nfreqs-1 do begin 
    ; Посчитаем радиокарты и структуру набора оптической толщины вдоль луча зрения:  
    rc = reo_calculate_map(ptr, Height, Temperature, Density, freqs[frind], FluxR = FluxR, FluxL = FluxL $
                             , tau_ctrl = taus $
                             , harmonics = harmonics $
                             , depthR = depthR, heightsR = heightsR, fluxesR = fluxesR, sR = shR $
                             , depthL = depthL, heightsL = heightsL, fluxesL = fluxesL, sL = shL $
                              )
    for x = 0, M[0]-1 do begin                              
        for y = 0, M[1]-1 do begin
            fR = test_calc_map_scan_temp_by_harms_fluxes(depthR[x, y], fluxesR[x, y, *], shR[x, y, *], harmonics)
            totR[*, frind] += fR
            fL = test_calc_map_scan_temp_by_harms_fluxes(depthL[x, y], fluxesL[x, y, *], shL[x, y, *], harmonics)
            totL[*, frind] += fL
        endfor                                  
    endfor
    ;totL[*, frind] /= total(totL[*, frind])                
endfor
print, 'performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)

colors = ['0000FF'x, 'FF0000'x, '00FF00'x]
winsize = [800, 650]
cnt = 0
xrange = [min(freqs)*0.95, max(freqs)*1.05]
asu_plt_winplot, cnt, 'Right spectra', winsize
yrange = [0, max(total(totR, 1))*1.05]
plot, freqs, total(totR, 1), xrange = xrange, yrange = yrange, xstyle = 1, xtitle = 'Frequency, Hz', ytitle = 'Flux, s.f.u./arcsec', thick = 2
for hind = 0, nharms-1 do begin
    oplot, freqs, totR[hind, *], color = colors[hind], thick = 2
endfor    

asu_plt_winplot, cnt, 'Left spectra', winsize
yrange = [0, max(total(totL, 1))*1.05]
plot, freqs, total(totL, 1), xrange = xrange, yrange = yrange, xstyle = 1, xtitle = 'Frequency, Hz', ytitle = 'Flux, s.f.u./arcsec', thick = 2
for hind = 0, nharms-1 do begin
    oplot, freqs, totL[hind, *], color = colors[hind], thick = 2
endfor    

rc = reo_uninit(ptr)
    
end
    