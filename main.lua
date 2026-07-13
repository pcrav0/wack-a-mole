-- Whac-A-Mole

require('utils')

lg = love.graphics

HAMMER_MOUSE = true

local function image_load(path)
	local result = lg.newImage(path)
	result:setFilter('linear', 'nearest')
	return result
end

function table:choose()
	return self[math.random(1, #self)]
end

function love.load()
	if HAMMER_MOUSE then
		love.mouse.setVisible(false)
	end

	entity_scale = 16

	local function texture_box(kind, offsets)
		local texture = image_load(kind .. '.png')

		return {
			kind = kind,
			texture = texture,
			x = entity_scale * offsets.x * texture:getWidth(),
			y = entity_scale * offsets.y * texture:getHeight(),
			w = entity_scale * offsets.w * texture:getWidth(),
			h = entity_scale * offsets.h * texture:getHeight(),
		}
	end

	hammer = image_load('hammer.png')
	_items = list{
		texture_box('mole', { x = 0.1, y = 0.2, w = 0.8, h = 0.8, }),
		texture_box('bomb', { x = 0.1, y = 0.2, w = 0.8, h = 0.7, }),
	}
	time = 0
	spawn_timer = 0
	player = { x = 0, y = 0 }
	entities = list{}
	hp = 3
end

function love.update(dt)
	time = time + dt
	spawn_timer = spawn_timer + dt

	if hp == 0 then
		return
	end

	for i = #entities, 1, -1 do
		local it = entities[i]

		switch(it.entity.kind) {
			['bomb'] = function()
				elapsed_time = time - it.time
				if elapsed_time < 3 then
					return
				end

				hp = hp - 1
				table.remove(entities, i)
			end,
			['mole'] = function() end,
		}
	end


	if spawn_timer > 1 and math.random() < 0.1 then
		local item = table.choose(_items)
		if #entities == 5 then
			return
		end
		spawn_timer = 0

		local texture = item.texture
		table.insert(
			entities,
			{
				time = time,
				x = math.random(0, lg.getWidth() - texture:getWidth() * entity_scale),
				y = math.random(0, lg.getHeight() - texture:getHeight() * entity_scale),
				entity = item,
			}
		)
	end
end

function love.draw()
	if hp == 0 then
		lg.print('end', 0, 0)
		return
	end

	lg.print(hp, 0, 0)

	for i, e in ipairs(entities) do
		lg.rectangle(
			'line',
			e.x + e.entity.x,
			e.y + e.entity.y,
			e.entity.w,
			e.entity.h
		)

		lg.draw(e.entity.texture, e.x, e.y, 0, entity_scale, entity_scale)
	end

	if HAMMER_MOUSE then
		local s = 8
		local w = hammer:getWidth() * s
		local h = hammer:getHeight() * s
		lg.draw(hammer, player.x - w / 2, player.y - h / 2, 0, s, s)
	end
end

function love.mousemoved(x, y)
	player.x = x
	player.y = y
end

function love.mousepressed(x, y)
	local to_remove = list()

	for i = #entities, 1, -1 do
		local it = entities[i]

		do -- check if you clicked inside the entity "it"
			local ex = it.x + it.entity.x
			local ey = it.y + it.entity.y
			local ew = ex   + it.entity.w
			local eh = ey   + it.entity.h

			if x < ex or x > ew or y < ey or y > eh then
				goto next
			end
		end

		switch(it.entity.kind) {
			['mole'] = function()
				print('clicked in the mole')
			end,
			['bomb'] = function()
				print('clicked in the bomb')
			end,
		}

		table.remove(entities, i)

		--[[
			if 2 or more entities are in the same place then
			all the entities are delete with the same click
			to prevent this just return
		]]
		do return end

		::next::
	end
end
