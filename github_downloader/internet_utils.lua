local component = require("component")
local internet = require("internet2")
local fs = require("filesystem")
local io = require("io")

--- Downloads and returns data for a given URL.
---
--- @return Returns data result as a string.
function download(url)
  local header = {}
  header["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
  local request, reason = internet.request(url, nil, header, "GET")
  local response = ""  
  for chunk in request do
    response = response..chunk
  end
  return response, request, reason
end

function download_to_file(url, path)
  local data = download(url)
  local file = io.open(path, "w")
  file:write(data)
  file:close()
end