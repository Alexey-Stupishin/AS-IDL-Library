function reo_get_field_los_transp_cut, v, nmax

vv = transpose(v, [1, 0, 2])
vvv = vv[*, *, 0:nmax-1]

return, vvv

end

function reo_get_field_los, ptr, depthFLOS, HFLOS, BFLOS, cosFLOS, viewmask = viewmask

dll_location = getenv('reo_dll_location')

vptr = ulong64(ptr)

value = bytarr(6)
value[0] = 1
vMask = 0L
value[1] = 1

if keyword_set(viewmask) then begin
    vMask = double(viewmask)
    vMask = 0L
    value[1] = 0
endif    

vM = lonarr(2)
returnCode = CALL_EXTERNAL(dll_location, 'reoGetVisParams', vptr, vM)
vLOS = CALL_EXTERNAL(dll_location, 'reoGetLOSFieldEst', vptr)
 
vdepthLOS = lonarr(vM[0], vM[1])
vHLOS = dblarr(vM[0], vM[1], vLOS)
vBLOS = dblarr(vM[0], vM[1], vLOS)
vcosLOS = dblarr(vM[0], vM[1], vLOS)

nmax = CALL_EXTERNAL(dll_location, 'reoGetLOSField', vptr, vMask, vdepthLOS, vHLOS, vBLOS, vcosLOS, value = value)

depthFLOS = transpose(vdepthLOS, [1, 0])
HFLOS = reo_get_field_los_transp_cut(vHLOS, nmax)
BFLOS = reo_get_field_los_transp_cut(vBLOS, nmax)
cosFLOS = reo_get_field_los_transp_cut(vcosLOS, nmax)

end
