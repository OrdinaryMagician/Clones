//=============================================================================
// CloneSprinkle.
//
// Magic!
//=============================================================================
class CloneSprinkle extends Actor;

event PostBeginPlay()
{
	DrawScale *= RandRange(0.8,1.2);
}

event Tick( float deltatime )
{
	ScaleGlow -= 2*deltatime;
	if ( ScaleGlow <= 0.0 )
		Destroy();
	Velocity.Z -= 400*deltatime;
}

event Landed( Vector HitNormal )
{
	HitWall(HitNormal,Level);
}

event HitWall( Vector HitNormal, Actor Wall )
{
	Velocity = 0.4*(Velocity-2*HitNormal*(Velocity dot HitNormal));
}

defaultproperties
{
	bHidden=False
	bCollideWorld=True
	CollisionRadius=1.0
	CollisionHeight=1.0
	Texture=Texture'Botpack.Sparky'
	DrawScale=0.2
	ScaleGlow=3.0
	Style=STY_Translucent
	Physics=PHYS_Projectile
	Mass=1.0
	Buoyancy=0.0
}
