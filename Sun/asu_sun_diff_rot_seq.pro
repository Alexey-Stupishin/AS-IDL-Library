function asu_sun_diff_rot_seq, x, y, t0, tseq, x_new, y_new, latitude = latitude, longitude = longitude, _extra = _extra
compile_opt idl2

from = anytim(t0)
to = anytim(tseq)
dt = to-from

jd0 = asu_anytim2julday(from)
asu_solar_par, jd0, solar_b = solar_b, solar_r = solar_r

if x^2+y^2 ge solar_r^2 then return, -1

rc = asu_sun_diff_rotation(x, y, dt, solar_b, solar_r, x_new, y_new, latitude = latitude, longitude = longitude, _extra = _extra) 

return, 0

end
 