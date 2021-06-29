function asu_get_dipole_model, req_depth, req_Bph, filename = filename, maxB = maxB

if n_elements(filename) eq 0 then begin
    dirpath = file_dirname((ROUTINE_INFO('asu_get_dipole_model', /source, /functions)).path, /mark)
    ;filename = dirpath + 'dipole_1Mm_1G_1arc_largeFOV.sav'
    filename = dirpath + 'dipole_1Mm_1G_500km_largeFOV.sav'
endif 
restore, filename

step = 6.96d10/Ra*arcstep
n = round((req_depth-depth)/step)
real_depth = n*step + depth

BX = BX[*,*,n:-1]
BY = BY[*,*,n:-1]
BZ = BZ[*,*,n:-1]

B = sqrt(BX[*,*,0]^2 + BY[*,*,0]^2 + BZ[*,*,0]^2)
factor = req_Bph/max(B)

BX *= factor
BY *= factor
BZ *= factor

if n_elements(maxB) eq 0 then maxB = 70 ; f >= 1 GHz, s <= 5
Bw = sqrt(BX^2 + BY^2 + BZ^2)
sz = size(Bw)
uplim = sz[3]-1
for h = sz[3]-1, 0, -1 do begin
    if max(Bw[*,*,h] ge maxB) then break
    uplim = h
endfor    

BX = BX[*,*,0:uplim]
BY = BY[*,*,0:uplim]
BZ = BZ[*,*,0:uplim]

print, 'Real depth = ' + asu_compstr(real_depth*1e-8) + ' Mm'

return, {BX:BX, BY:BY, BZ:BZ, modstep:modstep, depth:real_depth, Bmax:req_Bph}

end
