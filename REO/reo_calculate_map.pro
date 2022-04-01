; IDL Wrapper to:
;   radiomaps/scans calculations (in Alexey G. Stupishin implementation)
;   
; v 2.15.20.317 (rev.277)
; 
; NB! Beta-version! But nearly ready to enduser... (and only under Windows 64-bit, sorry...)
; 
; Call:
; rc = reo_calculate_map( ptr, H, T, D, freq $
;                       , scan_lim = scan_lim $
;                       , depthR = depthR, FluxR = FluxR, tauR = tauR, heightsR = heightsR, fluxesR = fluxesR, sR = sR $
;                       , depthL = depthL, FluxL = FluxL, tauL = tauL, heightsL = heightsL, fluxesL = fluxesL, sL = sL $
;                       , scanR = scanR, scanL = scanL $
;                       , depthFF = depthFF, FluxFF = FluxFF, tauFF = tauFF, heightsFF = heightsFF, fluxesFF = fluxesFF, scanFF = scanFF $
;                       , depthLOS = depthLOS, HLOS = HLOS, BLOS = BLOS, cosLOS = cosLOS $
;                       , rc = rc $        
;                       , _extra = _extra
; Parameters description:
; 
; Parameters required (in):
;   (in)      ptr             (ULONG64)                                   Pointer to the data structure (see reo_prepare_calc_map.pro)
;         H, T, D - height profiles
;   (in)      H               (n-elements fload/double array)        cm   Heights above the photosphere, in ascending order  
;   (in)      T               (n-elements fload/double array)         K   Corresponding temperatures (non-negative, no greater 10^8)
;   (in)      D               (n-elements fload/double array)    cm^{-3}  Corresponding electron densities (non-negative)
;                                                                         Note: all 3 arrays should be of the same length
;   (in)      freq            (fload/double)                          Hz  Frequency to calculate radioemission  
;   
; Parameters optional (in):
;   (in)      _extra          (various data types)                        Additional setting (such as tuning parameters, additional 
;                                                                         conditions etc.), partially:
;   (in)      harmonics                       (integer/long)              Calculated harmonic numbers (default [2, 3, 4]) 
;   (in)      tau_ctrl                        (float/double)              NB! To be described!
;   (in)      freefree                        (integer/long)       -----  (see description in reo_prepare_calc_map.pro)
;   (in)      cycloCalc_Distribution_Type     (integer/long)       -----  (see description in reo_prepare_calc_map.pro)
;   (in)      cycloCalc_Distribution_kappaK   (float/double)       -----  (see description in reo_prepare_calc_map.pro)
;   (in)      cycloCalc_LaplasMethod_Use      (integer/long)       -----  (see description in reo_prepare_calc_map.pro)
;   (in)      useqt                           (integer/long)       -----  (see description in reo_prepare_calc_map.pro)
;   (in)      usealtlibrary                   (integer/long)       -----  (see description in reo_prepare_calc_map.pro)

;   (in)      viewmask        (integer/long 2-D array)                    if viewmask[i,j] = 0, corresponding element of radiomaps will not be calculated
;                                                                         and set to zero. If viewmask omitted, whole map will be calculated.(*) 
;   (in)      mode, beam_c, beam_b, scan_lim                              RATAN-600 scan specific (see reo_convolve_map.pro and separate document)(**)  
;
; Parameters optional (out):
;   (out)     FluxR           (double 2-D array)         s.f.u./arcsec^2  Radiomap of the flux in the right polarization  
;   (out)     FluxL           (double 2-D array)         s.f.u./arcsec^2  Radiomap of the flux in the left polarization
;   (out)     scanR           (double 1-D array)           s.f.u./arcsec  Emulated RATAN-600 scan, right polarization, specific for RATAN-600(**)
;   (out)     scanL           (double 1-D array)           s.f.u./arcsec  Emulated RATAN-600 scan, left polarization, specific for RATAN-600(**)
; 
; *  Note: viewmask (int) should be of 'Mout' size (see output 'Mout' in reo_prepare_calc_map.pro). 
;          FluxR, FluxL (out) will be of the same size
; ** Note: some in/out parameters are specific to RATAN-600 scans, described in reo_convolve_map.pro and
;          separate document
;                  
;    Another Note: there are some other optional parameters, which will be descibed in the next versions of conveyor
; 
; Return code:
;       0     no errors
;   < 200   initialization errors (perhaprs reo_prepare_calc_map was not called before)
;     201   zero length atmosphere data
;     202   heights are not in asceding order
;     203   temperature(s) are negative or exceed 100 MK
;     204   density(ies) are negative
;
;     401   too low (< 1e8) or too high (> 1e12) frequency
;     402   zero length harmonic array
;     403   harmonic number(s) are less than 2 or greater than 32
;     404   for kappa-distribution: kappa parameter less that max. harmonic number + 1
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
                                              
;----------------------------------------------------------------------------------------------
function reo_calculate_map, ptr, H, T, D, freq $
                          , scan_lim = scan_lim $
                          , depthR = depthR, FluxR = FluxR, tauR = tauR, heightsR = heightsR, fluxesR = fluxesR, sR = sR $
                          , depthL = depthL, FluxL = FluxL, tauL = tauL, heightsL = heightsL, fluxesL = fluxesL, sL = sL $
                          , scanR = scanR, scanL = scanL $
                          , rc = rc $        
                          , _extra = _extra

dll_location = getenv('reo_dll_location')

vptr = ulong64(ptr)

;vRSun  = 960d
;returnCode = CALL_EXTERNAL(dll_location, 'reoGetDouble', vptr, 'cycloMap.Conditions.RSun', vRSun, VALUE = 0)

vM = lonarr(2)
returnCode = CALL_EXTERNAL(dll_location, 'reoGetVisParams', vptr, vM)

vn_atm = long(n_elements(H))
vH = double(H)
vT = double(T)
vD = double(D)
vfreq = double(freq)
vharm = [2L, 3L, 4L]
vtau = 25d

vMask = 0L

vmode = 3L
vck = double(0)
vbk = double(0)
vposR = -1L
vposL = -1L
vscanlimpos = 0L

value = bytarr(34)
value[2] = 1 ; n_atm
value[6:7] = 1 ; freq, nHarm
value[9] = 1 ; nTau
value[11] = 1 ; NULL Mask
value[12:13] = 1 ; mode, nBeam
value[16:18] = 1 ; posR, posL, NULL vscanlimpos

n = n_tags(_extra)
parameterMap = replicate({itemName:'',itemvalue:0d},n+1)
nParameters = 0;
if n gt 0 then begin
    keys = strlowcase(tag_names(_extra))
    for i = 0, n-1 do begin
        case keys[i] of
            'harmonics': begin
                vharm = long(_extra.(i))
            end
            'tau_ctrl': begin 
                vtau = double(_extra.(i))
            end
            'viewmask': begin
                vMask = transpose(long(_extra.(i)), [1, 0])
                value[11] = 0
            end
            'mode': begin 
                vmode = long(_extra.(i))
            end
            'beam_c': begin 
                vck = double(_extra.(i))
            end
            'beam_b': begin 
                vbk = double(_extra.(i))
            end
            'posr': begin 
                vposR = long(_extra.(i))
            end
            'posl': begin 
                vposL = long(_extra.(i))
            end
            else: begin
                parameterMap[nParameters].itemName = asu_subst_map_name(keys[i])
                parameterMap[nParameters].itemValue = _extra.(i)
                nParameters++
            end
        endcase
    endfor
endif
parameterMap[nParameters].itemName = '!____idl_map_terminator_key___!';

vnHarm = long(n_elements(vharm))
vnTau = long(n_elements(vtau))
vnBeam = long(n_elements(vck))    ; NB! check ck, bk length

scanLng = vM[1]
if keyword_set(scan_lim) then begin   ; NB! check length == 2
    scanLng = reo_get_scan_lim(vptr, scan_lim, vscanlimpos)
    value[18] = 0
endif
    
if arg_present(depthR)    then vdepthR    = lonarr(vM[0], vM[1])        else reu_setNULL, vdepthR,      value, 19 
if arg_present(fluxR)     then vfluxR     = dblarr(vM[0], vM[1])        else reu_setNULL, vfluxR,       value, 20 
if arg_present(tauR)      then vtauR      = dblarr(vM[0], vM[1])        else reu_setNULL, vtauR,        value, 21 
if arg_present(heightsR)  then vheightsR  = dblarr(vM[0], vM[1], vnTau) else reu_setNULL, vheightsR,    value, 22 
if arg_present(fluxesR)   then vfluxesR   = dblarr(vM[0], vM[1], vnTau) else reu_setNULL, vfluxesR,     value, 23 
if arg_present(sR)        then vsR        = lonarr(vM[0], vM[1], vnTau) else reu_setNULL, vsR,          value, 24
 
if arg_present(depthL)    then vdepthL    = lonarr(vM[0], vM[1])        else reu_setNULL, vdepthL,      value, 25 
if arg_present(fluxL)     then vfluxL     = dblarr(vM[0], vM[1])        else reu_setNULL, vfluxL,       value, 26 
if arg_present(tauL)      then vtauL      = dblarr(vM[0], vM[1])        else reu_setNULL, vtauL,        value, 27 
if arg_present(heightsL)  then vheightsL  = dblarr(vM[0], vM[1], vnTau) else reu_setNULL, vheightsL,    value, 28 
if arg_present(fluxesL)   then vfluxesL   = dblarr(vM[0], vM[1], vnTau) else reu_setNULL, vfluxesL,     value, 29 
if arg_present(sL)        then vsL        = lonarr(vM[0], vM[1], vnTau) else reu_setNULL, vsL,          value, 30

if arg_present(scanR)     then vscanR     = dblarr(scanLng)             else reu_setNULL, vscanR,       value, 31
if arg_present(scanL)     then vscanL     = dblarr(scanLng)             else reu_setNULL, vscanL,       value, 32

if arg_present(rc)        then vrc        = lonarr(vM[0], vM[1])        else reu_setNULL, vrc,          value, 39 

returnCode = CALL_EXTERNAL(  dll_location, 'reoCalculateMap', vptr, parameterMap $          ; 0-1
                           , vn_atm, vH, vT, vD $                                           ; 2-5    
                           , vfreq, vnHarm, vharm, vnTau, vtau $                            ; 6-10
                           , vMask $                                                        ; 11
                           , vmode, vnBeam, vck, vbk, vposR, vposL, vscanlimpos $           ; 12-18
                           , vdepthR, vFluxR, vtauR, vheightsR, vfluxesR, vsR $             ; 19-24
                           , vdepthL, vFluxL, vtauL, vheightsL, vfluxesL, vsL $             ; 25-30
                           , vscanR, vscanL $                                               ; 31-32
                           , vrc $                                                          ; 39        
                           , VALUE = value, /CDECL)

if isa(vdepthR,    /ARRAY) then depthR =    transpose(vdepthR, [1, 0])
if isa(vfluxR,     /ARRAY) then fluxR =     transpose(vfluxR, [1, 0])
if isa(vtauR,      /ARRAY) then tauR =      transpose(vtauR, [1, 0])
if isa(vheightsR,  /ARRAY) then heightsR =  transpose(vheightsR, [1, 0, 2])
if isa(vfluxesR,   /ARRAY) then fluxesR =   transpose(vfluxesR, [1, 0, 2])
if isa(vsR,        /ARRAY) then sR =        transpose(vsR, [1, 0, 2])

if isa(vdepthL,    /ARRAY) then depthL =    transpose(vdepthL, [1, 0])
if isa(vfluxL,     /ARRAY) then fluxL =     transpose(vfluxL, [1, 0])
if isa(vtauL,      /ARRAY) then tauL =      transpose(vtauL, [1, 0])
if isa(vheightsL,  /ARRAY) then heightsL =  transpose(vheightsL, [1, 0, 2])
if isa(vfluxesL,   /ARRAY) then fluxesL =   transpose(vfluxesL, [1, 0, 2])
if isa(vsL,        /ARRAY) then sL =        transpose(vsL, [1, 0, 2])

if isa(vscanR,     /ARRAY) then scanR = vscanR
if isa(vscanL,     /ARRAY) then scanL = vscanL
if isa(vscanFF,    /ARRAY) then scanFF = vscanFF

if isa(vrc,        /ARRAY) then rc =        transpose(vrc, [1, 0])

return, returnCode

end
