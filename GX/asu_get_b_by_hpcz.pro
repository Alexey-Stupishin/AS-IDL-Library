function asu_get_B_by_HPCZ, hpc, above_photosphere_Mm, box, Br = Br, coords = coords
  compile_opt idl2

  asu_box_get_coord, box, boxdata
  rotator = asu_gxbox_get_rotator(boxdata)

  source_to_sun_dist = above_photosphere_Mm*1e6/wcs_rsun()*rotator.dircos[2] + rotator.viszcen 
  
  return, asu_get_B_by_HPCD(hpc, source_to_sun_dist, box, Br = Br, coords = coords)
  
end
