function reo_get_los_profile, depth, v, x, y

dB = depth[x, y]
if dB eq 0 then return, !NULL
if dB eq 1 then return, v[x, y, 0]

prof = transpose(v[x, y, 0:dB-1], [2, 1, 0])

return, prof

end
