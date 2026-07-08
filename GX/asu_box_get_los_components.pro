function asu_box_get_los_components, box, base_coords, heights, vcos = vcos, outs = outs

if n_elements(vcos) eq 0 then vcos = [0d, 0d, 1d]

coords = asu_box_get_los_box_divisions(base_coords, heights, vcos = vcos)

n_los = n_elements(heights)
outs = intarr(n_los)
sz = size(box.bx)
for k = 0, n_los-1 do begin
    if coords[0,k] lt 0 || coords[0,k] gt sz[1]-1 || coords[1,k] lt 0 || coords[1,k] gt sz[2]-1 || coords[2,k] lt 0 || coords[2,k] gt sz[3]-1 then outs[k] = 1  
endfor

idxs = where(outs ne 1, count)
if count eq 0 then return, !NULL
coords = coords[*, idxs]

bx = interpolate(box.bx, coords[0, *], coords[1, *], coords[2, *])
by = interpolate(box.by, coords[0, *], coords[1, *], coords[2, *])
bz = interpolate(box.bz, coords[0, *], coords[1, *], coords[2, *])

return, {bx:bx, by:by, bz:bz, coords:coords}

end
