/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2019 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * MsltoeToroidal
 * @reference http://www.fractalforums.com/theory/toroidal-coordinates/msg9428/

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_msltoe_toroidal.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 MsltoeToroidalIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	if (fractal->transformCommon.functionEnabledFalse
			&& aux->i >= fractal->transformCommon.startIterationsD
			&& aux->i < fractal->transformCommon.stopIterationsD1) // pre-scale
	{
		z *= fractal->transformCommon.scale3D111;
		aux->DE *= native_divide(length(z), aux->r);
	}

	// Toroidal bulb
	REAL r1 = fractal->transformCommon.minR05; // default 0.5f
	REAL theta = atan2(z.y, z.x);
	REAL x1 = r1 * native_cos(theta);
	REAL y1 = r1 * native_sin(theta);
	aux->r = mad((z.x - x1), (z.x - x1), (z.y - y1) * (z.y - y1)) + z.z * z.z; //+ 1e-030f
	REAL phi = asin(native_divide(z.z, native_sqrt(aux->r)));
	REAL rp = native_powr(aux->r, fractal->transformCommon.pwr4); // default 4.0f

	phi *= fractal->transformCommon.pwr8; // default 8
	theta *= fractal->bulb.power;					// default 9 gives 8 symmetry

	// convert back to cartesian coordinates
	REAL r1RpCosPhi = mad(native_cos(phi), rp, r1);
	z.x = r1RpCosPhi * native_cos(theta);
	z.y = r1RpCosPhi * native_sin(theta);
	z.z = -rp * native_sin(phi);

	// DEcalc
	if (!fractal->analyticDE.enabledFalse)
	{
		aux->DE = mad(rp * aux->DE, (fractal->transformCommon.pwr4 + 1.0f), 1.0f);
	}
	else
	{
		aux->DE = mad(rp * aux->DE * (fractal->transformCommon.pwr4 + fractal->analyticDE.offset2),
			fractal->analyticDE.scale1, fractal->analyticDE.offset1);
	}

	if (fractal->transformCommon.functionEnabledAxFalse) // spherical offset
	{
		REAL lengthTempZ = -length(z);
		// if (lengthTempZ > -1e-21f) lengthTempZ = -1e-21f;   //  z is neg.)
		z *= 1.0f + native_divide(fractal->transformCommon.offset, lengthTempZ);
		z *= fractal->transformCommon.scale;
		aux->DE = mad(aux->DE, fabs(fractal->transformCommon.scale), 1.0f);
	}
	// then add Cpixel constant vector
	return z;
}