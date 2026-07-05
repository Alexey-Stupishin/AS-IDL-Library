;pro sample_calc_los_tau_v2
;cd, 'c:\Users\kaltman\Argo\2025\Izmiran_posters\Depression\calculus\incuadro\'

;restore, 'c:\Users\kaltman\Argo\2025\Izmiran_posters\Depression\calculus\incuadro2\model_0\Inst.sav'
;totInts_base=totInts

model='model_4'
  ;windim = [4000, 2000]
  windim = [1200, 800]   ; почти всегда влезает
  base_path = 'c:\temp\' ; 'c:\Users\kaltman\Argo\2026\IKI\calculus\incuadro\'+model+'/'
FILE_MKDIR, base_path


P = 3d15
H = 40d8 ;h_center   40d8=40 Мм
W = 2e7  ;width     0.5 Мм=5e7 см 
factorB = 2.;1.3
valueT = 2.e5; 10000


resolve_routine,'asu_get_anchor_module_dir',/compile_full_file, /either
dirpath = file_dirname((ROUTINE_INFO('asu_get_anchor_module_dir', /source, /functions)).path, /mark)
;restore, 'c:\Users\kaltman\Argo\2026\IKI\calculus\base_model\base_param.sav'
filename = dirpath + '..\Samples\mod_dipole_30_largeFOV2.sav'
restore, filename
;pR00 = plot(hR0, alog10(tauR0), color = 'RED', linestyle = line, thick = 3, name = 'Right' $
;  , symbol = symbol, sym_filled = 1, sym_size = 0.6 $
;  , title = title, xtitle = 'Height, Mm', ytitle = ytitle, xrange = [0, max([hR0, hL0])], /current, layout = layout, margin = 0.1)

; высота, температура, плотность
height0 = [0, 1d8, 1.1d8, 2.5d8, 5d9]
temperature0 = [4d3, 4d3, 1d6, 1.5d6, 2d6]
density0 = P/temperature0
; массивы одинаковой длины

; встраиваем холодный слой
is_atm_ok = asu_modify_LOS_gauss(height0, temperature0, H, W, height, temperature, value = valueT, /log)

;height = height0
;temperature = temperature0
density = P/temperature

; поле, угол
; загрузим поле диполя
filename = dirpath + '..\Samples\mod_dipole_30_largeFOV2.sav'
restore, filename




; поле 140х140 пикселей, макс. поле в центре на фотосфере 2000 Гс
; возмем точку несколько в стороне от оси диполя (69.6, 83.2), макс. поле 3000 Гс (factor = 1.5)
t = asu_box_get_los(box, [69.6, 83.2], factor = 1.5)
; => t.height, t.field, t.inclination
; массивы одинаковой длины

; встраиваем "трубку" (для LOS это просто профиль поля по высоте)
is_field_ok = asu_modify_LOS_gauss(t.height, t.field, H, W, height_B, field, factor = factorB)
is_incl_ok = asu_modify_LOS_gauss(t.height, t.inclination, H, W, foo, inclination, factor = 1d)
;height_B = t.height
;field = t.field
inclination = t.inclination


; частоты (1000 частот в диапазоне от 1 до 18 ГГц)
freqs = linspace(1, 18, 1000)*1e9
harmonics = [2, 3, 4];

; оптическая толщина (5000 значений в диапазоне от 0.01 до 1000 в лог. масштабе)
taus = 10^linspace(-2, 3, 5000)

; тормозное по умолчанию учитывается
rc = reo_calculate_los(t.height, t.field, t.inclination, height, temperature, density, freqs $
                      , harmonics = harmonics, tau_ctrl = taus $
                      , totInts = totInts, totTau = totTau $
                      , depth = depth, profHeight = profHeight, profInts = profInts, profHarm = profHarm, profAbsorb = profAbsorb $
                      )
 
                      
; ---- Структура по лучу зрения для выбранной частоты -----
; для примера: частота около 7.3 ГГц
freq =  1.5e9; 7.3e9 ; 3.e9;
mf = min(abs(freqs-freq), fidx)
print, 'Frequency = ' + asu_compstr(freqs[fidx])
freq_str = ', frequency = ' + strcompress(string(freqs[fidx]*1e-9, format = '(F4.1)'), /remove_all) + ' GHz'

; для каждой контролируемой величины получим:
; правая поляризация: hR - высоты [Mm], fR - интенсивности [s.f.u/arcsec^2], sR - номера гармоник
;                   , aR - коэффициенты поглощения [cm^-1]   
;                   , tauR - соответствующие контролируемые оптические толщины  
sample_calc_los_tau_result, fidx, 0, depth, profHeight, profInts, profHarm, profAbsorb, taus $
                          , hR, fR, sR, aR, tauR
