function asu_parse_list, clist, gt0 = gt0, delim = delim

vlist = list()

if n_elements(delim) eq 0 then delim = ','

pos = 0
while pos lt strlen(clist) do begin
    p = strpos(clist, delim, pos)
    if p lt 0 then p = strlen(clist)
    reads, strmid(clist, pos, p-pos), v
    pos = p+1
    if n_elements(gt0) ne 0 && v le 0 then continue
    vlist.Add, v
end

return, vlist.ToArray()

end
