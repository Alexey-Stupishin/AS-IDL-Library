function sst_to_box_ext, lng, depth
    m = 2^(depth-1)
    n = ceil(double(lng)/m)
    return, n*m + 1
end
