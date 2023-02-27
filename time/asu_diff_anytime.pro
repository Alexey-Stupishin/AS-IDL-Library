function asu_diff_anytime, from, to, sec = sec

jdfrom = asu_anytim2julday(from)
jdto = asu_anytim2julday(to)
dt = jdto - jdfrom

if n_elements(sec) ne 0 && sec ne 0 then dt *= (24d*60d*60d)

return, dt

end
