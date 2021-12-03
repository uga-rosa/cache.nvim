---@diagnostic disable-next-line: duplicate-doc-class
---@class CacheNode
---@field key any
---@field value any
---@field prev CacheNode
---@field next CacheNode
local CacheNode = setmetatable({}, {
    ---Initialize the cache node
    ---@param _ any
    ---@param key any
    ---@param value any
    ---@return CacheNode
    __call = function(_, key, value)
        return {
            key = key,
            value = value,
            prev = nil,
            next = nil,
        }
    end,
})

---@diagnostic disable-next-line: duplicate-doc-class
---@class LinkedList
---@field head CacheNode
---@field tail CacheNode
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
        return setmetatable(self, { __index = LinkedList })
    end,
})

---Add node
---@param node CacheNode
function LinkedList:add(node)
    node.prev = self.head
    self.head.next = node
    node.next = self.head.next
    node.next.prev = node
end

---Remove node
---@param node CacheNode
function LinkedList:remove(node)
    node.prev.next = node.next
    node.next.prev = node.prev
end

---Move node to the head
---@param node CacheNode
function LinkedList:move2head(node)
    self:remove(node)
    self:add(node)
end

---@class LruCache
---@field capacity integer
---@field key2node table<any, CacheNode>
---@field linked_list LinkedList
local LruCache = {}

setmetatable(LruCache, {
    ---Initialize the cache
    ---@param _ any
    ---@param capacity integer
    ---@return LruCache
    __call = function(_, capacity)
        local self = {}
        self.capacity = capacity
        self.key2node = {}
        self.linked_list = LinkedList()
        return setmetatable(self, { __index = LruCache })
    end,
})

---Add a data to the cache
---@param key any
---@param value any
function LruCache:put(key, value)
    if self.key2node[key] then
        local node = self.key2node[key]
        node.value = value
        self.linked_list:move2head(node)
    else
        local new_node = CacheNode(key, value)
        self.key2node[key] = new_node
        self.linked_list:add(new_node)

        if vim.tbl_count(self.key2node) > self.capacity then
            self.key2node[self.linked_list.tail.prev.key] = nil
            self.linked_list:remove(self.linked_list.tail.prev)
        end
    end
end

---Fetching a data from the cache
---@param key any
---@return any
function LruCache:get(key)
    if self.key2node[key] then
        self.linked_list.move2head(self.key2node[key])
        return self.key2node[key].value
    end
end

return LruCache
