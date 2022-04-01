function asu_get_color_curr_table, k, value = value

common colors, R_orig, G_orig, B_orig, R_curr, G_curr, B_curr

if n_elements(value) eq 0 then value = 1d 

idx = 0 > round(k*255) < 255
r = r_orig[idx]
g = g_orig[idx]
b = b_orig[idx]

if value ne 0 then begin
    COLOR_CONVERT, r, g, b, h, s, v, /RGB_HSV
    s /= value
    COLOR_CONVERT, h, s, v, r, g, b, /HSV_RGB
endif

return, (b*256L + g)*256L + r

end
