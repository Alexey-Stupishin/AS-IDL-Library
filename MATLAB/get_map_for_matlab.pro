function get_map_for_matlab, map_file

restore, map_file
m_out = !NULL
for k = 0, map.count-1 do begin
    mk = map.getmap(k)
    if m_out eq !NULL then m_out = replicate(mk, map.count)
    m_out[k] = mk; 
endfor

return, m_out 

end
