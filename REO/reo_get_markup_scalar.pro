function reo_get_markup_scalar, ptr, scalar_in, scalar_out, mask

dll_location = getenv('reo_dll_location')

if not keyword_set(posangle) then begin
    posangle = 0
endif

vptr = ulong64(ptr)
vIn = double(transpose(scalar_in, [1, 0]))

vM = lonarr(2)
returnCode = CALL_EXTERNAL(dll_location, 'reoGetVisParams', vptr, vM)
vOut = dblarr(vM[0], vM[1])
vMask = lonarr(vM[0], vM[1])

returnCode = CALL_EXTERNAL(dll_location, 'reoGetMarkupScalar', vptr, vIn, vOut, vMask)

scalar_out = transpose(vOut, [1, 0])
mask = transpose(vMask, [1, 0])

return, returnCode

end
