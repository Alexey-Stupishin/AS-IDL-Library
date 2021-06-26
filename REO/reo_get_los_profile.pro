function reo_get_los_profile, depth, v, x, y

dB = depth[x, y]
prof = transpose(v[x, y, 0:dB-1], [2, 1, 0])

return, prof

end
