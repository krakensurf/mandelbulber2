/**
 * Mandelbulber v2, a 3D fractal generator  _%}}i*<.        ____                _______
 * Copyright (C) 2020 Mandelbulber Team   _>]|=||i=i<,     / __ \___  ___ ___  / ___/ /
 *                                        \><||i|=>>%)    / /_/ / _ \/ -_) _ \/ /__/ /__
 * This file is part of Mandelbulber.     )<=i=]=|=i<>    \____/ .__/\__/_//_/\___/____/
 * The project is licensed under GPLv3,   -<>>=|><|||`        /_/
 * see also COPYING file in this folder.    ~+{i%+++
 *
 * Hybrid Color Trial
 * bailout may need to be adjusted with some formulas

 * This file has been autogenerated by tools/populateUiInformation.php
 * from the file "fractal_transf_hybrid_color.cpp" in the folder formula/definition
 * D O    N O T    E D I T    T H I S    F I L E !
 */

REAL4 TransfHybridColorIteration(REAL4 z, __constant sFractalCl *fractal, sExtendedAuxCl *aux)
{
	REAL linearOffset = 0.0f;
	REAL boxTrap = 0.0f;
	REAL sphereTrap = 0.0f;
	REAL planeBias = 0.0f;
	REAL twoPoints = 0.0f;
	REAL componentMaster = 0.0f;

	// max linear offset
	if (fractal->transformCommon.functionEnabledMFalse)
	{
		REAL temp30 = 0.0f;
		REAL4 temp31 = z;
		if (fractal->transformCommon.functionEnabledM) temp31 = fabs(temp31);

		temp30 = max(max(temp31.x, temp31.y), temp31.z);
		temp30 *= fractal->transformCommon.scaleD1;
		linearOffset = temp30;
	}

	// box trap
	if (fractal->surfBox.enabledX2False)
	{
		REAL4 box = fractal->transformCommon.scale3D444;
		REAL4 temp35 = z;
		REAL temp39 = 0.0f;
		if (fractal->transformCommon.functionEnabledCx) temp35 = fabs(temp35);

		temp35 = box - temp35;
		REAL temp36 = max(max(temp35.x, temp35.y), temp35.z);
		REAL temp37 = min(min(temp35.x, temp35.y), temp35.z);
		temp36 = mad(fractal->transformCommon.offsetB0, temp37, temp36);
		temp36 *= fractal->transformCommon.scaleC1;

		if (fractal->surfBox.enabledY2False)
		{
			REAL4 temp38 = aux->c;

			if (fractal->transformCommon.functionEnabledCz) temp38 = fabs(temp38);
			temp38 = box - temp38;

			temp39 = max(max(temp38.x, temp38.y), temp38.z);
			REAL temp40 = min(min(temp38.x, temp38.y), temp38.z);
			temp39 = mad(fractal->transformCommon.offsetA0, temp40, temp39);
			temp39 *= fractal->transformCommon.scaleE1;
		}
		boxTrap = temp36 + temp39;
	}

	// sphere trap
	if (fractal->transformCommon.functionEnabledzFalse)
	{
		REAL sphereRR = fractal->transformCommon.maxR2d1;
		REAL temp45 = dot(z, z);
		REAL temp46 = sphereRR - temp45;
		REAL temp47 = temp46;
		REAL temp51 = temp46;
		if (fractal->transformCommon.functionEnabledAx) temp51 = fabs(temp51);
		temp51 *= fractal->transformCommon.scaleF1;

		if (fractal->transformCommon.functionEnabledyFalse && temp45 > sphereRR)
		{
			temp46 *= temp46 * fractal->transformCommon.scaleG1;
		}
		if (fractal->transformCommon.functionEnabledPFalse && temp45 < sphereRR)
		{
			temp47 *= temp47 * fractal->transformCommon.scaleB1;
		}
		sphereTrap = temp51 + temp47 + temp46;
	}

	// plane bias
	if (fractal->transformCommon.functionEnabledAzFalse)
	{
		REAL4 tempP = z;
		if (fractal->transformCommon.functionEnabledEFalse)
		{
			tempP.x = tempP.x * tempP.y;
			tempP.x *= tempP.x;
		}
		else
		{
			tempP.x = fabs(tempP.x * tempP.y);
		}
		if (fractal->transformCommon.functionEnabledFFalse)
		{
			tempP.y = tempP.y * tempP.z;
			tempP.y *= tempP.y;
		}
		else
		{
			tempP.y = fabs(tempP.y * tempP.z);
		}

		if (fractal->transformCommon.functionEnabledKFalse)
		{
			tempP.z = tempP.z * tempP.x;
			tempP.z *= tempP.z;
		}
		else
		{
			tempP.z = fabs(tempP.z * tempP.x);
		}

		tempP = tempP * fractal->transformCommon.scale3D000;
		planeBias = tempP.x + tempP.y + tempP.z;
	}

	// two points
	if (fractal->transformCommon.functionEnabledBxFalse)
	{
		REAL4 PtOne = z - fractal->transformCommon.offset000;
		REAL4 PtTwo = z - fractal->transformCommon.offsetA000;
		REAL distOne = length(PtOne); // * weight
		REAL distTwo = length(PtTwo);
		twoPoints = min(distOne, distTwo);
		if (fractal->transformCommon.functionEnabledAxFalse)
		{
			REAL4 PtThree = z - fractal->transformCommon.offsetF000;
			REAL distThree = length(PtThree);
			twoPoints = min(twoPoints, distThree);
		}
		twoPoints *= fractal->transformCommon.scaleA1;
	}

	// build  componentMaster
	componentMaster = (linearOffset + boxTrap + sphereTrap + planeBias + twoPoints);

	aux->colorHybrid = componentMaster;
	return z;
}