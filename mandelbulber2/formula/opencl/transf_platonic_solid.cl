/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2019 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * platonic solid - from DarkBeam's code
 * @reference
 * http://www.fractalforums.com/3d-fractal-generation/platonic-dimensions/msg36528/#msg36528

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_transf_platonic_solid.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 TransfPlatonicSolidIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	REAL platonicR = 0.0f;
	REAL rho = 0.0f;
	if (!fractal->transformCommon.functionEnabledFalse)
	{
		rho = native_sqrt(aux->r); // the radius
		REAL theta = mad(native_cos(fractal->platonicSolid.frequency * z.x),
									 native_sin(fractal->platonicSolid.frequency * z.y),
									 native_cos(fractal->platonicSolid.frequency * z.y)
										 * native_sin(fractal->platonicSolid.frequency * z.z))
								 + native_cos(fractal->platonicSolid.frequency * z.z)
										 * native_sin(fractal->platonicSolid.frequency * z.x);
		platonicR = mad(theta, fractal->platonicSolid.amplitude, rho * fractal->platonicSolid.rhoMul);
		z *= platonicR;
	}
	else
	{
		REAL rho1 = 0.0f;
		REAL rho2 = 0.0f;
		REAL rho3 = 0.0f;
		if (fractal->transformCommon.functionEnabledx) rho1 = native_sqrt(aux->r);
		if (fractal->transformCommon.functionEnabledyFalse) rho2 = aux->r;
		if (fractal->transformCommon.functionEnabledzFalse) rho3 = aux->r * aux->r;

		if (fractal->transformCommon.functionEnabledAxFalse)
			rho = mad(fractal->transformCommon.scale1, (rho2 - rho1), rho1);
		else if (fractal->transformCommon.functionEnabledAyFalse)
			rho = mad(fractal->transformCommon.scale1, (rho3 - rho2), rho2);
		else
			rho = rho1 + rho2 + rho3;

		REAL theta = mad(native_cos(fractal->platonicSolid.frequency * z.x),
									 native_sin(fractal->platonicSolid.frequency * z.y),
									 native_cos(fractal->platonicSolid.frequency * z.y)
										 * native_sin(fractal->platonicSolid.frequency * z.z))
								 + native_cos(fractal->platonicSolid.frequency * z.z)
										 * native_sin(fractal->platonicSolid.frequency * z.x);
		// theta is pos or neg && < 3.0f

		if (fractal->transformCommon.functionEnabledAzFalse) theta = fabs(theta);

		platonicR = mad(theta, fractal->platonicSolid.amplitude, rho * fractal->platonicSolid.rhoMul);

		z *= platonicR; //  can be neg
	}

	if (fractal->analyticDE.enabled)
	{
		aux->DE =
			mad(aux->DE * fabs(platonicR), fractal->analyticDE.scale1, fractal->analyticDE.offset1);
	}
	return z;
}