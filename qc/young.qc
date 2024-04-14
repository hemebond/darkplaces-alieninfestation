
$frame base
$frame stand1
$frame run1 run2 run3 run4 run5 run6 run7 run8
$frame runatt1 runatt2 runatt3 runatt4 runatt5 runatt6 runatt7 runatt8

//============================================================================

void() young_slimedamage =
{
	if (self.watertype == CONTENT_LAVA)
	{
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 0.2;
			T_Damage(self, world, world, 20);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{
		if (self.dmgtime < time)
		{
			self.dmgtime = time + 1;
			T_Damage(self, world, world, 8);
		}
	}
};


void()	Young_JumpTouch;

void()	young_stand1	=[	$stand1,	young_stand1	] {ai_stand();young_slimedamage();};

/*
void()	young_run1	=[	$run1,		young_run2	] {ai_run(-2);young_slimedamage();};
void()	young_run2	=[	$run2,		young_run3	] {ai_face();makevectors(self.angles);self.velocity = v_forward * 400 + '0 0 240';if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;young_slimedamage();};
void()	young_run3	=[	$run3,		young_run4	] {young_slimedamage();};
void()	young_run4	=[	$run4,		young_run5	] {young_slimedamage();};
void()	young_run5	=[	$run5,		young_run6	] {young_slimedamage();};
void()	young_run6	=[	$run6,		young_run7	] {young_slimedamage();};
void()	young_run7	=[	$run7,		young_run8	] {ai_face();young_slimedamage();};
void()	young_run8	=[	$run8,		young_run1	] {ai_face();young_slimedamage();};
*/

void()	young_walk1	=[	$walk1,		young_walk2	] {ai_walk(16);young_slimedamage();};
void()	young_walk2	=[	$walk2,		young_walk3	] {ai_walk(16);young_slimedamage();};
void()	young_walk3	=[	$walk3,		young_walk4	] {ai_walk(16);young_slimedamage();};
void()	young_walk4	=[	$walk4,		young_walk5	] {ai_walk(16);young_slimedamage();};
void()	young_walk5	=[	$walk5,		young_walk6	] {ai_walk(16);young_slimedamage();};
void()	young_walk6	=[	$walk6,		young_walk7	] {ai_walk(16);young_slimedamage();};
void()	young_walk7	=[	$walk7,		young_walk8	] {ai_walk(16);young_slimedamage();};
void()	young_walk8	=[	$walk8,		young_walk1	] {ai_walk(16);young_slimedamage();};

void()	young_run1	=[	$run1,		young_run2	] {ai_run(16);young_slimedamage();};
void()	young_run2	=[	$run2,		young_run3	] {ai_run(16);young_slimedamage();};
void()	young_run3	=[	$run3,		young_run4	] {ai_run(16);young_slimedamage();};
void()	young_run4	=[	$run4,		young_run5	] {ai_run(16);young_slimedamage();};
void()	young_run5	=[	$run5,		young_run6	] {ai_run(16);young_slimedamage();};
void()	young_run6	=[	$run6,		young_run7	] {ai_run(16);young_slimedamage();};
void()	young_run7	=[	$run7,		young_run8	] {ai_run(16);young_slimedamage();};
void()	young_run8	=[	$run8,		young_run1	] {ai_run(16);young_slimedamage();};

void()	young_runatt1	=[	$runatt1,		young_runatt2	] {ai_face();};
void()	young_runatt2	=[	$runatt2,	young_runatt3	]
{
	ai_face();
	
	self.touch = Young_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 400 + '0 0 200';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};
void()	young_runatt3	=[	$runatt3,	young_runatt1	] {
self.nextthink = time + 3;
// if three seconds pass, assume young is stuck and jump again
};

void()	young_runatt4	=[	$runatt4,	young_runatt5	] {ai_face();young_slimedamage();};
void()	young_runatt5	=[	$runatt5,	young_runatt6	] {ai_face();young_slimedamage();};
void()	young_runatt6	=[	$runatt6,	young_runatt7	] {ai_face();young_slimedamage();};
void()	young_runatt7	=[	$runatt7,	young_runatt8	] {ai_face();young_slimedamage();};
void()	young_runatt8	=[ 	$runatt8,	young_run1		] {ai_face();young_slimedamage();};

void()	young_pain1	=[	$run1,		young_pain2	] {};
void()	young_pain2	=[	$run1,		young_pain3	] {young_slimedamage();};
void()	young_pain3	=[	$run1,		young_pain4	] {young_slimedamage();};
void()	young_pain4	=[	$run1,		young_run1	] {young_slimedamage();};

void(entity attacker, float damage)	young_pain =
{
	young_pain1 ();
};

void()	young_die1		=[	$runatt4,		young_die1	] {self.think = SUB_Remove;self.nextthink = time + 15;self.solid = SOLID_NOT;};

void() young_die =
{
	// spawned by a clinger, notify parent that one has died
	if (self.owner)
		self.owner.cnt = self.owner.cnt + 1;

// check for gib
	if (self.health < -30)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		remove(self);
		return;
	}

// regular death
	young_die1 ();
};


