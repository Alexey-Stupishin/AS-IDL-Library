pro asu_get_direction_cosine, latitude, longitude, dircos
compile_opt idl2

dircos = dblarr(3)
dircos[0] = -sin(longitude*!dtor)
dircos[1] = -cos(longitude*!dtor)*sin(latitude*!dtor)
dircos[2] =  cos(longitude*!dtor)*cos(latitude*!dtor)

end
