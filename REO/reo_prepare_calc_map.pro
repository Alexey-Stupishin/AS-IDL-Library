; IDL Wrapper to:
;   Preparing to calculate radiomaps (in Alexey G. Stupishin implementation)
;   
; v 2.15.20.317 (rev.277)
; 
; NB! Beta-version! But nearly ready to enduser... (and only under Windows 64-bit, sorry...)
; 
; Call:
; rc = reo_prepare_calc_map( $
;          box, visstep, Mout, base $
;        , dll_location = dll_location, alt_dll_location = alt_dll_location $
;        , posangle = posangle, _extra = _extra $
;        , arcbox = arcbox, field = field, R_arc = R_arc $
;        , version_info = version_info $
;                          )
; 
; Parameters description:
; 
; Parameters required (in):
;   (in)      box               (structure)                   -----     GX-box (standard conventions for GX-simulator, 
;                                                                       see Nita et al., 2015, ApJ, 799:236)
;   (in)      visstep           (float/double)               arcsec     required step of calculating radiomap (view from observer)
;   
; Parameters optional (in):
;   (in)      dll_location      (string)                      -----     Full path to calling radioemission DLL; if omitted, DLL will be
;                                                                       searched in the folder, containing reo_calculate_map.pro procedure
;   (in)      alt_dll_location  (string)                      -----     Full path to alternative radioemission DLL by Alexey Kuznetsov;
;                                                                       if omitted, DLL will be searched in the folder, containing reo_calculate_map.pro procedure
;
;   (in)      posangle                        (float/double)        degree     position angle (to rotate radiomap, if it is convenient), default = 0
;     
;   (in)      _extra                          (various data types)             Additional setting (such as tuning parameters, additional conditions etc.)
;                                                                              (can be reassigned in reo_calculate_map.pro), partially:
;   (in)      freefree                        (integer/long)        -----     if omitted or non-zero, free-free emission will be considered, otherwise not
;   (in)      cycloCalc_Distribution_Type     (integer/long)        -----     if omitted or 1, Maxwellian distribution used, if 2 - kappa-distribution
;   (in)      cycloCalc_Distribution_kappaK   (float/double)        -----     if omitted, kappa parameter = 5.0, otherwise kappa parameter, should be
;                                                                              no less than max. harmonic number + 1
;   (in)      cycloCalc_LaplasMethod_Use      (integer/long)        -----     if omitted or non-zero, use Laplace method whenever it is possible, otherwise
;                                                                              perform explicit integration along LOS
;   (in)      useqt                           (integer/long)        -----     if omitted or non-zero, conditions of quasi-transversal propagation will be
;                                                                              taking into account, otherwise not (see Zheleznyakov, 1997, pp.147-(159)-167)
;   (in)      usealtlibrary                   (integer/long)        -----     if not omitted and non-zero, Alexey Kuznetsov's gyroresonance code library will
;                                                                              be used in radioemission calculations 
;                                                                              (grid rendering still provided with A.S.'s agsGeneralRadioEmission library)
;                                                                        
; Parameters (out):
;   (out)     Mout            (2-elements long array)      (pixels)     Size of calculating radiomap (view from observer)   
;   (out)     base            (2-elements double array)      arcsec     Coordinates of low-left corner of (rotated) radiomap (zero = center of the Sun)  
;                                                                                 
; Parameters optional (out):
;   (out)     arcbox          (2x2 double array)             arcsec     bounding box of calculated radiomaps (in arcsec related to the Sun center):
;                                                                       arcbox[0, *] = left/right margins           
;                                                                       arcbox[1, *] = bottom/top margins           
;   (out)     field           (structure)                     -----     structure with fields Bx, By, Bz, which are 2-D arrays for field components,
;                                                                       from observer view, remapped to visual map grid 
;   (out)     R_arc                                          arcsec     Solar radius for the moment of observation time
;   (out)     version_info    (string)                                  agsGeneralRadioEmission.dll library version information
;   
; Output value (ULONG64): pointer to the data structure, should be passed to all consequently calls of DLL wrappers, should be non-zero
;                         if zero, something goes wrong
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

function reo_prepare_calc_map, box, visstep, Mout, base $
                             , dll_location = dll_location, alt_dll_location = alt_dll_location $
                             , setFOV = setFOV $
                             , posangle = posangle, _extra = _extra $
                             , arcbox = arcbox, field = field, R_arc = R_arc $
                             , model = model $
                             , version_info = version_info

ptr = reo_init(dll_location = dll_location, alt_dll_location = alt_dll_location, version_info = version_info, _extra = _extra)

if ptr eq 0 then begin
    return, ulong64(0)
endif

rc = reo_set_box(ptr, box, visstep, Mout, base, boxdata, posangle = posangle, setFOV = setFOV, model = model)

if rc ne 0 then begin
    return, 0
endif

if arg_present(R_arc) then begin
    R_arc = boxdata.rsun
endif

if arg_present(arcbox) then begin
    arcbox = dblarr(2, 2)
    arcbox[*, 0] = base[0]*boxdata.rsun + [0, (Mout[0]-1)*visstep]  
    arcbox[*, 1] = base[1]*boxdata.rsun + [0, (Mout[1]-1)*visstep]  
endif

if arg_present(field) then begin
    bx = dblarr(Mout[1], Mout[0])
    by = dblarr(Mout[1], Mout[0])
    bz = dblarr(Mout[1], Mout[0])
    
    returnCode = CALL_EXTERNAL(getenv('reo_dll_location'), 'reoGetField', ptr, bx, by, bz)
    
    field = {bx:transpose(by, [1, 0]), by:transpose(bx, [1, 0]), bz:transpose(bz, [1, 0])}
endif

; version_info = '---' ; NB! placeholder!

return, ptr

end
