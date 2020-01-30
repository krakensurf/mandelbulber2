/*
 * randomizer_dialog.cpp
 *
 *  Created on: 29 gru 2019
 *      Author: krzysztof
 */

#include "randomizer_dialog.h"

#include "ui_randomizer_dialog.h"

#include "formula/definition/all_fractal_list.hpp"
#include "common_my_widget_wrapper.h"
#include "my_group_box.h"
#include "thumbnail_widget.h"
#include "src/cimage.hpp"
#include "src/color_gradient.h"
#include "src/initparameters.hpp"
#include "src/fractal_container.hpp"
#include "src/interface.hpp"
#include "src/settings.hpp"

cRandomizerDialog::cRandomizerDialog(QWidget *parent)
		: QDialog(parent), ui(new Ui::cRandomizerDialog)
{
	ui->setupUi(this);

	setModal(true);

	randomizer.Initialize(QTime::currentTime().msec());

	actualStrength = randomizeMedium;
	referenceNoise = 0.0;
	pressedUse = false;

	int baseSize = int(systemData.GetPreferredThumbnailSize());
	int sizeSetiing = enumRandomizerPreviewSize(gPar->Get<int>("randomizer_preview_size"));
	int qualitySetiing = enumRandomizerPreviewQuality(gPar->Get<int>("randomizer_preview_quality"));
	float sizeMultiply;
	switch (sizeSetiing)
	{
		case previewSmall: sizeMultiply = 1.0; break;
		case previewMedium: sizeMultiply = 1.5; break;
		case previewBig: sizeMultiply = 2.0; break;
	}
	previewWidth = sizeMultiply * baseSize * 4 / 3;
	previewHeight = sizeMultiply * baseSize;

	qualityMultiplier = qualitySetiing + 1;

	connect(ui->pushButton_heavy, &QPushButton::clicked, this,
		&cRandomizerDialog::slotClickedHeavyRandomize);
	connect(ui->pushButton_medium, &QPushButton::clicked, this,
		&cRandomizerDialog::slotClickedMediumRandomize);
	connect(ui->pushButton_slight, &QPushButton::clicked, this,
		&cRandomizerDialog::slotClickedSlightRandomize);
<<<<<<< HEAD
	connect(ui->pushButton_use, &QPushButton::clicked, this, &cRandomizerDialog::slotClickedUseButton);
	connect(ui->pushButton_reset, &QPushButton::clicked, this, &cRandomizerDialog::slotClickedResetButton);
    connect(ui->randomSlider, &QSlider::sliderReleased, this, &cRandomizerDialog::slotSlideRandomize);
=======
	connect(
		ui->pushButton_use, &QPushButton::clicked, this, &cRandomizerDialog::slotClickedUseButton);
	connect(
		ui->pushButton_reset, &QPushButton::clicked, this, &cRandomizerDialog::slotClickedResetButton);
	connect(ui->pushButton_clean_up, &QPushButton::clicked, this, &cRandomizerDialog::slotCleanUp);
>>>>>>> refs/remotes/krakensurf/master

	for (int i = 1; i <= numberOfVersions; i++)
	{
		QString widgetName = QString("pushButton_select_%1").arg(i, 2, 10, QChar('0'));
		QPushButton *button = this->findChild<QPushButton *>(widgetName);
		connect(button, &QPushButton::clicked, this, &cRandomizerDialog::slotClickedSelectButton);
	}

	for (int i = 1; i <= numberOfVersions; i++)
	{
		QString widgetName = QString("toolButton_save_%1").arg(i, 2, 10, QChar('0'));
		QToolButton *button = this->findChild<QToolButton *>(widgetName);
		connect(button, &QToolButton::clicked, this, &cRandomizerDialog::slotClickedSaveButton);
	}

	// local copy of parameters
	actualParams = *gPar;
	actualFractParams = *gParFractal;

	ui->previewwidget_actual->SetSize(previewWidth, previewHeight, qualityMultiplier);
	ui->previewwidget_actual->DisableThumbnailCache();
	ui->previewwidget_actual->AssignParameters(actualParams, actualFractParams);
	ui->previewwidget_actual->update();

	referenceSkyPreview = new cThumbnailWidget();
	referenceSkyPreview->SetSize(previewWidth, previewHeight, qualityMultiplier);
	referenceSkyPreview->DisableThumbnailCache();
	referenceSkyPreview->DisableTimer();

	referenceNoisePreview = new cThumbnailWidget();
	referenceNoisePreview->SetSize(previewWidth, previewHeight, qualityMultiplier);
	referenceNoisePreview->DisableThumbnailCache();
	referenceNoisePreview->DisableTimer();

	for (int i = 0; i < numberOfVersions; i++)
	{
		QString widgetName = QString("previewwidget_%1").arg(i + 1, 2, 10, QChar('0'));
		cThumbnailWidget *previewWidget = this->findChild<cThumbnailWidget *>(widgetName);
		previewWidget->SetSize(previewWidth, previewHeight, qualityMultiplier);
		previewWidget->DisableThumbnailCache();
		previewWidget->UseOneCPUCore(true);

		connect(previewWidget, &cThumbnailWidget::thumbnailRendered, this,
			&cRandomizerDialog::slotPreviewRendered);
		connect(previewWidget, &cThumbnailWidget::signalZeroDistance, this,
			&cRandomizerDialog::slotDetectedZeroDistance);
		connect(previewWidget, &cThumbnailWidget::signalTotalRenderTime, this,
			&cRandomizerDialog::slotRenderTime);

		numbersOfRepeats.append(0);
		versionsDone.append(false);
		listsOfChangedParameters.append(QMap<QString, QString>());
	}
}

