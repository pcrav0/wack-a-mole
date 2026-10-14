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
	math.randomseed(os.time())

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
	grass = image_load('grass.png')
	_items = list{
		texture_box('mole', { x = 0.1, y = 0.2, w = 0.8, h = 0.8, }),
		texture_box('bomb', { x = 0.1, y = 0.2, w = 0.8, h = 0.7, }),
	}
	time = 0
	spawn_timer = 0
	player = { x = 0, y = 0 }
	entities = list{}
	hp = 3
	win = false
	entity_max = 5
	rotation_ns = table.map(range(16), function() return math.random(0, 3) end)
	rotation_table = table.map(range(0, 3), function(v) return v * math.pi end)
end

function love.update(dt)
	-- check for win condition
	if #entities == entity_max then
		has_won = true
		for i, e in ipairs(entities) do
			if e.entity.kind ~= 'mole' then
				has_won = false
				break
			end
		end
		if has_won then
			win = true
		end
	end

	if win then
		return
	end

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
		if #entities == entity_max then
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
	do
		a = entity_scale * 8

		for i = 0, math.floor(lg.getWidth() / a) do
			x = i * entity_scale * 8
			for j = 0, math.floor(lg.getHeight() / a) do
				y = j * entity_scale * 8
				local rotation_n = rotation_ns[(i + j) % #rotation_ns + 1]
				local rotation = rotation_table[(rotation_n + i + j) % #rotation_table + 1]
				lg.draw(grass, x, y + a / 2, rotation, entity_scale, entity_scale, grass:getWidth() / 2, grass:getHeight() / 2)
			end
		end
	end

	if win then
		lg.print('win', 0, 0)
		return
	end

	if hp == 0 then
		lg.print('end', 0, 0)
		return
	end

	lg.print(hp, 0, 0)

	for i, e in ipairs(entities) do
		if false then
			lg.rectangle(
				'line',
				e.x + e.entity.x,
				e.y + e.entity.y,
				e.entity.w,
				e.entity.h
			)
		end

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
