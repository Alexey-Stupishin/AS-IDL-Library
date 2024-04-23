pro asuml_sst2sst_separate, mfodata, data, bx, by, bz

names = tag_names(mfodata)
n = n_elements(names)

data = !NULL
for i = 0, n-1 do begin
    if names[i] ne 'BX' && names[i] ne 'BY' && names[i] ne 'BZ' then begin
        data = create_struct(data, create_struct(names[i], mfodata.(i)))
    endif
endfor

bx = float(mfodata.bx)
by = float(mfodata.by)
bz = float(mfodata.bz)

end
 