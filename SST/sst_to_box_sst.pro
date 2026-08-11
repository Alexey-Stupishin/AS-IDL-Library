pro sst_to_box_sst

date_obs = '2018-09-30T09:22:00'
cont_file = 'g:\BIGData\Work\12723\Sources\HMI\hmi.Ic_noLimbDark_720s.20180930_092400_TAI.continuum.fits'
mag_file = 'g:\BIGData\Work\12723\Sources\HMI\hmi.M_720s.20180930_092400_TAI.magnetogram.fits'

;fpath = 'g:\BIGData\Work\12723\Preparation\SST\cube_wide\'
;ID = 'SST+HMI3_dec_2'
fpath = 'g:\BIGData\Work\12723\Preparation\SST\cube_wide_35\'

ID = 'SST+HMI3_35_dec_4'
depth = 5

scale = 1
z_factor = 0.95

asu_plain_to_box, date_obs, fpath, ID, cont_file, mag_file, scale, depth, z_factor, pot = pot

end
