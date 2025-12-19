# Changelog

## Stable

### v1.0.0

**"The Foundation Update"**

Initial public release of the **iDar-Data** suite. This library was extracted from the core of iDar-Pacman to serve as the shared data handling layer for the entire ecosystem. No more copy-pasting `json.lua` between projects.

#### Core Modules

- **Serializer (JSON):**

  - **Smart Array Detection:** implemented a heuristic (`is_array`) to distinguish between Lua's sequential tables (arrays) and key-value tables (objects). It now correctly outputs `[]` or `{}` based on the keys, preventing the dreaded mixed-index JSON corruption.
  - **Deterministic Output:** Object keys are now alphanumerically sorted before serialization. This ensures that `{a=1, b=2}` and `{b=2, a=1}` always produce the exact same string hash.
  - **Type Safety:** Added explicit handling for `string`, `number`, `boolean`, and `nil` (converted to `"null"` string).

- **Logger:**

  - **Rotational Filing:** The logger now generates filenames dynamically based on the system date (`log_YYYY-MM-DD.log`).
  - **Auto-Serialization:** Passing a table to `Logger.info()` or other levels now automatically calls the Serializer, making debugging complex objects significantly easier than `textutils.serialize`.
  - **Levels:** Implemented standard severity levels: `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`.

- **Integrity (CRC32):**
  - **Standard Compliance:** Implemented the IEEE 802.3 polynomial (`0xEDB88320`). This ensures checksums are compatible with standard ZIP/Gzip tools outside of Minecraft.
  - **Lookup Table:** Uses a pre-calculated hex table for performance, avoiding expensive bitwise calculations on every byte during runtime.

#### Technical Details

- **Dependency Management:** The suite is designed to work with LuaJIT's `bit` library (standard in CC: Tweaked).
- **String Escaping:** The serializer now properly escapes backslashes and double quotes to produce valid JSON syntax compliant with RFC 8259.
