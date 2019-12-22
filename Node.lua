Node = {x = 5, y = 5, radius = 10, IsOn = true, IsConnected = false, gridX = 0, gridY = 0}

-- Function to check if the input coordinate is clicking on the node
function Node:IsPressed(x,y)

    if math.sqrt((y-self.y)^2 + (x - self.x)^2) < self.radius then
      return true
    end

    return false

end


-- function to turn the node off or on
function Node:ToggleNode()
  if self.IsOn then
    self.IsOn = false
  else
    self.IsOn = true
  end
end

-- create a new node
function Node:new(xPosition, yPosition, newRadius, gridPositionx, gridPositiony)
  o = {}
  setmetatable(o, self)

  o.x = xPosition or Node.x
  o.y = yPosition or  Node.y
  o.radius = newRadius or Node.radius
  o.gridX = gridPositionx or Node.gridX
  o.gridY = gridPositiony or Node.gridY
  o.isConnected = true
  self.__index = self
  return o
end



-- we are also adding connectors to this file (because what is a node that can't connect to other nodes?)
-- connectors simply connect two NodeChanceOffset
Connector = {Node1 = nil, Node2 = nil}

-- create a new connector
function Connector:new(NewNode1,NewNode2)
    o = {}
    setmetatable(o, self)

    o.Node1 = NewNode1
    o.Node2 = NewNode2

    self.__index = self
    return o
end
