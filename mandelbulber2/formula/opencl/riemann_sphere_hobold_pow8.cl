/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2019 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * RiemannSphereHobold power8
 * @reference https://fractalforums.org/fractal-mathematics-and-new-theories/28/
 * riemandelettuce-without-trigonometry/2996/msg16097#msg16097

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_riemann_sphere_hobold_pow8.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 RiemannSphereHoboldPow8Iteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	z *= native_divide(fractal->transformCommon.scale08,
		aux->r); // normalize vector to unit length => project onto sphere

	// find X-related iso-plane: polar projection onto unit circle
	REAL Kx = 2.0f * z.x * native_divide((1.0f - z.y), ((z.y - 2.0f) * z.y + z.x * z.x + 1.0f));
	REAL Ky =
		1.0f
		- 2.0f * native_divide((mad((z.y - 2.0f), z.y, 1.0f)), ((z.y - 2.0f) * z.y + z.x * z.x + 1.0f));

	// REALd point
	REAL K2x = -2.0f * Kx * Ky;
	REAL K2y = -(mad(Ky, Ky, -Kx * Kx));

	// two more doublings (for total power eight)
	Kx = -2.0f * K2x * K2y;
	Ky = -(mad(K2y, K2y, -K2x * K2x));
	K2x = -2.0f * Kx * Ky;
	K2y = -(mad(Ky, Ky, -Kx * Kx));

	// (relevant) normal vector coordinates of REALd point plane
	REAL n1x = K2y - 1.0f;
	REAL n1y = -K2x;

	n1x += fractal->transformCommon.offsetA0; // offset tweak

	// find Z-related iso-plane: polar projection onto unit circle
	REAL Kz = 2.0f * z.z * native_divide((1.0f - z.y), ((z.y - 2.0f) * z.y + z.z * z.z + 1.0f));
	Ky =
		1.0f
		- 2.0f * native_divide((mad((z.y - 2.0f), z.y, 1.0f)), ((z.y - 2.0f) * z.y + z.z * z.z + 1.0f));

	// REALd point
	REAL K2z = -2.0f * Kz * Ky;
	K2y = -(mad(Ky, Ky, -Kz * Kz));

	// two more doublings (for total power eight)
	Kz = -2.0f * K2z * K2y;
	Ky = -(mad(K2y, K2y, -K2z * K2z));
	K2z = -2.0f * Kz * Ky;
	K2y = -(mad(Ky, Ky, -Kz * Kz));

	// (relevant) normal vector coordinates of REALd point plane
	REAL n2y = -K2z;
	REAL n2z = K2y - 1.0f;

	n2z += fractal->transformCommon.offsetB0; // offset tweak

	// internal rotation
	if (fractal->transformCommon.angle0 != 0)
	{
		REAL tpx = n1x;
		REAL tpz = n2z;
		REAL beta = fractal->transformCommon.angle0 * M_PI_180;
		n1x = mad(tpx, native_cos(beta), tpz * native_sin(beta));
		n2z = mad(tpx, -native_sin(beta), tpz * native_cos(beta));
	}

	// compute position of REALd point as intersection of planes and sphere
	// solved ray parameter
	REAL nt = 2.0f
						* native_divide((n1x * n1x * n2z * n2z),
							(mad((mad(n1x, n1x, n1y * n1y)) * n2z, n2z, n1x * n1x * n2y * n2y)));

	// REALd point position
	z.y = 1.0f - nt;
	z.x = n1y * native_divide((1.0f - z.y), n1x);
	z.z = n2y * native_divide((1.0f - z.y), n2z);

	// raise original length to the power, then add constant
	z *= aux->r * aux->r * aux->r * aux->r; // for 8th power

	z += fractal->transformCommon.additionConstant000;

	if (fractal->transformCommon.rotationEnabled)
		z = Matrix33MulFloat4(fractal->transformCommon.rotationMatrix, z);
	if (fractal->analyticDE.enabled)
	{
		aux->DE = fractal->analyticDE.offset1
							+ aux->DE * native_divide(fabs(fractal->transformCommon.scale08), aux->r);
		aux->DE *= 8.0f * fractal->analyticDE.scale1 * native_divide(length(z), aux->r);
	}
	return z;
}