pro asu_make_movie_by_frames, pattern, to_filename, fps = fps
; call sample:
; asu_make_movie_by_frames, 'd:\work2022\jets\QPPs_051113\AIA_png_304A\aia_%05d.png', 'd:\work2022\jets\QPPs_051113\AIA_png_304A\ilename.mp4',fps = 5
compile_opt idl2

ffmpegpath = file_dirname((ROUTINE_INFO('asu_make_movie_by_frames', /source)).path, /mark)
if !version.OS_FAMILY eq 'unix' then begin ;use ffmpeg binary from the system in unix based OS
    ffmpegpath = ''
endif

cmd = ffmpegpath + 'ffmpeg -framerate ' + strcompress(long(fps),/remove_all) $
      + ' -i ' + pattern $
      + ' -y -vf scale="trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -profile:v high -pix_fmt yuv420p ' $
      + to_filename
print, cmd

spawn, cmd
  
; ffmpeg -f image2 -framerate 30 -i lin_%05d.png foo.mp4   
end
