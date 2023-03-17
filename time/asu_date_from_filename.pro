function asu_date_from_filename, filename, q_anytim = q_anytim

patterns = [  '([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9])T([0-9][0-9])([0-9][0-9])([0-9][0-9]).*' $
           ,  '([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9])_([0-9][0-9])([0-9][0-9])([0-9][0-9]).*' $
           ,  '([0-9][0-9][0-9][0-9])([0-9][0-9])T([0-9][0-9])([0-9][0-9])([0-9][0-9])([0-9][0-9]).*' $
           ,'.*([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9])T([0-9][0-9])([0-9][0-9])([0-9][0-9]).*' $
           ,'.*([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9])_([0-9][0-9])([0-9][0-9])([0-9][0-9]).*' $
           ,'.*([0-9][0-9][0-9][0-9])([0-9][0-9])T([0-9][0-9]) ([0-9][0-9])([0-9][0-9])([0-9][0-9]).*' $
           ]

for k = 0, n_elements(patterns)-1 do begin
    date = stregex(file_basename(filename), patterns[k] ,/subexpr,/extract)
    if date[0] ne '' then break
endfor

if date[0] eq '' then return, ''

if ~keyword_set(q_anytim) then begin
    return, date[1]+date[2]+date[3]
endif else begin
    return, anytim(date[1]+'-'+date[2]+'-'+date[3]+' '+date[4]+':'+date[5]+':'+date[6])
endelse        

end
