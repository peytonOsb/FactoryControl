Queue = {}
Queue.__index = Queue

Queue.MODE_FIFO     = "fifo"
Queue.MODE_PRIORITY = "priority"
Queue.MODE_COMBO    = "combo"

function Queue.new(opts)
    local self_obj = setmetatable({}, Queue)
    self_obj.items = {}
    self_obj.mode = (opts and opts.mode) or Queue.MODE_COMBO
    self_obj.aging_rate = (opts and opts.aging_rate) or 0.01
    self_obj.now = (opts and opts.now)
    return self_obj
end

local function get_now(self)
    if self.now then return self.now end
    return os.clock()
end

function Queue:setMode(mode)
    assert(mode == Queue.MODE_FIFO or mode == Queue.MODE_PRIORITY or mode == Queue.MODE_COMBO)
    self.mode = mode
end

function Queue:push(request)
    assert(type(request) == "table", "requests must be in the form of a table")

    request.priority = request.priority or 0
    request.t0 = request.t0 or get_now()
    table.insert(self.items, request)
end

function Queue:_score(request, t)
    if self.mode == Queue.MODE_FIFO then 
        return -(request.t0)

    elseif self.mode == Queue.MODE_PRIORITY then
        return request.priority

    elseif self.mode == Queue.MODE_COMBO then
        return request.priority + self.aging_rate * t

    end
end

function Queue:pop()
    local n = #self.items

    if n == 0 then return nil 
    elseif n == 1 then return self.items[1] end

    local best_index = 1
    local best_score = self:_score(self.items[1])
    
    for i = 2, n do
        local new_score = self:_score(self.items[i])

        if new_score > best_score then 
            best_score = new_score
            best_index = i
        end
    end
    
    return table.remove(self.items, best_index)
end

return Queue