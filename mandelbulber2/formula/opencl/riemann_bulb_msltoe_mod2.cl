/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2017 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * RiemannBulbMsltoe Mod2
 * @reference
 * http://www.fractalforums.com/new-theories-and-research/
 * another-way-to-make-my-riemann-sphere-'bulb'-using-a-conformal-transformation/

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_riemann_bulb_msltoe_mod2.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 RiemannBulbMsltoeMod2Iteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	Q_UNUSED(aux);

	REAL radius2 = fractal->transformCommon.minR05;
	REAL rr = mad(z.z, z.z, mad(z.x, z.x, z.y * z.y)); // r2 or point radius squared
	if (rr < radius2 * radius2)
	{
		if (fractal->transformCommon.functionEnabled)
			// smooth inside
			z *= radius2 * ((rr * 0.1f) + 0.4f) * 1.18f
					 * native_divide(fractal->transformCommon.scaleA1, rr);
		else
		{
			z *= fractal->transformCommon.constantMultiplier111;
		}
	} // if internal smooth function disabled, then z = z * scale, default vect3(1f,1,1)
	else
	{
		// 1st scale variable, default vect3 (1.7f, 1.7f, 1.7f),
		z *= fractal->transformCommon.constantMultiplier222;
		REAL shift = fractal->transformCommon.offset1;
		// r1 = length^2,  //  + 1e-030f
		REAL r1 = mad(z.x, z.x, (z.y - shift) * (z.y - shift)) + z.z * z.z;
		// inversions by length^2
		z.x = native_divide(z.x, r1);
		z.y = native_divide((z.y - shift), r1);
		z.z = native_divide(z.z, r1);
		// 2nd scale variable , default = REAL (3.0f)
		z *= fractal->transformCommon.scale3;
		// y offset variable, default = REAL (1.9f);
		z.y = z.y + fractal->transformCommon.offset105;
		if (fractal->transformCommon.functionEnabledx)
		{
			z.x = z.x - round(z.x); // periodic cubic tiling,
			z.z = z.z - round(z.z);
		}
		if (fractal->transformCommon.functionEnabledxFalse)
		{
			z.x = fabs(native_sin(M_PI_F * z.x * fractal->transformCommon.scale1));
			z.z = fabs(native_sin(M_PI_F * z.z * fractal->transformCommon.scale1));
		}
	}
	return z;
}