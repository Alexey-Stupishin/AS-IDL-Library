function rtu_circle_map, sz, R

ch = (sz[0]-1)/2d;
cv = (sz[1]-1)/2d;

map = dblarr(sz[0], sz[1])

for kx = 0, sz[0]-1 do begin
    for ky = 0, sz[1]-1 do begin
        if (kx-ch)^2 + (ky-cv)^2 le R^2 then map[kx, ky] = 1d
    endfor
endfor

return, map

end
