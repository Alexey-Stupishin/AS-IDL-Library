function asu_julday2str, jd

caldat, jd, month, day, year, hour, minute, second
return, string(Year, FORMAT = '(I04)') + '-' + string(Month, FORMAT = '(I02)') + '-' + string(Day, FORMAT = '(I02)') + ' ' $
      + string(Hour, FORMAT = '(I02)') + ':' + string(Minute, FORMAT = '(I02)') + ':' + string(Second, FORMAT = '(I02)')
      
end 
