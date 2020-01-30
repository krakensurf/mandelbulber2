/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2017 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * spherical fold varyV1 MBox type
 * This formula contains aux.color

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_transf_spherical_fold_vary_v1.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 TransfSphericalFoldVaryV1Iteration(
	REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	REAL r2 = dot(z, z);
	REAL tempVCf = fractal->mandelbox.foldingSphericalFixed; // constant to be varied
	REAL tempVCm = fractal->mandelbox.foldingSphericalMin;

	if (aux->i >= fractal->transformCommon.startIterationsA
			&& aux->i < fractal->transformCommon.stopIterationsA)
	{
		int iterationRange =
			fractal->transformCommon.stopIterationsA - fractal->transformCommon.startIterationsA;
		int currentIteration = (aux->i - fractal->transformCommon.startIterationsA);
		tempVCf +=
			fractal->transformCommon.offset * native_divide((1.0f * currentIteration), iterationRange);
	}
	if (aux->i >= fractal->transformCommon.stopIterationsA)
	{
		tempVCf = (tempVCf + fractal->transformCommon.offset);
	}
	if (aux->i >= fractal->transformCommon.startIterationsB
			&& aux->i < fractal->transformCommon.stopIterationsB)
	{

		int iterationRange =
			fractal->transformCommon.stopIterationsB - fractal->transformCommon.startIterationsB;
		int currentIteration = (aux->i - fractal->transformCommon.startIterationsB);
		tempVCm +=
			fractal->transformCommon.offset0 * native_divide((1.0f * currentIteration), iterationRange);
	}
	if (aux->i >= fractal->transformCommon.stopIterationsB)
	{
		tempVCm = tempVCm + fractal->transformCommon.offset0;
	}

	z += fractal->mandelbox.offset;

	tempVCm *= tempVCm;
	tempVCf *= tempVCf;

	if (r2 < tempVCm)
	{
		z *= native_divide(tempVCf, tempVCm);
		aux->DE *= native_divide(tempVCf, tempVCm);
		if (fractal->foldColor.auxColorEnabledFalse)
		{
			aux->color += fractal->mandelbox.color.factorSp1;
		}
	}
	else if (r2 < tempVCf)
	{
		REAL tglad_factor2 = native_divide(tempVCf, r2);
		z *= tglad_factor2;
		aux->DE *= tglad_factor2;
		if (fractal->foldColor.auxColorEnabledFalse)
		{
			aux->color += fractal->mandelbox.color.factorSp2;
		}
	}
	z -= fractal->mandelbox.offset;
	return z;
}