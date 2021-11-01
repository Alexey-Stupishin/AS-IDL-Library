pro asu_correct_cache, cache

ftrunk = cache + path_sep() + 'index.sav'
restore, ftrunk
newfiles = []

foreach q, queries, i do begin
    base = file_basename(files[i])
    fdir = file_dirname(files[i])
    fdate = file_basename(fdir)
    
    newdir = cache + path_sep() + fdate
    newfile = newdir + path_sep() + base
    
    newfiles = [newfiles, newfile]
endforeach     

files = newfiles
save, filename = ftrunk, files, queries 

end
