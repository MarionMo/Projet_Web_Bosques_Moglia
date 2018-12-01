pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--init call 1 time at launch
function _init()
	delay=time()
	timer=0
	offset=0
	scrolling=true
	cinematique=false
	cooldown_degat =0
	cooldown_tir=0
	cooldown_recharger = false
	--
	spells={}
	--levels
	level1 = false
	lvl1_success = false
	monstres={}
	
	--
 music(1)
	palt(14, true)
	--sprites
	p = make_actor(16,16,0)
	p.viseur = 1 -- 1 pour droite, -1 pour gauche. direction de visée des sorts
	c1= p.x-16
	peeves={x=112,y=104,sprite=7, f=7, st= 7, sz=2, spd=1/5}
	nuage={x=88,y=24,sprite=101, f=192, st=192, sz=3, spd=1/25}
 	torche1={x=32,y=104,sprite=101, f=101, st=101,sz=4, spd=1/5}
 	torche2={x=96,y=104,sprite=101, f=101, st=101,sz=4, spd=1/5}
	torche3={x=336,y=72,sprite=145, f=145, st=145,sz=4, spd=1/5}
 	torche4={x=384,y=72,sprite=145, f=145, st=145,sz=4, spd=1/5}
	
	-- monstres
	peeves_head={}
	peeves_head.x = 408
	peeves_head.y = 104
	peeves_head.sprite = 9
	peeves_head.anim="flotte"
	peeves_head.walk={f=9, st=9, sz=2, spd=1/10}
	peeves_head.tag = 2 --monstre
	peeves_head.dx = 0
	peeves_head.dy = 0
	peeves_head.box = {x1=1,y1=1,x2=6,y2=6}
	-- niveau du jeu ou se trouve
	-- le monstre
	peeves_head.location = 1
	peeves_head.degat = 1
	peeves_head.hp = 2
	peeves_head.cd_depla = 20
	peeves_head.cd_current = 0
	add(monstres, peeves_head)
	
	p.tag = 1
	-- pour les colisions entre mob
	-- et joueur
	-- tag joueur =>1
	-- tag monstre => 2
	-- tag projectile => 1
	
	solid=false
end

