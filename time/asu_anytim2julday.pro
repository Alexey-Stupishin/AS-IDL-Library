function asu_anytim2julday, t

tsu = anytim(t, out_style = 'UTC_EXT')
return, julday(tsu.month, tsu.day, tsu.year, tsu.hour, tsu.minute, tsu.second+tsu.millisecond*1d-3)

end
