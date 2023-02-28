pro asu_solar_par, obsdate, solar_p = solar_p, solar_b = solar_b, solar_r = solar_r, sol_dec = sol_dec

jday = isa(obsdate, 'STRING') ? asu_anytim2julday(obsdate) : obsdate

caldat, jday, Month, Day, Year, Hours, Mins, Secs
cdate = string(Year, FORMAT = '(I04)') + '-' + string(Month, FORMAT = '(I02)') + '-' + string(Day, FORMAT = '(I02)') + ' ' $
      + string(Hours, FORMAT = '(I02)') + string(Mins, FORMAT = '(I02)') + string(Secs, FORMAT = '(I02)') 
result = pb0r(cdate, /arcsec)
solar_p = result[0]
solar_b = result[1]
solar_r = result[2]
sunpos, jday, ra, sol_dec, longmed, oblt

end
