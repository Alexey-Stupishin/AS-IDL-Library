function asu_box_get_los, box, base_coords, factor = factor, vcos = vcos

H = !NULL
absB = !NULL
incl = !NULL

s = tag_names(box)
ind = where(s eq 'DR')
if ind ge 0 then begin
    s = box.dr[2]
endif else begin
    ind = where(s eq 'MODSTEP')
    if ind ge 0 then begin
        s = box.modstep
    end    
endelse

if n_elements(vcos) eq 0 then vcos = [0d, 0d, 1d]
dh = s*6.96d10/vcos[2]

; vcos not implemented!

sz = size(box.bx)
if n_elements(factor) eq 0 then factor = 1d
;bx = transpose(box.bx[base_coords[0], base_coords[1], *], [2, 0, 1]) * factor
;by = transpose(box.by[base_coords[0], base_coords[1], *], [2, 0, 1]) * factor
;bz = transpose(box.bz[base_coords[0], base_coords[1], *], [2, 0, 1]) * factor
bx = dblarr(sz(3))
by = dblarr(sz(3))
bz = dblarr(sz(3))

for k = 0, sz(3)-1 do begin
    bx(k) = interpolate(box.bx[*,*,k], base_coords[0], base_coords[1]) * factor
    by(k) = interpolate(box.by[*,*,k], base_coords[0], base_coords[1]) * factor
    bz(k) = interpolate(box.bz[*,*,k], base_coords[0], base_coords[1]) * factor
endfor

trans = sqrt(bx^2 + by^2)
absB = sqrt(trans^2 + bz^2)
incl = acos(bz/absB)/!DTOR
H = findgen(n_elements(absB))*dh

return, {height:H, field:absB, inclination:incl}

end
 