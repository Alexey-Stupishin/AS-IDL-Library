pro asuml_box2sst_files, filename

restore, filename

mfodata = asuml_box2sst(box)

parser = stregex(filename, '(.+).sav',/subexpr,/extract,/fold_case)
fileout = parser[1] + '_sst.sav'

save, filename = fileout, mfodata

end
