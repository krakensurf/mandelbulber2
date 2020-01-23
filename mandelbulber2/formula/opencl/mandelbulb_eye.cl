/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2019 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * 3D Version of the 2D Eye Fractal created by biberino, modified mclarekin

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_mandelbulb_eye.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 MandelbulbEyeIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	aux->DE = aux->DE * 2.0f * aux->r;

	// pre abs
	if (fractal->buffalo.preabsx) z.x = fabs(z.x);
	if (fractal->buffalo.preabsy) z.y = fabs(z.y);
	if (fractal->buffalo.preabsz) z.z = fabs(z.z);

	// bulb
	REAL4 zz = z * z;
	REAL rr = zz.x + zz.y + zz.z;
	REAL temp = native_sqrt(zz.x + zz.y);
	REAL theta1 = atan2(temp, z.z) * fractal->transformCommon.scaleB1;
	REAL theta2 = atan2(temp, -z.z) * fractal->transformCommon.scaleC1;
	temp = theta1 + theta2;

	REAL phi1 = atan2(z.y, z.x);
	REAL phi2 = 0.0f;
	if (!fractal->transformCommon.functionEnabledFalse)
		phi2 = atan2(-z.y, z.x);
	else
		phi2 = M_PI_F - phi1;
	phi1 *= fractal->transformCommon.scale1;
	phi1 += phi2;

	temp = rr * native_sin(theta1 + theta2);
	z.x = temp * native_cos(phi1);
	z.y = temp * native_sin(phi1);
	z.z = rr * native_cos(theta1 + theta2);

	// post abs
	z.x = fractal->buffalo.absx ? fabs(z.x) : z.x;
	z.y = fractal->buffalo.absy ? fabs(z.y) : z.y;
	z.z = fractal->buffalo.absz ? fabs(z.z) : z.z;

	// offset
	z += fractal->transformCommon.additionConstantA000;

	// analyticDE controls
	if (fractal->analyticDE.enabledFalse)
		aux->DE = mad(aux->DE, fractal->analyticDE.scale1, fractal->analyticDE.offset1);
	return z;
}