pro asuml_box2xyz, filename

restore, filename

bx = box.bx
by = box.by
bz = box.bz

parser = stregex(filename, '(.+).sav',/subexpr,/extract,/fold_case)
fileout = parser[1] + '.prep.sav'

save, filename = fileout, bx, by, bz

end
