function asu_ratan_position_angle_by_date, azimuth, date_time

t0 = anytim(date_time)
jd0 = asu_anytim2julday(t0)
asu_solar_par, jd0, solar_p = solar_p, solar_b = solar_b, solar_r = solar_r, sol_dec = sol_dec

return, asu_ratan_position_angle(azimuth, sol_dec, solar_p)

end
