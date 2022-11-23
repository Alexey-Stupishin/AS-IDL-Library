pro asu_get_latlon_hpc, latitude, longitude, x, y
; x along longitude
; y along latitude

; Spherical -> Cartesian
x = cos(latitude*!dtor)*sin(longitude*!dtor);
y = sin(latitude*!dtor);

end