; левая поляризация - аналогично: hL, fL, sL, aR, tauL
sample_calc_los_tau_result, fidx, 1, depth, profHeight, profInts, profHarm, profAbsorb, taus $
                          , hL, fL, sL, aL, tauL
         
; определим высоты гармоник
b1 = freq/2.799d6
b2 = b1/2
b3 = b1/3
b4 = b1/4
t.height *= 1d-8

hh = dblarr(5)
hh[2] = interpol(t.height, t.field, b2)
hh[3] = interpol(t.height, t.field, b3)
hh[4] = interpol(t.height, t.field, b4)


; все нарисуем
; гармоники на температурном профиле
win = window(dimensions = windim)
temp = plot(height*1d-8, alog10(temperature), color = 'RED', linestyle = '-', thick = 2, xrange = [0, max( [ max(hR), max(hL) ] )] $    ; max( [ max(hR), max(hL) ] )     max([hR, hL])
  , title = 'Atmoshpere', xtitle = 'Height, Mm', ytitle = 'log(T, K)', name = 'Temperature', /current, layout = [3, 2, 1], axis_style = 1, margin = 0.1)

dens = plot(height*1d-8, alog10(density), color = 'BLACK', linestyle = '-', thick = 2, xrange = [0, max( [ max(hR), max(hL) ] )], name = 'Density', /current, layout = [3, 2, 1], axis_style = 0, margin = 0.1)
dens_ax = axis('y', target = dens, location = [max(dens.xrange),0,0], textpos = 1, title = 'log(D, $cm^{-3}$)')

temp0 = plot(height*1d-8, alog10(temperature0), color = 'RED', linestyle = '--', thick = 1,  overplot =temp)
dens0 = plot(height*1d-8, alog10(density0), color = 'BLACK', linestyle = '--', thick = 1,  overplot =dens)

  mmt = minmax(alog10(temperature))
p2 = plot([hh[2], hh[2]], mmt, color = 'ORANGE', linestyle = ':', thick = 4, name = '$2^{nd}$ harmonic', overplot = temp)
p3 = plot([hh[3], hh[3]], mmt, color = 'LIME GREEN', linestyle = ':', thick = 4, name = '$3^{rd}$ harmonic', overplot = temp)
p4 = plot([hh[4], hh[4]], mmt, color = 'DEEP SKY BLUE', linestyle = ':', thick = 4, name = '$4^{th}$ harmonic', overplot = temp)


;dummy = legend(target = [temp, dens, p2, p3, p4])
dummy = LEGEND(TARGET=[temp, dens, p2, p3, p4], POSITION=[0.295,0.995], SAMPLE_WIDTH=0.05, VERTICAL_SPACING=0.008)
;win.Save, base_path + 'atmosphere.png', width = windim[0], height = windim[1], bit_depth = 2




; --- магнитное поле ---
b = plot(t.height*1d-8, t.field, $
  color='BLUE', thick=2, linestyle='-', $
  xtitle='Height, Mm', ytitle='B, G', $
  title='Magnetic field', name='B',  /current, layout = [3, 2, 2])

; если хочешь вторую кривую (штриховая)
b2 = plot(height_B*1d-8, field, $
  color='BLUE', thick=2, linestyle='--', $
  overplot=b, name='B (alt)')

; легенда
leg = legend(target=[b, b2], position=[0.75, 0.95])

;b = plot(t.height, t.field, color='BLUE', linestyle='-.', thick=2, $
;  name='B')






; ---- Спектр -----
;win = window(dimensions = windim)
fr_0 = 1.0
fr_k = 3.0

idx = where(freqs*1d-9 GE fr_0 AND freqs*1d-9 LE fr_k, nidx)
if nidx GT 0 then begin

  ; --- все кривые в диапазоне ---
  I  = totInts[0, idx] + totInts[1, idx]          ; R+L
  L  = totInts[1, idx]
  R  = totInts[0, idx]
  V  = totInts[1, idx] - totInts[0, idx]          ; L-R

  I0 = totInts0[0, idx] + totInts0[1, idx]
  V0 = totInts0[1, idx] - totInts0[0, idx]

  ; --- общий min/max по всем ---
  all = [ I, L, R, V, I0, V0 ]    ; 1D-вектор

  ymin = min(all) ;* 0.95
  ymax = max(all) ;* 1.05

endif else begin
  ; на всякий случай, если idx пустой
  ymin = !values.f_nan
  ymax = !values.f_nan
endelse



intsI = plot(freqs*1d-9, totInts[0, *]+totInts[1, *], color = 'BLACK', linestyle = '-', thick = 2, name = 'Right+Left' $
  , title = 'Intensity specta', xra=[fr_0,fr_k], yra=[ymin, ymax], xtitle = 'Frequency, GHz', ytitle = 'Intensity, $s.f.u./arcsec^2$', /current, layout = [3, 2, 4], margin = [0.15, 0.08, 0.08, 0.08]) ;/current
  intsL = plot(freqs*1d-9, totInts[1, *], color = 'BLUE', linestyle = '-', thick = 2, name = 'Left', overplot = intsI)