/*QUAKED monster_young (1 0 0) (-16 -16 -24) (16 16 32) Ambush

*/
void() monster_young =
{
	if (!self.lefty)
	{
		if (deathmatch)
		{
			remove(self);
			return;
		}
		precache_model ("progs/young.mdl");
	}

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/young.mdl");

	setorigin (self, self.origin - '0 0 24');
	setsize (self, '-16 -16 0', '16 16 8');
	self.health = 20;

	self.th_stand = young_stand1;
	self.th_walk = young_walk1;
	self.th_run = young_run1;
	self.th_die = young_die;
	self.th_missile = young_runatt1;			// jump attack
	self.th_pain = young_pain;

	if (self.lefty)
	{
		self.takedamage = DAMAGE_AIM;
	
		self.ideal_yaw = self.angles * '0 1 0';
		self.yaw_speed = 40;
		self.view_ofs = '0 0 6';
		
		self.flags = self.flags | FL_MONSTER;
		
		self.pausetime = 99999999;
		self.th_stand ();
		
		if (self.enemy)
			FoundTarget();
		young_runatt2();
		self.velocity_x = crandom() * 200;
		self.velocity_y = crandom() * 200;
		self.velocity_z = 250;
	}
	else
		walkmonster_start();
};

void(entity own, vector org) spawnmonster_young =
{
	local entity oldself;
	oldself = self;
	self = spawn();
	self.owner = own;
	self.lefty = TRUE;
	self.enemy = own.enemy;
	self.classname = "monster_young";
	setorigin(self, org);
	monster_young();
	self = oldself;
};


/*
==============================================================================

YOUNG

==============================================================================
*/

/*
==============
CheckYoungJump

==============
*/
float()	CheckYoungJump =
{
	local	vector	dist;

	if (!(self.flags & FL_ONGROUND))
		return FALSE;

	if (self.origin_z > self.enemy.origin_z + -6)
		return FALSE;
		
	if (self.origin_z < self.enemy.origin_z + -42)
		return FALSE;
		
	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	if (vlen(dist) > 200)
		return FALSE;
		
	return TRUE;
};

float()	YoungCheckAttack =
{
	if (CheckYoungJump ())
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}
	
	return FALSE;
};


//===========================================================================

void()	Young_JumpTouch =
{
	local	float	ldmg;

	if (self.health <= 0)
		return;

	// lots of jumping young often kill eachother without this check
	if (other.classname == self.classname)
		return;
		
	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 200 )
		{
			ldmg = 5 + 15*random();
			T_Damage (other, self, self, ldmg);	
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = young_runatt1;
	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.think = young_runatt4;
	self.nextthink = time + 0.1;
};

