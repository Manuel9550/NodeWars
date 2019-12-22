local gamera = require 'gamera'

-- file for the camera controller, a wrapper around the gamera camera that allows us to manipulate it easier
-- in the game scene

-- basic defaults for the camera controller
CameraController = {x = 250, y = 250, velocity = {x = 0, y = 0}, maxScale = 5, minScale = 0.1, camera = nil, maxX = 0, minX = 0, maxY = 0, minY = 0, scale = 1.0, SelectedNodeX = nil, SelectedNodeY = nil, Magnitude = nil}



-- create a Camera Controller
function CameraController:new(xPosition, yPosition, gameSceneWidth,gameSceneHeight, cameraScreenOffsetX,cameraScreenOffsetY)
  o = {}
  setmetatable(o, self)

  o.x = xPosition or CameraController.x
  o.y = yPosition or  CameraController.y
  o.velocity = CameraController.velocity
  o.scale = CameraController.scale
 
  -- create the gamera instance that our game controller will use
  cam = gamera.new(0,0,gameSceneWidth, gameSceneHeight)
  cam:setPosition(o.x, o.y)

  cam:setWindow(cameraScreenOffsetX, cameraScreenOffsetY, gameSceneWidth, gameSceneHeight)
  
  o.camera = cam
  
  -- set the max values to the cameras viewport
  
  x1,y1,x2,y2,x3,y3,x4,y4 = cam:getVisibleCorners()
  o.maxX = x3
  o.maxY = y3
  
  o.minX = x1
  o.minY = y1
  
  self.__index = self
  return o
end


-- get the gamera from the CameraController
function CameraController:GetCamera()
  return self.camera
end

-- change the position of the camera
function CameraController:ChangePosition(x,y)
  
  if x <= self.maxX and x >=self.minX and y <= self.maxY and y >= self.minY then
    self.x = x
    self.y = y
    self.camera:setPosition(x,y)
  end
end

function CameraController:ChangeScale(newScale)
  if newScale >= self.minScale and newScale <= self.maxScale then
    self.scale = newScale
    self.camera:setScale(newScale)
  end
end

-- the function we are going to use to slide the camera
function CameraController:SlideCamera(direction, distance)

  x1, y1, x2, y2, x3, y3, x4, y4 = self.camera:getVisibleCorners()


  

  if direction == "up" then
    -- we are moving up. Check if there is enough distance or we've reached the edge of the frame
    if (y3 + distance) <= self.maxY then
      self:ChangePosition(self.x, self.y + distance)
    else
      distanceToBorder = self.maxY - y3
      self:ChangePosition(self.x, self.y + distanceToBorder)
    end
    
  elseif direction == "down" then
    if (y1 - distance) >= self.minY then
      self:ChangePosition(self.x, self.y - distance)
    else
      distanceToBorder = y1 - self.minY
      self:ChangePosition(self.x, self.y - distanceToBorder)
    end
  elseif direction == "left" then
    if (x1 - distance) >= self.minX then
      self:ChangePosition(self.x - distance, self.y)
    else
      distanceToBorder = x1 - self.minX
      self:ChangePosition(self.x - distanceToBorder, self.y)
    end
  elseif direction == "right" then
    if (x3 + distance) <= self.maxX then
      self:ChangePosition(self.x + distance, self.y)
    else
      distanceToBorder = self.maxX - x3
      self:ChangePosition(self.x + distanceToBorder, self.y)
    end
  end
end

function CameraController:MoveToNode()
  if self.SelectedNodeX ~= nil and self.SelectedNodeY ~= nil then
    -- get the direction of the Node
      xDirection = self.SelectedNodeX - self.x
      yDirection = self.SelectedNodeY - self.y
      
      
      
      -- get the magnitude of the vector
      magnitude = math.sqrt((xDirection * xDirection) + (yDirection * yDirection))
      self.Magnitude = magnitude
      -- if the magnitude is less than or equal to about 20 pixels, don't bother moving the camera
      
      if magnitude <= 20 then
        self.SelectedNodeX = nil
        self.SelectedNodeY = nil
        
      else
         -- get the unit vector
        uX = xDirection / magnitude
        uY = yDirection / magnitude
      
        scale = magnitude / 10
      
        if scale < 5 then
          scale = 5
        end
        
        -- move the camera towards the selected node
        self:ChangePosition(self.x + (uX * scale), self.y + (uY * scale))
        
        -- gradually make the window smaller to focus on the node
        self:ChangeScale(self.scale + 0.1)
      end
      
  end
end


function CameraController:SelectNode(x,y)
  self.SelectedNodeX = x
  self.SelectedNodeY = y
end
