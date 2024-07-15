function asu_get_valid_LOS_voxels, box, bottom, rotator
compile_opt idl2

sz = size(box.bx)
valid = dblarr(3, sz[3])

bottom[2] = 0d
curr = bottom
cnt = 0
for k = 0, sz[3]-1 do begin
    if curr[0] ge 0 && curr[0] le sz[1]-1 && curr[1] ge 0 && curr[1] le sz[2]-1 then begin
        valid[*, cnt] = [curr[0], curr[1], k]
        cnt++
    endif
    curr[0:1] += rotator.dircos[0:1]
endfor

if cnt eq 0 then valid = !NULL else valid = valid[*, 0:cnt-1]

return, valid

end
