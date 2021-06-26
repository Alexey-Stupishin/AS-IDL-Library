; IDL Wrapper to:
;   RATAN-600 radiomaps convolution
;   
; v 2.15.20.317 (rev.277)
; 
; NB! Beta-version! But nearly ready to enduser... (and only under Windows 64-bit, sorry...)
; 
; Call:
; rc = function reo_convolve_map(ptr, fluxmap, freq, scan $
;                              , scan_lim = scan_lim $
;                              , _extra = _extra 
;                     
; Parameters description:
; 
; Parameters required (in):
;   (in)      ptr             (ULONG64)                                   Pointer to the data structure (see reo_prepare_calc_map.pro)
;   (in)      fluxmap         (float/double 2-D array)          s.f.u.    Radiomap of the flux to convolve(*)  
;   (in)      freq            (fload/double)                       Hz     Frequency to calculate beam parameters
;   
; Parameters optional (in):
;   (in)      _extra          (various data types)                        Additional setting (such as tuning parameters, additional
;                                                                         conditions etc.), partially:
;   (in)      mode            (integer/long)                    -----     beam type, default = APPROX (see separate document)  
;   (in)      beam_c          (float/double)                    -----     beam c-parameter (see separate document)  
;   (in)      beam_b          (float/double)                    -----     beam b-parameter (see separate document)  
;   (in/out)  scan_lim        (float/double 2-element array)   arcsec     limits can be set to extend scan margins (can be useful for long
;                                                                         wavelength). Note that after convolution margins can be slightly changed,
;                                                                         because of adjusting scan margins to the radio map grid
;    
; Parameters required (out):
;   (out)     scan            (double 1-D array)        s.f.u./arcsec     Emulated RATAN-600 scan
;
; * Note: convolution performed in the context of currently markuped radio map! It means that fluxmap should be of the size that defined in
;         markup procedure (see output 'Mout' parameter of reo_prepare_calc_map.pro).
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
                                             
function reo_convolve_map, ptr, fluxmap, freq, scan $
                         , scan_lim = scan_lim $
                         , _extra = _extra 

dll_location = getenv('reo_dll_location')

vptr = ulong64(ptr)
vmap = double(transpose(fluxmap, [1, 0]))
vfreq = double(freq)

vmode = 3L
vck = double(0)
vbk = double(0)
vscanlimpos = 0L

value = bytarr(9)
value[2] = 1 ; freq
value[4:5] = 1 ; mode nBeam
value[8] = 1 ; NULL vscanlimpos 

n = n_tags(_extra)
if n gt 0 then begin
    keys = strlowcase(tag_names(_extra))
    for i = 0, n-1 do begin
        case keys[i] of
            'mode': begin 
                vmode = long(_extra.(i))
            end
            'beam_c': begin 
                vck = double(_extra.(i))
            end
            'beam_b': begin 
                vbk = double(_extra.(i))
            end
            else:
        endcase
    endfor
endif

sz = size(fluxmap)
scanLng = sz[1]
if keyword_set(scan_lim) then begin   ; NB! check length == 2
    scanLng = reo_get_scan_lim(vptr, scan_lim, vscanlimpos)
    value[8] = 0
endif

scan = dblarr(scanLng)
returnCode = CALL_EXTERNAL(dll_location, 'reoConvolve', vptr, vmap, vfreq, scan, $
                           vmode, long(n_elements(vck)), vck, vbk, vscanlimpos, VALUE = value, /CDECL)

return, returnCode 

end
