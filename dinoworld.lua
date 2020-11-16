-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua

function TIC()
 if not(rst) then getInput() end
	prcAmbs()
	prcDino()
	prcCam()
	cls(10)
	drawMap()
	drawDino()
	
	--print("walk: "..tostring(dino.walk),10,10,3)
	--print("jump: "..tostring(dino.jump),10,20,3)
	--print("on ground: "..tostring(onGround()),10,30,3)
 --print("cam x,y: "..cam.x..','..cam.y,10,10,3)
		
 gametics=gametics+1
end

function onGround()
 local y=dino.y+8*dino.s.h  -- bottom y
 local x1=dino.x  -- left x
 local x2=dino.x+8*(dino.s.w-1)-1  -- middle x
 local x3=dino.x+8*dino.s.w-1  -- right x
	local s1,s2,s3,s4,s5,s6=false,false,false,false,false,false
	s1=isSolid(x1,y)
	s2=isSolid(x2,y)
	s3=isSolid(x3,y)
	s4=isJumpThrough(x1,y)
	s5=isJumpThrough(x2,y)
	s6=isJumpThrough(x3,y)
	if s1 or s2 or s3 or s4 or s5 or s6 then return true end
 return false
end

function isSolid(x,y)
 local s=mget(x//8,y//8)
	for i,v in ipairs(solids) do
	 if v==s then return true end
	end
	return false
end

function isWater(x,y)
 local s=mget(x//8,y//8)
	for i,v in ipairs(water) do
	 if v==s then return true end
	end
	return false
end

function isJumpThrough(x,y)
 local s=mget(x//8,y//8)
	for i,v in ipairs(jumpthrough) do
	 if v==s then return true end
	end
	return false
end

function getInput()
	dino.walk=false		
 if key(60) then  -- left
 	local nx=dino.x-dino.xvel
	 local ny=dino.y	
	 dino.walk=true
		dino.s.f=1
		if nx>0 and not(isSolid(nx,ny) or isSolid(nx,ny+dino.s.h*8-1)) then
		 dino.x=nx
		end
	elseif key(61) then  -- right
 	local nx=dino.x+dino.xvel
	 local ny=dino.y	
	 dino.walk=true
		dino.s.f=0
		if nx<1904 and not(isSolid(nx+dino.s.w*8-1,ny) or isSolid(nx+dino.s.w*8-1,ny+dino.s.h*8-1)) then
		 dino.x=nx
		end
	end
	if keyp(48) and onGround() then
	 dino.jump=true
		dino.yvel=dino.jumpvel
	end
end

function prcCam()
 cam.x=dino.x-120
	cam.y=dino.y-68
end

function clampCam(x,y)
 local lx,ly=x,y
 if x<0 then
	 lx=0 
	elseif x>1680 then
	 lx=-1680
	else
	 lx=-x
	end
	if y<0 then 
	 ly=0 
	else
	 ly=-y
	end
	return lx,ly
end

function prcAmbs()
	for i,v in ipairs(ambanims) do
	 if gametics%v.tics==0 then
		 v.frm=v.frm+1
			if v.frm>#v.frms then v.frm=1	end
		end
	end
end

function rstDino()
 dino.x=16
	dino.y=60
	rst=false
 wateranim=false
 rstTimer=60
	splashfrm=1
end

function prcDino()
 -- update walking/idle sprite
	local ds=dino.s
 if dino.walk then
	 if gametics%ds.atics==0 then
		 ds.walkfrm=ds.walkfrm+1
			if ds.walkfrm>#ds.walk then
			 ds.walkfrm=1
			end
		end
		ds.curr=ds.walk[ds.walkfrm]
	else
	 ds.curr=ds.idle
	end
	
	-- process player y
	local y=dino.y-dino.yvel+gravity
	--if not(onGround()) then
 if dino.jump then -- jumping 
		ds.curr=ds.jump
	 if dino.yvel>gravity and not(isSolid(dino.x,y) or isSolid(dino.x+dino.s.w*8-1,y)) then
	  dino.y=y
	 else
		 dino.yvel=gravity
	  dino.jump=false
	 end
	else -- falling
  if dino.y>132 then
		 if isWater(dino.x, dino.y) then
			 wateranim=true
			end
			rst=true
	 elseif not(isSolid(dino.x,y+dino.s.h*8-1) or isSolid(dino.x+dino.s.w*8-1,y+dino.s.h*8-1) or isSolid(dino.x+(dino.s.w-1)*8-1,y+dino.s.h*8-1) or isJumpThrough(dino.x,y+dino.s.h*8-1) or isJumpThrough(dino.x+dino.s.w*8-1,y+dino.s.h*8-1) or isJumpThrough(dino.x+(dino.s.w-1)*8-1,y+dino.s.h*8-1)) then
	  ds.curr=ds.fall
	  dino.y=y
		else
		 if not(onGround()) then
			 dino.y=dino.y+1
			end
	 end		 
 end
 if dino.yvel>0 then
	 dino.yvel=dino.yvel-0.1
	else
	 dino.yvel=0  --reset in case
	end
	if rst then
	 if wateranim then
		 
		end
	 rstTimer=rstTimer-1
		if rstTimer==0 then
		 rstDino()
		end
	end
end

function prcNpc()
 for i,v in ipairs(npc[level]) do
	 -- loop through npc list,load that routine
		-- check coords of trigger, and see if player is in it
		-- if the npc is ready to regen then ok!
		--    -- timer has passed
		--    -- only one enemy
	end
end

function drawMap()
 local cx,cy=clampCam(cam.x,cam.y)
 map(0,0,240,17,cx,0,0,1,remap)
end

function remap(s,x,y)
	for i,v in ipairs(ambanims) do
	 if s==v.frms[1] then return v.frms[v.frm] end
	end
 return s
end

function drawDino()
 local px,py=getLocalPos(dino.x,dino.y)
 spr(dino.s.curr,px,dino.y,3,1,dino.s.f,0,dino.s.w,dino.s.h)
	--print("dino.x: "..dino.x,10,20,3)
	--print("px: "..px,10,30,3)
end

function getLocalPos(x,y)
 local lx=x-cam.x
	local ly=y-cam.y
	if x<120 then 
	 lx=x
	elseif x>1800 then
	 lx=240-(1920-x)
	end
	--if y<68 then ly=y end
 return lx,ly 
end

function _data()end

gametics=0
gravity=2
level=1
rst=false
wateranim=false
rstTimer=60
wateranimtimer=20
splashfrm=1

solids={1,2,3,4,5,6,7,8,10,17,18,19,20,21,22,23,24,25}
jumpthrough={131,132,133,179}
water={80,81}
splash={82,83,80}

cam={
 x=0,
	y=0
}
 
dino={
 s={
	 curr=0,
	 idle=257,
	 walk={259,261},
	 jump=263,
	 fall=265,
	 w=2,
	 h=2,
		walkfrm=1,
		atics=20,
		f=0,
	},
 walk=false,
	jump=false,
	fall=false,
 x=16,
	y=60,
	xvel=1,
	yvel=0,
	jumpvel=5
}

ambanims={
 {frm=1,frms={80,81},tics=120}
}


n={}
-- x,y,xspd,yspd   always + the speed, -spd to move left/up
-- atics,frame,spr list, 
-- spawn x/y,spawn tics,spawn distance vars  


npc={
 {
	 {
	  name="pteradon",
		 s={288,290,292,290},
		 atics=10,
		 xvel=-1,
		}
	}
}