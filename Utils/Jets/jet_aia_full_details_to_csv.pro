pro jet_aia_full_details_to_csv

wave = '171'
root_dir = 'g:\BIGData\UData\Jets\Take_2021_June'

events = file_search(filepath('*', root_dir = root_dir))

fout = root_dir + path_sep() + 'combine.csv'
openw, fnum, fout, /GET_LUN

;printf, fnum, 'T start', 'T max', 'T end', '#', 'Duration', 'Max. cardinality', 'Jet aspect ratio', 'Max. aspect ratio', 'LtoW aspect ratio', 'Speed est.', 'Max speed est.', 'Total length', 'Av. width', 'X from', 'X to', 'Y from', 'Y to', $
;     FORMAT = '(%"%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s")'

for k = 0, n_elements(events)-1 do begin
    if file_test(events[k], /DIRECTORY) then begin
        filename = events[k] + path_sep() + 'objects_m2' + path_sep() + asu_compstr(wave) + '.sav'
        expr = stregex(events[k], '.*\\(.*)',/subexpr,/extract)
        if n_elements(expr) ne 2 then continue
        
        if file_test(filename) then jet_aia_full_details_to_csv_event, filename, fnum, expr[1]
    endif    
endfor    

close, fnum
FREE_LUN, fnum

end
