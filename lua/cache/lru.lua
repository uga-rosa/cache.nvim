---@diagnostic disable-next-line: duplicate-doc-class
---@class CacheNode
---@field key any
---@field value any
---@field prev CacheNode
---@field next CacheNode
local CacheNode = {}

---Initialize the cache node
---@param key any
---@param value any
---@return CacheNode
function CacheNode.init(key, value)
    return {
        key = key,
        value = value,
        prev = nil,
        next = nil,
    }
end

---@diagnostic disable-next-line: duplicate-doc-class
---@class LinkedList
---@field head CacheNode
---@field tail CacheNode
local LinkedList = {}

---Initialize the linked list
---@return LinkedList
function LinkedList.init()
    local self = {}
    self.head = CacheNode.init(0, 0) -- dummy
    self.tail = CacheNode.init(0, 0) -- dummy
    self.head.next = self.tail
    self.tail.prev = self.head
    return setmetatable(self, { __index = LinkedList })
end

---Add node
---@param node CacheNode
function LinkedList:add(node)
    node.prev = self.head
    node.next = self.head.next
    self.head.next = node
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

---Initialize the cache
---@param capacity integer
---@return LruCache
function LruCache.init(capacity)
    local self = {}
    self.capacity = capacity
    self.key2node = {}
    self.linked_list = LinkedList.init()
    return setmetatable(self, { __index = LruCache })
end

---Add a data to the cache
---@param key any
---@param value any
function LruCache:set(key, value)
    if self.key2node[key] then
        local node = self.key2node[key]
        node.value = value
        self.linked_list:move2head(node)
    else
        local new_node = CacheNode.init(key, value)
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
        self.linked_list:move2head(self.key2node[key])
        return self.key2node[key].value
    end
end

return LruCache
