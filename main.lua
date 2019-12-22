require "Node"
require "CameraController"
--local gamera = require 'gamera'
math.randomseed(os.time())
NodeChance = 10 -- out of 100, how likely is it that a node will form in each square
NodeChanceOffset = 5
length = 15
height = 15


-- constants
NodeRadius = 10
NodeOffsets = 30

-- the game scenes width and height will always be the max allowed columns and rows + 1
GameScene  = { w = (NodeOffsets * length) + (NodeOffsets * 1), h = (NodeOffsets * height) + (NodeOffsets * 1) }

-- debug stuff
testCount = 0
NodesTested = {}
TestString = ""
TestStartNode = ""

testY = 0
-- instead of using the gamera directly, use the CameraController to allow moving between nodes and such
--[[
-- camera stuff
cam = gamera.new(0,0,GameScene.w, GameScene.h)

cameraX = length * NodeOffsets / 2
cameraY = height * NodeOffsets / 2

cam:setPosition(cameraX, cameraY)

cam:setWindow(30, 30, GameScene.w, GameScene.h)

--camera scale
CameraScale = 1.0
--]]

SceneCameraController = CameraController:new(length * NodeOffsets / 2,height * NodeOffsets / 2, GameScene.w,GameScene.h, 30,30)

-- Runs immediately when the game starts. Put pre-game prep stuff here
function love.load()

  -- create the node array and the connection arrays
  NodeArray = {}
  ConnectionArray = {}

  for i=1,height do
    NodeArray[i] = {}
    for j=1,length do
      if ShouldGenerateNode(i,j) then
        NodeArray[i][j] = Node:new(i * NodeOffsets, j * NodeOffsets ,NodeRadius, i,j)
      else
        NodeArray[i][j] = nil
      end

    end
  end

  -- setting up the arrayconnectors
  SetupDone = true

  -- we need a random node to be our starting point
  startx = math.random(1, length)
  starty = math.random(1, height)

  NodeArray[startx][starty] = Node:new(startx * NodeOffsets, starty * NodeOffsets ,NodeRadius, startx, starty)
  NodeArray[startx][starty].IsConected = true
  TestStartNode = startx .. " " .. starty
  -- this array will store all our connected Nodes

  ConnectedNodes = {}
  table.insert(ConnectedNodes, NodeArray[startx][starty])


  -- initialize the node and use Prims algorithm to connect the nodes
  AllNodesConnected = false
  DebugCount = 0

  while not AllNodesConnected do
      DebugCount = DebugCount + 1;

      PossibleNodesToAdd = {}
      for count = 1, #ConnectedNodes do
          -- find the closest non-connected node to this one
          CurrentNode = ConnectedNodes[count]
          --table.insert(NodesTested, CurrentNode.gridX .. " " .. CurrentNode.gridY)
          FoundNode = FindClosestNode(CurrentNode.gridX, CurrentNode.gridY)

          -- check if there are no more nodes to add to the network
          if FoundNode == nil then
              AllNodesConnected = true
          else
              PossibleConnection = {}
              PossibleConnection.NodeInNetwork = CurrentNode
              PossibleConnection.NodeToAdd = FoundNode
              table.insert(PossibleNodesToAdd, PossibleConnection)
          end
      end

      if not AllNodesConnected then
        TestString = "We entered here!"

        -- we have gone through every node and found their closest non connected node
        -- Now, see which of those nodes we are going to add to the network
        CurrentBestNode1 = {}
        CurrentBestNode2 = {}

        currentBestNode = 100000 -- arbitrarily large number
        for count = 1, #PossibleNodesToAdd do


            Node1 = PossibleNodesToAdd[count].NodeInNetwork
            Node2 = PossibleNodesToAdd[count].NodeToAdd

            currentWeight = FindNodeWeight(Node1,Node2)
            if currentWeight <= currentBestNode then
              CurrentBestNode1 = Node1
              CurrentBestNode2 = Node2
              currentBestNode = currentWeight

            end

        end

        -- we now have the closest node to the current network. Connect it to the NodeInNetwork
        newConnector = Connector:new(CurrentBestNode1, CurrentBestNode2)
        table.insert(ConnectionArray,newConnector)
        CurrentBestNode2.IsConnected = true;
        table.insert(ConnectedNodes,CurrentBestNode2)
      end
  end


  -- setting up the camera world and position here
  

 
  myfont = love.graphics.newFont(15)
end

-- callback for when the mousewheel moves
function love.wheelmoved(x, y)
    if y > 0 then
      SceneCameraController:ChangeScale(SceneCameraController.scale + 0.1)
    elseif y < 0 then      
      SceneCameraController:ChangeScale(SceneCameraController.scale - 0.1)
    end
end

--called once every frame.. dt is delta time. Usually will be called 60 times a second
function love.update(dt)

  testX, testY = SceneCameraController:GetCamera():getVisibleCorners()
  -- check to see if we need to move the camera
  if love.keyboard.isDown( "left" ) then
     SceneCameraController:SlideCamera("left",1)
  end
   
   if love.keyboard.isDown( "right" ) then
     SceneCameraController:SlideCamera("right",1)
   end
   
   if love.keyboard.isDown( "up" ) then
    SceneCameraController:SlideCamera("up",1)
   end
   
   if love.keyboard.isDown( "down" ) then
    SceneCameraController:SlideCamera("down",1)
   end
   
   if love.keyboard.isDown( "space" ) then
      -- reset the camera back to the default position
      cameraX = length * NodeOffsets / 2
      cameraY = height * NodeOffsets / 2

      SceneCameraController:ChangePosition(cameraX, cameraY)
      
      SceneCameraController:ChangeScale(1.0)
   end
   
