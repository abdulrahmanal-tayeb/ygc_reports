import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ygc_reports/core/constants/types.dart';
import 'package:ygc_reports/core/services/database/report_repository.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';
import 'package:ygc_reports/core/utils/validators.dart';
import 'package:ygc_reports/features/creation/presentation/utils/utils.dart';
import 'package:ygc_reports/features/creation/presentation/widgets/drawer.dart';
import 'package:ygc_reports/features/creation/presentation/widgets/prefill_options_dialog.dart';
import 'package:ygc_reports/modals/share_type_sheet/share_type_sheet.dart';
import 'package:ygc_reports/modals/signature_pad/signature_pad.dart';
import 'package:ygc_reports/models/report_model.dart';
import 'package:ygc_reports/providers/report_provider.dart';
import 'package:ygc_reports/widgets/collapsable.dart';
import 'package:ygc_reports/widgets/floating_actions.dart';
import 'package:ygc_reports/widgets/focus_text_field.dart';
import 'package:ygc_reports/widgets/time_input_field.dart';


/// The **HomeScreen**. This is responsible for generating the report.
class CreateReportScreen extends StatelessWidget {
  const CreateReportScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Here, we are only providing that provider to its children, because it might not
    // be in need by other screens.
    return ChangeNotifierProvider(
      create: (_) => ReportProvider(),
      child: PopScope(
        // Closes the keyboard when back-navigated.
        canPop: !FocusScope.of(context).hasFocus,
        onPopInvokedWithResult: (popped, object){
          FocusScope.of(context).unfocus();
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          behavior: HitTestBehavior.opaque,
          child: const CreateReportForm()
        )
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
  /// Defines the space between each input field and the other.
  final double spaceBetweenInputs = 20;

  /// Flag whether the report is prefilled from a previous report.
  bool prefilledReport = false;

  /// The pump readings 
  List<Map<String, int>> pumpRows = [
    {"start": 0, "end": 0, "total": 0}
  ];

  /// Updates the total tank load by calculated the [tankLoad] and the [inboundAmount] when either of them changes.
  void updateTotalTankLoad(ReportProvider provider){
    final ReportModel model = provider.model;
    final totalLoad = model.tankLoad + model.inboundAmount;
    model.totalLoad = totalLoad;
    provider.notify();
  }

  /// Updates the reading row, checking if there is any error.
  void updateReadingRow(String key, int index, int reading){
    final Map<String, int> row = pumpRows[index];
    row[key] = reading;
    row["total"] = (row["end"] ?? 0) - (row["start"] ?? 0);
    
    if(row["end"] != null && row["end"]! > 0){
      if((row["end"]!) < (row["start"] ?? 0)){
        row["error"] = 1;
      }
      else {
        row["error"] = 0;
      }
    } 

    pumpRows[index] = row;
    setState((){});
  }

  /// Updates the fields that depends on the [tanksForPeople].
  void updateNotesReadings(ReportProvider provider){
    final ReportModel model = provider.model;
    model.tanksForPeople = (model.filledForPeople / 20).round();
    model.filledForBuses = model.totalConsumed - model.filledForPeople;
    provider.notify();
  }

  /// Updates all fields that depend on other fields.
  ReportModel? updateDependantFields(ReportProvider provider) {
    final ReportModel model = provider.model;
    model.pumpsReadings = pumpRows;
    model.totalConsumed = model.pumpsReadings!.fold(0, (int sum, Map<String, int> reading) => sum + reading["total"]!);
    model.remainingLoad = model.totalLoad - model.totalConsumed;
    if(model.totalConsumed > model.totalLoad){
      model.overflow = model.totalConsumed - model.totalLoad;
    }
    provider.notify();
    return model;
  }

  /// This is called when the report is to be generated.
  void _generateReport(ReportProvider provider) async {
    if(pumpRows.isEmpty) return;
    final recentModel = updateDependantFields(provider);
    if(recentModel == null){
      return;
    }

    await showShareTypeBottomSheet(
      context: context,
      onSelected: (ReportType selectedType) async => await generateReport(context: context, model: recentModel, fileType: selectedType),
    );
  }


  // This is used to update the prefill status after prefilling the report from existing report.
  void prefillReport(
    List<Map<String, int>>? pumpReadings
  )  {
    setState(() {
      prefilledReport = true;
      if(pumpReadings != null && pumpReadings.isNotEmpty){
        pumpRows = pumpReadings;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportProvider>(context);
    final isRtl = context.isRtl;

    return Scaffold(
        appBar: AppBar(
          title: Text(context.loc.createReportScreenTitle),
          actions: [
            IconButton(
              onPressed: (){
                context.push("/saved");
              },
              icon: Icon(Icons.save),
            )
          ],
        ),
        drawer: DrawerWidget(),
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: Stack(
            children: [
              /// Displays the bottom widgets, which include the **button for creating the report**
              /// the **checkbox for specifying whether the report is for emptying or not**
              Column(
                spacing: 5,
                children: [
                  Expanded(child: _buildForm(context, provider)),
                  Row(
                    children: [
                      Checkbox(
                        value: provider.model.isEmptying,
                        onChanged: (bool? isEmptying){
                        provider.setField("isEmptying", isEmptying);
                      }),
                      Text(context.loc.emptyingReport)
                    ],
                  )
                ]
              ),

              /// Displays the floating action button.
              Positioned(
                bottom: 10,
                right: isRtl? null : 10,
                left: isRtl? 10 : null,
                child: _buildFloatingButton(context, provider),
              )
            ],
          )
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if(prefilledReport)
              /// Displays the text to show whether the report is prefilled or not. 
              Row(
                spacing: 5,
                children: [
                  const Icon(Icons.auto_awesome, size: 10),
                  Text(
                    context.loc.hint_prefilledReport,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                  )
                ],
              ),
              const SizedBox(height: 5),

              /// The main button, the one that will trigger the generation.
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: Validators.validate(provider.model, pumpRows)? () => _generateReport(provider) : null, 
                  child: Text(context.loc.common_create)
                )
              )
            ],
          )
        ),
      );
  }

