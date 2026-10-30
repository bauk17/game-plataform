function readNumber(message, min, max, err)
  local number
  while not number do
    io.write(message)
    local input = io.read()
    if input == nil then
      return nil
    end

    number = tonumber(input)
    if not number or number < min or number > max then
      print(err)
      number = nil
    end
  end
  return number
end