cRandomizerDialog::~cRandomizerDialog()
{
	delete ui;
	delete referenceSkyPreview;
	delete referenceNoisePreview;
}

void cRandomizerDialog::InitParameterContainers()
{
	// initialize parameter containers
	listOfVersions.clear();
	for (int i = 0; i < numberOfVersions; i++)
	{
		sParameterVersion version;
		version.params = actualParams;
		version.fractParams = actualFractParams;
		listOfVersions.append(version);
	}
}

void cRandomizerDialog::RefreshReferenceImage()
{
	// refresh actual reference image
	ui->previewwidget_actual->AssignParameters(actualParams, actualFractParams);
	if (!ui->previewwidget_actual->IsRendered())
	{
		ui->previewwidget_actual->slotRender();
		while (!ui->previewwidget_actual->IsRendered())
		{
			QApplication::processEvents();
			Wait(10);
		}
	}
	ui->previewwidget_actual->update();
}

void cRandomizerDialog::RefreshReferenceSkyImage()
{
	// render reference sky
	cParameterContainer parSky = actualParams;
	cFractalContainer parFractSky = actualFractParams;
	for (int i = 1; i <= NUMBER_OF_FRACTALS; i++)
	{
		parSky.Set("fractal_enable", i, false);
	}
	parSky.Set("iteration_threshold_mode", false);
	// iterThresh mode needs to be disabled to render sky, otherwise DE will be zero.
	referenceSkyPreview->AssignParameters(parSky, parFractSky);
	if (!referenceSkyPreview->IsRendered())
	{
		referenceSkyPreview->slotRender();
		while (!referenceSkyPreview->IsRendered())
		{
			QApplication::processEvents();
			Wait(10);
		}
	}
}

void cRandomizerDialog::CalcReferenceNoise()
{
	// render the same image as actual to calculate reference noise
	referenceNoisePreview->AssignParameters(actualParams, actualFractParams);
	if (!referenceNoisePreview->IsRendered())
	{
		referenceNoisePreview->slotRender();
		while (!referenceNoisePreview->IsRendered())
		{
			QApplication::processEvents();
			Wait(10);
		}
	}
	cImage *actualImage = ui->previewwidget_actual->GetImage();
	cImage *noiseRefImage = referenceNoisePreview->GetImage();
	referenceNoise = noiseRefImage->VisualCompare(actualImage, true);
	// qDebug() << "Reference noise: " << referenceNoise;
}

void cRandomizerDialog::Randomize(enimRandomizeStrength strength)
{
	actualStrength = strength;

	QString progressBarText("Initializing Randomizer");
	ui->progressBar->setFormat(progressBarText);
	ui->progressBar->setValue(0.0);

	// initialize parameter containers
	InitParameterContainers();

	progressText.ResetTimer();

	// refresh actual reference image
	RefreshReferenceImage();

	// render reference sky
	RefreshReferenceSkyImage();

	// render the same image as actual to calculate reference noise
	CalcReferenceNoise();

	// randomizing
	for (int i = 0; i < numberOfVersions; i++)
	{
		// qDebug() << "Version " << i;

		numbersOfRepeats[i] = 0;
		versionsDone[i] = false;

		RandomizeParameters(strength, &listOfVersions[i].params, &listOfVersions[i].fractParams, i);

		QString widgetName = QString("previewwidget_%1").arg(i + 1, 2, 10, QChar('0'));
		// qDebug() << widgetName;
		cThumbnailWidget *previewWidget = this->findChild<cThumbnailWidget *>(widgetName);
		// qDebug() << previewWidget;
		previewWidget->AssignParameters(listOfVersions.at(i).params, listOfVersions.at(i).fractParams);
		previewWidget->setToolTip(CreateTooltipText(listsOfChangedParameters[i]));
		previewWidget->update();
	}
}

void cRandomizerDialog::slotClickedSlightRandomize()
{
	Randomize(randomizeSlight);
}

void cRandomizerDialog::slotClickedMediumRandomize()
{
	Randomize(randomizeMedium);
}

