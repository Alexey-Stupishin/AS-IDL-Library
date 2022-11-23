function asu_now_to_filename

jd = systime(/JULIAN)
caldat, jd, month, day, year, hour, minute, second
return, string(year, FORMAT = '(I04)') + string(month, FORMAT = '(I02)') + string(day, FORMAT = '(I02)') $
      + string(hour, FORMAT = '(I02)') + string(minute, FORMAT = '(I02)') + string(second, FORMAT = '(I02)')

end
