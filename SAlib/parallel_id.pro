function parallel_id,set = set
common parallel, id
  if n_elements(set) eq 1 then id = set[0]
  if not keyword_set(id) then return,0
  return,id
end