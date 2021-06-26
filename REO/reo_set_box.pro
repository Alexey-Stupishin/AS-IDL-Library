function reo_set_box, ptr, box, visstep0, Mout, base, boxdata, posangle = posangle, setFOV = setFOV, model = model

dll_location = getenv('reo_dll_location')

if keyword_set(model) then begin
    boxdata = {dx:box.modstep, rsun:975d, vcos:[0d, 0d, 1d]}
endif else begin  
    asu_box_get_coord, box, boxdata
endelse

returnCode = reo_set_double(ptr, 'cycloMap.Conditions.RSun', boxdata.rsun)

M = size(box.bx)
M = M[1:3]

modstep0 = boxdata.dx

modstep = [modstep0, modstep0, modstep0]
visstep = [visstep0, visstep0]
visstep = visstep/boxdata.rsun

if not keyword_set(setFOV) then begin
    Mout = lonarr(2)
    base = dblarr(2)
endif
    
rc = reo_set_field(ptr, box.bx, box.by, box.bz, boxdata.vcos, modstep, visstep, Mout, base, posangle = posangle, setFOV = setFOV)

return, rc

end
