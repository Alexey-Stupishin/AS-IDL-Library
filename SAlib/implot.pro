function implot_linspace, x1, x2, n
compile_opt idl2
  return, (dindgen(n)/ n) * (x2 - x1) + x1
end

function implot_logspace, x1, x2, n
compile_opt idl2
  if x1 le 0 or x2 le 0 then message,'Both limits must be positive'
  dx = (double(x2)/double(x1))^(1d/(n-1d))
  return, product([x1,replicate(dx,n-1)], /cumulative)
end

;+
  ; :Description:
  ;    Displays an image with the coordinate axes. Works similar to the CONTOUR routine
  ;
  ; :Params:
  ;    image  - image to display
  ;    x      - A vector representing the X-coordinate values to be plotted. If X is not specified,
  ;             it is calculated as a point number (starting at zero for linear scale and at one for log scale)
  ;    y      - A vector representing the Y-coordinate values to be plotted. If Y is not specified,
  ;             it is calculated as a point number (starting at zero for linear scale and at one for log scale)
  ;
  ; :Keywords:
  ;    xlog       - plot X axis in log scale. The image will ve interpolated to much the axis.
  ;    ylog       - plot Y axis in log scale. The image will ve interpolated to much the axis.
  ;    xrange     - The desired data range of the X axis, a 2-element vector
  ;    yrange     - The desired data range of the Y axis, a 2-element vector
  ;    sample     - Set this keyword to use nearest neighbour interpolation
  ;    resolution - required resolution (minimal image size) for the Post Script output, default 500
  ;    missing    - value to fill missing pixels during interpolation
  ;    _extra     - Most of the Direct Graphics keywords are supported
  ;
  ; :Author: Sergey Anfinogentov (segey.istp@gmail.com)
  ;-
pro implot, image, x, y, xlog = xlog, ylog = ylog, xrange = xrange, yrange = yrange,$
        sample = sample, _extra =_extra, missing = missing, resolution = resolution
compile_opt idl2

 ; Pmsave = !P.multi
  
  


  sz = size(image)
  nx = sz[1]
  ny = sz[2]
  
  if not keyword_Set(x) then begin
    x = dindgen(nx)
    if keyword_set(xlog) then x += 1d
  endif
  if not keyword_Set(y) then begin
    y = dindgen(ny)
    if keyword_set(ylog) then y += 1d
  endif
  
  if not keyword_set(xrange)      then xrange = minmax(x)
  if not keyword_set(yrange)      then yrange = minmax(y)
  if not keyword_set(resolution)  then resolution = 500l
  
  plot, x, y, xst=5, yst=5, /nodata, _extra = _extra, $
    xrange = xrange, yrange = yrange, xlog = xlog, ylog = ylog
    
  Nx_pix = round(!d.x_size*(!x.window[1]-!x.window[0]))
  Ny_pix = round(!d.y_size*(!y.window[1]-!y.window[0]))
  
  ;reduce image size for the Post Script output
  if !d.name eq 'PS' then begin

    scale = 512d/min([nx_pix,ny_pix])
    
    xsize = nx_pix
    ysize = ny_pix
    
    nx_pix = round(nx_pix*scale)
    ny_pix = round(ny_pix*scale)
    
  endif
  
  if keyword_set(xlog) then begin
    x_out = implot_logspace(xrange[0], xrange[1], nx_pix)
  endif else begin
    x_out = implot_linspace(xrange[0], xrange[1], nx_pix)
  endelse
  
  if keyword_set(ylog) then begin
    y_out = implot_logspace(yrange[0], yrange[1], ny_pix)
  endif else begin
    y_out = implot_linspace(yrange[0], yrange[1], ny_pix)
  endelse
  
  x_out_pix = interpol(dindgen(nx),x, x_out);, /spline)
  y_out_pix = interpol(dindgen(ny),y, y_out);, /spline)
  
  if keyword_Set(sample) then begin
    x_out_pix = round(x_out_pix)
    y_out_pix = round(y_out_pix)
  endif
  
   
  img = interpolate(image, x_out_pix, y_out_pix, cubic = -0.5, /grid, missing = missing)
  
  
  tvscl, img, !d.x_size*!x.window[0],  !d.y_size*!y.window[0], xsize = xsize, ysize = ysize
  !p.multi[0] = !p.multi[0]  +1
  contour, img, x_out, y_out, xlog = xlog, ylog = ylog, xrange = xrange, yrange = yrange,$
    /nodata, /noerase, _extra =_extra, xst = 1, yst =1
    !p.multi[0] = !p.multi[0]  -1

  
  


end