package.path = package.path .. ";../?.lua" -- Relative paths for 'require'

local fs = require("filesystem")
local term = require("term")
local component = require("component")
local gpu = component.gpu

require("utils/internet_utils")
local JSON = require("utils/json")

local GITHUB_DIRECTORY = ""
local API_URL = "https://api.github.com/"
local RAW_URL = "https://raw.githubusercontent.com/"

local print = function(msg)
  gpu.setForeground(0x00FF00)
  _G.print(msg)
  gpu.setForeground(0xFFFFFF)
end

function print_error(msg)
  gpu.setForeground(0xFFFF00)
  print(msg)
  gpu.setForeground(0xFFFFFF)
end

function mkdir_repository(author, repository, path)
  if path == nil then path = "" end
  local path = GITHUB_DIRECTORY.."/"..repository.."/"..path
  if not fs.isDirectory(path) then 
    fs.makeDirectory(path)
  end
end

function clone_repository(author, repository)
  local url = API_URL.."repos/"..author.."/"..repository.."/contents/"
  local response = download(url)
  local to_lua = JSON:decode(response) 
  local raw_url = RAW_URL..author.."/"..repository.."/master/"
  mkdir_repository(author, repository)  

  local recurse_file = nil
  local recurse_dir = nil
  local recurse = nil

  recurse_file = function(path, entry)
    local name = entry.name
    local file_url = raw_url..path.."/"..name
    local data = download(file_url)
    local file_path = GITHUB_DIRECTORY.."/"..repository.."/"..path..name
    local file = io.open(file_path, "w")
    if file == nil then
      print_error("Cannot write to file: \""..file_path.."\". Failed to open File.")
      return
    end
    print("Writing file: "..file_path.."..")
    file:write(data)
    file:close()
  end

  recurse_dir = function(path, entry)
    if path == nil then path = "" end
    if entry ~= nil then path = path..entry.name.."/" end
    if path == nil then path = "" end
    local dir_path = GITHUB_DIRECTORY.."/"..repository.."/"..path
    print("Making directory: "..dir_path.."..")
    local result = fs.makeDirectory(dir_path)

    --  if result ~= true and result ~= nil then
    --    print_error("Failed to create directory: \""..dir_path.."\". (Error: "..tostring(result)..")")
    --    return
    --  end

    -- Grab the information on the directory.
    local url = API_URL.."repos/"..author.."/"..repository.."/contents/"..path
    local response = download(url)
    local to_lua = JSON:decode(response)    
    if to_lua == nil then return end
    -- Go through each entry.
    for i in pairs(to_lua) do recurse(path, to_lua[i]) end 
  end

  recurse = function(path, entry)
    if entry.type == "dir" then
      if entry.name:sub(1,1) == "." then
        print_error("Ignoring directory: \""..entry.name.."\". It starts with a period, which cannot be copied in OpenOS.")
        return
      end
      recurse_dir(path, entry)
    else
      recurse_file(path, entry)
    end
  end

  recurse_dir("", nil)
  print("Cloned repository!")
end

function request_clone_repository()  
  print("Enter the GitHub account: ") 
  local author = string.gsub(term.read(),"\n", "")
  print("Enter the GitHub repository: ")
  local repository = string.gsub(term.read(), "\n", "")
  print("Enter the directory to clone to: ")
  GITHUB_DIRECTORY = string.gsub(term.read(), "\n", "")
  -- Make sure that the Github repository exists...
  if GITHUB_DIRECTORY ~= "" and not fs.isDirectory(GITHUB_DIRECTORY) then
    fs.makeDirectory(GITHUB_DIRECTORY)
  end
  print("Attempting to clone the GitHub repository "..author.."/"..repository.."..")
  clone_repository(author, repository)
end

request_clone_repository()