function asu_box_get_los_box_divisions, base_coords, heights, vcos = vcos

if n_elements(vcos) eq 0 then vcos = [0d, 0d, 1d]

d_ph = base_coords[2]/vcos[2] ; distance from photosphere along los

coords_ph = base_coords - d_ph * vcos ; seed on photosphere

d = heights/vcos[2]; 

n_los = n_elements(heights)
coords = dblarr(3, n_los)
out = intarr(n_los)
for k = 0, n_los-1 do begin
    coords[*, k] = coords_ph + d[k] * vcos
endfor

return, coords

end
