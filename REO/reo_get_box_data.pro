function reo_get_box_data, ptr, box, visstep0, posangle = posangle 

dll_location = getenv('reo_dll_location')

asu_box_get_coord, box, boxdata

returnCode = reo_set_double(ptr, 'cycloMap.Conditions.RSun', boxdata.rsun)

M = size(box.bx)
M = M[1:3]

modstep0 = boxdata.dx

baseP = dblarr(2)
baseP[0] = - double((M[0]-1)/2.)*modstep0
baseP[1] = - double((M[1]-1)/2.)*modstep0

modstep = [modstep0, modstep0, modstep0]
visstep = [visstep0, visstep0]
visstep = visstep/boxdata.rsun

if not keyword_set(posangle) then begin
    posangle = 0
endif

Mout = lonarr(2)
base = dblarr(2)
rc = reo_set_field(ptr, box.bx, box.by, box.bz, M, boxdata.vcos, modstep, baseP, visstep, posangle, Mout, base)

return, rc

end
