
// base
$frame base1

// stand
$frame stand1

// walk
$frame walk1 walk2 walk3 walk4 walk5 walk6

// pain
$frame pain1 pain2 pain3 pain4 pain5

// fly
$frame fly1 fly2 fly3 fly4 fly5 fly6 fly7 fly8 fly9 fly10 fly11

// twirl
$frame twirl1 twirl2 twirl3 twirl4 twirl5 twirl6 twirl7 twirl8

void() ballmech_explosionfx =
{
	local vector v;
	v = self.origin;
	v_x = v_x + self.mins_x + random(self.size_x);
	v_y = v_y + self.mins_y + random(self.size_y);
	v_z = v_z + self.mins_z + random(self.size_z);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, v_x);
	WriteCoord (MSG_BROADCAST, v_y);
	WriteCoord (MSG_BROADCAST, v_z);
};

void() Blaster_Touch =
{
	local vector org;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		SpawnBlood (org, self.velocity*0.2, 10);
		T_Damage (other, self, self.owner, 10);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}

	remove(self);
};

void(vector org, vector vec) LaunchBlaster =
{
	if (self.classname == "monster_ballmech")
		sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	vec = normalize(vec);

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, '0 0 0', '0 0 0');

	setorigin (newmis, org);

	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = Blaster_Touch;
};



void() ballmech_fire =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors (self.angles);

	org = self.origin + v_forward * 20 + '0 0 30';

	LaunchBlaster(org, self.enemy.origin - org);
};


// stand (looping)
void() ballmech_stand1 =[ $stand1, ballmech_stand1 ] {self.touch = SUB_Null;ai_stand();if (random() < 0.1) sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);};


// walk (looping)
void() ballmech_walk1 =[ $walk1, ballmech_walk2 ] {self.touch = SUB_Null;if (random() < 0.2) sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);ai_walk(24);};
void() ballmech_walk2 =[ $walk2, ballmech_walk3 ] {ai_walk(24);};
void() ballmech_walk3 =[ $walk3, ballmech_walk4 ] {ai_walk(24);};
void() ballmech_walk4 =[ $walk4, ballmech_walk5 ] {ai_walk(24);};
void() ballmech_walk5 =[ $walk5, ballmech_walk6 ] {ai_walk(24);};
void() ballmech_walk6 =[ $walk6, ballmech_walk1 ] {ai_walk(24);};


// run (looping)
void() ballmech_run1 =[ $walk1, ballmech_run2 ] {self.touch = SUB_Null;if (random() < 0.2) sound (self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);ai_run(24);};
void() ballmech_run2 =[ $walk2, ballmech_run3 ] {ai_run(24);};
void() ballmech_run3 =[ $walk3, ballmech_run4 ] {ai_run(24);};
void() ballmech_run4 =[ $walk4, ballmech_run5 ] {ai_run(24);};
void() ballmech_run5 =[ $walk5, ballmech_run6 ] {ai_run(24);};
void() ballmech_run6 =[ $walk6, ballmech_run1 ] {ai_run(24);};


// pain
void() ballmech_pain1 =[ $pain1, ballmech_pain2 ] {};
void() ballmech_pain2 =[ $pain2, ballmech_pain3 ] {};
void() ballmech_pain3 =[ $pain3, ballmech_pain4 ] {};
void() ballmech_pain4 =[ $pain4, ballmech_pain5 ] {};
void() ballmech_pain5 =[ $pain5, ballmech_run1 ] {};


void() ballmech_flytouch =
{
	if (!other.takedamage)
		return;
	if (vlen(self.velocity) < 300)
		return;

	T_Damage(other, self, self, 45);
};


void(entity attacker, float damage) ballmech_pain =
{
	if (self.touch == ballmech_flytouch)
		return;
	if (damage < 40)
		return;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;
	ballmech_pain1();
};


