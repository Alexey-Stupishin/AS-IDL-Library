pro test_mfo_nlfff_nix

restore, '/home/stupishin/Samples/11312_hmi.M_720s.20111010_085818.W116N26CR.CEA.POT.sav'
return_code = gx_box_make_nlfff_wwas_field('/home/stupishin/cpp/MagFieldLibrary/Linux//WWNLFFFReconstruction.so', box)

save, filename = '/home/stupishin/Samples/11312_hmi.M_720s.20111010_085818.W116N26CR.CEA.NAS.sav', box

end
