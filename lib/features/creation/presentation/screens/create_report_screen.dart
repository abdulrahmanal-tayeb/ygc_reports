import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:ygc_reports/core/utils/validators.dart';
import 'package:ygc_reports/features/creation/presentation/utils/utils.dart';
import 'package:ygc_reports/providers/report_provider.dart';
import 'package:ygc_reports/widgets/collapsable.dart';
import 'package:ygc_reports/widgets/time_input_field.dart';

class CreateReportScreen extends StatelessWidget {
  const CreateReportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportProvider(),
      child: Scaffold(
        appBar: AppBar(title: Text('Create Report')),
        body: const CreateReportForm(),
      ),
    );
  }
}

class CreateReportForm extends StatefulWidget {
  const CreateReportForm({super.key});
  @override
  State<CreateReportForm> createState() => _CreateReportFormState();
}


class _CreateReportFormState extends State<CreateReportForm> {
  final double spaceBetweenInputs = 20;
  List<Map<String, double>> pumpRows = [
    {"start": 0.0, "end": 0.0}
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportProvider>(context);
    final model = provider.model;

    return Form(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Metadata Section ---
          buildSection(
            title: 'Metadata',
            children: [
              _spaced(TextFormField(
                decoration: const InputDecoration(labelText: 'Station Name'),
                initialValue: model.stationName,
                onChanged: provider.setStationName,
                validator: (val) => Validators.required(val, 'Station Name'),
              )),
              _spaced(GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: model.date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) provider.setDate(picked);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Date'),
                    controller: TextEditingController(
                      text: model.date.toString().split(" ")[0],
                    ),
                  ),
                ),
              )),
              _spaced(TimeInputField(
                label: 'Begin Time',
                initialTime: model.beginTime,
                onTimeChanged: provider.setBeginTime,
              )),
              _spaced(TimeInputField(
                label: 'End Time',
                initialTime: model.endTime,
                onTimeChanged: provider.setEndTime,
              )),
            ],
          ),

          buildSection(
            title: 'Station Status',
            children: [
              _spaced(buildNumberField(context, 'Start Liters', model.startLiters, 'startLiters')),
              _spaced(buildNumberField(context, 'End Liters', model.endLiters, 'endLiters')),
              _spaced(buildNumberField(context, 'Total Consumed', model.totalConsumed, 'totalConsumed')),
            ],
          ),
          buildSection(
            title: 'Pump Readings',
            children: [
              ...List.generate(pumpRows.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Start Liters'),
                          initialValue: pumpRows[index]["start"].toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            setState(() {
                              pumpRows[index]["start"] = double.tryParse(val) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'End Liters'),
                          initialValue: pumpRows[index]["end"].toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            setState(() {
                              pumpRows[index]["end"] = double.tryParse(val) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: pumpRows.length > 1
                            ? () {
                                setState(() => pumpRows.removeAt(index));
                              }
                            : null,
                      ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    pumpRows.add({"start": 0.0, "end": 0.0});
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Row"),
              ),
            ],
          ),

          buildSection(
            title: 'Notes',
            children: [
              _spaced(buildNumberField(context, 'Filled for People (L)', model.filledForPeople, 'filledForPeople')),
              _spaced(TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                initialValue: model.notes,
                maxLines: 3,
                onChanged: (v) => provider.setField('notes', v),
              )),
            ],
          ),

          buildSection(
            title: 'Workers',
            children: [
              _spaced(TextFormField(
                decoration: const InputDecoration(labelText: 'Station Worker Name'),
                initialValue: model.workerName,
                onChanged: (v) => provider.setField('workerName', v),
              )),
              _spaced(TextFormField(
                decoration: const InputDecoration(labelText: 'YGC Representative Name'),
                initialValue: model.representativeName,
                onChanged: (v) => provider.setField('representativeName', v),
              )),
              const SizedBox(height: 10),
              const Placeholder(fallbackHeight: 60),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async => await Printing.layoutPdf(
              onLayout: (PdfPageFormat format) => generateReportPdf(stationName: model.stationName, startTime: model.beginTime.toString(), endTime: model.endTime.toString(), pumpRows: pumpRows, filledForPeople: model.filledForPeople, notes: model.notes),
            ), 
            child: const Text("Create")
          )
        ],
      ),
    );
  }

  Widget buildSection({required String title, required List<Widget> children}) {
    return Collapsable(
      name: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...children,
        ],
      )
    );
  }

  Widget buildNumberField(BuildContext context, String label, double value, String fieldName) {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      onChanged: (val) => provider.setField(fieldName, double.tryParse(val) ?? 0),
      validator: (val) => Validators.positiveNumber(val, label),
    );
  }

  Widget _spaced(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: child,
      );
}
