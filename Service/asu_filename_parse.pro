pro asu_filename_parse, filename, path = path, name = name, ext = ext 

lastsep = strpos(filename, '\', /REVERSE_SEARCH)
path = strmid(filename, 0, lastsep+1)
thisfile = strmid(filename, lastsep+1)
lastsep = strpos(thisfile, '.', /REVERSE_SEARCH)
name = strmid(thisfile, 0, lastsep)
ext = strmid(thisfile, lastsep+1)

; parse = stregex(thisfile,'(.*).sav',/subexpr,/extract)

end
