/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2019 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * Box Tiling 4d

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_transf_box_tiling4d.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 TransfBoxTiling4dIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	REAL4 size = fractal->transformCommon.offset2222;
	REAL4 oldZ = z;

	if (!fractal->transformCommon.functionEnabledFalse)
	{
		if (fractal->transformCommon.functionEnabledx && size.x != 0.0f)
		{
			z.x -= round(native_divide(z.x, size.x)) * size.x;
		}
		if (fractal->transformCommon.functionEnabledyFalse && size.y != 0.0f)
		{
			z.y -= round(native_divide(z.y, size.y)) * size.y;
		}
		if (fractal->transformCommon.functionEnabledzFalse && size.z != 0.0f)
		{
			z.z -= round(native_divide(z.z, size.z)) * size.z;
		}
		if (fractal->transformCommon.functionEnabledwFalse && size.w != 0.0f)
		{
			z.w -= round(native_divide(z.w, size.w)) * size.w;
		}
	}
	else
	{
		REAL4 repeatPos = fractal->transformCommon.offsetA1111;
		REAL4 repeatNeg = fractal->transformCommon.offsetB1111;

		if (fractal->transformCommon.functionEnabledx && z.x < (repeatPos.x + 0.5f) * size.x
				&& z.x > (repeatNeg.x + 0.5f) * -size.x && size.x != 0.0f)
		{
			z.x -= round(native_divide(z.x, size.x)) * size.x;
		}
		if (fractal->transformCommon.functionEnabledyFalse && z.y < (repeatPos.y + 0.5f) * size.y
				&& z.y > (repeatNeg.y + 0.5f) * -size.y && size.y != 0.0f)
		{
			z.y -= round(native_divide(z.y, size.y)) * size.y;
		}
		if (fractal->transformCommon.functionEnabledzFalse && z.z < (repeatPos.z + 0.5f) * size.z
				&& z.z > (repeatNeg.z + 0.5f) * -size.z && size.z != 0.0f)
		{
			z.z -= round(native_divide(z.z, size.z)) * size.z;
		}
		if (fractal->transformCommon.functionEnabledwFalse && z.w < (repeatPos.w + 0.5f) * size.w
				&& z.w > (repeatNeg.w + 0.5f) * -size.w && size.w != 0.0f)
		{
			z.w -= round(native_divide(z.w, size.w)) * size.w;
		}
	}

	if (fractal->transformCommon.functionEnabledBxFalse)
	{
		z.x = z.x * native_divide(fractal->transformCommon.scale1, (fabs(oldZ.x) + 1.0f));
		z.y = z.y * native_divide(fractal->transformCommon.scale1, (fabs(oldZ.y) + 1.0f));
		z.z = z.z * native_divide(fractal->transformCommon.scale1, (fabs(oldZ.z) + 1.0f));
		z.w = z.w * native_divide(fractal->transformCommon.scale1, (fabs(oldZ.w) + 1.0f));
	}

	if (fractal->analyticDE.enabled)
	{
		if (!fractal->analyticDE.enabledFalse)
			aux->DE = mad(aux->DE, fractal->analyticDE.scale1, fractal->analyticDE.offset0);
		else
		{
			aux->DE = mad(aux->DE * length(z), fractal->analyticDE.scale1, fractal->analyticDE.offset0);
		}
	}
	return z;
}