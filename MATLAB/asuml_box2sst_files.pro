pro asuml_box2sst_files, filename, pbox = pbox, bfloat = bfloat

restore, filename

if n_elements(pbox) ne 0 then box = pbox

mfodata = asuml_box2sst(box, bfloat = bfloat)

parser = stregex(filename, '(.+).sav',/subexpr,/extract,/fold_case)
fileout = parser[1] + '_sst.sav'

save, filename = fileout, mfodata

end
