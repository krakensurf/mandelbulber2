/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2019 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * Benesi Cube to sphere transform
 * Warps a cube to a sphere; transform made by M.Benesi, optimized by Luca.
 * @reference http://www.fractalforums.com/mathematics/circle2square/

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_transf_benesi_cube_sphere.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 TransfBenesiCubeSphereIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	Q_UNUSED(fractal);
	// Q_UNUSED(aux);
	REAL4 oldZ = z;
	z *= z; // so all now positive

	// if (z.x == 0.0f)
	//	z.x = 1e-21f;
	// if (z.z == 0.0f)
	//	z.z = 1e-21f;

	REAL rCyz = native_divide(z.y, z.z);

	REAL rCxyz = native_divide((z.y + z.z), z.x);

	if (rCxyz == -1.0f) z.z = 1.0f; //+ 1e-21f
	if (rCyz < 1.0f)
		rCyz = native_sqrt(rCyz + 1.0f);
	else
		rCyz = native_sqrt(native_recip(rCyz) + 1.0f);

	if (rCxyz < 1.0f)
		rCxyz = native_sqrt(rCxyz + 1.0f);
	else
		rCxyz = native_sqrt(native_recip(rCxyz) + 1.0f);

	z.y *= rCyz;
	z.z *= rCyz;

	z *= native_divide(rCxyz, SQRT_3_2);
	// aux->DE *= native_divide(length(z), length(oldZ));
	if (fractal->analyticDE.enabled)
	{
		aux->DE = aux->DE * fractal->analyticDE.scale1 * native_divide(length(z), length(oldZ))
							+ fractal->analyticDE.offset1;
	}
	return z;
}