pro hmi_utils_get_image, filename, win, windim

read_sdo, filename, index, data
;read_sdo, filename, index0, data0
;hmi_prep, index0, data0, index, data

data = data > (-6000d) < 6000d

asu_fits2image, index, data, win, windim

end
