function asu_gxbox_rotate_line, line3D, rotator

in_vis = asu_gxbox_rotate_to_vis(line3D, rotator)
return, in_vis*rotator.rsun

end
