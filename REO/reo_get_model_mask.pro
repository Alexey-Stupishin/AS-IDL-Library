;
; This code create mask for each pixel of GX-box photosphere using 
; Mask values (from 1 to 7) corresponds to the model numbers: Fontenla et al., The Astrophysical Journal, 707:482–502, 2009 December 10
;    ADS: 2009ApJ...707..482F
;    DOI: 10.1088/0004-637X/707/1/482
;    IDL: asu_get_fontenla2009.pro
;
; v 1.0.21.1001 (rev.472)
; 
; Call:
; mask = reo_get_model_mask(ptr, Bph, baseIC, outIC, cont = cont, cmask = cmask)
; 
; Parameters description (see also Comments to asu_get_fontenla2009.pro/section below):
; 
; Parameters required (in):
;   (in)      ptr     (ULONG64)                                   Pointer to the data structure (see reo_prepare_calc_map.pro)
;   (in)      Bph     (double 2D array)
;             baseIC
;   
; Parameters required (out):
;   (out)     outIC       (double 2D array)        heigths above photosphere (cm), heretheafter see comment #2 regarding arrays length
;  
; Parameters optional (out):
;   (out)     cont      (double 2D array)        proton density at corresponding heights (cm^{-3})
;   (out)     cmask     (long 2D array)        hydrogen density at corresponding heights (cm^{-3})
;   
; Return value:
;   mask 
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
function reo_get_model_mask, ptr, Bph, baseIC, outIC, cont = cont, cmask = cmask

vBph = Bph
rc = reo_get_markup_scalar(ptr, baseIC, cont, cmask)
idx = where(cmask eq 0, count)
if count gt 0 then begin
    vBph[idx] = 10; conditional QS Bph
    cont[idx] = max(cont); conditional QS cont
endif
model_mask = decompose(vBph, cont); see Fontenla 2009. e.g. 7 - umbra, 6 - penumbra etc.

return, model_mask

end
