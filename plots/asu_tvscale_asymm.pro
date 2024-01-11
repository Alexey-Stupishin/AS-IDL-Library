pro asu_tvscale_asymm, data0, range_colors, background

data = double(data0)
srange = asu_asymm_range(data)
asu_colortable_create, step_colors = range_colors, /load, abs_bottom = background
tvscale, data, /nointerpolation, minvalue = srange[0], maxvalue = srange[1]

end
