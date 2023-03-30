function asu_sun_diff_rotation, x, y, dt, solar_b, solar_r, x_new, y_new, latitude = latitude, longitude = longitude, _extra = _extra 
; dt in seconds

if x^2+y^2 ge solar_r then return, -1

asu_get_hpc_latlon, x/solar_r, y/solar_r, lat, lon
asu_sun_rotate_by_B, lat, lon, solar_b, lat_b, lon_b
ddeg = asu_sun_diff_rotation_speed(lat_b, _extra = _extra); degrees/day
lon_bt = lon_b + ddeg*dt/(24d*3600d)
asu_sun_rotate_by_B, lat_b, lon_bt, -solar_b, latitude, longitude
asu_get_latlon_hpc, latitude, longitude, xr, yr
x_new = xr*solar_r
y_new = yr*solar_r

return, 0

end
