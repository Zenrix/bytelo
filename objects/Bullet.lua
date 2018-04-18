Bullet = GameObject:extend()

function Bullet:new(area, x, y, opts)
  -- **TODO** Fix bullet centering bug, make bullets perform math on center of rectangle instead of on top left corner
  Bullet.super.new(self, area, x, y, opts)
  self.opts = opts or {100, 0, 0, 0}

  self.width = opts[1] or 8
  self.height = opts[2] or 8

  -- math
  self.goalX = opts[3] or 0
  self.goalY = opts[4] or 0

  self.bullet_speed = opts[5] or 100

  self.angle = math.atan2((self.goalX - self.x), (self.goalY - self.y))
  self.dx = self.bullet_speed * math.sin(self.angle)
  self.dy = self.bullet_speed * math.cos(self.angle)

  -- the * 28 is the offset from our player. This makes bullets
  -- spawn outside the player object instead of center of player
  self.x = self.x + self.width/2 + math.sin(self.angle) * 28
  self.y = self.y + self.height/2 + math.cos(self.angle) * 28

  -- physics
  self.collider = self.area.world:add(self, self.x, self.y, self.width, self.height)

  -- destory bullet object after 5 seconds
  self.timer:after(5, function() self:destroy() end)
end

function Bullet:update(dt)
  Bullet.super.update(self, dt)
  
  -- **TODO** destor bullet upon hitting wall or non-enemy
  if((self.x > 1366 or self.x < 0) or (self.y > 768 or self.y < 0)) then
    --self.dead = true
  end

  local function filter(item, other)
    if other.class == "Upgrade" then return "cross" end
    if other.class == "Player" then return "cross" end
    if other.class == "player_bullet" then return "cross" end
    return "touch"
  end

  if not self.dead then
    local actualX, actualY, cols, len = self.area.world:move(
      self.collider, 
      self.x + self.dx * dt, 
      self.y + self.dy * dt,
      filter
    )
    self.x = actualX
    self.y = actualY

    for i = 1, len do
      obj = cols[i].other
      if obj.class == "Enemy" then 
        self:destroy()
        obj:destroy()
      end
    end
  end
end

function Bullet:draw()
  love.graphics.setColor(0, 1, 1)
  love.graphics.rectangle('line', self.x, self.y, self.width, self.height)

  love.graphics.setColor(0, 1, 1, 0.2)
  love.graphics.rectangle('fill', self.x, self.y, self.width - 1, self.height - 1)

  love.graphics.setColor(1, 1, 1)
end

function Bullet:destroy()
  Bullet.super.destroy(self)
end