import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:ygc_reports/core/constants/report_type.dart';
import 'package:ygc_reports/core/utils/validators.dart';
import 'package:ygc_reports/features/creation/presentation/utils/utils.dart';
import 'package:ygc_reports/modals/share_type_sheet/share_type_sheet.dart';
import 'package:ygc_reports/models/report_model.dart';
import 'package:ygc_reports/providers/report_provider.dart';
import 'package:ygc_reports/widgets/collapsable.dart';
import 'package:ygc_reports/widgets/focus_text_field.dart';
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
  List<Map<String, int>> pumpRows = [
    {"start": 0, "end": 0, "total": 0}
  ];


  void updateTotalTankLoad(ReportProvider provider){
    final ReportModel model = provider.model;
    final totalLoad = model.tankLoad + model.inboundAmount;
    model.totalLoad = totalLoad;
    provider.notify();
  }

  void updateReadingRow(String key, int index, int reading){
    final Map<String, int> row = pumpRows[index];
    row[key] = reading;
    row["total"] = (row["end"] ?? 0) - (row["start"] ?? 0);
    pumpRows[index] = row;
    setState((){});
  }

  void updateNotesReadings(ReportProvider provider){
    final ReportModel model = provider.model;
    model.tanksForPeople = (model.filledForPeople / 20).round();
    model.filledForBuses = model.totalConsumed - model.filledForPeople;
    provider.notify();
  }


  void updateDependantFields(ReportProvider provider) {
    final ReportModel model = provider.model;
    if(model.pumpsReadings == null) return;
    model.totalConsumed = model.pumpsReadings!.fold(0, (int sum, Map<String, int> reading) => sum + reading["total"]!);
    debugPrint("MODEL TOTAL BROOOOOOOOOOOOO: ${model.totalConsumed}");
    model.remainingLoad = model.totalLoad - model.totalConsumed;
    if(model.totalConsumed > model.totalLoad){
      model.overflow = model.totalConsumed - model.totalLoad;
    }
    provider.notify();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportProvider>(context);
    final model = provider.model;

    debugPrint("MOOOOOOOOOOOOOOOOOOOOOOOOOOOdEL: ${provider.model.totalLoad}");
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
              _spaced(buildNumberField(context, 'Tank Load', model.tankLoad, 'tankLoad', calculateDependent: () => updateTotalTankLoad(provider))),
              _spaced(buildNumberField(context, 'Inbound Amount', model.inboundAmount, 'inboundAmount', calculateDependent: () => updateTotalTankLoad(provider))),
              _spaced(buildNumberField(context, 'Total Load', model.totalLoad, 'totalLoad', enabled: false)),
            ],
          ),

          buildSection(
            title: 'Pump Readings',
            children: [
              ...List.generate(pumpRows.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FocusTextField(
                              decoration: const InputDecoration(labelText: 'Start Reading'),
                              initialValue: pumpRows[index]["start"].toString(),
                              onDebouncedChanged: (val) {
                                updateReadingRow("start", index, int.tryParse(val) ?? 0);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FocusTextField(
                              decoration: const InputDecoration(labelText: 'End Reading'),
                              initialValue: pumpRows[index]["end"].toString(),
                              onDebouncedChanged: (val) {
                                updateReadingRow("end", index, int.tryParse(val) ?? 0);
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          if(index != 0)
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
                      if(pumpRows[index]["total"] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            "Consumed: ${pumpRows[index]["total"]}", 
                            style: TextStyle(
                              fontSize: 8

                            ),
                          )
                        )
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    pumpRows.add({"start": 0, "end": 0, "total": 0});
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
              _spaced(buildNumberField(context, 'Filled for People (L)', model.filledForPeople, 'filledForPeople', calculateDependent: () => updateNotesReadings(provider))),
              _spaced(FocusTextField(
                decoration: const InputDecoration(labelText: 'Notes'),
                initialValue: model.notes,
                maxLines: 3,
                onDebouncedChanged: (v) => provider.setField('notes', v),
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
            onPressed: () async {
              if(pumpRows.isEmpty) return;
              updateDependantFields(provider);
              model.pumpsReadings = pumpRows;
              showShareTypeBottomSheet(
                context: context,
                onSelected: (ReportType selectedType) async => await generateReport(model: model, shareType: selectedType),
              );
            }, 
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

  Widget buildNumberField(BuildContext context, String label, int value, String fieldName, {void Function()? calculateDependent, bool enabled = true}) {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    return FocusTextField(
      decoration: InputDecoration(labelText: label),
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      onDebouncedChanged: (val){
        debugPrint("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
        provider.setField(fieldName, int.tryParse(val) ?? 0);
        calculateDependent?.call();
      },
      validator: (val) => Validators.positiveNumber(val, label),
      onBlur: calculateDependent,
      enabled: enabled,
    );
  }

  Widget _spaced(Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: child,
      );
}
