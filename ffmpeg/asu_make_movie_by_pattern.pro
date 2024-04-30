pro asu_make_movie_by_pattern, prefix, from_dir, to_filename, fps = fps, postfix = postfix, digits = digits

extns = '.png'
if n_elements(postfix) eq 0 then postfix = '.png'
if n_elements(digits) eq 0 then digits = 5
if n_elements(fps) eq 0 then fps = 5

digits = 1 > digits < 9
format = '%0' + strcompress(string(digits), /remove_all) + 'd'

inst_mask = from_dir + path_sep() + prefix + format + postfix
asu_make_movie_by_frames, inst_mask, to_filename, fps = fps

end
