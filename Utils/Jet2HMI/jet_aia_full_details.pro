pro jet_aia_full_details_image, windim, data, x, y, cm_aia, jtitle, dimage
  win = window(dimensions = windim)
  dimage = image(comprange(data,2,/global), x, y, RGB_TABLE = cm_aia, /CURRENT, TITLE = jtitle, FONT_SIZE = 16)
  xax = axis('X', LOCATION=[x[0],y[0]], target = dimage)
  xax.tickdir = 1
  yax = axis('Y', LOCATION=[x[0],y[0]], target = dimage)
  yax.tickdir = 1
end

pro jet_aia_full_details_draw_rect, xf, yf, dimage, color, thick
    pp = plot([xf[0], xf[0]], [yf[0], yf[1]], overplot = dimage, color = color, thick = thick)
    pp = plot([xf[0], xf[1]], [yf[1], yf[1]], overplot = dimage, color = color, thick = thick)
    pp = plot([xf[1], xf[1]], [yf[1], yf[0]], overplot = dimage, color = color, thick = thick)
    pp = plot([xf[1], xf[0]], [yf[0], yf[0]], overplot = dimage, color = color, thick = thick)
end

pro jet_aia_full_details_draw_qh, szd, details, frames, coords, dimage, color, thick
    for k = 0, n_elements(details)-1 do begin
        detail = details[k]
        frame2work = frames[detail.frameptr]
        from = frames[detail.frameptr].CoordPtr
        to = frames[detail.frameptr+detail.nframes-1].CoordPtr + frames[detail.frameptr+detail.nframes-1].Card - 1
        cc = coords[*, from:to]
        cc[0,*] = 0 > cc[0,*] < szd[1]-1
        cc[1,*] = 0 > cc[1,*] < szd[2]-1
        qhull, cc, qh
        sz = size(qh)
        xarc = (cc[0,*]-frame2work.crpix1)*frame2work.cdelt1
        yarc = (cc[1,*]-frame2work.crpix2)*frame2work.cdelt2
        for i = 0, sz[2]-1 do begin
            pp = plot([xarc[qh[0,i]], xarc[qh[1,i]]], [yarc[qh[0,i]], yarc[qh[1,i]]], overplot = dimage, color = color, thick = thick)
        endfor
    endfor
end

pro jet_aia_full_details_draw_contour, data, x, y, dshift, details, frames, coords, dimage, color, thick
    szd = size(data)
    for k = 0, n_elements(details)-1 do begin
        detail = details[k]
        frame2work = frames[detail.frameptr]
        from = frames[detail.frameptr].CoordPtr
        to = frames[detail.frameptr+detail.nframes-1].CoordPtr + frames[detail.frameptr+detail.nframes-1].Card - 1
        cc = coords[*, from:to]
        cc[0,*] = 0 > cc[0,*] < szd[1]-1
        cc[1,*] = 0 > cc[1,*] < szd[2]-1
        jet = dblarr(szd[1], szd[2])
        for i = 0, to-from do begin
            jet[cc[0,i]+dshift[0], cc[1,i]+dshift[1]] = 1d
        endfor
        rcont = contour(gauss_smooth(double(jet),3,/edge_truncate),x,y, min_value = 0, max_value = 0.05, n_levels = 2, overplot = dimage, color = color, c_thick = thick)
    endfor
end

;pro jet_aia_full_details, occpath, wave
pro jet_aia_full_details

occpath = '/home/stupishin/coronal_jets/Jets/20111211_112500_20111211_133700_-543_-319_500_500'
wave = 171

fncsv = occpath + path_sep() + 'objects_m2' + path_sep() + asu_compstr(wave) + '.csv'
if ~file_test(fncsv) then return

jet2hmi_candidates_info, fncsv, info
n = n_elements(info)
if n eq 0 then return

filename = occpath + path_sep() + 'objects_m2' + path_sep() + asu_compstr(wave) + '.sav'
jet2hmi_candidates2arrays, filename, details, frames, coords, rotcrds

xx = dblarr(2, n)
yy = dblarr(2, n)
for k = 0, n-1 do begin
    xx[*, k] = info[k].x
    yy[*, k] = info[k].y
endfor
xf = dblarr(2)
xf[0] = min(xx[0, *])
xf[1] = max(xx[1, *])
yf = dblarr(2)
yf[0] = min(yy[0, *])
yf[1] = max(yy[1, *])

fulldir = occpath + path_sep() + 'aia_data' + path_sep() + asu_compstr(wave) + path_sep() + 'fullimage'
fulls = file_search(filepath('*.fits', root_dir = fulldir))

fits = fulls[1] ; 2nd, NB!
read_sdo, fits, index, data

sz = size(data)
x = (findgen(sz[1])-index.crpix1)*index.cdelt1
y = (findgen(sz[2])-index.crpix2)*index.cdelt2

sunglobe_aia_colors, wave, red, green, blue
cm_aia = bytarr(256, 3)
cm_aia[*, 0] = red 
cm_aia[*, 1] = green 
cm_aia[*, 2] = blue

windim = [1100, 1000]
jet_aia_full_details_image, windim, data, x, y, cm_aia, jtitle, dimage
for k = 0, n-1 do begin
    jet_aia_full_details_draw_rect, xx[*, k], yy[*, k], dimage, 'green', 3
endfor
jet_aia_full_details_draw_rect, xf, yf, dimage, 'red', 3

jet_aia_full_details_image, windim, data, x, y, cm_aia, jtitle, dimage
;jet_aia_full_details_draw_qh, size(data), details, frames, coords, dimage, 'green', 3
xpix = fix(xf/index.cdelt1 + index.crpix1) 
ypix = fix(yf/index.cdelt2 + index.crpix2) 
;jet_aia_full_details_draw_contour, data, x, y, [xpix[0], ypix[0]], details, frames, coords, dimage, 'green', 3

;jet_aia_full_details_draw_rect, xf, yf, dimage, 'red', 3

x = (findgen(xpix[1]-xpix[0]+1)+xpix[0]-index.crpix1)*index.cdelt1
y = (findgen(ypix[1]-ypix[0]+1)+ypix[0]-index.crpix2)*index.cdelt2

xdata = data[xpix[0]:xpix[1], ypix[0]:ypix[1]]

;wintrim = fix([(xpix[1]-xpix[0]+1)/4096d*windim[0], (ypix[1]-ypix[0]+1)/4096d*windim[1]])
wintrim = windim
jet_aia_full_details_image, wintrim, xdata, x, y, cm_aia, jtitle, dimage

for k = 0, n-1 do begin
    jet_aia_full_details_draw_rect, xx[*, k], yy[*, k], dimage, 'green', 3
endfor

jet_aia_full_details_image, wintrim, xdata, x, y, cm_aia, jtitle, dimage
;jet_aia_full_details_draw_qh, size(xdata), details, frames, coords, dimage, 'green', 3
jet_aia_full_details_draw_contour, xdata, x, y, [0,0], details, frames, coords, dimage, 'green', 3

end
