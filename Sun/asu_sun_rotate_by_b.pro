pro asu_sun_rotate_by_B, latitude, longitude, solar_b, lat_rot, lon_rot

lat_rot = asin(sin(latitude*!dtor)*cos(solar_b*!dtor) + cos(latitude*!dtor)*cos(longitude*!dtor)*sin(-solar_b*!dtor)) / !dtor
lon_rot = asin(cos(latitude*!dtor)*sin(longitude*!dtor)/cos(lat_rot*!dtor)) / !dtor

end
