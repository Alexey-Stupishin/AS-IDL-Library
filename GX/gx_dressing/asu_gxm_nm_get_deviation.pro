function asu_gxm_nm_get_deviation, x

m = mean(x, dimension = 1)
d = stddev(x, dimension = 1)
return, abs(d/m)

end
