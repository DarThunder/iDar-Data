# iDar-Data

![State: Stable v1.0.0](https://img.shields.io/badge/State-Stable_v1.0.0-green)
![License: MIT](https://img.shields.io/badge/License-MIT-blue)

**The essential data manipulation suite for the iDar Ecosystem.**

**iDar-Data** is the foundational layer for data persistence and integrity within the iDar environment. It provides a robust set of utilities to handle JSON serialization, system logging, and integrity checks without the bloat of massive external libraries.

Designed to be lightweight and fast, it powers higher-level tools like [**iDar-DB**](https://github.com/DarThunder/iDar-DB), ensuring that when you save a table, it stays saved.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Modules](#modules)
  - [Serializer (JSON)](#serializer-json)
  - [Logger](#logger)
  - [CRC32 Integrity](#crc32-integrity)
- [FAQ](#faq)
- [License](#license)

## Features

- **Context-Aware Serialization**: Smart detection of Lua arrays vs. objects to produce valid JSON standard output automatically.
- **Rotational Logging**: Automatically organizes logs by date (`log_YYYY-MM-DD.log`) to keep your filesystem clean and your debugging sane.
- **Bitwise Integrity**: Fast CRC32 implementation compliant with IEEE 802.3 for validating data transmission and storage.
- **Dependency Free**: (Mostly). Built to run on standard ComputerCraft: Tweaked environments (requires `bit` API).

## Installation

The recommended way to install is via **iDar-Pacman**:

```lua
pacman -S idar-data
```

Or manually via `wget` (good luck with the folder structure):

```lua
-- Create directory /iDar/Data/src/
-- Download logger.lua, serializer.lua, crc32.lua
```

## Modules

### Serializer (JSON)

A robust JSON parser and stringifier tailored for Lua tables.

**Usage:**

```lua
local Serializer = require("iDar.Data.src.serializer")

local my_data = {
    name = "Turtle01",
    inventory = {"coal", "diamond"},
    level = 42
}

-- Serialize to string
local json_str = Serializer.serialize(my_data)
print(json_str)
-- Output: {"inventory":["coal","diamond"],"level":42,"name":"Turtle01"}

-- Deserialize back to table
local restored_table = Serializer.deserialize(json_str)
```

### Logger

Forget about `print()`. The Logger module writes structured events to disk, rotating files daily to prevent massive log dumps.

**File Location:** `/iDar/logs/log_YYYY-MM-DD.log`

**Usage:**

```lua
local Logger = require("iDar.Data.src.logger")

Logger.info("System startup complete.")
Logger.warn({ component = "Modem", status = "Unstable" }) -- Auto-serializes tables!
Logger.error("Fuel level critical!")
```

**Output Example:**

```text [INFO]: System startup complete. [WARN]: {"component":"Modem","status":"Unstable"}

```

### CRC32 Integrity

Validates that your data hasn't been corrupted during transfer or storage.

**Usage:**

```lua
local CRC32 = require("iDar.Data.src.crc32")

local data = "Important Mission Data"
local checksum = CRC32.crc32(data)

print(string.format("Checksum: %X", checksum))
```

## FAQ

**Q: Why another JSON parser?**
A: Because `textutils.serializeJSON` sometimes acts funny with mixed tables, and we needed granular control over array detection. Plus, we like reinventing wheels.

**Q: My logs are taking up too much space.**
A: That sounds like a _you_ problem. But seriously, the logger appends to files based on the date. Feel free to `rm iDar/logs/*.log` occasionally.

**Q: Is the CRC32 compatible with ZIP/PNG?**
A: Yes, it uses the standard IEEE 802.3 polynomial (`0xEDB88320`). It's the real deal.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
