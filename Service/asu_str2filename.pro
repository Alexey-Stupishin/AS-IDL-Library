function asu_str2filename, str

while (((pos = strpos(str, ' '))) ne -1) do strput, str, '_', pos
while (((pos = strpos(str, ':'))) ne -1) do strput, str, '_', pos
while (((pos = strpos(str, '\'))) ne -1) do strput, str, '_', pos
while (((pos = strpos(str, '|'))) ne -1) do strput, str, '_', pos
while (((pos = strpos(str, '/'))) ne -1) do strput, str, '_', pos
while (((pos = strpos(str, '?'))) ne -1) do strput, str, '_', pos
while (((pos = strpos(str, '<'))) ne -1) do strput, str, '_', pos
while (((pos = strpos(str, '>'))) ne -1) do strput, str, '_', pos
while (((pos = strpos(str, '*'))) ne -1) do strput, str, '_', pos
while (((pos = strpos(str, '"'))) ne -1) do strput, str, '_', pos

return, str

end