  /// Builds the floating action button
  Widget _buildFloatingButton(BuildContext context, ReportProvider provider){
    return FloatingActions<Map<String, dynamic>>(
      options: [
        {"label": context.loc.common_fromLastReport, "icon": Icons.history, "onTap": () async {
            prefillReport(await provider.loadFromReport());
          }
        },
        {
          "label": context.loc.common_fromPreviousReport, "icon": Icons.edit_document,
          "onTap": () async {
            final result = await context.push<ReportModel>('/reportPicker');

            if(result != null){
              final prepareForNextReport = await showDialog<bool>(context: context, builder: (context) => PrefillOptionsDialog());
              prefillReport(await provider.loadFromReport(reportModel: result, prepareForNextReport: (prepareForNextReport ?? false)));
            }
          }
        },
        {"label": context.loc.common_saveDraft, "icon": Icons.save_as_rounded, "onTap": () {
          final report = provider.model;
          report.isDraft = true;
          reportRepository.insertReport(report);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.loc.message_draftSaved)),
          );
        }},
        {"label": context.loc.common_newReport, "icon": Icons.refresh, "onTap": () {
          provider.clear(notify: false);
          setState(() {
            prefilledReport = false;
            pumpRows = [{"start": 0, "end": 0, "total": 0}];
          });
        }},
      ],

      itemBuilder: (item) => SpeedDialChild(
        child: Icon(item['icon'], color: Colors.white),
        backgroundColor: Colors.black,
        label: item['label'],
        labelStyle: const TextStyle(color: Colors.white, fontSize: 17),
        labelBackgroundColor: Colors.black,
        onTap: item['onTap'],
      ),
    );
  }

  /// Builds the entire form.
  Widget _buildForm(BuildContext context, ReportProvider provider) {
    final ReportModel model = provider.model;

    return Form(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMetadataSection(context, provider, model),
          _buildStationStatusSection(context, provider, model),
          _buildPumpReadingsSection(context, provider, model),
          _buildNotesSection(context, provider, model),
          _buildWorkersSection(context, provider, model),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context, ReportProvider provider, ReportModel model) {
    return buildSection(
      initialCollapsed: false,
      title: context.loc.section_metadata,
      children: [
        _spaced(_buildField(
          context,
          context.loc.field_stationName,
          model.stationName,
          "stationName",
          validator: (val) => Validators.required(context, val, 'Station Name'),
        )),
        _spaced(_buildDatePickerField(context, provider, model)),
        _spaced(TimeInputField(
          label: context.loc.field_beginTime,
          initialTime: model.beginTime,
          onTimeChanged: provider.setBeginTime,
        )),
        _spaced(TimeInputField(
          label: context.loc.field_endTime,
          initialTime: model.endTime,
          onTimeChanged: provider.setEndTime,
        )),
      ],
    );
  }


  Widget _buildDatePickerField(BuildContext context, ReportProvider provider, ReportModel model) {
    return GestureDetector(
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
        child: _buildField(
          context,
          context.loc.field_date,
          model.date.toString().split(" ")[0],
          "date",
        ),
      ),
    );
  }

  Widget _buildStationStatusSection(BuildContext context, ReportProvider provider, ReportModel model) {
    return buildSection(
      title: context.loc.section_stationStatus,
      children: [
        _spaced(_buildField(
          context,
          context.loc.field_tankLoad,
          model.tankLoad,
          'tankLoad',
          validator: (val) => Validators.positiveNumber(context, val, "Tank Load"),
          onChange: () => updateTotalTankLoad(provider),
        )),
        _spaced(_buildField(
          context,
          context.loc.field_inboundAmount,
          model.inboundAmount,
          'inboundAmount',
          validator: (val) => Validators.positiveNumber(context, val, "Inbound Load"),
          onChange: () => updateTotalTankLoad(provider),
        )),
        _spaced(_buildField(
          context,
          context.loc.field_totalLoad,
          model.totalLoad,
          'totalLoad',
          enabled: false,
          validator: (val) => Validators.positiveNumber(context, val, "Total Load"),
        )),
      ],
    );
  }

  Widget _buildPumpReadingsSection(BuildContext context, ReportProvider provider, ReportModel model) {
    return buildSection(
      title: context.loc.section_pumpReadings,
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
                        decoration: InputDecoration(labelText: context.loc.field_startReading),
                        initialValue: pumpRows[index]["start"].toString(),
                        onDebouncedChanged: (val) => updateReadingRow("start", index, int.tryParse(val) ?? 0),
                        validator: (val) => Validators.validateNumber(context, val, isRequired: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FocusTextField(
                        decoration: InputDecoration(labelText: context.loc.field_endReading),
                        initialValue: pumpRows[index]["end"].toString(),
                        onDebouncedChanged: (val) => updateReadingRow("end", index, int.tryParse(val) ?? 0),
                        validator: (val) => Validators.validateNumber(context, val, isRequired: true),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (index != 0)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: pumpRows.length > 1 ? () => setState(() => pumpRows.removeAt(index)) : null,
                      ),
                  ],
                ),

                if(pumpRows[index]["error"] == 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      context.loc.error_incorrectReading,
                      style: const TextStyle(
                        fontSize: 8, 
                        color: Colors.red,
                      ),
                    ),
                  )
                else if (pumpRows[index]["total"] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Text(
                      context.loc.hint_consumed(pumpRows[index]["total"] ?? 0),
                      style: const TextStyle(fontSize: 8),
                    ),
                  ),
              ],
            ),
          );
        }),
        ElevatedButton.icon(
          onPressed: () => setState(() {
            pumpRows.add({"start": 0, "end": 0, "total": 0});
          }), 
          icon: Icon(Icons.add, color: Theme.of(context).scaffoldBackgroundColor),
          label: Text(context.loc.common_addRow),
        )
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, ReportProvider provider, ReportModel model) {
    debugPrint("MOOOOOOOOOODEL: ${model.filledForPeople} : ${model.notes}");
    return buildSection(
      title: context.loc.section_notes,
      children: [
        _spaced(_buildField(
          context,
          context.loc.field_filledForPeople,
          model.filledForPeople,
          'filledForPeople',
          decoration: InputDecoration(
            labelText: context.loc.field_filledForPeople,
            suffixText: '/ ${model.totalConsumed}',
          ),
          onChange: () => updateNotesReadings(provider),
          keyboardType: TextInputType.number,
          onFocus: () => updateDependantFields(provider),
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            final number = int.tryParse(value);
            if (number == null) return context.loc.error_onlyNumbers;
            if (number > model.totalConsumed) return context.loc.error_numberLimitExceeded(model.totalConsumed);
            return null;
          },
        )),
        _spaced(_buildField(
          context,
          context.loc.field_tankWeight,
          model.fullTankWeight,
          'fullTankWeight',
          decoration: InputDecoration(
            labelText: context.loc.field_tankWeight,
          ),
          keyboardType: TextInputType.number,
        )),
        _spaced(FocusTextField(
          decoration: InputDecoration(labelText: context.loc.field_notes),
          initialValue: model.notes,
          maxLines: 3,
          onDebouncedChanged: (v) => provider.setField('notes', v),
        )),
      ],
    );
  }

  Widget _buildWorkersSection(BuildContext context, ReportProvider provider, ReportModel model) {
    return buildSection(
      title: context.loc.section_workers,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: buildSection(
            colored: false,
            title: context.loc.section_stationWorker,
            children: [
              _spaced(_buildField(
                context,
                context.loc.field_workerName,
                model.workerName,
                "workerName",
              )),
              _buildSignature("worker", provider),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: buildSection(
            colored: false,
            title: context.loc.section_representative,
            children: [
              _spaced(_buildField(
                context,
                context.loc.field_representativeName,
                model.representativeName,
                "representativeName",
              )),
              _buildSignature("representative", provider),
            ],
          ),
        ),
      ],
    );
  }

  /// Adds the necessary padding to all of the fields.
  Widget _spaced(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: child,
  );

  /// Builds the signature sheet.
  Widget _buildSignature(String employee, ReportProvider provider){
    final ReportModel model = provider.model;
    final Uint8List? signature = employee == "worker"? model.workerSignature : model.representativeSignature;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(signature != null)
          SizedBox(
            width: 200,
            height: 100,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(signature),
              ),
            )
          ),
          const SizedBox(height: 10,),
          ElevatedButton.icon(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              try {
                final signature = await showSignaturePad(context);
                provider.setField("${employee}Signature", signature);
              } catch(e){
                debugPrint("Couldn't get the signature: $e");
              }
            }, 
            icon: Icon(Icons.mode_edit_outline_rounded, color: Theme.of(context).scaffoldBackgroundColor),
            label:  Text(context.loc.common_sign)
          )
      ],
    );
  }

  /// Builds a collapsable section.
  Widget buildSection({
    required String title, 
    required List<Widget> children, 
    bool initialCollapsed = true,
    bool colored = true
  }) {
    return Collapsable(
      name: title,
      colored: colored,
      initialCollapsed: initialCollapsed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...children,
        ],
      )
    );
  }

  /// Builds the text field, which has additional functionalities such as [onDebouncedChanged]
  Widget _buildField<T>(
    BuildContext context,
    String label, 
    dynamic value,  // It will be casted to String regardless of its type.
    String fieldName, 
    {
      void Function()? onChange, 
      bool enabled = true,
      String? Function(String?)? validator,
      void Function()? onFocus,
      InputDecoration? decoration,
      TextInputType? keyboardType,
    }) {
    final provider = context.read<ReportProvider>();
    return FocusTextField(
      decoration: decoration ?? InputDecoration(labelText: label),
      initialValue: value.toString(),
      keyboardType: keyboardType,
      onDebouncedChanged: (val){
        provider.setField(fieldName, val);
        onChange?.call();
      },
      validator: validator,
      onBlur: onChange,
      enabled: enabled,
      onFocus: onFocus,
    );
  }
}