end

-- draws stuff to the screen.
function love.draw()



  -- draw the bakcground to be white
  love.graphics.setColor(1,1,1)
  love.graphics.rectangle("fill", 0, 0, NodeOffsets * length * 2, NodeOffsets * height * 2)
  love.graphics.setColor(0,0,1)
  
  -- draw the game background to be black
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill", 30, 30, GameScene.w,GameScene.h)
  love.graphics.setColor(0,0,1)

  SceneCameraController:GetCamera():draw(function(l,t,w,h)
    -- draw camera stuff here
    DrawNodes()
  end)
  love.graphics.print(SceneCameraController.x, 0, 0)
  love.graphics.print(SceneCameraController.y, 0, 20)
  love.graphics.print(SceneCameraController.maxX, 0, 40)
  love.graphics.print(SceneCameraController.maxY, 0, 60)
  love.graphics.print(testY, 0, 80)
end

-- draws the nodes to the screen
function DrawNodes()
  for i=1,height do
    for j=1,length do

      currentNode = NodeArray[i][j]

      if currentNode ~= nil and currentNode.IsOn then

          love.graphics.circle("fill", currentNode.x,  currentNode.y, currentNode.radius)
      elseif currentNode ~= nil and (currentNode.IsOn == false) then
      
          love.graphics.setColor(1,0,0)
          love.graphics.circle("fill", currentNode.x,  currentNode.y, currentNode.radius)
          love.graphics.setColor(0,0,1)
      end
    
    

    end
  end


  -- draw each connector
  for ConnectorCount = 1, #ConnectionArray do
      currentConnector = ConnectionArray[ConnectorCount]
      love.graphics.line( currentConnector.Node1.x, currentConnector.Node1.y, currentConnector.Node2.x, currentConnector.Node2.y)
  end

  OutputStringtest = TestStartNode .. ")" .. TestString

  for count = 1, #NodesTested do
    OutputStringtest = OutputStringtest .. "|" .. NodesTested[count]
  end


  love.graphics.setFont(myfont)
  love.graphics.setColor(0,0,1)
  
end

-- calculates whether a node should spawn in this square
-- starts off with a base chance, and increases the cahnce if there are no node nearby
function ShouldGenerateNode(x,y)

  chance = NodeChance

  if x > 1 then

    if  NodeArray[x - 1][y] == nil  then
      chance = chance + NodeChanceOffset
    else
      chance = chance - NodeChanceOffset
    end
  end

  if y > 1 then

    if  NodeArray[x][y - 1] == nil  then
      chance = chance + NodeChanceOffset
    else
      chance = chance - NodeChanceOffset
    end
  end

  return math.random(1, 100) <= chance

end

function love.mousepressed(x,y,b, isTouch)
  if b == 1 then

    worldX, worldY = cam:toWorld(x,y)
    -- loop through every node, and try to see if the mouse pressed on any
    for i=1,height do
      for j=1,length do
        currentNode = NodeArray[i][j]
        if currentNode ~= nil and currentNode:IsPressed(worldX,worldY) then
          NodeArray[i][j]:ToggleNode()
          break
        end

      end
    end

  end

end


function distancebetween(x1,y1,x2,y2)
  return math.sqrt((y2-y1)^2 + (x2 - x1)^2)
end

--[[
Name: FindNodeWeight
Description: returns distacne between the two entered nodes
--]]

function FindNodeWeight(Node1, Node2)
    return distancebetween(Node1.x, Node1.y, Node2.x, Node2.y)
end

--[[
Name: FindClosestNode
Description: returns the closest grid element that has an unconnected node, while connecting that node
Paramaters:
  x : the x location of the grid to begin searching for unconnected nodes
  y : the y location of the grid to begin searching for unconnected nodes
Returns:  a table of i and j, which corrospond to the grid location where it found the node
--]]
function FindClosestNode(x,y)
    TestString = "Finding " .. x .. " " .. y .. "|"
    offsetX = 1
    offsetY = 1
    returnNode = nil

    EndOfNodes = false
    while not EndOfNodes do
      -- loop through the surrounding nodes, and check to see if there is a node there
      for i = (x - offsetX), (offsetX + x) do
          for j = (y - offsetY), (offsetY + y) do

            if i >= 1 and j >= 1 and i <= length and j <= height then
                  -- check to see if this neighbor contains a node that isn't connected
                  --table.insert(NodesTested, "[" .. i .. " " .. j .."]")
                  if NodeArray[i][j] ~= nil and NodeArray[i][j].IsConnected == false then
                      -- add this node to the network by creating a connection between the two nodes


                        --newConnector = Connector:new(NodeArray[x][y], NodeArray[i][j])
                        --table.insert(ConnectionArray,newConnector)



                      --  NodeArray[i][j].IsConnected = true;

                        -- we found the closest node, return it
                        returnNode = NodeArray[i][j]
                        EndOfNodes = true
                        --table.insert(NodesTested, i .. " " .. j)

                        -- debugging

                        break
                  end
            end


         end

      end
      -- we have completed the loop, check if we need to expand the perimeter
      if not EndOfNodes then
        offsetX = offsetX + 1
        offsetY = offsetY + 1

        if offsetX > length then
          --table.insert(NodesTested, offsetX .. " " .. offsetY)
          EndOfNodes = true
        end
      end
    end

    return returnNode
end