intsR = plot(freqs*1d-9, totInts[0, *], color = 'RED', linestyle = '-', thick = 2, name = 'Right', overplot = intsI)
intsV = plot(freqs*1d-9, totInts[1, *]-totInts[0, *], color = 'GREY', linestyle = '-', thick = 2, name = 'Left-Right', overplot = intsI)
intsIbase = plot(freqs*1d-9, totInts0[1, *]+totInts0[0, *], color = 'BLACK', linestyle = '--', thick = 1, name = 'I_base', overplot = intsI)
intsVbase = plot(freqs*1d-9, totInts0[1, *]-totInts0[0, *], color = 'GREY', linestyle = ':', thick = 2, name = 'V_base', overplot = intsI)

;dummy = legend(target = [intsI,intsR, intsL],  position=[0.2,0.2])
dummy = LEGEND(TARGET=[intsI, intsR, intsL,intsV,intsIbase,intsVbase], POSITION=[0.3,0.42], SAMPLE_WIDTH=0.05, VERTICAL_SPACING=0.01)
;dummy = LEGEND(TARGET=[intsI, intsR, intsL,intsV], POSITION=[0.3,0.4], SAMPLE_WIDTH=0.05, VERTICAL_SPACING=0.01)
;win.Save, base_path + 'Spectra.png', width = windim[0], height = windim[1], bit_depth = 2

;pR = plot(hR, alog10(tauR), color = 'RED', linestyle = line, thick = 3, name = 'Right' $
;  , symbol = symbol, sym_filled = 1, sym_size = 0.6 $
;  , title = title, xtitle = 'Height, Mm', ytitle = ytitle, xrange = [0, max([hR, hL])], /current, layout = layout, margin = 0.1)
;  pL = plot(hR0, alog10(tauR0), color = 'BLUE', linestyle = line, thick = 2, name = 'Left' $
;    , symbol = symbol, sym_filled = 1, sym_size = 0.4 $
;    , overplot = pR)
    
    
;    ;win = window(dimensions = windim)
;
sample_calc_los_tau_plot_comb2_add, hR, hL, alog10(tauR), alog10(tauL),hR0, hL0, alog10(tauR0), alog10(tauL0),'Optical Depth' + freq_str, '$log(\tau, -)$', 0, hh, [3, 2, 3], 1, /zero, /legend
;sample_calc_los_tau_plot_comb2, hR, hL, transpose(sR), transpose(sL),hR0, hL0, transpose(sR0), transpose(sL0), 'Harmonics' + freq_str, 'Harmonic number, -', 1, hh, [3, 2, 3],2
sample_calc_los_tau_plot_comb2_add, hR, hL, transpose(fR), transpose(fL), hR0, hL0, transpose(fR0), transpose(fL0), 'Intensity' + freq_str, 'Intensity, $s.f.u/arcsec^2$', 0, hh, [3, 2, 5],3
sample_calc_los_tau_plot_comb2_add, hR, hL, transpose(alog10(aR)), transpose(alog10(aL)),hR0, hL0, transpose(alog10(aR0)), transpose(alog10(aL0)), 'Absorption' + freq_str, 'log(Absorption, $cm^{-1})$', 1, hh, [3, 2, 6],4

;sample_calc_los_tau_plot_comb, hR, hL, alog10(tauR), alog10(tauL), 'Optical Depth' + freq_str, '$log(\tau, -)$', 0, hh, [3, 2, 2], /zero, /legend
;sample_calc_los_tau_plot_comb, hR, hL, transpose(sR), transpose(sL), 'Harmonics' + freq_str, 'Harmonic number, -', 1, hh, [3, 2, 3]
;sample_calc_los_tau_plot_comb, hR, hL, transpose(fR), transpose(fL), 'Intensity' + freq_str, 'Intensity, $s.f.u/arcsec^2$', 0, hh, [3, 2, 5]
;sample_calc_los_tau_plot_comb, hR, hL, transpose(alog10(aR)), transpose(alog10(aL)), 'Absorption' + freq_str, 'log(Absorption, $cm^{-1})$', 1, hh, [3, 2, 6]

win.Save, base_path + 'atmosphere_all2.png', width = windim[0], height = windim[1], bit_depth = 2

;temperature0=temperature
;density0=density
;totInts0=totInts
;tauR0=tauR
;tauL0=tauL
;sR0=sR
;sL0=sL
;fR0=fR
;fL0=fL
;aR0=aR
;aL0=aL
;hR0=hR
;hL0=hL
;SAVE,  hR0,hL0,temperature0, density0, totInts0, tauR0, tauL0,sR0,sL0,fR0,fL0,aR0,aL0, FILENAME=base_path +'base_param.sav'

end
