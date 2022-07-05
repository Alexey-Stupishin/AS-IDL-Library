function reo_set_field, ptr, fieldX, fieldY, fieldZ, vcos, step, visstep $
                        ; output:
                      , Mout, base $
                        ; optional:
                      , posangle = posangle, setFOV = setFOV  

dll_location = getenv('reo_dll_location')

if ~keyword_set(posangle) then posangle = 0

vptr = ulong64(ptr)
vfieldX = double(transpose(fieldY, [1, 0, 2]))
vfieldY = double(transpose(fieldX, [1, 0, 2]))
vfieldZ = double(transpose(fieldZ, [1, 0, 2]))
sz = size(vfieldX)
vM = long(sz[1:3])
vvcos = double(vcos)
vvcos[0:1] = reverse(vvcos[0:1])
vstep = double(step)
vstep[0:1] = reverse(vstep[0:1])
vbaseP = dblarr(2)
vbaseP[0] = - double((vM[0]-1)/2.)*vstep[0]
vbaseP[1] = - double((vM[1]-1)/2.)*vstep[1]
;vbaseP = double(reverse(baseP))
vvisstep = double(reverse(visstep))
vposangle = double(posangle)
value = bytarr(14)
value[13] = 1

if ~keyword_set(setFOV) then setFOV = 0L else setFOV = 1L

returnCode = CALL_EXTERNAL(dll_location, 'reoSetField', vptr, vfieldX, vfieldY, vfieldZ, $
                           vM, vM, vvcos, vstep, vbaseP, vvisstep, vposangle, Mout, base, setFOV, VALUE = value)

Mout = reverse(Mout)
base = reverse(base)

return, returnCode

end
