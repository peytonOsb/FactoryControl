Node = {}
Node.__index = Node

--create a node object for sorting
function Node:createNode(Val)
    --create new object of type "Node" with left, right, and value characteristics
    local self_obj = setmetatable({}, Node)
    self_obj.value = Val
    self_obj.parent = nil
    self_obj.left = nil
    self_obj.right = nil

    return self_obj
end

--insert a leaflet into a binary search tree where the first object acts as a root
function Node:insert(node)
    --parameter assertion 
    assert(type(node) == "table", "must be a node being inserted")
    assert(node.value ~= nil, "Node must contain a value to sort")

    if self.value[1] < node.value[1] then
        if self.right == nil then 
            self.right = node 
            node.parent = self 
        else
            self.right:insert(node)
        end
    elseif self.value[1] > node.value[1] then
        if self.left == nil then 
            self.left = node 
            node.parent = self 
        else
            self.left:insert(node)
        end
    else
        error("no duplicate nodes should exist")
    end
end

--remove a node from a Binary search tree
function Node:remove()   
    -- Ensure the node has a parent
    assert(self.parent ~= nil, "To remove this node, it must be part of a tree")

    --Simply detach the node
    if self.left == nil and self.right == nil then
        if self.parent.left == self then
            self.parent.left = nil
        else
            self.parent.right = nil
        end

    -- Reinsert children correctly
    else
        -- Store reference to parent before we reinsert
        local parentNode = self.parent

        -- Remove reference to the node from the parent
        if parentNode.left == self then
            parentNode.left = nil
        else
            parentNode.right = nil
        end

        -- Reinsert left child first to maintain BST properties
        if self.left ~= nil then
            parentNode:insert(self.left)
            self.left = nil
        end

        -- Then reinsert the right child
        if self.right ~= nil then
            parentNode:insert(self.right)
            self.right = nil
        end
    end

    -- Remove parent reference 
    self.parent = nil
end


function Node:lookupTableToBST(table)
    --create root from midpoint lookup table entry
    local Root = Node:createNode(table[math.floor(#table / 2)])

    --iterate over lookup table and attach each entry to root
    for index, key in pairs(table) do
        if index ~= math.floor(#table / 2) then Root:insert(Node:createNode(key)) end
    end

    return Root
end

function Node:search(value, TOL)
    if self.value[1] == value then
        return self
    elseif math.abs(value - self.value[1]) < TOL then
        return self
    elseif value < self.value[1] then
        return self.left and self.left:search(value, TOL) or nil
    else
        return self.right and self.right:search(value, TOL) or nil
    end
end


return Node