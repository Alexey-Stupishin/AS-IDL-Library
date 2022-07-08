pro test_calc_spectra_atm_plot, freqs, FA, FP, FS, S5, S8, mode, xrange, yrange, title
compile_opt idl2

colors = ['000000'x, 'FF00FF'x, '0000FF'x, 'FF0000'x, '00FF00'x, '00FFFF'x]
winsize = [1200, 800]
w = window(window_title = title, title = title, dimensions = winsize)
hR = plot(freqs, freqs, /nodata, color = colors[0], xrange = xrange, yrange = yrange $ ; , /ylog
        , xtitle = 'Frequency, Hz', ytitle = 'Flux, s.f.u./arcsec', thick = 2, overplot = 1)
hfa = plot(freqs, FA[*, mode], color = colors[1], thick = 2, Name = 'Fontenla 1999 A', overplot = hR)
hfp = plot(freqs, FP[*, mode], color = colors[2], thick = 2, Name = 'Fontenla 1999 P', overplot = hR)
hfs = plot(freqs, FS[*, mode], color = colors[3], thick = 2, Name = 'Fontenla 1999 S', overplot = hR)
hs5 = plot(freqs, S5[*, mode], color = colors[4], thick = 2, Name = 'Selhorst 2005', overplot = hR)
hs8 = plot(freqs, S8[*, mode], color = colors[5], thick = 2, Name = 'Selhorst 2008', overplot = hR)
l = legend(TARGET = [hfa, hfp, hfs, hs5, hs8], /DEVICE, /AUTO_TEXT_COLOR, position = [1000, 790])
    
end

;-----------------------------------------------
function test_calc_spectra_atm_atm, atmpath, atmfile, ptr, freqs, taus, harmonics
compile_opt idl2

n_freqs = n_elements(freqs)
spectra = dblarr(n_freqs, 2)
restore, atmpath + atmfile
for frind = 0, n_freqs-1 do begin ; для всех частот: 
    rc = reo_calculate_map( $
          ptr, Height, Temperature, Density, freqs[frind] $
        , tau_ctrl = taus $
        , harmonics = harmonics $
        , ScanR = ScanR $
        , ScanL = ScanL $
        )
    spectra[frind, 0] = max(scanR)     
    spectra[frind, 1] = max(scanL)     
endfor

return, spectra

end

;-----------------------------------------------
pro test_calc_spectra_atm
compile_opt idl2

resolve_routine,'asu_atm_add_profile',/compile_full_file, /either
resolve_routine,'asu_get_dipole_model',/compile_full_file, /either

atmpath = file_dirname((ROUTINE_INFO('asu_atm_add_profile', /functions, /source)).path, /mark)
modpath = file_dirname((ROUTINE_INFO('asu_get_dipole_model', /functions, /source)).path, /mark)

; box из дипольной модели
modfile = modpath + 'dip_140_05_16e8_3000.sav'
reo_load_model, modfile, box, mult = 1.5d

visstep = 2d ; arcsec - шаг видимой сетки радиокарты
freqs = asu_linspace(4, 18, 15)*1d9 ; Hz - частоты
taus = 100d
harmonics = [2, 3, 4]

ptr = reo_prepare_calc_map(box, visstep, M, base, posangle = 0, arcbox = arcbox, field = field, version_info = version_info $
                         , model = 1 $
                         , freefree = 0 $
                          ) 

if ptr eq 0 then begin ; Чтобы акулы не укусили:
    message, 'Prepare Library Problem', /cont
    return
endif

print, version_info

maxs = dblarr(2)
tt = systime(/seconds)
FA = test_calc_spectra_atm_atm(atmpath, 'fontenla1999_A_faint_supgr_cell_interior.sav', ptr, freqs, taus, harmonics)
maxs[0] = max([maxs[0], max(FA[*, 0])])
maxs[1] = max([maxs[1], max(FA[*, 1])])
print, 'performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)

tt = systime(/seconds)
FP = test_calc_spectra_atm_atm(atmpath, 'fontenla1999_P_bright_plage.sav', ptr, freqs, taus, harmonics)
maxs[0] = max([maxs[0], max(FP[*, 0])])
maxs[1] = max([maxs[1], max(FP[*, 1])])
print, 'performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)

tt = systime(/seconds)
FS = test_calc_spectra_atm_atm(atmpath, 'fontenla1999_S_umbra.sav', ptr, freqs, taus, harmonics)
maxs[0] = max([maxs[0], max(FS[*, 0])])
maxs[1] = max([maxs[1], max(FS[*, 1])])
print, 'performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)

tt = systime(/seconds)
S5 = test_calc_spectra_atm_atm(atmpath, 'selhorst2005.sav', ptr, freqs, taus, harmonics)
maxs[0] = max([maxs[0], max(S5[*, 0])])
maxs[1] = max([maxs[1], max(S5[*, 1])])
print, 'performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)

tt = systime(/seconds)
S8 = test_calc_spectra_atm_atm(atmpath, 'selhorst2008_10_708_4_397.sav', ptr, freqs, taus, harmonics)
maxs[0] = max([maxs[0], max(S8[*, 0])])
maxs[1] = max([maxs[1], max(S8[*, 1])])
print, 'performed in ' + asu_sec2hms(systime(/seconds)-tt, /issecs)

xrange = [min(freqs)*0.95, max(freqs)*1.05]
yrange = [1e-4, 2]
test_calc_spectra_atm_plot, freqs, FA, FP, FS, S5, S8, 0, xrange, yrange, 'Right spectra'
test_calc_spectra_atm_plot, freqs, FA, FP, FS, S5, S8, 1, xrange, yrange, 'Left spectra'
 
rc = reo_uninit(ptr)
    
end
    