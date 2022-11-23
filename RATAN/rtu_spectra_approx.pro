; IDL Wrapper to:
;   Approximation of RATAN-600 scans by Asym2Sig function:
;   F(f) = y0 + A*(1/(1+exp(-(f-xc+w1/2)/w2)))*(1-1/(1+exp(-(f-xc-w1/2)/w3)))
;   
; v 2.17.20.802 (rev.324)
; 
; Call:
;   rc = rtu_spectra_approx(freqs, fluxes, result)
;   
; Parameters description:
; 
; Parameters required (in):
;   (in)    freqs           (float/double)  any units   array of observation frequncies
;   (in)    fluxes          (float/double)  any units   array of observed fluxes (of the same length as freqs)
;   
; Parameters optional (in):
;   (in)    dll_location    (string)        -----       Full path to calling radioemission DLL; if omitted, DLL will be
;                                                       searched in the folder, containing reo_calculate_map.pro procedure
;                                                       
; Parameters (out):
;   (out)   result          (double)        any units   array of smoothed fluxes at the same frequencies and in the same units
;                                                       as fluxes
;   
; Parameters optional (out):
;   (out)   version_info    (string)        -----       agsGeneralRadioEmission.dll library version information
;   
; Output value (int):
;    1 - success (but it should be checked if the result is reasonable)
;    0 - too many iterations, but result could be reasonable
;   -1 - library is not found
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

function rtu_spectra_approx, freqs, fluxes $ ; in
                        , result $ ; out
                        , dll_location = dll_location, version_info = version_info ; optional

ptr = reo_init(dll_location = dll_location, version_info = version_info)
vptr = ulong64(ptr)
vfreqs = double(freqs)
if min(freqs) gt 1d8 then vfreqs *= 1d-9  
vfluxes = double(fluxes)

if ptr eq 0 then begin
    return, -1
endif

n = long(n_elements(freqs))
result = dblarr(n)
    
returnCode = CALL_EXTERNAL(getenv('reo_dll_location'), 'reo_aduSpectraAsym2Sig', vptr, n, vfreqs, vfluxes, result, value = [1, 1, 0, 0])
returnCode2 = reo_uninit(ptr)
    
return, returnCode

end
