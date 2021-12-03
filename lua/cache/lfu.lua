---@diagnostic disable-next-line: duplicate-doc-class
---@class CacheNode
---@field key integer
---@field value integer
---@field freq integer
---@field prev CacheNode
---@field next CacheNode
local CacheNode = {}

setmetatable(CacheNode, {
    ---Initialize the cache node
    ---@param _ any
    ---@param key any
    ---@param value any
    ---@return CacheNode
    __call = function(_, key, value)
        return {
            key = key,
            value = value,
            freq = 1,
            prev = nil,
            next = nil,
        }
    end,
})

---@diagnostic disable-next-line: duplicate-doc-class
---@class LinkedList
---@field head CacheNode
---@field tail CacheNode
---@field length integer
local LinkedList = {}

setmetatable(LinkedList, {
    ---Initialize the linked list
    ---@return LinkedList
    __call = function()
        local self = {}
        self.head = CacheNode(0, 0) -- dummy
        self.tail = CacheNode(0, 0) -- dummy
        self.head.next = self.tail
        self.tail.prev = self.head
        self.length = 0
        return setmetatable(self, { __index = LinkedList })
    end,
})

---Get the length of linked list
---@return integer
function LinkedList:len()
    return self.length
end

---Add node
---@param node CacheNode
function LinkedList:add(node)
    node.prev = self.head
    self.head.next = node
    node.next = self.head.next
    node.next.prev = node
    self.length = self.length + 1
end

---Remove node
---@param node CacheNode
function LinkedList:remove(node)
    node.prev.next = node.next
    node.next.prev = node.prev
    self.length = self.length - 1
end

---@class LfuCache
---@field capacity integer
---@field key2node table<integer, CacheNode>
---@field list_map table<integer, LinkedList>
---@field total_size integer
---@field min_freq integer
local LfuCache = {}

setmetatable(LfuCache, {
    ---Initialize the cache
    ---@param _ any
    ---@param capacity integer
    ---@return LfuCache
    __call = function(_, capacity)
        local self = {}
        self.capacity = capacity
        self.key2node = {}
        self.list_map = {}
        self.total_size = 0
        self.min_freq = 0
        return setmetatable(self, { __index = LfuCache })
    end,
})

---Add a data to the cache
---@param key any
---@param value any
function LfuCache:put(key, value)
    if self.key2node[key] then
        local node = self.key2node[key]
        node.value = value
        self:_update(node)
    else
        if self.total_size == self.capacity then
            local last_node = self.list_map[self.min_freq].tail.prev
            self.list_map[self.min_freq]:remove(last_node)
            self.key2node[last_node.key] = nil
            self.total_size = self.total_size - 1
        end

        local new_node = CacheNode(key, value)
        self.key2node[key] = new_node
        self.list_map[1]:add(new_node)
        self.min_freq = 1
        self.total_size = self.total_size + 1
    end
end

---Fetching a data from the cache
---@param key any
---@return any
function LfuCache:get(key)
    if self.key2node[key] then
        local node = self.key2node[key]
        self:_update(node)
        return node.value
    end
end

---Update the number of accesses to a node
---@param node CacheNode
function LfuCache:_update(node)
    local cur_freq = node.freq
    node.freq = cur_freq + 1
    self.list_map[cur_freq].remove(node)
    self.list_map[node.freq].add(node)
    if cur_freq == self.min_freq and vim.tbl_isempty(self.list_map[cur_freq]) then
        self.min_freq = cur_freq + 1
    end
end

return LfuCache
