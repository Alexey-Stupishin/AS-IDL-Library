function asu_anytim2julday, t
; see also SSW/ /anytim2jd

tsu = anytim(t, out_style = 'UTC_EXT')
return, double(julday(tsu.month, tsu.day, tsu.year, tsu.hour, tsu.minute, tsu.second+tsu.millisecond*1d-3))

end
