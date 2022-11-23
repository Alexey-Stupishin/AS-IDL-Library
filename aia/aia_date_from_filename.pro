function aia_date_from_filename, filename, q_anytim = q_anytim
pattern ='([0-9][0-9][0-9][0-9])-([0-9][0-9])-([0-9][0-9])T([0-9][0-9])([0-9][0-9])([0-9][0-9]).*'
date = stregex(file_basename(filename), pattern,/subexpr,/extract)
if date[0] eq '' then begin
    pattern ='.*AIA([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9])_([0-9][0-9])([0-9][0-9])([0-9][0-9]).*'
    date = stregex(file_basename(filename), pattern,/subexpr,/extract)
endif

if ~keyword_set(q_anytim) then begin
    return, date[1]+date[2]+date[3]
endif else begin
    return, anytim(date[1]+'-'+date[2]+'-'+date[3]+' '+date[4]+':'+date[5]+':'+date[6])
endelse        


end
