/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2019 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * transfDIFSGridIteration  fragmentarium code, mdifs by knighty (jan 2012)
 * and  Buddhi

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_transf_difs_grid.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 TransfDIFSGridIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	REAL4 zc = z;

	REAL size = fractal->transformCommon.scale1;
	REAL grid = 0.0f;

	zc.z /= fractal->transformCommon.scaleF1;

	if (fractal->transformCommon.rotationEnabled)
	{
		zc = Matrix33MulFloat4(fractal->transformCommon.rotationMatrix, zc);
	}

	REAL xFloor = fabs(zc.x - size * floor(native_divide(zc.x, size) + 0.5f));
	REAL yFloor = fabs(zc.y - size * floor(native_divide(zc.y, size) + 0.5f));
	REAL gridXY = min(xFloor, yFloor);

	if (!fractal->transformCommon.functionEnabledJFalse)
		grid = native_sqrt(mad(gridXY, gridXY, zc.z * zc.z));
	else
		grid = max(fabs(gridXY), fabs(zc.z));

	aux->dist =
		min(aux->dist, native_divide((grid - fractal->transformCommon.offset0005), (aux->DE + 1.0f)));
	return z;
}