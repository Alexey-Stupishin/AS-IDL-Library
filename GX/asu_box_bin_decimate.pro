pro asu_box_bin_decimate, filename, bin

restore, filename

sz = size(box.bx)
sz = sz-1
nbx = box.bx[0:sz[1]:bin, 0:sz[2]:bin, 0:sz[3]:bin]
nby = box.by[0:sz[1]:bin, 0:sz[2]:bin, 0:sz[3]:bin]
nbz = box.bz[0:sz[1]:bin, 0:sz[2]:bin, 0:sz[3]:bin]

nbbx = box.base.bx[0:sz[1]:bin, 0:sz[2]:bin]
nbby = box.base.by[0:sz[1]:bin, 0:sz[2]:bin]
nbbz = box.base.bz[0:sz[1]:bin, 0:sz[2]:bin]
nbic = box.base.ic[0:sz[1]:bin, 0:sz[2]:bin]
nbase = {bx:nbbx, by:nbby, bz:nbbz, ic:nbic} 

sz = size(nbx)
index = box.index
index.cdelt1 = index.cdelt1*bin
index.cdelt2 = index.cdelt2*bin
index.crpix1 = (sz[1]+1)/2d
index.crpix2 = (sz[2]+1)/2d
index.naxis1 = sz[1]
index.naxis2 = sz[2]
dr = box.dr*bin

nbox = {add_base_layer:box.add_base_layer, base:nbase, bx:nbx, by:nby, bz:nbz, dr:dr, id:box.id, index:index, execute:'', refmaps:box.refmaps}
box = nbox

box.execute = sst_get_execute(box)

parser = stregex(filename, '(.+).sav',/subexpr,/extract,/fold_case)
outname = parser[1] + '_bin' + asu_compstr(bin) + '.sav'
save, filename = outname, box

end
