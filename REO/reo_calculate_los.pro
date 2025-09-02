; IDL Wrapper to:
;   cyclotron/free-free emission calculations along LOS (in Alexey G. Stupishin implementation)
;   
; v 1.1.21.627 (rev.447)
; 
; Call:
;rc = reo_calculate_los(H, B, Th, T, D, freqs $
;                      , harmonics = harmonics, taus = taus $
;                      , totInts = totInts, totTau = totTau $
;                      , depth = depth, profHeight = profHeight, profInts = profInts, profHarm = profHarm $
;                      , dll_location = dll_location $
;                      , _extra = _extra
;                      )
;
; Parameters description:
; 
; Parameters required (in):
;         H, B, Th, T, D - height profiles
;   (in)      H               (n-elements fload/double array)        cm   Heights above the photosphere, in ascending order  
;   (in)      B               (n-elements fload/double array)         G   Corresponding abs. magnetic field values
;   (in)      Th              (n-elements fload/double array)   degrees   Corresponding angles between field and LOS
;   (in)      T               (n-elements fload/double array)         K   Corresponding temperatures (non-negative, no greater 10^8)
;   (in)      D               (n-elements fload/double array)    cm^{-3}  Corresponding electron densities (non-negative)
;                                                                         Note: all 5 arrays should be of the same length
;   (in)      freqs           (fload/double)                         Hz   Frequencies to calculate radioemission  
;   
; Parameters optional (in):
;   (in)      dll_location                    (string)                    Full path to calling DLL; if omitted, DLL will be searched in the folder,
;                                                                         containing reo_init.pro function
;   (in)      harmonics                       (integer/long)              Calculated harmonic numbers (default [2, 3, 4]) 
;   (in)      tau_ctrl                        (float/double)              Controlled optical thickness values (default 208 points 
;                                                                         from 0.01 to 10 in logarithic scale)
;                                                                          
;   (in)      _extra          (various data types)                        Additional setting (such as tuning parameters, additional 
;                                                                         conditions etc.), partially:
;   (in)      freefree                        (integer/long)        ----- (see description in reo_prepare_calc_map.pro)
;   (in)      use_laplace                     (integer/long)        ----- (see description in reo_prepare_calc_map.pro).
;                                                                          Note: default value is 0. Highly recommended to leave it,
;                                                                          to provide most detailed height profile       
;   (in)      useqt                           (integer/long)        ----- (see description in reo_prepare_calc_map.pro)
;
; Parameters optional (out):
;   (out)     totInts     (2xNFreqs double array)         s.f.u./arcsec^2 Source intensity   
;   (out)     totTau      (2xNFreqs double array)                   -----     
;   depth = depth, profHeight = profHeight, profInts = profInts, profHarm = profHarm : NB! To be described!
; 
;    Note: there are some other optional parameters, which will be descibed in the next versions
; 
; Return code:
;       0     no errors, otherwise errors
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
                                              
;----------------------------------------------------------------------------------------------
function reo_calculate_los, H, B, Th, T, D, freqs $
                          , harmonics = harmonics, tau_ctrl = tau_ctrl $
                          , totInts = totInts, totTau = totTau $
                          , depth = depth, profHeight = profHeight, profInts = profInts, profHarm = profHarm, profAbsorb = profAbsorb $
                          , dll_location = dll_location $
                          , _extra = _extra

vptr = ulong64(reo_init(dll_location = dll_location, _extra = _extra))

vL = long(n_elements(H))
vH = double(H)
vB = double(B)
vcost = double(cos(Th*!DTOR))
vT = double(T)
vD = double(D)
vfreqs = double(freqs)

if n_elements(harmonics) gt 0 then vharms = long(harmonics) else vharms = [2L, 3L, 4L] 
if n_elements(tau_ctrl) gt 0 then vtaus = double(tau_ctrl) else vtaus = double(10^asu_linspace(-2, 1, 208)) 

nfreqs = long(n_elements(vfreqs))
nharms = long(n_elements(vharms))
ntaus = long(n_elements(vtaus))

use_laplace = 0;
n = n_tags(_extra)
if n gt 0 then begin
    keys = strlowcase(tag_names(_extra))
    for i = 0, n-1 do begin
        case keys[i] of
            'use_laplace': use_laplace = long(_extra.(i))
            else:
        endcase
    endfor    
endif

parameterMap = replicate({itemName:'',itemvalue:0d},2)
parameterMap[0].itemName = asu_subst_map_name('use_laplace')
parameterMap[0].itemValue = use_laplace
parameterMap[1].itemName = '!____idl_map_terminator_key___!'

vtotInts = dblarr(2, nfreqs)
vtottau = dblarr(2, nfreqs)

vdepth = lonarr(2, nfreqs)
vprofh = dblarr(2, ntaus, nfreqs)
vproff = dblarr(2, ntaus, nfreqs)
vprofs = lonarr(2, ntaus, nfreqs)
vprofa = dblarr(2, ntaus, nfreqs)
vrc = dblarr(1)

value = bytarr(21)
value[2] = 1 ; L
value[8] = 1 ; nfreqs
value[10] = 1 ; nharms
value[12] = 1 ; ntaus

returnCode = CALL_EXTERNAL(  dll_location, 'reoCalculateLOS', vptr, parameterMap $  ; 0-1
                           , vL, vH, vB, vcost, vT, vD $                            ; 2-7
                           , nfreqs, vfreqs, nharms, vharms, ntaus, vtaus $         ; 8-13
                           , vdepth, vtotInts, vtottau $                            ; 14-16
                           , vprofh, vproff, vprofs, vprofa $                       ; 17-20
                           , vrc $                                                  ; 21        
                           , VALUE = value, /CDECL)

if returnCode eq 0 then begin
    if arg_present(totInts)     then totInts    = vtotInts 
    if arg_present(totTau)      then totTau     = vtottau 
    if arg_present(depth)       then depth      = vdepth
    if arg_present(profHeight)  then profHeight = vprofh
    if arg_present(profInts)    then profInts   = vproff
    if arg_present(profHarm)    then profHarm   = vprofs
    if arg_present(profAbsorb)  then profAbsorb = vprofa
    ; rc ?
endif

return, returnCode

end
