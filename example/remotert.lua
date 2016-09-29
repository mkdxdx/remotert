--[[
	Remote rendertarget helper for love2d
	by mkdx/cval
	
	license: you may use, redistribute or change 
	the software as you want except claiming as your own

]]--

local l_gfx = love.graphics


local RRTNode = {}
RRTNode.__index = RRTNode
function RRTNode:new(tx,ty,x,y,sx,sy)
	local self = setmetatable({},RRTNode)
	-- position
	self[1] = x or 0
	self[2] = y or 0
	-- enabled
	self[3] = true
	-- scale
	self[4] = sx or 1
	self[5] = sy or 1
	-- target position
	self[6] = tx or 0
	self[7] = ty or 0
	
	-- rt color 
	self[8] = 255
	self[9] = 255
	self[10]= 255
	self[11]= 255
	return self
end

function RRTNode:setTarget(tx,ty) self[6],self[7] = tx,ty end
function RRTNode:getTarget() return self[6],self[7] end

function RRTNode:setPosition(x,y) self[1],self[2] = x,y end
function RRTNode:getPosition() return self[1],self[2] end

function RRTNode:setScale(sx,sy) self[4],self[5] = sx,sy end
function RRTNode:getScale() return self[4],self[5] end

function RRTNode:setEnable(e) self[3] = e end
function RRTNode:getEnable() return self[3] end

function RRTNode:setColor(r,g,b,a) self[8],self[9],self[10],self[11] = r or self[8],g or self[9],b or self[10],a or self[11] end
function RRTNode:getColor() return self[8],self[9],self[10],self[11] end 

RemoteRT = {}
RemoteRT.__index = RemoteRT
RemoteRT.viewport = {0,0, 1,1, 0,0}
RemoteRT.renderImmediate = true
function RemoteRT:new(fbo_sz,fbo_mode)
	local self = setmetatable({},RemoteRT)
	self.fbo_sz = fbo_sz or 128
	self.fbo_mode = fbo_mode
	if self.fbo_mode == true then
		self.fbo = {}
	else
		self.fbo = l_gfx.newCanvas(self.fbo_sz,self.fbo_sz)
	end
	self.nodes = {}
	return self
end

function RemoteRT:setViewport(x,y,sx,sy,shx,shy)
	self.viewport[1] = x or self.viewport[1]
	self.viewport[2] = y or self.viewport[2]
	self.viewport[3] = sx or self.viewport[3]
	self.viewport[4] = sy or self.viewport[4]
	self.viewport[5] = (shx or self.viewport[5])*0 -- lightsource coordinates shearing is not implemented yet!
	self.viewport[6] = (shy or self.viewport[6])*0
end

function RemoteRT:addNode(tx,ty,x,y,sx,sy)
	local n = RRTNode:new(tx,ty,x,y,sx,sy)
	self.nodes[#self.nodes+1] = n
	return n
end

function RemoteRT:setRenderImmediate(ri)
	self.renderImmediate = ri
end

function RemoteRT:getRenderImmediate() return self.renderImmediate end

-- semifinal canvas, scene render function
function RemoteRT:render(main_canvas,f_render)
	l_gfx.push("all")
	l_gfx.setCanvas(main_canvas)
	
	local fbo_sz = self.fbo_sz
	local fbo_szh = fbo_sz*0.5
	local buf_fbo = self.fbo
	
	local vpx,vpy,vpsx,vpsy = self.viewport[1],self.viewport[2],self.viewport[3],self.viewport[4]
	
	
	local nodelist = self.nodes
	local nodecount = #nodelist
	if nodecount>0 then
		for i=1,nodecount do
			local n = nodelist[i]
			local rr,rg,rb,ra = n:getColor()
			if (n:getEnable() == true and ra>0) then
				local nx,ny = n:getPosition()
				local nsx,nsy = n:getScale()
				local rsx,rsy = 1/nsx,1/nsy
				local tx,ty = n:getTarget()
				-- save gfx state
				l_gfx.push("all")
				-- render scene to a remote fbo
				l_gfx.setCanvas(buf_fbo)
				l_gfx.clear()
				l_gfx.scale(rsx,rsy)
				l_gfx.translate(-tx+fbo_szh*nsx,-ty+fbo_szh*nsy)
				f_render()
				l_gfx.pop()
				local cr,cg,cb,ca = l_gfx.getColor()
				l_gfx.setColor(rr,rg,rb,ra)
				
				l_gfx.push()
				l_gfx.scale(vpsx,vpsy)
				l_gfx.translate(-vpx,-vpy)
				l_gfx.draw(buf_fbo,nx,ny,0,nsx,nsy,fbo_szh,fbo_szh)
				l_gfx.pop()
				l_gfx.setColor(cr,cg,cb,ca)
			end
		end
	end
	l_gfx.pop()
	if self:getRenderImmediate() == true then
		l_gfx.draw(main_canvas)
	end
end