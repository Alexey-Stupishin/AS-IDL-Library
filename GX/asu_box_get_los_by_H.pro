function asu_box_get_los_by_H, box, base_coords, heights, vcos = vcos

if n_elements(vcos) eq 0 then vcos = [0d, 0d, 1d]

field = asu_box_get_los_components(box, base_coords, heights, vcos = vcos, outs = outs)
if field eq !NULL then return, !NULL

n_los = n_elements(field.bx)
distance = dblarr(n_los)
h = dblarr(n_los)
absB = sqrt(field.bx^2 + field.by^2 + field.bz^2)
cost = (field.bx*vcos[0] + field.by*vcos[1] + field.bz*vcos[2])/absB
incl = acos(cost)/!DTOR
for k = 0, n_los-1 do begin
    d = field.coords[*,k] - base_coords
    distance[k] = sqrt(d[0]^2 + d[1]^2 + d[2]^2)
    h[k] = field.coords[2,k] 
endfor

return, {height:h, distance:distance, absB:absB, incl:incl}

end
