;
; This code create mask for each pixel of GX-box photosphere using 
; Mask value array (from 1 to 7) corresponds to the model numbers: Fontenla et al., The Astrophysical Journal, 707:482–502, 2009 December 10
;    ADS: 2009ApJ...707..482F
;    DOI: 10.1088/0004-637X/707/1/482
;    IDL: see also 'asu_get_fontenla2009.pro'
;
; v 1.0.21.1009 (rev.475)
; 
; Call:
; mask = reo_get_model_mask(ptr, Bph, baseIC, cont = cont, used = used)
; 
; Parameters description (see also Comments to asu_get_fontenla2009.pro/section below):
; 
; Parameters required (in):
;   (in)      ptr     (ULONG64)                 Pointer to the data structure (see reo_prepare_calc_map.pro)
; !***********************************   (in)      Bph     (double 2D array)         Photosphere magnetic field, absolute value (marked up as radiomap)
;             baseIC                            Continuum emission, as in the GX-Box
;   
; Parameters optional (out):
;   (out)     cont    (double 2D array)         Continuum emission, marked up as radiomap
;   (out)     used    (long 2D array)           corresponding using array, 1 - pixel is in the GX-Box, 0 - pixel is out          
;   
; Return value:
;   model mask (integer 2D array), values 1 - 7 (see reference above)
;
; Comments:
;   Function calls function 'decompose' from SSW package 'GX-simulator' 
;
; (c) Alexey G. Stupishin, Saint Petersburg State University, Saint Petersburg, Russia, 2021
;     mailto:agstup@yandex.ru
;
;--------------------------------------------------------------------------;
;     \|/     Set the Controls for the Heart of the Sun           \|/      ;
;    --O--        Pink Floyd, "A Saucerful Of Secrets", 1968     --O--     ;
;     /|\                                                         /|\      ;  
;--------------------------------------------------------------------------;
;                                                              
function reo_get_model_mask, ptr, baseBz, baseIC, cont = cont, used = used

rc = reo_get_markup_scalar(ptr, baseBz, bz, used)
rc = reo_get_markup_scalar(ptr, baseIC, cont, used)
idx = where(used eq 0, count)
if count gt 0 then begin
    bz[idx] = 0; conditional QS Bph
    cont[idx] = max(cont); conditional QS cont
endif
model_mask = decompose_as(bz, cont, used); see Fontenla 2009. e.g. 7 - umbra, 6 - penumbra etc.

return, model_mask

end
