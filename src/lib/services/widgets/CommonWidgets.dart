import 'package:fitness_planner/models/BodyProgression.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';

class CommonWidgets {
  static Widget myCustomTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }

  static Widget progressCulumnChartSyncFusion({
    required BodyProgression newBodyInfo,
    required Map<String, dynamic> progressData,
  }) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      title: ChartTitle(text: 'Body Progression'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        ColumnSeries<BodyProgression, String>(
          dataSource: <BodyProgression>[
            BodyProgression(
              weight: newBodyInfo.weight,
              muscle: newBodyInfo.muscle,
              fat: newBodyInfo.fat,
              date: newBodyInfo.date,
            ),
          ],
          xValueMapper: (BodyProgression body, _) => 'New Data',
          yValueMapper: (BodyProgression body, _) => body.weight,
          name: 'Weight',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
        ColumnSeries<BodyProgression, String>(
          dataSource: <BodyProgression>[
            BodyProgression(
              weight: newBodyInfo.weight,
              muscle: newBodyInfo.muscle,
              fat: newBodyInfo.fat,
              date: newBodyInfo.date,
            ),
          ],
          xValueMapper: (BodyProgression body, _) => 'New Data',
          yValueMapper: (BodyProgression body, _) => body.muscle,
          name: 'Muscle',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
        ColumnSeries<BodyProgression, String>(
          dataSource: <BodyProgression>[
            BodyProgression(
              weight: newBodyInfo.weight,
              muscle: newBodyInfo.muscle,
              fat: newBodyInfo.fat,
              date: newBodyInfo.date,
            ),
          ],
          xValueMapper: (BodyProgression body, _) => 'New Data',
          yValueMapper: (BodyProgression body, _) => body.fat,
          name: 'Fat',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
        ColumnSeries<BodyProgression, String>(
          dataSource: <BodyProgression>[
            BodyProgression(
              weight: progressData['weightProgress'],
              muscle: progressData['muscleProgress'],
              fat: progressData['fatProgress'],
              date: newBodyInfo.date,
            ),
          ],
          xValueMapper: (BodyProgression body, _) => 'Progress',
          yValueMapper: (BodyProgression body, _) => body.weight,
          name: 'Weight Progress',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
        ColumnSeries<BodyProgression, String>(
          dataSource: <BodyProgression>[
            BodyProgression(
              weight: progressData['weightProgress'],
              muscle: progressData['muscleProgress'],
              fat: progressData['fatProgress'],
              date: newBodyInfo.date,
            ),
          ],
          xValueMapper: (BodyProgression body, _) => 'Progress',
          yValueMapper: (BodyProgression body, _) => body.muscle,
          name: 'Muscle Progress',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
        ColumnSeries<BodyProgression, String>(
          dataSource: <BodyProgression>[
            BodyProgression(
              weight: progressData['weightProgress'],
              muscle: progressData['muscleProgress'],
              fat: progressData['fatProgress'],
              date: newBodyInfo.date,
            ),
          ],
          xValueMapper: (BodyProgression body, _) => 'Progress',
          yValueMapper: (BodyProgression body, _) => body.fat,
          name: 'Fat Progress',
          dataLabelSettings: DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  static Widget entryFieldRecords(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
      ],
    );
  }

  static Widget myCustomTextFieldProgression({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  static Widget bodyProgressionChartSyncFusion({
    required List<BodyProgression> bodyProgression,
  }) {
    List<LineSeries<BodyProgression, DateTime>> series = [
      LineSeries<BodyProgression, DateTime>(
        dataSource: bodyProgression,
        xValueMapper: (BodyProgression bodyProgression, _) =>
            bodyProgression.date,
        yValueMapper: (BodyProgression bodyProgression, _) =>
            bodyProgression.weight,
        name: 'Weight',
        markerSettings: MarkerSettings(
          isVisible: true,
        ),
      ),
      LineSeries<BodyProgression, DateTime>(
        dataSource: bodyProgression,
        xValueMapper: (BodyProgression bodyProgression, _) =>
            bodyProgression.date,
        yValueMapper: (BodyProgression bodyProgression, _) =>
            bodyProgression.muscle,
        name: 'Muscle',
        markerSettings: MarkerSettings(
          isVisible: true,
        ),
      ),
      LineSeries<BodyProgression, DateTime>(
        dataSource: bodyProgression,
        xValueMapper: (BodyProgression bodyProgression, _) =>
            bodyProgression.date,
        yValueMapper: (BodyProgression bodyProgression, _) =>
            bodyProgression.fat,
        name: 'Fat',
        markerSettings: MarkerSettings(
          isVisible: true,
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 5,
        child: Container(
          height: 400,
          width: double.infinity,
          child: SfCartesianChart(
            title: ChartTitle(text: 'Body Progression'),
            legend: Legend(isVisible: true),
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat.Md(),
            ),
            series: series,
            tooltipBehavior: TooltipBehavior(
              enable: true,
            ),
          ),
        ),
      ),
    );
  }

  static Widget PieChartSyncFusion({
    required double protein,
    required double carbs,
    required double fat,
  }) {
    List<PieChartSampleData> data = [
      PieChartSampleData('Protein\n$protein', protein, Colors.red),
      PieChartSampleData('Carbs\n$carbs', carbs, Colors.blue),
      PieChartSampleData('Fat\n$fat', fat, Colors.green),
    ];

    return SfCircularChart(
      title: ChartTitle(text: 'Macros'),
      series: <CircularSeries<PieChartSampleData, String>>[
        PieSeries<PieChartSampleData, String>(
          dataSource: data,
          xValueMapper: (PieChartSampleData data, _) => data.category,
          yValueMapper: (PieChartSampleData data, _) => data.value,
          pointColorMapper: (PieChartSampleData data, _) => data.color,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
          ),
        )
      ],
    );
  }

  static Widget BmiGaugeSyncFusion({
    required double bmi,
  }) {
    String label = '';

    if (bmi < 18.5) {
      label = 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      label = 'Good';
    } else if (bmi >= 25 && bmi < 30) {
      label = 'Slightly Overweight';
    } else {
      label = 'Overweight';
    }

    return SfRadialGauge(
      title: GaugeTitle(
        text: 'BMI',
        textStyle: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 50,
          ranges: <GaugeRange>[
            GaugeRange(
              startValue: 0,
              endValue: 18.5,
              color: Colors.red,
              startWidth: 10,
              endWidth: 10,
            ),
            GaugeRange(
              startValue: 18.5,
              endValue: 25,
              color: Colors.green,
              startWidth: 10,
              endWidth: 10,
            ),
            GaugeRange(
              startValue: 25,
              endValue: 30,
              color: Colors.orange,
              startWidth: 10,
              endWidth: 10,
            ),
            GaugeRange(
              startValue: 30,
              endValue: 50,
              color: Colors.red,
              startWidth: 10,
              endWidth: 10,
            ),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
              value: bmi,
              needleLength: 0.6,
              lengthUnit: GaugeSizeUnit.factor,
              needleStartWidth: 0,
              needleEndWidth: 5,
              needleColor: Colors.black,
              knobStyle: KnobStyle(
                knobRadius: 0.05,
                sizeUnit: GaugeSizeUnit.factor,
                color: Colors.white,
              ),
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Container(
                child: Text(
                  bmi.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Adjust color as needed
                  ),
                ),
              ),
              angle: 90,
              positionFactor: 0.65, // Adjust the position as needed
            ),
            GaugeAnnotation(
              widget: Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              angle: 90,
              positionFactor: 0.8,
            ),
          ],
        ),
      ],
    );
  }
}

class PieChartSampleData {
  PieChartSampleData(this.category, this.value, this.color);

  final String category;
  final double value;
  final Color color;
}
