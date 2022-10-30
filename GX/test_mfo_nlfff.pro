pro test_mfo_nlfff

lib_location = 's:\Projects\CPP\MagFieldLibrary\binaries\WWNLFFFReconstruction.dll'

version_info = gx_box_field_library_version(lib_location)

restore, 'G:\Samples\11312_hmi.M_720s.20111010_085818.W116N26CR.CEA.POT.sav'
return_code = gx_box_make_nlfff_wwas_field(lib_location, box)

save, filename = 'G:\Samples\11312_hmi.M_720s.20111010_085818.W116N26CR.CEA.NAS.sav', box

end