void cRandomizerDialog::slotClickedHeavyRandomize()
{
	Randomize(randomizeHeavy);
}
void cRandomizerDialog::slotSlideRandomize()
{
    Randomize(slider);
}

void cRandomizerDialog::AssignSourceWidget(const QWidget *sourceWidget)
{
	int level = 0;
	setWindowTitle(QString("Randomizer (for parameters from %1)").arg(sourceWidget->objectName()));
	CreateParametersTreeInWidget(&parametersTree, sourceWidget, level, 0);
}

void cRandomizerDialog::RandomizeIntegerParameter(
	double randomScale, cOneParameter &parameter, const QString &parameterName)
{
	int min = parameter.Get<int>(valueMin);
	int max = parameter.Get<int>(valueMax);
	int value = parameter.Get<int>(valueActual);
	if (parameterName.contains(QRegularExpression("formula_\\d")))
	{
		// qDebug() << "*********** randomizing fractal *******************";
		// find fractal on the list
		int indexOnFractalList = -1;
		for (int i = 0; i < newFractalList.size(); i++)
		{
			if (newFractalList.at(i)->getInternalId() == value)
			{
				indexOnFractalList = i;
				break;
			}
		}
		int minIndex = indexOnFractalList - newFractalList.size() * randomScale;
		minIndex = qMax(minIndex, 0);
		int maxIndex = indexOnFractalList + newFractalList.size() * randomScale;
		maxIndex = qMin(maxIndex, newFractalList.size() - 1);

		int r = randomizer.Random(maxIndex - minIndex) + minIndex;
		value = newFractalList.at(r)->getInternalId();
	}
	else
	{
		int sign = randomizer.Random(1);
		if (sign == 0 || value == min)
		{
			int range = max - value - 1;
			if (range > 0)
			{
				int r = randomizer.Random(range) * randomScale + 1;
				value += r;
			}
			else
			{
				value++;
			}
		}
		else
		{
			int range = value - min - 1;
			if (range > 0)
			{
				int r = randomizer.Random(range) * randomScale + 1;
				value -= r;
			}
			else
			{
				value--;
			}
		}
		if (min != max)
		{
			if (value > max) value = max;
			if (value < min) value = min;
		}
	}
	parameter.Set(value, valueActual);
}

void cRandomizerDialog::RandomizeDoubleParameter(
	double randomScale, bool isAngle, cOneParameter &parameter)
{
	double min = parameter.Get<double>(valueMin);
	double max = parameter.Get<double>(valueMax);
	double value = parameter.Get<double>(valueActual);
	if (value == 0.0)
	{
		if (min < 0.0)
		{
			if (isAngle)
				value = randomizer.Random(-randomScale * 180.0, randomScale * 180.0, randomScale / 10.0);
			else
				value = randomizer.Random(-randomScale, randomScale, randomScale / 1000.0);
		}
		else
		{
			value = randomizer.Random(0.0, randomScale, randomScale / 1000.0);
		}
	}
	else
	{
		if (min < 0.0)
		{
			double r = randomizer.Random(-randomScale * 5.0, randomScale * 5.0, randomScale / 1000.0);
			value += r;
		}
		else
		{
			double r = randomizer.Random(-randomScale, randomScale, randomScale / 1000.0);
			value = value * pow(10.0, r);
		}

		if (min != max)
		{
			if (value > max) value = max;
			if (value < min) value = min;
		}
	}
	parameter.Set(value, valueActual);
}

double cRandomizerDialog::RandomizeDoubleValue(double value, double randomScale, bool isAngle)
{
	if (value == 0)
	{
		if (isAngle)
			value = randomizer.Random(-randomScale * 180.0, randomScale * 180.0, randomScale / 10.0);
		else
			value = randomizer.Random(-randomScale, randomScale, randomScale / 1000.0);
	}
	else
	{
		double r = randomizer.Random(-randomScale, randomScale, randomScale / 1000.0);
		value = value * pow(10.0, r);
		if (isAngle)
		{
			value = fmod(value + 3 * M_PI, 2 * M_PI) - M_PI;
		}
	}
	return value;
}

void cRandomizerDialog::RandomizeVector3Parameter(
	double randomScale, bool isAngle, cOneParameter &parameter)
{
	CVector3 value = parameter.Get<CVector3>(valueActual);
	value.x = RandomizeDoubleValue(value.x, randomScale, isAngle);
	value.y = RandomizeDoubleValue(value.y, randomScale, isAngle);
	value.z = RandomizeDoubleValue(value.z, randomScale, isAngle);
	parameter.Set(value, valueActual);
}

void cRandomizerDialog::RandomizeVector4Parameter(
	double randomScale, bool isAngle, cOneParameter &parameter)
{
	CVector4 value = parameter.Get<CVector4>(valueActual);
	value.x = RandomizeDoubleValue(value.x, randomScale, isAngle);
	value.y = RandomizeDoubleValue(value.y, randomScale, isAngle);
	value.z = RandomizeDoubleValue(value.z, randomScale, isAngle);
	value.w = RandomizeDoubleValue(value.w, randomScale, isAngle);
	parameter.Set(value, valueActual);
}

