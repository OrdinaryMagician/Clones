//============================================================================
// Miniclone.
//
// RIP headphone users.
//=============================================================================
class Miniclone extends Actor config(Clones);

// ucc won't let me use these directly so I have to embed them on the mod
#exec AUDIO IMPORT NAME=screams0 FILE=Sounds\deathc1.wav
#exec AUDIO IMPORT NAME=screams1 FILE=Sounds\deathc3.wav
#exec AUDIO IMPORT NAME=screams2 FILE=Sounds\deathc4.wav
#exec AUDIO IMPORT NAME=screams3 FILE=Sounds\deathc51.wav
#exec AUDIO IMPORT NAME=screams4 FILE=Sounds\deathc53.wav
#exec AUDIO IMPORT NAME=screams5 FILE=Sounds\M2backup.wav
#exec AUDIO IMPORT NAME=screams6 FILE=Sounds\M2imhit.wav
#exec AUDIO IMPORT NAME=screams7 FILE=Sounds\M2incoming.wav
#exec AUDIO IMPORT NAME=screams8 FILE=Sounds\M2Medic.wav
#exec AUDIO IMPORT NAME=screams9 FILE=Sounds\M2underattack.wav
#exec AUDIO IMPORT NAME=explsound FILE=Sounds\Explg02.wav
#exec AUDIO IMPORT NAME=landsound FILE=Sounds\land10.wav
#exec AUDIO IMPORT NAME=hitsound0 FILE=Sounds\injurL2.wav
#exec AUDIO IMPORT NAME=hitsound1 FILE=Sounds\injurM04.wav
#exec AUDIO IMPORT NAME=hitsound2 FILE=Sounds\injurH5.wav
#exec AUDIO IMPORT NAME=footstep0 FILE=Sounds\stone02.wav
#exec AUDIO IMPORT NAME=footstep1 FILE=Sounds\stone04.wav
#exec AUDIO IMPORT NAME=footstep2 FILE=Sounds\stone05.wav

#exec TEXTURE IMPORT NAME=malc1 FILE=Textures\Blkt1.pcx
#exec TEXTURE IMPORT NAME=malc2 FILE=Textures\Blkt2.pcx
#exec TEXTURE IMPORT NAME=malc3 FILE=Textures\Blkt3.pcx
#exec TEXTURE IMPORT NAME=malc4 FILE=Textures\blkt4Malcom.pcx

// CVars
var() config float SizeFactor,SpeedFactor,MinDuration,MaxDuration,Drift,
	MinScream,MaxScream;
var() config int MinSprinkles,MaxSprinkles;

var() Sound Screams[10];
var() Sound ExplSound,LandSound;
var() Sound HitSound[3];
var() Sound FootStep[3];
var Vector GroundNormal;
var float LifeTime;
var float ScreamTimer;
var bool IsFlying;
var ClonesMutator Mute;

event Destroyed()
{
	if ( Mute != None )
		Mute.ClonesCount--;
}

function PlayFootStep()
{
	local int i;
	i = Rand(3);
	PlaySound(FootStep[i],SLOT_Interact,0.5*SizeFactor,,,1.0/SizeFactor);
}

function PlayLanded()
{
	PlaySound(LandSound,SLOT_Interact,0.8*SizeFactor,,,1.0/SizeFactor);
}

function PlayHitSound()
{
	local int i;
	i = Rand(3);
	PlaySound(HitSound[i],SLOT_Pain,1.5*SizeFactor,,,1.0/SizeFactor);
}

function Scream()
{
	local int i;
	i = Rand(10);
	PlaySound(Screams[i],SLOT_None,2.0*SizeFactor,,,1.0/SizeFactor);
	ScreamTimer = RandRange(MinScream,MaxScream);
}

event PostBeginPlay()
{
	SetTimer(0.01,false);
	LifeTime = RandRange(MinDuration,MaxDuration);
	ScreamTimer = RandRange(MinScream,MaxScream);
}

event Timer()
{
	SetPhysics(PHYS_Falling);
	DrawScale *= SizeFactor;
	SetCollisionSize(CollisionRadius*SizeFactor,
		CollisionHeight*SizeFactor);
	Mass *= SizeFactor;
	Buoyancy = Mass-1;
	TweenAnim('JumpSmFr',0.1);
	IsFlying = True;
}

event TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation,
	Vector Momentum, Name DamageType )
{
	if ( !IsInState('Roaming') )
		return;
	SetPhysics(PHYS_Falling);
	TweenAnim('JumpSmFr',0.1);
	IsFlying = True;
	Velocity += Momentum/Mass;
	PlayHitSound();
}

event Tick( float deltatime )
{
	local Vector X,Y,Z,newdir;
	// Drifting
	if ( Physics == PHYS_Projectile )
	{
		GetAxes(Rotation,X,Y,Z);
		newdir = X + Drift*Y*(0.5-FRand());
		Velocity = 400.0*SizeFactor*SpeedFactor*newdir;
		SetRotation(Rotator(Velocity));
	}
	// Mai laifu
	LifeTime -= deltatime;
	if ( LifeTime <= 0.0 )
		GotoState('Explosion');
	// AAAAAAAAAAAAAAAAAAAA
	ScreamTimer -= deltatime;
	if ( ScreamTimer <= 0.0 )
		Scream();
	// Land check
	if ( !IsFlying&&FastTrace(Location-GroundNormal*CollisionHeight*2.0) )
		SetPhysics(PHYS_Falling);
}

