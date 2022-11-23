function asu_julday_mod, jd, secs = secs, mins = mins, hours = hours, days = days 

if n_elements(secs) eq 0 then secs = 0
if n_elements(mins) eq 0 then mins = 0
if n_elements(hours) eq 0 then hours = 0
if n_elements(days) eq 0 then days = 0

return, jd + days + (hours + (mins + secs/60d)/60d)/24d

end
