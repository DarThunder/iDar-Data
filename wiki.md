# iDar-Data Functions Wiki

## Introduction

This wiki explains the functions available in **iDar-Data**, a utility suite designed to handle serialization, logging, and data integrity within the iDar ecosystem. It ensures your tables don't explode when you try to save them and that your logs are actually readable by humans (or turtles).

## Modules

## Serializer

### Serializer.serialize(value)

Converts a Lua value (table, string, number, boolean, or nil) into a valid JSON string.

- **Parameters:**
  - `value`: The data to serialize (`any`). Tables are recursively processed.
- **Returns:**
  - `jsonString`: The resulting JSON string (`string`).

#### Implementation Details:

- **Array Detection:** It automatically detects if a table is a list (array) or a dictionary (object) by checking if keys are sequential integers starting from 1. No more mixed `{"1": "a", "key": "b"}` abominations.
- **Deterministic Keys:** Object keys are sorted alphabetically before serialization. This ensures that `{a=1, b=2}` always produces the same string string hash, which is nice for checksums.
- **Escaping:** Handles quotes and backslashes in strings so your JSON doesn't break.

#### Example:

```lua
local data = { name = "Steve", items = {"sword", "pickaxe"} }
local json = Serializer.serialize(data)
print(json)
-- Output: {"items":["sword","pickaxe"],"name":"Steve"}
```

### Serializer.deserialize(json)

Parses a JSON string back into a Lua table (or primitive).

- **Parameters:**
  - `json`: The JSON string to parse (`string`).
- **Returns:**
  - `value`: The reconstructed Lua data (`table`, `string`, `number`, `boolean`, `nil`).

#### Implementation Details:

- **Pure Lua:** This is a handwritten recursive descent parser. It's slower than `textutils.unserializeJSON` for massive files, but it gives us precise control over types.
- **Tolerance:** Handles standard whitespace (spaces, tabs, newlines) gracefully.

---

## Logger

### Logger.debug(data) | .info(data) | .warn(data) | .error(data)

Writes a log entry to the filesystem with the specified severity level.

- **Parameters:**
  - `data`: The message or table to log (`any`). If a table is provided, it is automatically serialized to JSON.
- **Returns:**
  - `nil`

#### Implementation Details:

- **File Rotation:** Logs are saved in `/iDar/logs/` with the filename format `log_YYYY-MM-DD.log`. A new file is created automatically every day.
- **Timestamps:** Every line is prefixed with `[HH:MM:SS] [LEVEL]:`.
- **Append Mode:** Files are opened in append mode (`"a"`), so history is preserved until you manually delete the files.

#### Example:

```lua
Logger.info("System initializing...")
Logger.warn({ sensor = "left", reading = 0 }) -- Auto-serializes to JSON
-- File content: [WARN]: {"reading":0,"sensor":"left"}
```

---

## CRC32 (Integrity)

### crc32.crc32(str)

Calculates the 32-bit Cyclic Redundancy Checksum of a string.

- **Parameters:**
  - `str`: The input data (`string`).
- **Returns:**
  - `checksum`: The calculated checksum (`number`).

#### Implementation Details:

- **Standard Polynomial:** Uses the standard IEEE 802.3 polynomial (`0xEDB88320`). This matches the implementation used by ZIP, Gzip, and Ethernet.
- **Bitwise Ops:** Relies on the `bit` library (standard in CC: Tweaked / LuaJIT).
- **Performance:** It uses a precomputed lookup table. It's fast, but don't try to checksum a 1GB file in one tick unless you want the `Too long without yielding` crash.

#### Example:

```lua
local data = "Transfer complete"
local hash = crc32.crc32(data)
print(string.format("%X", hash)) -- Prints hex value, e.g., 9A2B3C4D
```

## Additional Notes

- **Log Maintenance:** The logger creates a new file **every single day**. If you run your server for a year, you will have 365 files. I recommend a cleanup script unless you have infinite storage (you don't).
- **Serializer limits:** It doesn't support cyclic references (tables pointing to themselves). If you try to serialize a self-referencing table, the stack will overflow and the turtle might cry.
- **JSON Nulls:** The string `"null"` in JSON becomes `nil` in Lua. If you have a key with a null value `{"key": null}`, it will disappear from the Lua table because `table.key = nil` deletes the entry. That's just how Lua works, fam.

## Security Considerations

- **Logging Secrets:** The Logger serializes _everything_ you give it. **DO NOT** pass `Logger.info(user_password)`. It will be written in plain text to the disk.
- **Integrity vs Security:** CRC32 is for detecting accidental corruption (bit flips), **NOT** for security. It is trivial to forge a collision. Use [`iDar-CryptoLib`](https://github.com/DarThunder/iDar-CryptoLib) (SHA-256) if you need tamper resistance.
