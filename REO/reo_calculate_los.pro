function reo_calculate_los, H, B, Th, T, D, freqs $
                          , harmonics = harmonics, taus = taus $
                          , totFlux = totFlux, totTau = totTau $
                          , depth = depth, profHeight = profHeight, profFlux = profFlux, profHarm = profHarm $
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
if n_elements(taus) gt 0 then vtaus = double(taus) else vtaus = [0.1d, 1d, 10d] 

nfreqs = long(n_elements(vfreqs))
nharms = long(n_elements(vharms))
ntaus = long(n_elements(vtaus))

parameterMap = {itemName:'!____idl_map_terminator_key___!',itemvalue:0d}

vtotflux = dblarr(2, nfreqs)
vtottau = dblarr(2, nfreqs)

vdepth = lonarr(2, nfreqs)
vprofh = dblarr(2, ntaus, nfreqs)
vproff = dblarr(2, ntaus, nfreqs)
vprofs = dblarr(2, ntaus, nfreqs)
vrc = dblarr(1)

value = bytarr(20)
value[2] = 1 ; L
value[8] = 1 ; nfreqs
value[10] = 1 ; nharms
value[12] = 1 ; ntaus

returnCode = CALL_EXTERNAL(  dll_location, 'reoCalculateLOS', vptr, parameterMap $  ; 0-1
                           , vL, vH, vB, vcost, vT, vD $                            ; 2-7
                           , nfreqs, vfreqs, nharms, vharms, ntaus, vtaus $         ; 8-13
                           , vdepth, vtotflux, vtottau $                            ; 14-16
                           , vprofh, vproff, vprofs $                               ; 17-19
                           , vrc $                                                  ; 20        
                           , VALUE = value, /CDECL)

if returnCode eq 0 then begin
    if arg_present(totFlux)     then totFlux    = vtotflux 
    if arg_present(totTau)      then totTau     = vtottau 
    if arg_present(depth)       then depth      = vdepth
    if arg_present(profHeight)  then profHeight = vprofh
    if arg_present(profFlux)    then profFlux   = vproff
    if arg_present(profHarm)    then profHarm   = vprofs
    ; rc ?
endif

return, returnCode

end
