pro asu_merge_cache, cache_trunk, cache_merge

restore, cache_merge + path_sep() + 'index.sav'
fm = files
qm = queries

ftrunk = cache_trunk + path_sep() + 'index.sav'
restore, ftrunk

foreach q, qm, i do begin
    idx = where(q eq queries, count)
    if count gt 0 then continue
    
    base = file_basename(fm[i])
    fdir = file_dirname(fm[i])
    fdate = file_basename(fdir)
    
    newdir = cache_trunk + path_sep() + fdate
    file_mkdir, newdir
    oldfile = cache_merge + path_sep() + fdate + path_sep() + base
    newfile = newdir + path_sep() + base
    file_copy, oldfile, newfile
    
    queries = [queries, q]
    files = [files, newfile]
endforeach     

save, filename = cache_merge + path_sep() + 'index4check.sav', files, queries 

end
