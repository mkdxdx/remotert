require("remotert")

local lg = love.graphics
tex = lg.newImage("figs.png")

function love.load()
	-- create some quads
	local tw,th = tex:getWidth(),tex:getHeight()
	rrt = RemoteRT:new(128,128)
	tile1 = lg.newQuad(0,0,64,64,tw,th)
	tile2 = lg.newQuad(64,0,64,64,tw,th)
	
	figures = {	lg.newQuad(128,0,64,64,tw,th),
				lg.newQuad(192,0,64,64,tw,th),
				lg.newQuad(256,0,64,64,tw,th),
				lg.newQuad(320,0,64,64,tw,th) }
				
	lamp = lg.newQuad(384,0,64,64,tw,th)
	block = lg.newQuad(448,0,64,64,tw,th)
	
	scene_batch = lg.newSpriteBatch(tex,1000)
	
	

	
	local fieldx,fieldy = 8,8
	-- create chess field
	local t = 1
	for y=1,fieldy do
		for x=1,fieldx do
			local qx,qy,qw,qh = tile1:getViewport()
			if x%2 ~= y%2 then
				scene_batch:add(tile1,qw*(x),qh*(y))
			else
				scene_batch:add(tile2,qw*(x),qh*(y))
			end
		end
	end
	
	-- add some figures
	for i=1,6 do
		local qx,qy,qw,qh = tile1:getViewport()
		local x,y = math.random(1,fieldx)*qw,math.random(1,fieldy)*qh
		local fig = math.random(1,4)
		if i==4 then
			-- color-code shadow's elevation
			scene_batch:setColor(128,255,255,255)
		else
			scene_batch:setColor(255,255,255,255)
		end
		scene_batch:add(figures[fig],x,y)
	end
	
	mainc = lg.newCanvas(lg:getWidth(),lg:getHeight())
	c2 = lg.newCanvas(128,128)
	
	node = rrt:addNode(0,0,256,256)
	node:setColor(255,255,255,64)
	
end

function love.draw()
	lg.setCanvas(mainc)
	lg.clear()
	lg.draw(scene_batch)
	lg.setCanvas()
	
	
	--[[
	lg.setCanvas(mainc)
	lg.draw(scene_batch)
	lg.setCanvas()
	lg.draw(mainc)
	]]--
	
	
	local f_render = function()
		lg.draw(scene_batch)
	end
	rrt:render(mainc,f_render)
	
end


function love.mousemoved(x,y)
	node:setTarget(x,y)
end