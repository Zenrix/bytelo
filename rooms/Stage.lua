Object = require '../lib/classic/classic'

Stage = Object:extend()

function Stage:new()
  self.area = Area(self)
  self.area:addPhysicsWorld()
  self.enemy_speed = 1
  timer:every(10, function()
     self.enemy_speed = self.enemy_speed + 1 
     self.area:addGameObject(
       'Notify', 
       0,
       766/2, 
       {"Difficulty up!", 100, 3, 3, "center"}
      )
  end)

  -- spawn our self.player and set him to a variable for easy access
  self.player = self.area:addGameObject('Player', window_width/2, window_height/2)
end

function Stage:update(dt)
  -- call the update function from our area
  self.area:update(dt)

  -- delete the last object added to the stage
  if input:pressed('f4') then
    self.area.game_objects[#self.area.game_objects].dead = true
  end

  -- manually spawn an enemy with mouse2
  if input:pressed('mouse2') then
    local x, y = love.mouse.getPosition()
    self.area:addGameObject('Enemy', x, y)
  end

  -- manually spawn an upgrade with u
  if input:pressed('u') then
    local x, y = love.mouse.getPosition()
    self.area:addGameObject('Upgrade', x, y)
  end

  -- make sure self.player stays within the screens dimensions
  if self.player:outOfBounds() then
    self.player.x = window_width/2
    self.player.y = window_height/2
  end

  -- spawn an upgrade
  if self.player.ups < self.enemy_speed then
    self.player.ups = self.player.ups + 1
    self.area:addGameObject('Upgrade', random(100, 1266), random(100, 668))
  end

  -- spawn enemies randomly in each quadrant
  local rand = math.ceil(random(150)) -- **TODO** turn on enemy spawn
  if rand == 1 then
    self.area:addGameObject(
      'Enemy', 
      self.player.x + random(200, 450), 
      self.player.y + random(250, 250), 
      {self.enemy_speed}
    )
  elseif rand == 2 then
    self.area:addGameObject(
      'Enemy', 
      self.player.x + random(-200, -450), 
      self.player.y + random(-250, -250), 
      {self.enemy_speed}
    )
  elseif rand == 3 then
    self.area:addGameObject(
      'Enemy', 
      self.player.x + random(-200, -450), 
      self.player.y + random(250, 250), 
      {self.enemy_speed}
    )
  elseif rand == 4 then
    self.area:addGameObject(
      'Enemy', 
      self.player.x + random(200, 450), 
      self.player.y + random(-250, -250), 
      {self.enemy_speed}
    )
  end
end

function Stage:draw()
  self.area:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("WASD or arrow keys to move", 10, 10)
  --love.graphics.print("Double tap key to dash", 10, 25)
  love.graphics.print("Mouse1 to shoot", 10, 25)
  love.graphics.print("R to restart", 10, 40)
  love.graphics.print("Score: " .. self.player.score, 10, 55)
end