int cRandomizerDialog::RandomizeColor16Component(double randomScale, int value)
{
	int min = value - randomScale * 65535;
	if (min < 0) min = 0;
	int max = value + randomScale * 65535;
	if (max > 65535) max = 65535;
	int range = max - min;
	int r = randomizer.Random(range);
	value = min + r;
	if (value < 0) value = 0;
	if (value > 65536) value = 65535;
	return value;
}

int cRandomizerDialog::RandomizeColor8Component(double randomScale, int value)
{
	int min = value - randomScale * 255;
	if (min < 0) min = 0;
	int max = value + randomScale * 255;
	if (max > 255) max = 255;
	int range = max - min;
	int r = randomizer.Random(range);
	value = min + r;
	if (value < 0) value = 0;
	if (value > 255) value = 255;
	return value;
}

void cRandomizerDialog::RandomizeRGBParameter(double randomScale, cOneParameter &parameter)
{
	sRGB value = parameter.Get<sRGB>(valueActual);
	value.R = RandomizeColor16Component(randomScale, value.R);
	value.G = RandomizeColor16Component(randomScale, value.G);
	value.B = RandomizeColor16Component(randomScale, value.B);
	parameter.Set(value, valueActual);
}

void cRandomizerDialog::RandomizeBooleanParameter(cOneParameter &parameter)
{
	parameter.Set(!parameter.Get<bool>(valueActual), valueActual);
}

void cRandomizerDialog::RandomizeStringParameter(double randomScale, cOneParameter &parameter)
{
	if (parameter.IsGradient())
	{
		cColorGradient gradient;
		gradient.SetColorsFromString(parameter.Get<QString>(valueActual));
		int numberOfColors = gradient.GetNumberOfColors();

		if (numberOfColors == 2)
		{
			int numberOfColors = randomizer.Random(18) + 2;
			gradient.DeleteAll();
			for (int i = 0; i < numberOfColors; i++)
			{
				sRGB color(randomizer.Random(255), randomizer.Random(255), randomizer.Random(255));
				float position = randomizer.Random(10000) / 10000.0f;
				if (i == 0)
				{
					gradient.AddColor(color, 0.0f);
					gradient.AddColor(color, 1.0f);
				}
				else
				{
					gradient.AddColor(color, position);
				}
			}
		}
		else
		{
			for (int i = 0; i < numberOfColors; i++)
			{
				sRGB color = gradient.GetColorByIndex(i);
				color.R = RandomizeColor8Component(randomScale, color.R);
				color.G = RandomizeColor8Component(randomScale, color.G);
				color.B = RandomizeColor8Component(randomScale, color.B);
				gradient.ModifyColor(i, color);

				if (i == 0)
				{
					gradient.ModifyColor(1, color);
					i++;
				}

				if (i >= 2)
				{
					float position = gradient.GetPositionByIndex(i);
					float delta = 1.0 / numberOfColors * randomScale;
					float r = randomizer.Random(-delta, delta, delta / 100.0);
					position += r;
					if (position < 0.0) position = 0.0;
					if (position > 1.0) position = 1.0;
					gradient.ModifyPosition(i, position);
				}
			}
		}
		QString gradientString = gradient.GetColorsAsString();
		parameter.Set(gradientString, valueActual);
	}
}

