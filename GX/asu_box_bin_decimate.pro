pro asu_box_bin_decimate, filename, bin

restore, filename

sz = size(box.bx)
sz = sz-1
nbx = box.bx[0:sz[1]:bin, 0:sz[2]:bin, 0:sz[3]:bin]
nby = box.by[0:sz[1]:bin, 0:sz[2]:bin, 0:sz[3]:bin]
nbz = box.bz[0:sz[1]:bin, 0:sz[2]:bin, 0:sz[3]:bin]

sz = size(nbx)
index = box.index
index.cdelt1 = index.cdelt1*bin
index.cdelt2 = index.cdelt2*bin
index.crpix1 = (sz[1]+1)/2d
index.crpix2 = (sz[2]+1)/2d
index.naxis1 = sz[1]
index.naxis2 = sz[1]
dr = box.dr*bin

nbox = {add_base_layer:box.add_base_layer, base:box.base, bx:nbx, by:nby, bz:nbz, dr:dr, id:box.id, index:index, refmaps:box.refmaps}
box = nbox

parser = stregex(filename, '(.+).sav',/subexpr,/extract,/fold_case)
outname = parser[1] + '_bin' + asu_compstr(bin) + '.sav'
save, filename = outname, box

end
