pro asu_get_hpc_latlon, x, y, latitude, longitude
; x along longitude (x also)
; y along latitude  (y also)

latitude = asin(y) / !dtor
longitude = asin(x/sqrt(1-y^2)) / !dtor

end
