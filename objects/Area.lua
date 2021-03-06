Area = Object:extend()

function Area:new(room)
  self.room = room
  self.game_objects = {}
end

function Area:update(dt)
  for i = #self.game_objects, 1, -1 do
    local game_object = self.game_objects[i]
    if game_object.dead then 
      game_object:destroy()
      table.remove(self.game_objects, i) 
    end
    game_object:update(dt)
  end
end

function Area:draw()
  -- sort drawn objects by depth to provide a layering system
  -- if two objects have the same depth, prioritize creation_time
  table.sort(self.game_objects, function(a, b)
    if a.depth == b.depth then
      return a.creation_time < b.creation_time
    end
    return a.depth < b.depth
  end)

  for _, game_object in ipairs(self.game_objects) do game_object:draw(dt) end
end

function Area:destroy()
  for i = #self.game_objects, 1, -1 do
    local game_object = self.game_objects[i]
    game_object:destroy()
    table.remove(self.game_objects, i)
  end
  self.game_objects = {}

  if self.world then
    self.world = nil
  end
end

function Area:addGameObject(game_object_type, x, y, opts, class)
  local class = class or game_object_type
  local opts = opts or {}
  local game_object = _G[game_object_type](self, x or 0, y or 0, opts)

  game_object.class = class

  table.insert(self.game_objects, game_object)
  return game_object
end

function Area:addPhysicsWorld()
  self.world = physics.newWorld()
end

function Area:queryCircleArea(x, y, radius, object_types)
  local output = {}
  
  -- for every game_object in the table game_objects
  for _, game_object in ipairs(self.game_objects) do
    -- if that game_object.class property is equal to one of
    -- the object types we are comparing to
    if moses.any(object_types, game_object.class) then
      -- Call the utility function distance() and store the result
      -- in a local variable distance
      local distance = distance(x, y, game_object.x, game_object.y)
      -- if the distance between the two points is within the radius
      -- we are checking then add the game_object to our output table
      if distance <= radius then
        table.insert(output, game_object)
      end
    end
  end

  return output
end

function Area:getClosestObject(x, y, radius, object_types)
  -- call our query function to find every object fitting
  -- object_types in our area and store them in a table
  local objects = self:queryCircleArea(x, y, radius, object_types)
  -- Sort our table so that objects with the lowest distance
  -- are first in the table
  table.sort(objects, function(a, b)
    local da = distance(x, y, a.x, a.y)
    local db = distance(x, y, b.x, b.y)
    return da < db
  end)
  -- return the first object in the table as it is the shortest
  -- distance
  return objects[1]
end