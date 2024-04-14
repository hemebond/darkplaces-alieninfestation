
$frame base
$frame idle1
$frame shake1 shake2 shake3 shake4 shake5 shake6 shake7 shake8
$frame fall1
$frame hit1 hit2 hit3
$frame explode1 explode2

void() clinger_fall1;
void() clinger_idle1 =[ $idle1, clinger_idle1 ]
{
	local entity targ;
	local vector targposition, v;
	// all children still alive?  don't fall yet
	if (self.cnt < 1)
		return;
	targ = checkclient();
	if (!targ)
		return;
	targposition = targ.origin + targ.velocity * 0.3;
	targposition_z = targ.origin_z;
	// if target is not below clinger, return
	if (targposition_z + targ.maxs_z > self.origin_z + self.mins_z)
		return;
	// if target is not in a cylindrical area below the clinger, return
	v = targposition - self.origin;
	v_z = 0;
	if (vlen(v) > 128)
		return;
	// if a fall trace can't see the target, return
	v = self.origin + self.mins_z * '0 0 1';
	traceline(v, v - '0 0 1000', FALSE, self);
	v = trace_endpos + self.size_z * '0 0 2';
	if (v_z > self.origin_z + self.maxs_z)
		v_z = self.origin_z + self.maxs_z;
	traceline(v, targposition, TRUE, self);
	if (trace_fraction < 1)
		return;
	// looks good, let go
	self.enemy = targ;
	clinger_fall1();
};

void() clinger_shake1 =[ $shake1, clinger_shake2 ] {};
void() clinger_shake2 =[ $shake1, clinger_shake3 ] {};
void() clinger_shake3 =[ $shake1, clinger_shake4 ] {};
void() clinger_shake4 =[ $shake1, clinger_shake2 ] {};
void() clinger_shake5 =[ $shake1, clinger_shake6 ] {};
void() clinger_shake6 =[ $shake1, clinger_shake7 ] {};
void() clinger_shake7 =[ $shake1, clinger_shake8 ] {};
void() clinger_shake8 =[ $shake1, clinger_idle1 ] {};

void(entity attacker, float damage) clinger_pain =
{
	if (damage < 5)
		return;
	if (time < self.pain_finished)
		return;
	self.pain_finished = time + 0.5;
	clinger_shake1();
};

void() clinger_falltouch;
void() clinger_fall1 =[ $fall1, clinger_fall2 ]
{
	self.th_pain = SUB_Null;
	self.movetype = MOVETYPE_TOSS;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.touch = clinger_falltouch;
	self.velocity = '0 0 -400';
};
void() clinger_fall2 =[ $fall1, clinger_fall2 ] {if (self.flags & FL_ONGROUND) self.th_die();};

void() clinger_die1  =[ $hit1    , clinger_die2  ] {self.touch = SUB_Null;self.th_die = SUB_Null;self.solid = SOLID_NOT;self.takedamage = DAMAGE_NO;};
void() clinger_die2  =[ $hit2    , clinger_die3  ] {};
void() clinger_die3  =[ $hit3    , clinger_die4  ] {};
void() clinger_die4  =[ $explode1, clinger_die5  ] {};
void() clinger_die5  =[ $explode2, clinger_die6  ] {};
void() clinger_die6  =[ $explode2, clinger_respawn  ]
{
	local float c;
	local vector v, vel;
	sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	// take into account the clipping hull size used by young and spawn them
	// either at the top of the box, or the bottom if spawning them at the top
	// of the box would put them in the floor
	v = self.origin + self.maxs_z * '0 0 1';
	traceline(v, v - '0 0 56', FALSE, self);
	v = trace_endpos + '0 0 24';
	while (self.cnt > 0)
	{
		self.cnt = self.cnt - 1;
		spawnmonster_young(self, v);
	}
	c = 4;
	while (c > 0)
	{
		c = c - 1;
		vel_x = crandom() * 100;
		vel_y = crandom() * 100;
		vel_z = 200;
		SpawnMeatSpray(v, vel);
		ThrowGib ("progs/gib1.mdl", self.health);
	}
	self.model = "";
	self.nextthink = time + 30;
	if (!deathmatch)
		remove(self);
};
void() clinger_respawn =[ $idle1, clinger_idle1 ]
{
	local float respawning;
	respawning = self.modelindex != 0;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_NONE;

	setmodel (self, "progs/clinger2.mdl");
	setsize (self, '-16 -16 -40', '16 16 0');
	setorigin (self, self.dest1);
	self.health = 80;
	self.takedamage = DAMAGE_AIM;
	self.deadflag = DEAD_NO;
	self.th_pain = clinger_pain;
	self.th_die = clinger_die1;
	self.enemy = world;

	// count all the young that will drop as monsters
	total_monsters = total_monsters + self.cnt;

	if (respawning)
		sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
};


void() clinger_falltouch =
{
	self.th_die();
};

/*QUAKED monster_clinger (1 0 0) (-16 -16 -56) (16 16 0) Ambush

*/
void() monster_clinger
{
	/*
	if (deathmatch)
	{
		remove(self);
		return;
	}
	*/
	precache_model ("progs/clinger2.mdl");
	precache_model ("progs/young.mdl");
	
	// for respawning in deathmatch
	self.dest1 = self.origin - '0 0 0.125';
	self.cnt = 2 + cvar("skill") * 2;
	clinger_respawn();
};
