function l_gx_box_download_aia_data_as_wlist, key, default
  if isa(key, /scalar) && key eq 1 then begin
    wlist = default
  endif else begin
    wlist = []
    foreach w, key do begin
        if isa(w, /NUMBER) then s = asu_compstr(w) else s = w
        wlist = [wlist, s]
    endforeach
  endelse
  
  return, wlist    
end

function gx_box_download_aia_data_as, t, out_dir, cache_dir = cache_dir, UV = UV, EUV = EUV, time_window = time_window
  
  if not keyword_set(UV) and not keyword_set(EUV) then EUV = 1
  t_ = anytim(t)
  
    if not keyword_set(time_window) then time_window = 12d
    if keyword_set(UV) then time_window = time_window > 24d

    t1 = t_ - time_window/2d
    t2 = t_ + time_window/2d
    
    waves = []
    ds = []
    segment = []
    files ={}
    if keyword_set(euv) then begin
      wlist = l_gx_box_download_aia_data_as_wlist(euv, ['171','193','211','94','131','304','335'])  
      waves = [waves, wlist]
      ds = [ds,replicate('aia.lev1_euv_12s',n_elements(wlist))]
      segment = [segment,replicate('image',n_elements(wlist))]
    endif
    
    if keyword_set(uv) then begin
      wlist = l_gx_box_download_aia_data_as_wlist(uv, ['1600','1700'])  
      waves = [waves, wlist]
      ds = [ds,replicate('aia.lev1_uv_24s',n_elements(wlist))]
      segment = [segment,replicate('image',n_elements(wlist))]
    endif
    
    for i = 0, n_elements(ds)-1 do begin
      file = gx_box_jsoc_get_fits(t1, t2, ds[i], segment[i], cache_dir, wave = waves[i])
      if file ne '' then files = create_struct('aia_'+waves[i],file,files)
    endfor
  return, files
end