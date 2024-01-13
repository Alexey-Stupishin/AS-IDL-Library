function asu_colortable_create_parse, color, normal = normal

    if isa(color, /number, /array) then return, c
    if ~isa(color, /string) then return, byte([0, 0, 0])

    case color of
        'k':  this_col = 'black'
        'w':  this_col = 'white'
        'la': this_col = 'lightgray'
        'a':  this_col = 'gray'
        'da': this_col = 'darkgray'
        'r':  this_col = 'red'
        'dr': this_col = 'darkred'
        'g':  this_col = 'green'
        'dg': this_col = 'darkgreen'
        'b':  this_col = 'blue'
        'db': this_col = 'darkblue'
        'c':  this_col = 'cyan'
        'dc': this_col = 'darkcyan'
        'm':  this_col = 'magenta'
        'dm': this_col = 'darkmagenta'
        'y':  this_col = 'yellow'
        'dy': this_col = 'darkyellow'
        'brown':  this_col = 'darkyellow'
        'p':  this_col = 'pink'
        'v':  this_col = 'violet'
        else: this_col = color
    endcase

    case this_col of
        'black':       c = [   0,    0,    0]
        'white':       c = [   1,    1,    1]
        'lightgray':   c = [0.75, 0.75, 0.75]
        'gray':        c = [ 0.5,  0.5,  0.5]
        'darkgray':    c = [0.25, 0.25, 0.25]
        'red':         c = [   0,    0,    1]
        'darkred':     c = [   0,    0,  0.5]
        'green':       c = [   0,    1,    0]
        'darkgreen':   c = [   0, 0.65,    0]
        'blue':        c = [   1,    0,    0]
        'darkblue':    c = [ 0.5,    0,    0]
        'cyan':        c = [   1,    1,    0]
        'darkcyan':    c = [ 0.5,  0.5,    0]
        'magenta':     c = [   1,    0,    1]
        'darkmagenta': c = [ 0.5,    0,  0.5]
        'yellow':      c = [   0,    1,    1]
        'darkyellow':  c = [   0,  0.7,  0.7]
        'pink':        c = [0.71,    0,    1]
        'violet':      c = [   1,    0,  0.5]
        else:          c = [   0,    0,    0]
    endcase

    if n_elements(normal) eq 0 then c = byte(c*255) 
    return, c

end
