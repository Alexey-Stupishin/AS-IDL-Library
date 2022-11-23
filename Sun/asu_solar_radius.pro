function asu_solar_radius, year, month, day

jd = julday(fix(month), fix(day), fix(year), 12, 0, 0)

return, 959.67983 + 16.02141*sin((jd-2455474.04713)*0.0172027)

end
