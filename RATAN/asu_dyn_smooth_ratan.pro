; AGS Utilities collection
;   RATAN QS paddle (base)  
;   
; Call:
;   asu_dyn_smooth_RATAN, scan, step, down = down, slit_vert = slit_vert, slit_horz = slit_horz, symm = symm, lim_top = lim_top, lim_edge = lim_edge
; 
; Parameters:
;     Required:
;         scan (in)         RATAN scan (1st dimension is scan, ther dims arbitrary)  
;         step (in)         RATAN scan step, arcsec
;         
;     Optional:
;         method (in)       smoothing method (1 or 2) (default = 1)
;         
;         slit_vert (in)    vertical slit (for mostly steep parts of scan, such as limbs) (rel.part of max)
;                           (default = 0.2 for method 1, 0.4 for method 2)  
;         slit_horz (in)    horizontal slit (for mostly flat parts of scan, such disk center) (arcsec, default = 900)
;         
;         lim_edge (in)     relative part of most "exceeding" points, which should be corrected (default = 0.9)
;                           provides approach to the lower envelop, see Note below  
;         down (in)         number of iterations (smooth of smoothed) (default = 1)
;         
;         symm (in)         if set (/symm), required that paddle should be symmetric
;
; Return value:
;         smoothed scans of the same size as 'scan'
;           
; Notes:
;   To get more smoothed (but maybe not precise) scan you can:
;       1. increase slit_vert (for steep of scan)
;       2. increase slit_horz (for flat of scan)
;       
;   To get the paddle closer to the lower envelop you can:
;       2. increase lim_edge
;       3. increase down
; 
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2021-2023
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;
;

function asu_dyn_smooth_RATAN, scan, step, down = down, slit_vert = slit_vert, slit_horz = slit_horz, symm = symm, lim_edge = lim_edge, method = method

if n_elements(method) eq 0 then method = 1
if n_elements(down) eq 0 then down = 1
if n_elements(slit_vert) eq 0 then slit_vert = method eq 1 ? 0.2 : 0.4
if n_elements(slit_horz) eq 0 then slit_horz = 900 
if n_elements(lim_top) eq 0 then lim_top = 0.8 
if n_elements(lim_edge) eq 0 then lim_edge = 0.9
down = fix(0 > down < 10)
slit_vert = 0.01 > slit_vert < 0.99
slit_horz = 10 > slit_horz < 3000
lim_top = 0.01 > lim_top < 0.99
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
        
        smt = asu_dyn_smooth(I, half_slit_vert, half_slit_horz, method = method)
        Imod = I
        
        for t = 1, down do begin
            smt = asu_dyn_smooth_down(Imod, smt, half_slit_vert, half_slit_horz, lim_top, lim_edge, method = method)
            if keyword_set(symm) then smt = asu_dyn_smooth_symm(Imod, smt, Imod, half_slit_vert, half_slit_horz, method = method)
        endfor
        
        smoo[*, k, m] = smt
    endfor
endfor



return, smoo

end
