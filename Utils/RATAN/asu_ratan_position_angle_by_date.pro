function asu_ratan_position_angle_by_date, azimuth, date_time

jd = anytim2jd(date_time)
asu_solar_par, jd, solar_p = solar_p, sol_dec = sol_dec

if (solar_p GT 180d) then solar_p = solar_p - 360d
if (solar_p LT -180d) then solar_p = solar_p + 360d

solrtn = solar_p + asin(-tan(azimuth*!dtor)* tan(sol_dec*!dtor)) /!dtor;

return, solrtn

end