void cRandomizerDialog::RandomizeParameters(enimRandomizeStrength strength,
	cParameterContainer *params, cFractalContainer *fractal, int widgetIndex)
{
	listsOfChangedParameters[widgetIndex].clear();

	int numberOfParameters = parametersTree.GetSize();

	if (numberOfParameters <= 1) return; // no parameters to random (only "root")

	int numberOfParametersToChange = 0;
	double randomScale = 1.0;

	switch (strength)
	{
		case randomizeSlight:
		{
			numberOfParametersToChange = 1;
			randomScale = 0.1;
			break;
		}
		case randomizeMedium:
		{
			numberOfParametersToChange = numberOfParameters / 100 + 2;
			randomScale = 0.5;
			break;
		}
		case randomizeHeavy:
		{
			numberOfParametersToChange = numberOfParameters / 10 + 3;
			randomScale = 1.0;
			break;
		}
        case slider:
        {
            double slideVal = ui->randomSlider->value();
           // double inverseVal = 101-slideVal;
            if(slideVal > 10 && slideVal < 49) {
                numberOfParametersToChange = numberOfParameters / 100 + 2;
            }
            else if(slideVal > 50 && slideVal < 101){
                numberOfParametersToChange = numberOfParameters / 10 + 3;
            }
            else {
                numberOfParametersToChange = 1;
            }

            randomScale = slideVal/100;
            break;
        }
	}
	numberOfParametersToChange = qMin(numberOfParametersToChange, numberOfParameters);

	QVector<int> listOfIndexes;

	for (int i = 0; i < numberOfParametersToChange; i++)
	{
		int randomIndex = 0;
		int trialCounter = numberOfParameters * 10;
		do
		{
			if (numberOfParameters > 2)
			{
				randomIndex =
					randomizer.Random(numberOfParameters - 2) + 1; // first string in the tree is root
			}
			else
			{
				randomIndex = 1; // there is only parameter #1
			}
			trialCounter--;
		} while (listOfIndexes.contains(randomIndex) && trialCounter > 0);
		listOfIndexes.append(randomIndex);

		QString fullParameterName = parametersTree.GetString(randomIndex);
		// qDebug() << fullParameterName;

		// check is parameter is enabled
		bool skip = false;

		if (!parametersTree.IsEnabled(randomIndex))
		{
			i--;
			continue;
		}

		int actualParameterIndex = randomIndex;
		int parentIndex = 0;
		do
		{
			parentIndex = parametersTree.GetParentIndex(actualParameterIndex);
			if (parentIndex >= 0)
			{
				// qDebug() << "--Checking parent:" << parametersTree.GetString(parentIndex);

				if (parametersTree.GetString(parentIndex) == "root") break;

				bool hidden = !parametersTree.IsEnabled(parentIndex);
				if (hidden)
				{
					// qDebug() << "is hidden";
					skip = true;
					break;
				}

				QString fullParameterNameToCheck = parametersTree.GetString(parentIndex);
				cParameterContainer *container =
					ContainerSelector(fullParameterNameToCheck, params, fractal);
				int firstDashIndex = fullParameterNameToCheck.indexOf("_");
				QString parameterName = fullParameterNameToCheck.mid(firstDashIndex + 1);
				if (!container->Get<bool>(parameterName))
				{
					skip = true;
					break;
				}
				actualParameterIndex = parentIndex;
			}
		} while (parentIndex >= 0);

		if (skip)
		{
			i--;
			continue;
		}

		// if parameter is a group then enable this group and randomize deeper parameter
		if (parametersTree.IsGroup(randomIndex))
		{
			QList<int> childrens = parametersTree.GetChildrens(randomIndex);

			int randomChildIndex;
			if (childrens.size() > 1)
			{
				randomChildIndex = randomizer.Random(childrens.size() - 1);
			}
			else
			{
				randomChildIndex = 0;
			}
			int deeperRandomIndex = childrens.at(randomChildIndex);

			// enable group
			cParameterContainer *container = ContainerSelector(fullParameterName, params, fractal);
			int firstDashIndex = fullParameterName.indexOf("_");
			QString parameterName = fullParameterName.mid(firstDashIndex + 1);
			container->Set(parameterName, true);

			// and further randomize one of deeper parameters
			fullParameterName = parametersTree.GetString(deeperRandomIndex);
			// qDebug() << "----Deeper: " << fullParameterName;
		}

		RandomizeOneParameter(fullParameterName, randomScale, params, fractal, widgetIndex);
	}
}

void cRandomizerDialog::RandomizeOneParameter(QString fullParameterName, double randomScale,
	cParameterContainer *params, cFractalContainer *fractal, int widgetIndex)
{
	cParameterContainer *container = ContainerSelector(fullParameterName, params, fractal);
	int firstDashIndex = fullParameterName.indexOf("_");
	QString parameterName = fullParameterName.mid(firstDashIndex + 1);
	// qDebug() << "---Randomizing: " << container->GetContainerName() << parameterName;

	cOneParameter parameter = container->GetAsOneParameter(parameterName);
	enumVarType varType = parameter.GetValueType();
	enumMorphType morphType = parameter.GetMorphType();
	bool isAngle = false;
	if (morphType == morphLinearAngle || morphType == morphCatMullRomAngle
			|| morphType == morphAkimaAngle)
		isAngle = true;

	switch (varType)
	{
		case typeInt:
		{
			RandomizeIntegerParameter(randomScale, parameter, parameterName);
			break;
		}
		case typeDouble:
		{
			RandomizeDoubleParameter(randomScale, isAngle, parameter);
			break;
		}
		case typeString:
		{
			RandomizeStringParameter(randomScale, parameter);
			break;
		}
		case typeVector3:
		{
			RandomizeVector3Parameter(randomScale, isAngle, parameter);
			break;
		}
		case typeVector4:
		{
			RandomizeVector4Parameter(randomScale, isAngle, parameter);
			break;
		}
		case typeRgb:
		{
			RandomizeRGBParameter(randomScale, parameter);
			break;
		}
		case typeBool:
		{
			RandomizeBooleanParameter(parameter);
			break;
		}
		default: break;
	}

	container->SetFromOneParameter(parameterName, parameter);

	if (!listsOfChangedParameters[widgetIndex].contains(fullParameterName))
	{
		QString parameterValueString = container->Get<QString>(parameterName);
		listsOfChangedParameters[widgetIndex].insert(fullParameterName, parameterValueString);
	}
}

