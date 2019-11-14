/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2019 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * Hybrid DIFS aux.Color

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the function "TransfDIFSAuxColorIteration" in the file fractal_formulas.cpp
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 TransfDIFSAuxColorIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	z.z += 0.000000001f; // so not detected as a  zero change in z

	if (aux->i >= fractal->transformCommon.startIterations
			&& aux->i < fractal->transformCommon.stopIterations)
	{
		REAL colorAdd = 0.0f;
		if (fractal->foldColor.auxColorEnabledFalse)
		{
			colorAdd += fractal->foldColor.difs0000.x * fabs(z.x * z.y);
			colorAdd += fractal->foldColor.difs0000.y * max(z.x, z.y);
			colorAdd += fractal->foldColor.difs0000.z * max(z.x * z.x, z.y * z.y);
			colorAdd += fractal->foldColor.difs0000.w * z.z;

			if (fractal->transformCommon.functionEnabledFalse)
				colorAdd = fractal->transformCommon.scale1 * round(colorAdd);
		}
		colorAdd += fractal->foldColor.difs1;

		if (fractal->foldColor.auxColorEnabledA)
		{
			if (aux->dist != aux->colorHybrid) aux->color += colorAdd;
		}
		else
		{
			aux->color += colorAdd;
		}
		// update for next iter
		aux->colorHybrid = aux->dist;
	}
	// else
	// aux->color = 0.0f;

	// aux->dist tweak
	if (aux->i >= fractal->transformCommon.startIterationsA
			&& aux->i < fractal->transformCommon.stopIterationsA)
	{

		aux->dist = aux->dist * fractal->analyticDE.scale1;
	}
	return z;
}
