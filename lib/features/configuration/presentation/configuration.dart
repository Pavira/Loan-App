import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/core/theme/app_theme.dart';
import 'package:loan_app/features/configuration/data/configuration_model.dart';
import 'package:loan_app/features/configuration/data/configuration_repository.dart';
import 'package:loan_app/widgets/animated_text_field.dart';
import 'package:loan_app/widgets/appbar.dart';
import 'package:loan_app/widgets/custom_snackbar.dart';

class ConfigurationPage extends StatefulWidget {
  @override
  _ConfigurationPageState createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  bool isSubmitting = false;
  final TextEditingController finePercentageController =
      TextEditingController();

  bool isFineEditable = false;
  bool isLoading = true; // 🔹 for loader while fetching

  @override
  void initState() {
    super.initState();
    fetchConfiguration();
  }

  @override
  void dispose() {
    finePercentageController.dispose();
    super.dispose();
  }

  Future<void> fetchConfiguration() async {
    try {
      final config = await ConfigurationRepository().getConfiguration();
      if (config != null && config.finePercentage != null) {
        finePercentageController.text = config.finePercentage!.toString();
        // print('Fine Percentage: ${config.finePercentage}');
        setState(() => isFineEditable = false);
      } else {
        setState(() => isFineEditable = true);
      }
    } catch (e) {
      showCustomSnackbar(
        context,
        "Failed to load configuration",
        color: Colors.red,
      );
      isFineEditable = true; // fallback to allow input
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> submitConfiguration() async {
    if (finePercentageController.text.isEmpty) {
      showCustomSnackbar(context, "Please fill Fine %*");
      return;
    }

    final fineValue = int.tryParse(finePercentageController.text);
    ConfigurationModel newConfiguration = ConfigurationModel(
      finePercentage: fineValue,
    );

    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    try {
      await ConfigurationRepository().saveConfiguration(
        newConfiguration,
      ); // 🔹 update same doc
      showCustomSnackbar(
        context,
        "Configuration saved successfully!",
        color: Colors.green,
      );
      setState(() {
        isFineEditable = false;
      });
    } catch (e) {
      showCustomSnackbar(
        context,
        "Failed to save Configuration. Try again!",
        color: Colors.red,
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor,
      appBar: CustomAppBar(title: 'Configuration', centerTitle: true),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator()) // 🔹 loader
              : SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AnimatedTextField(
                                  label: 'Fine %*',
                                  controller: finePercentageController,
                                  isReadOnly: !isFineEditable,
                                  inputFormatter: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isFineEditable ? Icons.check : Icons.edit,
                                  color:
                                      isFineEditable
                                          ? Colors.green
                                          : Colors.blue,
                                ),
                                onPressed: () {
                                  if (isFineEditable) {
                                    submitConfiguration();
                                  } else {
                                    setState(() => isFineEditable = true);
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