function draw_monsters_lvl1()
	for m in all(monstres) do
		spr(anim(m.walk), m.x, m.y)
	end
	if(#monstres == 0) lvl1_success = true
end
-- debug
function debug()
	--if(p.x == 24) mset(0,0,nil)
	--print(is_grounded(), 0, 0, 7)
	--print(is_plafoned(), 0, 6, 7)
	--print(is_midplafoned(), 0,12,8)
	--print("tile  x ".. ((p.x - (p.x % 8))/8), ((p.x - (p.x % 8))/8), 12, 7)
	--print("tile y ".. ((p.y - (p.y %8))/8), ((p.x - (p.x % 8))/8), 18, 7)
	--hud(p.x-8,p.y-9)
	if(p.x == 79) then
		offset=1.5
		delay = time() + 5
		music(-1,200)
		sfx(0)
	end
	if(p.x == 80) then
		cinematique=true
 		print("ha!ha!", 88,88,11)
	 	spr(anim(peeves), peeves.x, peeves.y)
	end
	
	if(p.x >= 303) then
		print("-- chapitre 1 --", 264,14, 7)                 
		print("-- les douves --", 264,24, 7)	
		--print(lvl1_success, 264, 34, 8)
 
 		spr(anim(torche3), torche3.x, torche3.y)
	 	spr(anim(torche4), torche4.x, torche4.y)
	 	
 	
		draw_monsters_lvl1();
		move_monsters();
		colisions() --gestion des colisions avec les monstres
		
	
		--passage unique, "démarrage du level"
		if(level1 == false) then
			level1 = true
			--on remet le flag solid au bloc pont en bois
			fset(97,0, true)
			music(2)
		end
		-- TODO WIP
		if(lvl1_success)then
			mset(432, 112, nil)
			mset(432, 104, nil)
			--spr(97, 432, 112)
			--spr(97, 432, 104)
		end
		if(p.x >= 440 and lvl1_success) victory()
	end
	
end

--bug tofix musique joue en boucle la premiere note
function victory()
	if(cinematique == false) cinematique = true
	rectfill(430, 70, 512, 100, 0)
	print("--victoire--", 435, 80, 7)
	print("--fin de la demo--", 435, 90, 7)
	--music(-1, 200)
	--sfx(6)
end
function getrandomnumber() 
	return rnd(20) - 10
end
function move_monsters()
	for m in all(monstres) do
		if(level1 and m.cd_current == 0) then
			r = getrandomnumber()
			if(r > 0 and is_rwalled(m) == false)then
				m.x = r + m.x
			elseif(r < 0  and is_lwalled(m) == false) then
				m.x = r + m.x
			end
			
			m.cd_current = m.cd_depla 
		elseif(level1 and m.cd_current > 0)then
			m.cd_current -=1
		end
	end
end
-- make actors
function make_actor(x,y, sprite)
	local actor = {}
	actor.x = x
	actor.y = y
	actor.hp = 3
	actor.sprite = sprite
	actor.anim="stand"
	actor.stand={f=17,st=17, sz=5, spd=1/4}
	actor.walk={f=0,st=0, sz=2,spd=1/5}
	--direction
	actor.dx = 0
	actor.dy = 0
	actor.tag = 1
	--boite de colision du perso
	actor.box = {x1=1, y1=1, x2=7, y2=7}
	add(actors, actor)
	return actor
	
end




function anim_actor()
	if(p.anim == "walk") then
		return anim(p.walk)
	end
	if(p.anim == "stand") then
		return anim(p.stand)
	end
	
end
-- draw actor
function draw_actors()
	for a in all(actors) do
		-- lorsque l'acteur a dessiner est un joueur
		if(a.tag ==1) then
			spr(anim_actor(), a.x, a.y)
		end
		-- lorsque l'acteur a dessiner est un sortilege
		if(a.tag == 3) then
			spr(anim(a.spell), a.x, a.y)
			-- tout le bazar des if c'est pour éviter que les sorts changent de direction
			-- une fois qu'ils sont tiré
			if(p.direction > 0 )then
				if(a.shoted == "left")then
					a.x -= 2
					if(a.x > p.x +50) del(actors,a)
				end
				if(a.shoted == "right")then
					a.x += 2
					if(a.x < p.x -50) del(actors,a)	
				end
				if(a.shoted == nil) then 
					a.shoted = "right"
					a.x += 2
				end	
			end
			if(p.direction < 0 )then
			 	if(a.shoted == "left")then
					a.x -= 2
					if(a.x > p.x +50) del(actors,a)
				end
				if(a.shoted == "right")then
					a.x += 2
					if(a.x < p.x -50) del(actors,a)	
				end
				if(a.shoted == nil) then 
					a.shoted = "left"
					a.x -= 2
				end	
			end
		end
		

	end
end
actors={}

--anim
function anim(a)
	a.f += a.spd
	if(a.f >= a.st + a.sz)then
		a.f = a.st
	end
	return flr(a.f)
end

--draw
function _draw()
	cls()
	mset(432,112,97)

	draw_background()
	spr(anim(nuage), nuage.x, nuage.y)
	spr(anim(torche1), torche1.x, torche1.y)
	spr(anim(torche2), torche2.x, torche2.y)
 
	if(is_grounded()) then
		p.y = flr(flr(p.y)/8)*8
	end
	
	debug()
	draw_actors()
	if(btnp(4) and cooldown_recharger == false)then
		shoot()
	end
	
end
--update
function _update()
	
	--cooldown degats hero
	if(cooldown ==true and cooldown_degat >0) then
	 cooldown_degat -=1
	end
	if cooldown and cooldown_degat ==0 then
		cooldown = false
	end

	--cooldown tir
	if(cooldown_recharger == true and cooldown_tir >0)then
		cooldown_tir -=1
	end
	if(cooldown_recharger and cooldown_tir == 0) then
		cooldown_recharger = false
	end
	

	if(p.x == 80) screen_shake(0.95)
	p.anim = "stand"
 	local tile = fget(mget(tilex, tiley),0)
	p.dx = 0
	--gauche
	if(btn(0) and is_lwalled(p) == false and cinematique==false) then
		p.direction = -1
		p.dx -=1
	end
	if(btn(1) and is_rwalled(p) == false and cinematique==false) then
	 	p.direction = 1
	 	p.dx +=1
	end
	p.x += p.dx
	if(is_grounded()) then
		p.dy = 0 --gravite
		-- if jump press 1 time
		if(btnp(2) and cinematique==false) then
			if(is_plafoned())then
				-- rien
		 	elseif(is_midplafoned()) then
				-- en cas de plafond 
				-- on saute moins haut
				p.dy = -4
		 	else
		 		p.dy = -5.8
		 	end 
		end
	else
		p.dy += 0.98 --gravite
		if(p.dy > 4) p.dy = 4
	end
	p.y += p.dy
	if((btn(0) or btn(1) or btn(2)) and cinematique==false) then
		p.anim = "walk"
		
		if(p.x-64<0 and 0 or p.x-64) then
			camera(p.x-64<0 and 0 or p.x-64, 0)
			
		end
	end
end

function get_box(a)
	local box = {}
	box.x1 = a.x + a.box.x1
	box.y1 = a.y + a.box.y1
	
	box.x2 = a.x + a.box.x2
	box.y2 = a.y + a.box.y2
	return box
end

function check_coll(a,b)
	if(a==b or a.tag == b.tag) return false --no colide
	local box_a = get_box(a)
	local box_b = get_box(b)
	if(box_a.x1 > box_b.x2 or
				box_a.y1 > box_b.y2 or
				box_b.x1 > box_a.x2 or
				box_b.y1 > box_a.y2) then
		return false
	end
	return true
end

function	colisions()
	for a in all(actors) do
		for b in all(monstres) do
			if(a.tag == 3 and check_coll(a,b) == true) then 
				b.hp -= 1
				if(b.hp >0) then 
					sfx(3)
					del(actors,a)
					return true
				end
				if(b.hp == 0) then
					sfx(5)
					del(monstres,b)
					del(actors,a)
					return true
				end
			end
			if(a.tag == 1 and check_coll(a,b) == true) then
				if(cooldown_degat == 0) then
					degat(b.degat)
				end
				return true
			end
		end
	end
end

function is_grounded()
	
	-- on get le bloc sous le joueur
		-- +4 pour get le centre du joueur
		bloc = mget(flr(p.x+4)/8, flr(p.y)/8+1)
		--get le flag du bloc
		-- 0 =>1er flag
		return fget(bloc, 0) 
end

-- check si un bloc solide
-- se trouve 2 blocs au dessus
-- du joueur
function is_midplafoned()
	-- on get le bloc sous le joueur
		-- +4 pour get le centre du joueur
		bloc = mget(flr(p.x+4)/8, (flr(p.y)/8)-1.5)
		--get le flag du bloc
		-- 0 =>1er flag
		return fget(bloc, 0) 
end

-- check si un bloc solide 
-- se trouve 1 bloc au dessus
-- du joueur
function is_plafoned()
	-- on get le bloc sous le joueur
		-- +4 pour get le centre du joueur
		bloc = mget(flr(p.x+4)/8, (flr(p.y)/8)-1)
		--get le flag du bloc
		-- 0 =>1er flag
		return fget(bloc, 0) 
end

function is_lwalled(a)
	bloc_gauche = mget(flr(a.x+6)/8-1, (flr(a.y)/8))
	
	return fget(bloc_gauche,0)
end

function is_rwalled(a)
	bloc_droit = mget(flr(a.x)/8+1, (flr(a.y)/8))
 return fget(bloc_droit,0)
end





-- collide check
function solid_tile(x, y)
--local mean dont exist outside
	local tilex = ((x - (x % 8)) /8)
	local tiley = ((y - (y % 8)) /8)
	
	-- identifier what tile is
	if(fget(mget(tilex, tiley),0)) then
		--if true, le tile a flag solid
		return true
	else
		return false
	end
	
end

-- background drawing
function draw_background()
	--rectfill(0,0,128,128, 1)
	map(0,0,0,0,64,64)
end

-- screen shake
function screen_shake(n)
  local fade = n
  local offset_x=16-rnd(32)
  local offset_y=16-rnd(32)
  offset_x*=offset
  offset_y*=offset
  
  camera(offset_x,offset_y)
  offset*=fade
  if offset<0.05 then
    offset=0
    
    fset(97,0,false)
 	timer = time()
 	if(timer > delay)then 
    	--fade_scr(1)
     	if(time() > delay + 3) then
  	   		--coordonne lvl 1
 	    	p.x = 304
	     	p.y = 112
	     	camera(p.x-64<0 and 0 or p.x-64, 0)
  	   		--fade_scr(0)
			cinematique = false
			draw_background()
  	   		return
     	end
		 
 	end
	
  end
end

-- "fa" is a number ranging from 0 to 1
-- 1 = 100% faded out
-- 0 = 0% faded out
-- 0.5 = 50% faded out, etc.

function fade_scr(fa)
	fa=max(min(1,fa),0)
	local fn=8
	local pn=15
	local fc=1/fn
	local fi=flr(fa/fc)+1
	local fades={
		{1,1,1,1,0,0,0,0},
		{2,2,2,1,1,0,0,0},
		{3,3,4,5,2,1,1,0},
		{4,4,2,2,1,1,1,0},
		{5,5,2,2,1,1,1,0},
		{6,6,13,5,2,1,1,0},
		{7,7,6,13,5,2,1,0},
		{8,8,9,4,5,2,1,0},
		{9,9,4,5,2,1,1,0},
		{10,15,9,4,5,2,1,0},
		{11,11,3,4,5,2,1,0},
		{12,12,13,5,5,2,1,0},
		{13,13,5,5,2,1,1,0},
		{14,9,9,4,5,2,1,0},
		{15,14,9,4,5,2,1,0}
	}
	
	for n=1,pn do
		pal(n,fades[n][fi],0)
	end
end

function wait(a) for i = 1,a do flip() end end	

-- hud
function hud(x,y)
	hp_bar(p.hp, x,y, 1,1)
end

-- hp_bar
function hp_bar(hp,x,y,w,h)
		if(hp == 1) then
			
		 spr(195, x,y,w,h)
		 spr(196, x+9,y,w,h)
		 spr(196, x+18,y,w,h)
		end
		if(hp == 2) then
		 spr(195, x,y,w,h)
		 spr(195, x+9,y,w,h)
		 spr(196, x+18,y,w,h)
		end
		if(hp == 3) then
		 --rectfill(x+p.x,y,25,6,0)
		 spr(195, x,y,w,h)
		 spr(195, x+9,y,w,h)
		 spr(195, x+18,y,w,h)
		end
	
end

function degat(n)
	p.hp -= n
	sfx(3)
	----on decremente cette variable dans update de 1, 
	--comme elle est appelée 30fois par seconde, ça fait 2s pour pouvoir reprendre des degats
	cooldown_degat = 60 
	cooldown = true
end

function shoot()

	bullet = make_actor(p.x, p.y, 197)
	
	bullet.anim = "spell"
	bullet.spell = {f=197,st=197,sz=1,spd=0}
	bullet.tag = 3
	-- 3 pour les sorts
	bullet.tag = 3
	--colisions
	bullet.box = {x1=2,y1=3,x2=6,y2=5}
	cooldown_tir = 8 --0.5s/tir
	cooldown_recharger = true
	sfx(4)
	
end


__gfx__
00ffff0000000000000000001111111100000000000000004111222200bbb000000000000bbbbbb0000000000000000000000000000000000000000000000000
0f7777f000ffff0000000000111111110000000000000000411222210626bb0000bbb0000b6666b00bbbbbb00000000000000000000000000000000000000000
f757757f0f7777f0000000001111111100000000000000004122222106666b000626bb00066666600b6666b00000000000000000000000000000000000000000
f756657ff757757f0000000011111111000000000000000041fcfff105666b0005666b0006266260066666600000000000000000000000000000000000000000
f779977ff756657f0000000011111111000000000000000041fffff10066660000666b0006666660062662600000000000000000000000000000000000000000
fffffffff779977f0000000011111111000000000000000047788881066660000666660006655660066666600000000000000000000000000000000000000000
4fb33bf4ffb33bff0000000011111111000000000000000017788881060660000606600000666600066556600000000000000000000000000000000000000000
44666644446666440000000011111111000000000000000077888881000066600000666000000000006666000000000000000000000000000000000000000000
0bbbbbb000ffff0000ffff0000ffff0000ffff0000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b6666b00f7777f00f7777f00f7777f00f7777f00f7777f000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660f757757ff777777ff777777ff777777ff757757f00000000000000000000000000000000000000000000000000000000000000000000000000000000
06266260f756657ff756657ff776677ff756657ff756657f00000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660f779977ff779977ff779977ff779977ff779977f00000000000000000000000000000000000000000000000000000000000000000000000000000000
06655660ffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000
006666004fb33bf44fb33bf44fb33bf44fb33bf44fb33bf400000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000446666444466664444666644446666444466664400000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ffff0000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000fff77700fff777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffff7576ffff757600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffff7779ffff777900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffff7779ffff777900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffb3ffffffb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000fffff600fffff6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000044000444400044000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333344444444cccccccc00000000ccc777cc55555555cccccccc5ccccccc5ccccc55ccc33ccccc3443ccccc443cc55533555553443555554435500000000
3333333344444444cccccccc00077700ccc7677c55555555ccccccc555cccccc55ccc555cc3333ccc334433ccc34433c55333355533443355534433500000000
4444444444444444cccccccc00777700cc77667755555555cccccc55555ccccc555c5555cc33333c33c44c33c334433355333335335445335334433300000000
4444444444444444cccccccc07777770c776666755555555ccccc5555555cccc55555555c334433ccc3443cc33344c3353344335553443553334453300000000
4444444444444444cccccccc77777777c766556755555555cccc55555555cccc55555555c334433ccc34433c33c44ccc53344335553443353354455500000000
4444444444444444cccccccc000777707665556655555555ccc5555555555ccc55555555c334433cc3344c33ccc44ccc53344335533445335554455500000000
4444444444444444cccccccc000000006555555655555555cc5555555555555c55555555c334433c333443ccccc44ccc53344335333443555554455500000000
4444444444444444cccccccc000000005555555555555555c55555555555555555555555c334433c33344333ccc44ccc53344335333443335554455500000000
06666667117667111111011110000000101101011111111111111111cccccccc5555556655556665000000000000000000000000000000000000000000000000
05555556177777711110011110000001000000001111111111111111cccccccc5665555666655555000000000000000000000000000000000000000000000000
05555556776776671110011100000000000000001111111111111111cccccccc5665555555555665000000000000000000000000000000000000000000000000
05555556766766671100001101000000000000001111111111111111cccccccc5555555566655565000000000000000000000000000000000000000000000000
05555556777766671100000110000011000000001111111111111111cccccccc5555665555555566000000000000000000000000000000000000000000000000
05555556667776671100000000100001000000001111111111111111cccccccc5555665566555666000000000000000000000000000000000000000000000000
05555556176667711000000011000000000000001111111117111111cccccccc6555555666656656000000000000000000000000000000000000000000000000
00000005117777111000000010000000000000001111111111111111cccccccc6655556655565555000000000000000000000000000000000000000000000000
000000000999999a000440000000000000044000eeee8eeeeeeee8eeeeee8eeeeee8eeee00000000000000000000000000000000000000000000000000000000
0000000004444449000449000000000000944000eee898eeeeee898eeee898eeee898eee00000000000000000000000000000000000000000000000000000000
0000000004444449000440999999999999044000ee89998eeee8998eee89998eee8998ee00000000000000000000000000000000000000000000000000000000
0000000004444449000440000900090000044000ee89a98eeee89a8eee89a98eee8a98ee00000000000000000000000000000000000000000000000000000000
0000000004444449000440000900090000044000eee999eeeee899eeeee999eeeee998ee00000000000000000000000000000000000000000000000000000000
0000000004444449000440000900090000044000eee544eeeee544eeeee544eeeee544ee00000000000000000000000000000000000000000000000000000000
0000000004444449000440000900090000044000eee54eeeeee54eeeeee54eeeeee54eee00000000000000000000000000000000000000000000000000000000
0000000000000000000440000900090000044000eee44eeeeee44eeeeee44eeeeee44eee00000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00080000000080000008000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00898000000898000089800008980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08999800008998000899980008998000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
089a98000089a800089a980008a98000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999000008990000099900000998000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00544000005440000054400000544000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00540000005400000054000000540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00440000004400000044000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99919999955815559555855595581555958515550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55515559558985555558985555898555589815550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55515559589998555589985558999855589985550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111189a98111189a811189a981118a981110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15555559169996551689965516999655169986550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15555559165446551654465516544655165446550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
15555559165466551654665516546655165466550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111114411111144111111441111114411110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000e00e00eee00e00ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000600000000880880e0550550e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000060000000000000000888870e0555550e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000060000000000000000888880e0555550e0033370000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006000000000000000e08880eee05550ee0033330000000000000000000000000000000000000000000000000000000000000000000000000000000000
600000000000000000000000ee080eeeee050eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
660000000000000000000000eee0eeeeeee0eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
600000000000000000000000eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000010000000000000001000000000000000001000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0355555555555555555555555655555000005050505050000000000000000000000000000000000000000000000000000000000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555655555555555556555555555000005050505050000000000000000000000000000000000000000000000000000000000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5556555555515556555555555555555000005050505050000000000000000000000000000000000000000000000000000000000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555555555555655555555555000005050505050000000000000000000000000000000000000000000000000000000000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555655565555565555065555555000005050505050000000000000000000000000000000000000000000000000000000000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5655555555555555555555505555555000005050505050000000000000000000000000000000000000000000000000000000000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5555555555555555555555555050505000005050505050000000000000000000000000000000000000000000000000000000000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5252525252525252525252525250505000005050505050000000000000000000000000000000000000000000000000000000000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5353535353535353535353535353535000005050505050000000000000000000000000000000600000909090000000909090600000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d060606060606060606060606060605000005050505050000000000000000000000000000000606060909090606060909090600000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0606060606060606060606060606050000050505050500000000000000000000000000000d0606060909090606060909090000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0606060606060606060606060606050000050505050500000000000000000000000000000d0606060606060606060600000000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0202060606060606060606060606060000050505050500000000000000000000000000000d0606060606060606060600000000000005858585858585858000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0602060606060606060606060606060600050505050500000000000000000000000000000d0606060606060606060600000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d0600260626363636363636364606060000050505050500000000000000000000000000000d0606060606060606060600000000000002000002020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505061616161616161616150505050505050505050575757575757575757575757575757585858585858585858585858585858585850505050505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6060606000000000000060600000006000000000000000000000000000000000000000000000595900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000606000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000d00001705018050190501e0501d050190501805000000000001805000000000001805000000000001805000000000000000000000000000000000000000000000000000000000000000000000000000000000
001d001f170501c0501c0501f0501e0501e0501c0501c0501c0502305023050210502105021050210501e0501e0501e0501e0501c0501c0501c0501f0501e0501e0501a0501a0501a0501e0501e0501705017000
0010000006100061000615006150061500615006150061500615000000000000a15009150081500715007150071500715006150061500615006150061500615000000000001210013150101500f1500f1500f150
0002000024150211501f150150501b150171500b050131500f1500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003535033350313502e3502a35027350213501f3501b35017350133500f3500c3500a350083500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000800000440037750297501b75011750097500375001750000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000234502345021450214501f4501f4501d450244502a4502d4502d450000000000001000010000100001000010000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001255000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 00424344
03 01424344
03 02434344
00 03424344
00 04424344
00 05424344
00 06424344
