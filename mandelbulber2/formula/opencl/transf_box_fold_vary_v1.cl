/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2019 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * Box Fold VaryV1. Varies folding limit based on iteration conditions
 * This formula contains aux.color

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_transf_box_fold_vary_v1.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 TransfBoxFoldVaryV1Iteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	REAL4 oldZ = z;
	REAL limit = fractal->mandelbox.foldingLimit;
	REAL tempVC = limit; // constant to be varied

	if (aux->i >= fractal->transformCommon.startIterations250
			&& aux->i < fractal->transformCommon.stopIterations
			&& (fractal->transformCommon.stopIterations - fractal->transformCommon.startIterations250
					!= 0))
	{
		int iterationRange =
			fractal->transformCommon.stopIterations - fractal->transformCommon.startIterations250;
		int currentIteration = (aux->i - fractal->transformCommon.startIterations250);
		tempVC +=
			fractal->transformCommon.offset * native_divide((1.0f * currentIteration), iterationRange);
	}
	if (aux->i >= fractal->transformCommon.stopIterations)
	{
		tempVC = (tempVC + fractal->transformCommon.offset);
	}

	limit = tempVC;
	REAL value = fractal->transformCommon.scale2 * limit;

	if (z.x > limit)
	{
		z.x = value - z.x;
	}
	else if (z.x < -limit)
	{
		z.x = -value - z.x;
	}
	if (z.y > limit)
	{
		z.y = value - z.y;
		;
	}
	else if (z.y < -limit)
	{
		z.y = -value - z.y;
	}
	REAL zLimit = limit * fractal->transformCommon.scale1;
	REAL zValue = value * fractal->transformCommon.scale1;
	if (z.z > zLimit)
	{
		z.z = zValue - z.z;
	}
	else if (z.z < -zLimit)
	{
		z.z = -zValue - z.z;
	}
	if (fractal->foldColor.auxColorEnabledFalse)
	{
		if (z.x != oldZ.x) aux->color += fractal->mandelbox.color.factor.x;
		if (z.y != oldZ.y) aux->color += fractal->mandelbox.color.factor.y;
		if (z.z != oldZ.z) aux->color += fractal->mandelbox.color.factor.z;
	}
	aux->DE *= fractal->analyticDE.scale1;
	return z;
}