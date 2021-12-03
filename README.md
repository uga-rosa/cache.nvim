# cache.nvim

lru and lfu cache for neovim lua

# Example

```lua
local lru = require("cache.lru")
local lfu = require("cache.lfu")
local function dump(v)
    print(vim.inspect(v))
end
```

### lru

```lua
local rc = lru.init(3) -- capacity 3

rc:set("hello", { "hello", "world", "uga" })
rc:set(12, 3456789)
rc:set(true, "false")

dump(rc:get(true))
dump(rc:get("hello"))
dump(rc:get(12))

rc:set(false, "true") -- over capacity
dump(rc:get(true)) -- Removeda the least recently used cache.
```

### lfu

```lua
local fc = lru.init(3) -- capacity 3

fc:set("hello", { "hello", "world", "uga" })
fc:set(12, 3456789)
fc:set(true, "false")

dump(fc:get(true)) -- freq = 2
dump(fc:get(true)) -- freq = 3
dump(fc:get("hello")) -- freq = 2
dump(fc:get(12)) -- freq = 2

fc:set(false, "true") -- over capacity
dump(rc:get(true)) -- Removed the least frequent cache with the oldest accesses.
```

# License

CC0
