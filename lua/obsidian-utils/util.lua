local function read_file_lines(path)
  local lines = {}
  local f = io.open(tostring(path), 'r')
  if f then
    for line in f:lines() do
      table.insert(lines, line)
    end
    f:close()
  end
  return lines
end