void cRandomizerDialog::CreateParametersTreeInWidget(
	cTreeStringList *tree, const QWidget *widget, int &level, int parentId)
{
	QList<QWidget *> listChildrenWidgets =
		widget->findChildren<QWidget *>(QString(), Qt::FindDirectChildrenOnly);

	if (listChildrenWidgets.size() > 0)
	{
		QSet<QString> listOfParameters;

		foreach (QWidget *w, listChildrenWidgets)
		{
			// qDebug() << QString(level, ' ') << "Widget: " << w->objectName();

			int newParentId = -1;

			CommonMyWidgetWrapper *myWidget = dynamic_cast<CommonMyWidgetWrapper *>(w);
			if (myWidget)
			{
				QString parameterName = myWidget->getFullParameterName();

				// exceptions
				if (parameterName.contains("material_id")) continue;
				if (parameterName == "info") continue;
				if (parameterName == "analyticDE_enabled") continue;
				if (parameterName == "analyticDE_enabled_false") continue;
				if (parameterName == "analyticDE_scale_1") continue;
				if (parameterName == "analyticDE_tweak_005") continue;
				if (parameterName == "analyticDE_offset_0") continue;
				if (parameterName == "analyticDE_offset_1") continue;
				if (parameterName == "analyticDE_offset_2") continue;

				QString containerName = myWidget->getParameterContainerName();
				QString fullParameterName = containerName + "_" + parameterName;
				listOfParameters.insert(fullParameterName);

				// qDebug() << QString(level, ' ') << "ParameterName: " << fullParameterName;

				bool hidden = w->isHidden();
				// if (hidden) qDebug() << "hidden";

				int newId = tree->AddChildItem(fullParameterName, !hidden, parentId);

				if (dynamic_cast<MyGroupBox *>(w))
				{
					// qDebug() << QString(level, ' ') << "GroupBox:" << fullParameterName;
					newParentId = newId;
				}
			}

			// recursion
			level++;
			CreateParametersTreeInWidget(tree, w, level, (newParentId >= 0) ? newParentId : parentId);
		}
	}
	level--;
}

cParameterContainer *cRandomizerDialog::ContainerSelector(
	QString fullParameterName, cParameterContainer *params, cFractalContainer *fractal)
{
	cParameterContainer *container = nullptr;

	int firstDashIndex = fullParameterName.indexOf("_");
	QString containerName = fullParameterName.left(firstDashIndex);

	if (containerName == "main")
	{
		container = params;
	}
	else if (containerName.indexOf("fractal") >= 0)
	{
		const int index = containerName.rightRef(1).toInt();
		if (index < NUMBER_OF_FRACTALS)
		{
			container = &fractal->at(index);
		}
		else
		{
			qWarning() << "cRandomizerDialog::ContainerSelector(): wrong fractal container index"
								 << containerName << index;
		}
	}
	else
	{
		qWarning() << "cRandomizerDialog::ContainerSelector(): wrong container name" << containerName;
	}

	return container;
}

void cRandomizerDialog::slotClickedSelectButton()
{
	QString buttonName = this->sender()->objectName();
	QString numberString = buttonName.right(2);
	int buttonNumber = numberString.toInt();

	actualParams = listOfVersions.at(buttonNumber - 1).params;
	actualFractParams = listOfVersions.at(buttonNumber - 1).fractParams;

	ui->previewwidget_actual->AssignParameters(actualParams, actualFractParams);
	ui->previewwidget_actual->update();

	// update main list of changed parameters
	QMapIterator<QString, QString> i(listsOfChangedParameters[buttonNumber - 1]);
	while (i.hasNext())
	{
		i.next();
		if (!actualListOfChangedParameters.contains(i.key()))
		{
			actualListOfChangedParameters.insert(i.key(), i.value());
		}
	}
	ui->previewwidget_actual->setToolTip(CreateTooltipText(actualListOfChangedParameters));
}

void cRandomizerDialog::slotClickedSaveButton()
{
	QString buttonName = this->sender()->objectName();
	QString numberString = buttonName.right(2);
	int buttonNumber = numberString.toInt();

	cSettings parSettings(cSettings::formatCondensedText);
	parSettings.CreateText(
		&listOfVersions.at(buttonNumber - 1).params, &listOfVersions.at(buttonNumber - 1).fractParams);

	QFileDialog dialog(this);
	dialog.setOption(QFileDialog::DontUseNativeDialog);
	dialog.setFileMode(QFileDialog::AnyFile);
	dialog.setNameFilter(tr("Fractals (*.txt *.fract)"));
	dialog.setDirectory(
		QDir::toNativeSeparators(QFileInfo(systemData.lastSettingsFile).absolutePath()));
	dialog.selectFile(
		QDir::toNativeSeparators(QFileInfo(systemData.lastSettingsFile).completeBaseName()));
	dialog.setAcceptMode(QFileDialog::AcceptSave);
	dialog.setWindowTitle(tr("Save settings..."));
	dialog.setDefaultSuffix("fract");
	QStringList filenames;
	if (dialog.exec())
	{
		filenames = dialog.selectedFiles();
		QString filename = QDir::toNativeSeparators(filenames.first());
		parSettings.SaveToFile(filename);
		systemData.lastSettingsFile = filename;
	}
}

