pro copy_aia, withaia, withnas, out

restore, withaia
aiadata = mfodata
aiatags = TAG_NAMES(aiadata)
restore, withnas
nasdata = mfodata
nastags = TAG_NAMES(nasdata)
mfodata = {}

for i = 0, n_elements(aiatags)-1 do begin
    tag = aiatags[i]
    if strlen(tag) ge 3 && strmid(tag, 0, 3) eq 'AIA' then begin
        add = create_struct(aiatags[i], aiadata.(i))
        mfodata = create_struct(mfodata, add)
    endif
endfor

for i = 0, n_elements(nastags)-1 do begin
    tag = nastags[i]
    if strlen(tag) lt 3 || strmid(tag, 0, 3) ne 'AIA' then begin
        add = create_struct(nastags[i], nasdata.(i))
        mfodata = create_struct(mfodata, add)
    endif
endfor

save, filename = out, mfodata

end

pro jet_aia_to_nas

dirwithaia = 'g:\BIGData\UData\SDOBoxes_HMI_3'
dirwithnas = 'g:\BIGData\UData\SDOBoxes_HMI_2'
dirout = 'g:\BIGData\UData\SDOBoxes_HMI_JETS'

pref1 = '_hmi.M_720s.'
pref2 = '.CEA.'
post = '_sst.sav'

aiamask = '(.*)_hmi\.M_720s\.(.*)\.CEA\.POT_([0-9]*)_sst\.sav'

ffiles_in_aia = file_search(filepath('*.sav', root_dir = dirwithaia))
files_in_aia = file_basename(ffiles_in_aia)
ffiles_in_nas = file_search(filepath('*.sav', root_dir = dirwithnas))
files_in_nas = file_basename(ffiles_in_nas)
foreach file_in, files_in_aia, i do begin
    print, file_in
    expr = stregex(file_in, aiamask,/subexpr,/extract)
    if n_elements(expr) ne 4 or strlen(expr[0]) eq 0 then continue

    idx = where(file_in eq files_in_nas, count)
    if count ne 0 then begin
        copy_aia, dirwithaia + path_sep() + file_in, dirwithnas + path_sep() + file_in, dirout + path_sep() + file_in
    endif
    
    nasfile = expr[1] + pref1 + expr[2] + pref2 + 'NAS' + '_' + expr[3] + post
    idx = where(nasfile eq files_in_nas, count)
    if count ne 0 then begin
        copy_aia, dirwithaia + path_sep() + file_in, dirwithnas + path_sep() + nasfile, dirout + path_sep() + nasfile
    endif
    
endforeach

end
