/*
 * randomizer_dialog.h
 *
 *  Created on: 29 gru 2019
 *      Author: krzysztof
 */

#ifndef MANDELBULBER2_QT_RANDOMIZER_DIALOG_H_
#define MANDELBULBER2_QT_RANDOMIZER_DIALOG_H_

#include <QDialog>

#include "src/fractal_container.hpp"
#include "src/parameters.hpp"
#include "src/progress_text.hpp"
#include "src/random.hpp"
#include "src/tree_string_list.h"

namespace Ui
{
class cRandomizerDialog;
}

class cImage;
class cThumbnailWidget;

class cRandomizerDialog : public QDialog
{
	Q_OBJECT

public:
	explicit cRandomizerDialog(QWidget *parent = nullptr);
	~cRandomizerDialog();

	void AssignSourceWidget(const QWidget *sourceWidget);

private:
	enum enimRandomizeStrength
	{
		randomizeSlight,
		randomizeMedium,
        randomizeHeavy,
        slider
	};

	enum enumRandomizerPreviewSize
	{
		previewSmall,
		previewMedium,
		previewBig
	};

	enum enumRandomizerPreviewQuality
	{
		previewQualityLow,
		previewQualityMedium,
		previewQualityHigh
	};

	struct sParameterVersion
	{
		cParameterContainer params;
		cFractalContainer fractParams;
		QStringList modifiedParameters;
	};

	const int numberOfVersions = 12;

	void Randomize(enimRandomizeStrength strength);
	void InitParameterContainers();
	void RefreshReferenceImage();
	void RefreshReferenceSkyImage();
	void CalcReferenceNoise();

	void CreateParametersTreeInWidget(
		cTreeStringList *tree, const QWidget *widget, int &level, int parentId);
	static cParameterContainer *ContainerSelector(
		QString fullParameterName, cParameterContainer *params, cFractalContainer *fractal);
	void RandomizeParameters(enimRandomizeStrength strength, cParameterContainer *params,
		cFractalContainer *fractal, int widgetIndex);
	void RandomizeOneParameter(QString fullParameterName, double randomScale,
		cParameterContainer *params, cFractalContainer *fractal, int widgetIndex);
	void RandomizeIntegerParameter(
		double randomScale, cOneParameter &parameter, const QString &parameterName);
	double RandomizeDoubleValue(double value, double randomScale, bool isAngle);
	void RandomizeDoubleParameter(double randomScale, bool isAngle, cOneParameter &parameter);
	void RandomizeVector3Parameter(double randomScale, bool isAngle, cOneParameter &parameter);
	void RandomizeVector4Parameter(double randomScale, bool isAngle, cOneParameter &parameter);
	int RandomizeColor16Component(double randomScale, int value);
	int RandomizeColor8Component(double randomScale, int value);
	void RandomizeRGBParameter(double randomScale, cOneParameter &parameter);
	void RandomizeBooleanParameter(cOneParameter &parameter);
	void RandomizeStringParameter(double randomScale, cOneParameter &parameter);
	void UpdateProgressBar(double progress);
	QString CreateTooltipText(const QMap<QString, QString> &list);

	// events
	void closeEvent(QCloseEvent *event) override;

private slots:
	void slotClickedSlightRandomize();
	void slotClickedMediumRandomize();
	void slotClickedHeavyRandomize();
	void slotClickedSelectButton();
	void slotClickedSaveButton();
	void slotClickedUseButton();
	void slotClickedResetButton();
	void slotPreviewRendered();
	void slotDetectedZeroDistance();
	void slotRenderTime(double time);
<<<<<<< HEAD
    void slotSlideRandomize();
=======
	void slotCleanUp();
>>>>>>> refs/remotes/krakensurf/master

private:
	Ui::cRandomizerDialog *ui;
	cTreeStringList parametersTree;
	QList<sParameterVersion> listOfVersions;
	QList<int> numbersOfRepeats;
	QList<bool> versionsDone;
	cParameterContainer actualParams;
	cFractalContainer actualFractParams;
	cRandom randomizer;
	enimRandomizeStrength actualStrength;
	cThumbnailWidget *referenceSkyPreview;
	cThumbnailWidget *referenceNoisePreview;
	cProgressText progressText;
	QList<QMap<QString, QString>> listsOfChangedParameters;
	QMap<QString, QString> actualListOfChangedParameters;

	int previewWidth;
	int previewHeight;
	int qualityMultiplier;

	double referenceNoise;
	bool pressedUse;
};

#endif /* MANDELBULBER2_QT_RANDOMIZER_DIALOG_H_ */