// fly and twirl (looping)
void() ballmech_fly1 =[ $fly1, ballmech_fly2 ] {ai_face();};
void() ballmech_fly2 =[ $fly2, ballmech_fly3 ] {ai_face();};
void() ballmech_fly3 =[ $fly3, ballmech_fly4 ] {ai_face();};
void() ballmech_fly4 =[ $fly4, ballmech_fly5 ] {ai_face();};
void() ballmech_fly5 =[ $fly5, ballmech_fly6 ] {ai_face();};
void() ballmech_fly6 =[ $fly6, ballmech_fly7 ]
{
	ai_face();

	self.touch = ballmech_flytouch;
	makevectors(self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 400';
	self.flags = self.flags - (self.flags & FL_ONGROUND);
};
void() ballmech_fly7 =[ $fly7, ballmech_fly8 ] {};
void() ballmech_fly8 =[ $fly8, ballmech_fly9 ] {};
void() ballmech_fly9 =[ $fly9, ballmech_fly10 ] {};
void() ballmech_fly10 =[ $fly10, ballmech_fly11 ] {};
void() ballmech_fly11 =[ $fly11, ballmech_twirl1 ] {};
void() ballmech_twirl1 =[ $twirl1, ballmech_twirl2 ] {};
void() ballmech_twirl2 =[ $twirl2, ballmech_twirl3 ] {};
void() ballmech_twirl3 =[ $twirl3, ballmech_twirl4 ] {};
void() ballmech_twirl4 =[ $twirl4, ballmech_twirl5 ] {};
void() ballmech_twirl5 =[ $twirl5, ballmech_twirl6 ] {if (self.flags & FL_ONGROUND) ballmech_run1();};
void() ballmech_twirl6 =[ $twirl6, ballmech_twirl7 ] {};
void() ballmech_twirl7 =[ $twirl7, ballmech_twirl8 ] {};
void() ballmech_twirl8 =[ $twirl8, ballmech_twirl1 ] {};


// shoot
void() ballmech_shoot1 =[ $stand1, ballmech_shoot2 ] {ai_face();};
void() ballmech_shoot2 =[ $stand1, ballmech_shoot3 ] {ai_face();};
void() ballmech_shoot3 =[ $stand1, ballmech_shoot4 ] {ai_face();ballmech_fire();};
void() ballmech_shoot4 =[ $stand1, ballmech_shoot5 ] {ai_face();ballmech_fire();};
void() ballmech_shoot5 =[ $stand1, ballmech_shoot6 ] {ai_face();ballmech_fire();};
void() ballmech_shoot6 =[ $stand1, ballmech_shoot7 ] {ai_face();ballmech_fire();};
void() ballmech_shoot7 =[ $stand1, ballmech_shoot8 ] {ai_face();};
void() ballmech_shoot8 =[ $stand1, ballmech_run1 ] {ai_face();SUB_CheckRefire (ballmech_shoot1);};


// die
void() ballmech_die1  =[ $stand1, ballmech_die2  ] {ballmech_explosionfx();self.touch = SUB_Null;};
void() ballmech_die2  =[ $stand1, ballmech_die3  ] {};
void() ballmech_die3  =[ $stand1, ballmech_die4  ] {};
void() ballmech_die4  =[ $stand1, ballmech_die5  ] {ballmech_explosionfx();};
void() ballmech_die5  =[ $stand1, ballmech_die6  ] {};
void() ballmech_die6  =[ $stand1, ballmech_die7  ] {ballmech_explosionfx();};
void() ballmech_die7  =[ $stand1, ballmech_die8  ] {ballmech_explosionfx();};
void() ballmech_die8  =[ $stand1, ballmech_die9  ] {ballmech_explosionfx();};
void() ballmech_die9  =[ $stand1, ballmech_die10 ] {ballmech_explosionfx();};
void() ballmech_die10 =[ $stand1, ballmech_die11 ] {ballmech_explosionfx();};
void() ballmech_die11 =[ $stand1, ballmech_die11 ]
{
	T_RadiusDamage (self, self, 200, self);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	BecomeExplosion ();
};


float() ballmech_checkfly =
{
	local vector dist;
	local float d;
	local float r;

	if (!(self.flags & FL_ONGROUND))
		return FALSE;

	if (self.origin_z > self.enemy.origin_z + 20)
		return FALSE;

	if (self.origin_z < self.enemy.origin_z + -60)
		return FALSE;

	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	d = vlen(dist);
	r = random();

	return TRUE;
};


float() BallMechCheckAttack =
{
	local vector	spot1, spot2;
	local entity	targ;
	local float		chance;

	targ = self.enemy;

// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
		return FALSE;		// don't have a clear shot

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (enemy_range > RANGE_MELEE && time < self.attack_finished)
		return FALSE;

	if (enemy_range == RANGE_MELEE)
		chance = 0.1;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.1;
	else
		chance = 0.2;

	if (random() < chance)
	{
		ballmech_fly1();
		SUB_AttackFinished (2*random());
		return TRUE;
	}

	if (enemy_range == RANGE_MELEE)
		chance = 1;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.9;
	else
		chance = 0.5;

	if (random() < chance)
	{
		ballmech_shoot1();
		SUB_AttackFinished (2*random());
		return TRUE;
	}

	return FALSE;
};

/*QUAKED monster_ballmech (1 0 0) (-32 -32 -24) (32 32 88) Ambush

*/
void() monster_ballmech =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model("progs/ballmech2.mdl");
	precache_model2("progs/laser.mdl");
	precache_sound2("enforcer/idle1.wav");
	precache_sound2("enforcer/enfire.wav");
	precache_sound2("enforcer/enfstop.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	// compensate for the strange model offset
	setmodel(self, "progs/ballmech2.mdl");

	setsize(self, '-32 -32 -24', '32 32 46');
	self.health = 400;

	self.th_stand = ballmech_stand1;
	self.th_walk = ballmech_walk1;
	self.th_run = ballmech_run1;
	self.th_pain = ballmech_pain;
	self.th_die = ballmech_die1;
	self.th_missile = ballmech_shoot1;

	walkmonster_start();
};
