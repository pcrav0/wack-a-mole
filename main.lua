-- Whac-A-Mole

require('utils')

lg = love.graphics

function img(path)
   local result = lg.newImage(path)
   result:setFilter('linear', 'nearest')
   return result
end

function love.load()
   if false then
      love.mouse.setVisible(false)
   end

   entity_scale = 16
   textures = {
      mole = img('mole.png'),
      hammer = img('hammer.png'),
   }
   bouding_box = {
      mole = {
	 x = entity_scale * textures.mole:getWidth()  * 0.1,
	 y = entity_scale * textures.mole:getHeight() * 0.2,
	 w = entity_scale * textures.mole:getWidth()  * 0.8,
	 h = entity_scale * textures.mole:getHeight() * 0.8,
      }
   }
   time = 0
   player = { x = 0, y = 0 }
   entities = list()
end

function love.update(dt)
   time = time + dt

   if time > 1 and math.random() < 0.1 then
      if true and #entities == 1 then
	 return
      end
      time = 0

      local texture = textures.mole
      table.insert(
	 entities,
	 {
	    x = math.random(0, lg.getWidth() - texture:getWidth() * entity_scale),
	    y = math.random(0, lg.getHeight() - texture:getHeight() * entity_scale),
	    texture = texture,
	 }
      )
   end
end

function love.draw()
   for i, e in ipairs(entities) do
      lg.rectangle(
	 'line',
	 e.x + bouding_box.mole.x,
	 e.y + bouding_box.mole.y,
	 bouding_box.mole.w,
	 bouding_box.mole.h
      )
      lg.draw(e.texture, e.x, e.y, 0, entity_scale, entity_scale)
   end

   local s = 8
   local w = textures.hammer:getWidth() * s
   local h = textures.hammer:getHeight() * s
   if false then lg.draw(textures.hammer, player.x - w / 2, player.y - h / 2, 0, s, s) end
end

function love.mousemoved(x, y)
   player.x = x
   player.y = y
end

function love.mousepressed(x, y)
   local to_remove = list()

   for i, e in ipairs(entities) do
      ex = e.x + bouding_box.mole.x
      ey = e.y + bouding_box.mole.y
      ew = ex + bouding_box.mole.w
      eh = ey + bouding_box.mole.h

      print(x, ex, ex)
      print(y, ey, ey)

      if x < ex or x > ew then
	 goto next
      end

      if y < ey or y > eh then
	 goto next
      end

      table.insert(to_remove, i)

      ::next::
   end

   for i, v in ipairs(to_remove) do
      table.remove(entities, v)
   end
end
