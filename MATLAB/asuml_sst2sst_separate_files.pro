pro asuml_sst2sst_separate_files, filename

asu_filename_parse, filename, path = path, name = name, ext = ext
pref = path + name

restore, filename

asuml_sst2sst_separate, mfodata, data, bx, by, bz

save, filename = pref + '_index.sav', data
save, filename = pref + '_bx.sav', bx
save, filename = pref + '_by.sav', by
save, filename = pref + '_bz.sav', bz

end
