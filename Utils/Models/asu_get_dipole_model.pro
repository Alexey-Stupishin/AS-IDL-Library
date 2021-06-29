function asu_get_dipole_model, req_depth, req_Bph, filename = filename

if n_elements(filename) eq 0 then begin
    dirpath = file_dirname((ROUTINE_INFO('asu_get_dipole_model', /source, /functions)).path, /mark)
    filename = dirpath + 'dipole_1Mm_1G_1arc_largeFOV.sav'
endif 
restore, filename

step = 6.96d10/Ra*arcstep
n = round(req_depth/step)
real_depth = n*step

BX = BX[*,*,n-1:-1]
BY = BY[*,*,n-1:-1]
BZ = BZ[*,*,n-1:-1]

B = sqrt(BX[*,*,0]^2 + BY[*,*,0]^2 + BZ[*,*,0]^2)
factor = req_Bph/max(B)

BX *= factor
BY *= factor
BZ *= factor

print, 'Real depth = ' + asu_compstr(real_depth*1e-8) + ' Mm'

return, {BX:BX, BY:BY, BZ:BZ, modstep:modstep, depth:real_depth, Bmax:req_Bph}

end
