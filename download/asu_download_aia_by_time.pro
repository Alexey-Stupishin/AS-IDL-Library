pro asu_download_aia_by_time, compr_dir, aia_dir, qtime, waves

foreach cwave, waves, iw do begin
    if fix(cwave) gt 1000 then gap = 24 else gap = 12
    ds = ssw_jsoc_wave2ds(cwave)
    filename = asu_jsoc_get_fits(qtime, gap, ds, 'image', compr_dir, aia_dir, wave = cwave) ; , err = err
endforeach
  
end
 