void cRandomizerDialog::slotClickedUseButton()
{
	pressedUse = true;
	*gPar = actualParams;
	*gParFractal = actualFractParams;
	gMainInterface->SynchronizeInterface(gPar, gParFractal, qInterface::write);
	close();
}

void cRandomizerDialog::slotPreviewRendered()
{
	QString previewName = this->sender()->objectName();
	QString numberString = previewName.right(2);
	int previewNumber = numberString.toInt();

	//qDebug() << "Preview finished " << previewNumber;

	cThumbnailWidget *widget = qobject_cast<cThumbnailWidget *>(this->sender());
	widget->update();
	if (widget)
	{
		cImage *image = widget->GetImage();
		cImage *actualImage = ui->previewwidget_actual->GetImage();
		cImage *skyImage = referenceSkyPreview->GetImage();
		double difference = image->VisualCompare(actualImage, true) - referenceNoise;
		double differenceSky = image->VisualCompare(skyImage, true) - referenceNoise;

		// compare with all another versions
		for (int i = 1; i <= numberOfVersions; i++)
		{
			if (i == previewNumber) continue; // do not compare with the same image
			if (versionsDone.at(i - 1))
			{
				QString widgetName = QString("previewwidget_%1").arg(i, 2, 10, QChar('0'));
				cThumbnailWidget *previewWidget = this->findChild<cThumbnailWidget *>(widgetName);
				cImage *imageFromOtherVersion = previewWidget->GetImage();
				double diffOther =
					(image->VisualCompare(imageFromOtherVersion, false) - referenceNoise) / 3.0;
				// divided by 3 to make bigger differences between versions
				difference = min(difference, diffOther);
				//qDebug() << i << diffOther << difference;
			}
		}

		int numberOfRepeats = numbersOfRepeats.at(previewNumber - 1);
		//qDebug() << "Differences: " << referenceNoise << difference << differenceSky << numberOfRepeats;

		if (difference < referenceNoise * 3 || differenceSky < referenceNoise * 3)
		{
			if (numberOfRepeats < 10)
			{
				numberOfRepeats++;
				numbersOfRepeats[previewNumber - 1] = numberOfRepeats;

				listOfVersions[previewNumber - 1].params = actualParams;
				listOfVersions[previewNumber - 1].fractParams = actualFractParams;

				RandomizeParameters(actualStrength, &listOfVersions[previewNumber - 1].params,
					&listOfVersions[previewNumber - 1].fractParams, previewNumber - 1);
				widget->AssignParameters(listOfVersions.at(previewNumber - 1).params,
					listOfVersions.at(previewNumber - 1).fractParams);
				widget->setToolTip(CreateTooltipText(listsOfChangedParameters[previewNumber - 1]));
				widget->update();
			}
			else
			{
				versionsDone[previewNumber - 1] = true;
			}
		}
		else
		{
			versionsDone[previewNumber - 1] = true;
		}
	}

	int doneCount = versionsDone.count(true);
	double progress = double(doneCount) / (numberOfVersions);
	UpdateProgressBar(progress);
}

void cRandomizerDialog::slotDetectedZeroDistance()
{
	QString previewName = this->sender()->objectName();
	QString numberString = previewName.right(2);
	int previewNumber = numberString.toInt();
	cThumbnailWidget *widget = qobject_cast<cThumbnailWidget *>(this->sender());
	//qDebug() << "ZERO DISTANCE DETECTED " << previewNumber;

	int numberOfRepeats = numbersOfRepeats.at(previewNumber - 1);
	if (numberOfRepeats < 100)
	{
		numberOfRepeats++;
		numbersOfRepeats[previewNumber - 1] = numberOfRepeats;

		listOfVersions[previewNumber - 1].params = actualParams;
		listOfVersions[previewNumber - 1].fractParams = actualFractParams;

		RandomizeParameters(actualStrength, &listOfVersions[previewNumber - 1].params,
			&listOfVersions[previewNumber - 1].fractParams, previewNumber - 1);
		widget->AssignParameters(listOfVersions.at(previewNumber - 1).params,
			listOfVersions.at(previewNumber - 1).fractParams);
		widget->setToolTip(CreateTooltipText(listsOfChangedParameters[previewNumber - 1]));
		widget->update();
	}
}