event Landed( Vector HitNormal )
{
	local Vector X,Y,Z;
	GetAxes(Rotator(Velocity),X,Y,Z);
	X = Y cross HitNormal;
	Velocity = VSize(Velocity)*X;
	SetRotation(Rotator(Velocity));
	GroundNormal = HitNormal;
	if ( IsFlying || (Velocity.Z < -300) )
	{
		IsFlying = False;
		GotoState('FellDown');
		return;
	}
	TweenAnim('LandSmFr',0.1);
	GotoState('HasLanded');
}

event HitWall( Vector HitNormal, Actor Wall )
{
	local Vector X,Y,Z;
	if ( IsFlying )
	{
		Velocity *= 0;
		return;
	}
	if ( HitNormal.Z < 0.4 )
		Velocity -= 2*HitNormal*(Velocity dot HitNormal);
	else
	{
		GetAxes(Rotator(Velocity),X,Y,Z);
		X = Y cross HitNormal;
		Velocity = 400.0*SizeFactor*SpeedFactor*X;
		GroundNormal = HitNormal;
	}
	SetRotation(Rotator(Velocity));
}

State Roaming
{

Begin:
	SetPhysics(PHYS_Projectile);
	Velocity = 400.0*SizeFactor*SpeedFactor*Vector(Rotation);
	LoopAnim('RunSm',SpeedFactor);
}

State FellDown
{
	ignores Timer, Tick, Landed, HitWall;

Begin:
	SetPhysics(PHYS_Projectile);
	PlayHitSound();
	TweenAnim('DeathEnd3',0.2);
	Velocity *= 0.1;
	Sleep(0.5);
	TweenAnim('DuckWlkS',0.2);
	Sleep(0.2);
	TweenAnim('Walk',0.3);
	Sleep(0.3);
	GotoState('Roaming');
}

State HasLanded
{
	ignores Timer, Tick, Landed, HitWall;

Begin:
	SetPhysics(PHYS_Projectile);
	PlayLanded();
	Velocity *= 0.1;
	Sleep(0.1);
	GotoState('Roaming');
}

function Vector RandomSpot()
{
	local Vector v;

	v = Location;
	v.X += RandRange(-CollisionRadius,CollisionRadius);
	v.Y += RandRange(-CollisionRadius,CollisionRadius);
	v.Z += RandRange(-CollisionHeight,CollisionHeight);
	return v;
}

function BlowUp()
{
	local int i,m;
	local CloneSprinkle s;
	PlaySound(ExplSound,SLOT_None,10.0,,,1.0/SizeFactor);
	m = RandRange(MinSprinkles,MaxSprinkles)*SizeFactor;
	for ( i=0; i<m; i++ )
	{
		s = Spawn(Class'CloneSprinkle',,,RandomSpot());
		if ( s == None )
			continue;
		s.Velocity += 0.2*Velocity;
		s.Velocity += VRand()*RandRange(10.0,80.0);
		s.Velocity.Z += RandRange(30.0,100.0);
		s.DrawScale *= SizeFactor;
	}
}

State Explosion
{
	ignores Timer, Tick, Landed, HitWall;

Begin:
	Sleep(0.1);
	BlowUp();
	Destroy();
}

defaultproperties
{
	CollisionRadius=17
	CollisionHeight=39
	bHidden=False
	DrawType=DT_Mesh
	Mesh=LODMesh'Botpack.Soldier'
	MultiSkins(0)=Texture'Clones.malc1'
	MultiSkins(1)=Texture'Clones.malc2'
	MultiSkins(2)=Texture'Clones.malc3'
	MultiSkins(3)=Texture'Clones.malc4'
	Physics=PHYS_Falling
	Mass=100
	Buoyancy=99
	bCollideWorld=True
	bCollideActors=True
	bProjTarget=True
	AnimSequence='Walk'
	SizeFactor=0.3
	SpeedFactor=1.25
	MinDuration=10.0
	MaxDuration=30.0
	Drift=0.1
	MinScream=0.2
	MaxScream=0.8
	MinSprinkles=20
	MaxSprinkles=40
	Screams(0)=Sound'Clones.screams0'
	Screams(1)=Sound'Clones.screams1'
	Screams(2)=Sound'Clones.screams2'
	Screams(3)=Sound'Clones.screams3'
	Screams(4)=Sound'Clones.screams4'
	Screams(5)=Sound'Clones.screams5'
	Screams(6)=Sound'Clones.screams6'
	Screams(7)=Sound'Clones.screams7'
	Screams(8)=Sound'Clones.screams8'
	Screams(9)=Sound'Clones.screams9'
	ExplSound=Sound'Clones.explsound'
	LandSound=Sound'Clones.landsound'
	HitSound(0)=Sound'Clones.hitsound0'
	HitSound(1)=Sound'Clones.hitsound1'
	HitSound(2)=Sound'Clones.hitsound2'
	FootStep(0)=Sound'Clones.footstep0'
	FootStep(1)=Sound'Clones.footstep1'
	FootStep(2)=Sound'Clones.footstep2'
}
