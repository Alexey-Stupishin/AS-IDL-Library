pro sst_to_photosphere_test

date_obs = '2018-09-30T09:22:00'
fpath = 'g:\BIGData\Work\ISSI\12723\Preparation\SST\cube\'
; infile = fpath + 'SST+HMI.sav'
infile = fpath + 'SST+HMI0.sav'

base = sst_to_photosphere(date_obs, infile, 1, 6, i0 = i0, wcs0 = wcs0, wcsR = wcsR)

; save, filename = fpath + 'test_wcs_transf.sav', base, i0, wcs0, wcsR
save, filename = fpath + 'test_wcs_transf0.sav', base, i0, wcs0, wcsR

end
