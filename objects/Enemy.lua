Enemy = GameObject:extend()

-- **TODO** Rewrite entire Enemy class, implement state machine/simple AI
function Enemy:new(area, x, y, opts)
  Enemy.super.new(self, area, x, y, opts)
  self.speed = opts[1] or 100
  self.width = opts[2] or 30
  self.height = opts[3] or 30

  self.depth = 49

  self.vx, self.vy = 20, 20
  self.goalX, self.goalY = self.x, self.y

  -- test stuff
  self.offsetX = self.width/2
  self.offsetY = self.height/2

  -- physics
  self.collider = self.area.world:add(self, self.x, self.y, self.width, self.height)

  -- **TODO** find a better way to reference player
  self.target_player = self.area:getClosestObject(1366/2, 768/2, 2000, {'Player'})
end

function Enemy:update(dt)
  Enemy.super.update(self, dt)
  self:moveEnemy(dt)
  if self:isOutOfBounds() then self:destroy() end
end

function Enemy:draw()
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle('line', self.x, self.y, self.width, self.height)

  love.graphics.setColor(1, 0, 0, 0.2)
  love.graphics.rectangle('fill', self.x + 1, self.y + 1, self.width - 1, self.height - 1)

  love.graphics.setColor(1, 1, 1)
end

function Enemy:destroy()
  -- **TODO** Figure out why I can't access self.area from an Enemy:die() function
  for i = 1, love.math.random(8, 12) do 
    self.area:addGameObject('ExplodeParticle', self.x + 15, self.y + 15, {color={1,0,0,0.8}}) 
  end
  Enemy.super.destroy(self)
end

-- **TODO** Fix enemy collision so they don't go flying out of the group when nearby enemies are killed
function Enemy:moveEnemy(dt)

  if self.target_player then
    if self.target_player.x + 10 > self.x + self.offsetX then
      self.goalX = self.goalX + self.speed*dt
    elseif self.target_player.x + 10 < self.x + self.offsetX then
      self.goalX = self.goalX - self.speed*dt
    end
    if self.target_player.y + 10 > self.y + self.offsetY then
      self.goalY = self.goalY + self.speed*dt
    elseif self.target_player.y + 10 < self.y + self.offsetY then
      self.goalY = self.goalY - self.speed*dt
    end
  end

  local function filter(item, other)
    if other.class == "player_bullet" then return "cross" end
    if other.class == "Upgrade" then return "cross" end
    return "slide"
  end

  if not self.dead and self.target_player then
    local actualX, actualY, cols, len = self.area.world:move(
      self.collider, 
      self.goalX, 
      self.goalY,
      filter
    )
    self.x, self.y = actualX, actualY

    for i = 1, len do
      obj = cols[i].other
      if obj.class == "player_bullet" then 
        self:destroy()
        obj:destroy()
      end
      if obj.class == "Player" then 
        obj:destroy()
      end
    end
  end
end

function Enemy:isOutOfBounds()
  if self.y > 1400 or self.y < -1400 then
    return true
  elseif self.x > 2000 or self.x < -1700 then
    return true
  else
    return false
  end
end