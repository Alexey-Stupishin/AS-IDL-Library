function asu_julday_tick, dummy1, dummy2, jd, dummy4

caldat, jd, month, day, year, hour, minute, second
;return, string(hour, FORMAT = '(I02)') + ':' + string(hinute, FORMAT = '(I02)') + ':' + string(second, FORMAT = '(I02)')
return, string(hour, FORMAT = '(I02)') + ':' + string(minute, FORMAT = '(I02)')
      
end 
