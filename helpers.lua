function readNumber(message, min, max, err)
  local number
  while not number do
    io.write(message)
    number = tonumber(io.read())
    if not number or number < min or number > max then
      print(err)
      number = nil
    end
  end
  return number
end
