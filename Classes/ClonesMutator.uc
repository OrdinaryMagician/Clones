//=============================================================================
// ClonesMutator.
//
// Here come the miniclones, look at them run, look at them explode!
//=============================================================================
class ClonesMutator extends Mutator config(Clones);

// CVars
var() config int DClonesMin, DClonesMax, ClonesLimit;
var() config bool InstigatorVictim;
var() config float VelocityFactor,Deviation,RandomXMin,RandomXMax,RandomZMin,
	RandomZMax;

var bool bInitialized;

var int ClonesCount,ClonesMax;

// Setup
function PostBeginPlay()
{
	if ( bInitialized )
		return;
	Level.Game.RegisterDamageMutator(self);
	bInitialized = true;
	ClonesCount = 0;
	ClonesMax = 0;
}

// Add counter
function HUDAdd( Pawn Other )
{
	local HUDMutator m;
	local PlayerPawn p;
	if ( !Other.IsA('PlayerPawn') )
		return;
	p = PlayerPawn(Other);
	if ( p.myHUD == None )
		return;
	m = HUDMutator(p.myHUD.HUDMutator);
	while ( m != None )
	{
		if ( m.IsA('ClonesCounter') );
			return;
		m = m.NextRHUDMutator;
	}
	m = Spawn(Class'ClonesCounter');
	m.RegisterAHUDMutator();
	ClonesCounter(m).Mute = Self;
}

function ModifyPlayer( Pawn Other )
{
	HUDAdd(Other);
	if ( NextMutator != None )
		NextMutator.ModifyPlayer(Other);
}

// Score!
function ScoreKill( Pawn Killer, Pawn Other )
{
	local Miniclone clone;
	local int i,m;
	local Vector X,Y,Z;
	if ( Other == None )
	{
		if ( NextMutator != None )
			NextMutator.ScoreKill(Killer, Other);
		return;
	}
	GetAxes(Other.Rotation,X,Y,Z);
	m = RandRange(DClonesMin,DClonesMax);
	for ( i=0; i<m; i++ )
	{
		if ( ClonesCount >= ClonesLimit )
			break;
		clone = Spawn(class'Miniclone',Other,,Other.Location);
		if ( clone == None )
			continue;
		clone.Mute = self;
		ClonesCount++;
		if ( InstigatorVictim )
			clone.Instigator = Other;
		else
			clone.Instigator = Killer;
		clone.Velocity += Other.Velocity*VelocityFactor+(X+VRand()
			*Deviation)*RandRange(RandomXMin,RandomXMax);
		clone.Velocity += Z*RandRange(RandomZMin,RandomZMax);
		GetAxes(Rotator(clone.Velocity),X,Y,Z);
		clone.SetRotation(Rotator(X));
	}
	if ( ClonesCount > ClonesMax )
		ClonesMax = ClonesCount;
	if ( NextMutator != None )
		NextMutator.ScoreKill(Killer, Other);
}

defaultproperties
{
	DClonesMin=10
	DClonesMax=20
	ClonesLimit=2500
	InstigatorVictim=True
	VelocityFactor=0.5
	Deviation=0.8
	RandomXMin=100.0
	RandomXMax=500.0
	RandomZMin=50.0
	RandomZMax=800.0
}
