function asu_get_var2vph_rotate_matrix, latitude, longitude

sinlat = sin(latitude*!DTOR);
coslat = cos(latitude*!DTOR);
sinlon = sin(longitude*!DTOR);
coslon = cos(longitude*!DTOR);

rotmatr = double([ $
            [coslon,         0,      -sinlon] $
           ,[-sinlat*sinlon, coslat, -sinlat*coslon] $
           ,[coslat*sinlon,  sinlat,  coslat*coslon] $
          ])

return, rotmatr

end