void cRandomizerDialog::closeEvent(QCloseEvent *event)
{
	if (pressedUse)
	{
		event->accept();
	}
	else
	{
		event->ignore();
		if (QMessageBox::Yes
				== QMessageBox::question(
					this, "Close Confirmation", "Exit Randomizer?", QMessageBox::Yes | QMessageBox::No))
		{
			event->accept();
		}
	}
}

void cRandomizerDialog::UpdateProgressBar(double progress)
{
	QString progressBarText = progressText.getText(progress);
	ui->progressBar->setFormat(progressBarText);
	ui->progressBar->setValue(progress * 1000);
}

void cRandomizerDialog::slotClickedResetButton()
{
	actualParams = *gPar;
	actualFractParams = *gParFractal;
	ui->previewwidget_actual->AssignParameters(actualParams, actualFractParams);
	if (!ui->previewwidget_actual->IsRendered())
	{
		ui->previewwidget_actual->slotRender();
		while (!ui->previewwidget_actual->IsRendered())
		{
			QApplication::processEvents();
			Wait(10);
		}
	}
	ui->previewwidget_actual->update();
	actualListOfChangedParameters.clear();
}

QString cRandomizerDialog::CreateTooltipText(const QMap<QString, QString> &list)
{
	QString text = "List of randomized parameters:\n";
	QMapIterator<QString, QString> i(list);
	while (i.hasNext())
	{
		i.next();
		text += QString("%1 = %2\n").arg(i.key()).arg(i.value());
	}
	return text;
}

void cRandomizerDialog::slotRenderTime(double time)
{
	QString previewName = this->sender()->objectName();
	QString numberString = previewName.right(2);
	int previewNumber = numberString.toInt();

	QString widgetName = QString("groupBox_version_%1").arg(previewNumber, 2, 10, QChar('0'));
	QGroupBox *groupboxWidget = this->findChild<QGroupBox *>(widgetName);

	QString versionTimeString;
	versionTimeString = tr("Version %1, time %2s").arg(previewNumber).arg(time, 0, 'f', 1);

	groupboxWidget->setTitle(versionTimeString);
}

void cRandomizerDialog::slotCleanUp()
{
	QString progressBarText("Initializing cleaning up");
	ui->progressBar->setFormat(progressBarText);
	ui->progressBar->setValue(0.0);

	progressText.ResetTimer();

	// refresh actual reference image
	RefreshReferenceImage();

	// render the same image as actual to calculate reference noise
	CalcReferenceNoise();

	cParameterContainer actualParamsCleaned = actualParams;
	cFractalContainer actualFractParamsCleaned = actualFractParams;

	QList<QString> list = actualListOfChangedParameters.keys();

	cThumbnailWidget *cleanedPreview = new cThumbnailWidget();
	cleanedPreview->SetSize(previewWidth, previewHeight, qualityMultiplier);
	cleanedPreview->DisableThumbnailCache();
	cleanedPreview->DisableTimer();

	for (int i = 0; i < list.size(); i++)
	{
		QString fullParameterName = list.at(i);
		int firstDashIndex = fullParameterName.indexOf("_");
		QString parameterName = fullParameterName.mid(firstDashIndex + 1);

		cParameterContainer *containerOrigin = ContainerSelector(fullParameterName, gPar, gParFractal);

		cParameterContainer *containerCleaned =
			ContainerSelector(fullParameterName, &actualParamsCleaned, &actualFractParamsCleaned);

		cParameterContainer *containerActual =
			ContainerSelector(fullParameterName, &actualParams, &actualFractParams);

		cOneParameter parameterOrigin = containerOrigin->GetAsOneParameter(parameterName);
		containerCleaned->SetFromOneParameter(parameterName, parameterOrigin);

		// render cleaned settings
		cleanedPreview->AssignParameters(actualParamsCleaned, actualFractParamsCleaned);
		if (!cleanedPreview->IsRendered())
		{
			cleanedPreview->slotRender();
			while (!cleanedPreview->IsRendered())
			{
				QApplication::processEvents();
				Wait(10);
			}
		}
		cImage *actualImage = ui->previewwidget_actual->GetImage();
		cImage *cleanedImage = cleanedPreview->GetImage();
		double diff = cleanedImage->VisualCompare(actualImage, false);

		// retrieve randomized parameter because change was significant
		if (diff > referenceNoise * 3)
		{
			cOneParameter parameterActual = containerActual->GetAsOneParameter(parameterName);
			containerCleaned->SetFromOneParameter(parameterName, parameterActual);
		}
		else
		{
			actualListOfChangedParameters.remove(fullParameterName);
		}

		double progress = double(i + 1) / (list.size());
		UpdateProgressBar(progress);
		QApplication::processEvents();
	}

	actualParams = actualParamsCleaned;
	actualFractParams = actualFractParamsCleaned;

	// refresh actual reference image
	RefreshReferenceImage();
	ui->previewwidget_actual->setToolTip(CreateTooltipText(actualListOfChangedParameters));

	delete cleanedPreview;
}
