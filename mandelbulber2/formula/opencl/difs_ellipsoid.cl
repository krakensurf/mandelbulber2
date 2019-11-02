/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2019 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * DifsEllipsoidIteration  fragmentarium code, mdifs by knighty (jan 2012)
 * and http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the function "DIFSEllipsoidIteration" in the file fractal_formulas.cpp
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 DIFSEllipsoidIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	REAL colorAdd = 0.0f;
	REAL4 oldZ = z;
	REAL4 boxFold = fractal->transformCommon.additionConstantA111;

	// abs z
	if (fractal->transformCommon.functionEnabledAx
			&& aux->i >= fractal->transformCommon.startIterationsX
			&& aux->i < fractal->transformCommon.stopIterationsX)
		z.x = fabs(z.x);
	if (fractal->transformCommon.functionEnabledAy
			&& aux->i >= fractal->transformCommon.startIterationsY
			&& aux->i < fractal->transformCommon.stopIterationsY)
		z.y = fabs(z.y);
	if (fractal->transformCommon.functionEnabledAzFalse
			&& aux->i >= fractal->transformCommon.startIterationsZ
			&& aux->i < fractal->transformCommon.stopIterationsZ)
		z.z = fabs(z.z);
	// folds
	if (fractal->transformCommon.functionEnabledFalse)
	{
		// xy box fold
		if (fractal->transformCommon.functionEnabledBxFalse
				&& aux->i >= fractal->transformCommon.startIterationsA
				&& aux->i < fractal->transformCommon.stopIterationsA)
		{
			z.x -= boxFold.x;
			z.y -= boxFold.y;
		}
		// xyz box fold
		if (fractal->transformCommon.functionEnabledByFalse
				&& aux->i >= fractal->transformCommon.startIterationsB
				&& aux->i < fractal->transformCommon.stopIterationsB)
			z -= boxFold;
		// polyfold
		if (fractal->transformCommon.functionEnabledPFalse
				&& aux->i >= fractal->transformCommon.startIterationsP
				&& aux->i < fractal->transformCommon.stopIterationsP)
		{
			z.x = fabs(z.x);
			int poly = fractal->transformCommon.int6;
			REAL psi = fabs(fmod(atan(native_divide(z.y, z.x)) + native_divide(M_PI_F, poly),
												native_divide(M_PI_F, (0.5f * poly)))
											- native_divide(M_PI_F, poly));
			REAL len = native_sqrt(mad(z.x, z.x, z.y * z.y));
			z.x = native_cos(psi) * len;
			z.y = native_sin(psi) * len;
		}
		// diag fold1
		if (fractal->transformCommon.functionEnabledCxFalse
				&& aux->i >= fractal->transformCommon.startIterationsCx
				&& aux->i < fractal->transformCommon.stopIterationsCx)
			if (z.x > z.y)
			{
				REAL temp = z.x;
				z.x = z.y;
				z.y = temp;
			}
		// abs offsets
		if (fractal->transformCommon.functionEnabledCFalse
				&& aux->i >= fractal->transformCommon.startIterationsC
				&& aux->i < fractal->transformCommon.stopIterationsC)
		{
			REAL xOffset = fractal->transformCommon.offsetC0;
			if (z.x < xOffset) z.x = fabs(z.x - xOffset) + xOffset;
		}
		if (fractal->transformCommon.functionEnabledDFalse
				&& aux->i >= fractal->transformCommon.startIterationsD
				&& aux->i < fractal->transformCommon.stopIterationsD)
		{
			REAL yOffset = fractal->transformCommon.offsetD0;
			if (z.y < yOffset) z.y = fabs(z.y - yOffset) + yOffset;
		}
		// diag fold2
		if (fractal->transformCommon.functionEnabledCyFalse
				&& aux->i >= fractal->transformCommon.startIterationsCy
				&& aux->i < fractal->transformCommon.stopIterationsCy)
			if (z.x > z.y)
			{
				REAL temp = z.x;
				z.x = z.y;
				z.y = temp;
			}
	}

	// reverse offset part 1
	if (aux->i >= fractal->transformCommon.startIterationsE
			&& aux->i < fractal->transformCommon.stopIterationsE)
		z.x -= fractal->transformCommon.offsetE2;

	if (aux->i >= fractal->transformCommon.startIterationsF
			&& aux->i < fractal->transformCommon.stopIterationsF)
		z.y -= fractal->transformCommon.offsetF2;

	// scale
	REAL useScale = 1.0f;
	if (aux->i >= fractal->transformCommon.startIterationsS
			&& aux->i < fractal->transformCommon.stopIterationsS)
	{
		useScale = aux->actualScaleA + fractal->transformCommon.scale2;
		z *= useScale;
		aux->DE = mad(aux->DE, fabs(useScale), 1.0f);
		// scale vary
		if (fractal->transformCommon.functionEnabledKFalse
				&& aux->i >= fractal->transformCommon.startIterationsK
				&& aux->i < fractal->transformCommon.stopIterationsK)
		{
			// update actualScaleA for next iteration
			REAL vary = fractal->transformCommon.scaleVary0
									* (fabs(aux->actualScaleA) - fractal->transformCommon.scaleC1);
			aux->actualScaleA = aux->actualScaleA - vary;
		}
	}

	// reverse offset part 2
	if (aux->i >= fractal->transformCommon.startIterationsE
			&& aux->i < fractal->transformCommon.stopIterationsE)
		z.x += fractal->transformCommon.offsetE2;

	if (aux->i >= fractal->transformCommon.startIterationsF
			&& aux->i < fractal->transformCommon.stopIterationsF)
		z.y += fractal->transformCommon.offsetF2;

	// offset
	z += fractal->transformCommon.offset001;

	// rotation
	if (fractal->transformCommon.functionEnabledRFalse
			&& aux->i >= fractal->transformCommon.startIterationsR
			&& aux->i < fractal->transformCommon.stopIterationsR)
	{
		z = Matrix33MulFloat4(fractal->transformCommon.rotationMatrix, z);
	}

	// DE
	REAL colorDist = aux->dist;
	REAL4 zc = oldZ;

	// ellipsoid
	if (aux->i >= fractal->transformCommon.startIterations
			&& aux->i < fractal->transformCommon.stopIterations)
	{
		REAL4 rads4 = fractal->transformCommon.additionConstant111;
		REAL3 rads3 = (REAL3){rads4.x, rads4.y, rads4.z};
		REAL tempX = zc.x;
		REAL tempY = zc.y;
		REAL tempZ = zc.z;
		REAL absZ = fabs(zc.z);

		if (fractal->transformCommon.functionEnabledJFalse) absZ = zc.z;

		if (fractal->transformCommon.functionEnabledNFalse
				&& aux->i >= fractal->transformCommon.startIterationsN
				&& aux->i < fractal->transformCommon.stopIterationsN)
		{
			// REAL absZ = fabs(zc.z);
			tempX = mad(fractal->transformCommon.scale0, absZ, zc.x);
		}
		if (fractal->transformCommon.functionEnabledOFalse
				&& aux->i >= fractal->transformCommon.startIterationsO
				&& aux->i < fractal->transformCommon.stopIterationsO)
		{
			// REAL absZ = fabs(zc.z);
			tempY = mad(fractal->transformCommon.scaleA0, absZ, zc.y);
		}

		// z.z sqrd
		if (fractal->transformCommon.functionEnabledTFalse
				&& aux->i >= fractal->transformCommon.startIterationsT
				&& aux->i < fractal->transformCommon.stopIterationsT)
		{
			tempZ = zc.z * zc.z;
		}

		REAL3 rV = (REAL3){tempX, tempY, tempZ};
		rV /= rads3;

		REAL3 rrV = rV;
		rrV /= rads3;

		REAL rd = length(rV);
		REAL rrd = length(rrV);
		REAL ellD = rd * native_divide((rd - 1.0f), rrd);
		aux->dist = min(aux->dist, native_divide(ellD, aux->DE));
	}
	// sphere
	if (fractal->transformCommon.functionEnabledMFalse
			&& aux->i >= fractal->transformCommon.startIterationsM
			&& aux->i < fractal->transformCommon.stopIterationsM)
	{
		REAL sphereRadius = fractal->transformCommon.offsetR1;
		REAL spD = length(zc) - sphereRadius;
		aux->dist = min(aux->dist, native_divide(spD, aux->DE));
	}
	// aux->color
	if (fractal->foldColor.auxColorEnabled)
	{
		if (fractal->foldColor.auxColorEnabledFalse)
		{
			colorAdd += fractal->foldColor.difs0000.x * fabs(z.x * z.y);
			colorAdd += fractal->foldColor.difs0000.y * max(z.x, z.y);
			// colorAdd += fractal->foldColor.difs0000.z * round(abs(z.x * z.y));
			// colorAdd += fractal->foldColor.difs0000.w * max(z.x, z.y); //
		}
		colorAdd += fractal->foldColor.difs1;
		if (fractal->foldColor.auxColorEnabledA)
		{
			if (colorDist != aux->dist) aux->color += colorAdd;
		}
		else
			aux->color += colorAdd;
	}
	return z;
}
