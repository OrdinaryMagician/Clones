//=============================================================================
// ClonesCounter.
//
// Count dem clones.
//=============================================================================
class ClonesCounter extends HUDMutator;

var ClonesMutator Mute;

function PostRender( Canvas Canvas )
{
	if ( PlayerOwner == None )
	{
		Destroy();
		if ( NextRHUDMutator != None )
			NextRHUDMutator.PostRender(Canvas);
		return;
	}

	if ( Mute == None )
		return;
	Canvas.Font = Font'Engine.SmallFont';
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	Canvas.SetPos(0.1*Canvas.ClipX,0.6*Canvas.ClipY-24);
	Canvas.DrawText("CLONES CURRENT:");
	if ( Mute.ClonesCount < 1 )
	{
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
	}
	else if ( Mute.ClonesCount < 10 )
	{
		Canvas.DrawColor.R = 128;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
	}
	else if ( Mute.ClonesCount < 100 )
	{
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
	}
	else if ( Mute.ClonesCount < 1000 )
	{
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 128;
		Canvas.DrawColor.B = 0;
	}
	else
	{
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
	}
	Canvas.SetPos(0.1*Canvas.ClipX+8,0.6*Canvas.ClipY-16);
	Canvas.DrawText(Mute.ClonesCount);
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.G = 255;
	Canvas.DrawColor.B = 255;
	Canvas.SetPos(0.1*Canvas.ClipX,0.6*Canvas.ClipY-8);
	Canvas.DrawText("CLONES PEAK:");
	if ( Mute.ClonesMax < 1 )
	{
		Canvas.DrawColor.R = 0;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
	}
	else if ( Mute.ClonesMax < 10 )
	{
		Canvas.DrawColor.R = 128;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
	}
	else if ( Mute.ClonesMax < 100 )
	{
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 255;
		Canvas.DrawColor.B = 0;
	}
	else if ( Mute.ClonesMax < 1000 )
	{
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 128;
		Canvas.DrawColor.B = 0;
	}
	else
	{
		Canvas.DrawColor.R = 255;
		Canvas.DrawColor.G = 0;
		Canvas.DrawColor.B = 0;
	}
	Canvas.SetPos(0.1*Canvas.ClipX+8,0.6*Canvas.ClipY);
	Canvas.DrawText(Mute.ClonesMax);
	if ( NextRHUDMutator != None )
		NextRHUDMutator.PostRender(Canvas);
}
