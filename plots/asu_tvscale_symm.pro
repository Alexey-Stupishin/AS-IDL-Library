pro asu_tvscale_symm, data0, background

data = double(data0)
srange = asu_symm_range(data)
asu_colortable_create, /load, abs_bottom = background
tvscale, data, /nointerpolation, minvalue = srange[0], maxvalue = srange[1]

end
