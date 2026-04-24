local Serializer = require("Data.serialiazer")

local Logger = {}
local LOG_DIR = "iDar/logs/"
local LOG_LEVELS = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4, FATAL = 5 }

local function write_log_line(level_name, message)
    local date_str = os.date("%Y-%m-%d")
    local file_path = LOG_DIR .. "log_" .. date_str .. ".log"
    local file_handle = io.open(file_path, "a")

    if file_handle then
        local hour = os.date("%H:%M:%S")
        local final_message = string.format("[%s] [%s]: %s\n", hour, level_name, message)
        file_handle:write(final_message)
        file_handle:close()
    else
        error("ERROR: can't open the log file: " .. file_path)
    end
end

local function log_event(level_name, data)
    local level = LOG_LEVELS[level_name]

    if not level then
        return
    end

    local message

    if type(data) == "table" then    
        message = Serializer.serialize(data)
    else
        message = tostring(data)
    end

    write_log_line(level_name, message)
end

function Logger.debug(data)
    log_event("DEBUG", data)
end

function Logger.info(data)
    log_event("INFO", data)
end

function Logger.warn(data)
    log_event("WARN", data)
end

function Logger.error(data)
    log_event("ERROR", data)
end

return Logger