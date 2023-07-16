function asu_model_dipole, nx, ny, nz, arcstep, B0ph, depth
;
; Fill NX x NY x NZ array with dipole field
; 
; Input:
;   NX, NY, XZ - sizes
;   arcstep - grid step in arcsec
;   B0ph - max. photospheric field (G)
;   depth - under photosphere (cm)
;
; Return: 
;   structure with field components BX, BY, BZ
;    

Rr = 6.96d10
Ra = 960d

modstep = double(arcstep)/Ra
D = double(depth)/Rr/modstep
posy = (ny - 1)*0.5d
posx = (nx - 1)*0.5d
mu = 0.5d*B0ph*D^3

BOX = {bx:dblarr(nx, ny, nz), by:dblarr(nx, ny, nz), bz:dblarr(nx, ny, nz), modstep:modstep, arcstep:modstep*Ra}
for kz = 0, nz-1 do begin
    for ky = 0, ny-1 do begin
        for kx = 0, nx-1 do begin
            B = asu_model_dipole_point(kx-posx, ky-posy, D+kz, mu)
            BOX.BX(kx, ky, kz) = B.x
            BOX.BY(kx, ky, kz) = B.y
            BOX.BZ(kx, ky, kz) = B.z
        endfor
    endfor
endfor

return, BOX

end
