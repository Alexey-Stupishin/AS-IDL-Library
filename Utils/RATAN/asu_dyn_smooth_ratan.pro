; AGS Utilities collection
;   RATAN QS paddle (base)  
;   
; Call:
;   asu_dyn_smooth_RATAN, scan, step, down = down, slit_vert = slit_vert, slit_horz = slit_horz, symm = symm, lim_top = lim_top, lim_edge = lim_edge
; 
; Parameters:
;     Required:
;         scan (in) RATAN  
;         step (in)
;         
;     Optional:
;         down (in) 
;         step (in)
;         
; Return value:
;     RATAN position angle (between "E-W" line and RATAN scan line), counter clock wise, degrees
;           (positive e.g. if the RATAN scan line goes from bottom-left to top-right direction)                    
; 
; Sources: Scientific report, SAO RAN, 1983
;    
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2017-2020
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;
;
;smoo = asu_dyn_smooth_RATAN(scan, step)
; где scan – скан для сглаживания, step – шаг скана, угл.сек,  smoo – сглаженные значения в тех же точках.
;входной массив может быть от одно- до трехмерного (скан – всегда по первому измерению), выход будет такого же размера. Т.е. можно, например, сгладить только на выбранных частотах:
; smoo = asu_dyn_smooth_RATAN(template_qs_sun[*, 1, [1, 10, 60]], step)
; получится размерностью 2041x1x3.
;Симметрию задает ключ /symm, по умолчанию он не установлен, подложка будет несимметричной. Кроме того, есть 2 ключа, down (количество итераций, по умолчанию 1) и lim_edge (отвечает за степень приближения к нижней огибающей, по умолчанию 0.9). Ежели тебе кажется, что подложка слишком занижена, можешь уменьшить lim_edge (значение 0 – отсутствие подгонки к нижней огибающей). Ежели наоборот, хочется подложку опустить ниже, можно увеличить lim_edge вплоть до единицы, либо увеличить количество итераций (down = 2, 3).
;Ключ  slit_vert по умолчанию он 0.2, если на подложке появляются выбросы, его можно немного увеличить, скажем, до 0.25. Очень сильно увеличивать опасно, подложка слишком сгладится.


function asu_dyn_smooth_RATAN, scan, step, down = down, slit_vert = slit_vert, slit_horz = slit_horz, symm = symm, lim_top = lim_top, lim_edge = lim_edge

if n_elements(down) eq 0 then down = 1
if n_elements(slit_vert) eq 0 then slit_vert = 0.2 
if n_elements(slit_horz) eq 0 then slit_horz = 900 
if n_elements(lim_top) eq 0 then lim_top = 0.5 
if n_elements(lim_edge) eq 0 then lim_edge = 0.9
down = fix(0 > down < 10)
slit_vert = 0.01 > slit_vert < 0.99
slit_horz = 10 > slit_horz < 3000
lim_top = 0.1 > lim_top < 0.9 
lim_edge = 0 > lim_edge < 0.99

sz0 = size(scan)
sz = [3, 1, 1, 1]
sz[1:sz0[0]] = sz0[1:sz0[0]]
smoo = dblarr(sz[1], sz[2], sz[3])
for k = 0, sz[2]-1 do begin
    for m = 0, sz[3]-1 do begin
        I = scan[*, k, m]
        I[where(I le 0, /NULL)] = 1e-3
        
        half_slit_vert = slit_vert*max(I)/2
        half_slit_horz = fix(slit_horz/step)
        
        smt = asu_dyn_smooth(I, half_slit_vert, half_slit_horz)
        Imod = I
        
        for t = 1, down do begin
            smt = asu_dyn_smooth_down(Imod, smt, half_slit_vert, half_slit_horz, lim_top, lim_edge)
            if keyword_set(symm) then smt = asu_dyn_smooth_symm(Imod, smt, Imod, half_slit_vert, half_slit_horz)
        endfor
        
        smoo[*, k, m] = smt
    endfor
endfor



return, smoo

end
