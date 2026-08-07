import 'package:flutter/material.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';

class SubProjectMultiSelectDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<dynamic>? initialValues;
  final String labelKey;
  final void Function(List<dynamic>)? onChanged;
  final String? hintText;
  final String? labelText;
  final TextStyle? labelStyle;
  final double? borderRadius;
  final bool? filled;
  final Color? fillColor;
  final bool? disabled;

  const SubProjectMultiSelectDropdown({
    super.key,
    required this.items,
    required this.labelKey,
    this.initialValues,
    this.onChanged,
    this.hintText,
    this.labelText,
    this.labelStyle,
    this.borderRadius,
    this.filled,
    this.fillColor,
    this.disabled,
  });

  @override
  State<SubProjectMultiSelectDropdown> createState() => _SubProjectMultiSelectDropdownState();
}

class _SubProjectMultiSelectDropdownState extends State<SubProjectMultiSelectDropdown> {
  late List<dynamic> _selectedValues = widget.initialValues ?? [];

  void _openMultiSelectDialog() async {
    final List<dynamic>? results = await showDialog<List<dynamic>>(
      context: context,
      builder: (context) {
        List<dynamic> tempSelected = List.from(_selectedValues);
        late TextEditingController otherController;
        String otherMessage = "";
        bool showError = false;

        // Fetch existing "Other" message if already selected
        final otherItem = tempSelected.firstWhere((e) => e["title"] == "Other", orElse: () => null);
        if (otherItem != null && otherItem["message"] != null) {
          otherMessage = otherItem["message"];
        }
        otherController = TextEditingController(text: otherMessage);
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(4.0)),
              title: Text(widget.labelText ?? "Select Options"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.items.map((item) {
                      final isSelected = tempSelected.any((e) => e["id"] == item["id"]);

                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(item[widget.labelKey]),
                        visualDensity: VisualDensity.compact,
                        activeColor: AppColors.red,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (checked) {
                          setStateDialog(() {
                            if (checked == true) {
                              tempSelected.add(item);
                            } else {
                              tempSelected.removeWhere((e) => e["id"] == item["id"]);
                            }

                            // If "Other" unchecked → remove error message
                            if (!tempSelected.any((e) => e["title"] == "Other")) {
                              otherMessage = "";
                              showError = false;
                            }
                          });
                        },
                      );
                    }),

                    // ---------- SHOW TEXTFIELD WHEN "OTHER" IS SELECTED ----------
                    if (tempSelected.any((e) => e["title"] == "Other"))
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: otherController,
                              minLines: 1,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: "Enter Remarks",
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.greyLite)),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.black)),
                                errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.red)),
                                focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.red)),
                                errorText: showError && otherMessage.trim().isEmpty ? "Please enter remarks" : null,
                              ),
                              onChanged: (value) {
                                setStateDialog(() {
                                  otherMessage = value;
                                  if (otherMessage.trim().isNotEmpty) {
                                    showError = false;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text("CANCEL", style: AppTextStyle.ts14MB.copyWith(color: AppColors.primaryDarkColor)),
                  onPressed: () {
                    Navigator.pop(context, _selectedValues);
                  },
                ),
                TextButton(
                  child: Text("OK", style: AppTextStyle.ts14MB.copyWith(color: AppColors.primaryDarkColor)),
                  onPressed: () {
                    // Validation: "Other" selected but no message entered
                    if (tempSelected.any((e) => e["title"] == "Other") && otherMessage.trim().isEmpty) {
                      setStateDialog(() {
                        showError = true;
                      });
                      return; // Prevent closing dialog
                    }

                    // Store message inside the "Other" selection
                    if (tempSelected.any((e) => e["title"] == "Other")) {
                      tempSelected = tempSelected.map((e) {
                        if (e["title"] == "Other") {
                          return {"id": e["id"], "title": "Other", "message": otherMessage};
                        }
                        return e;
                      }).toList();
                    }
                    Navigator.pop(context, tempSelected);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (results != null) {
      setState(() => _selectedValues = results);
      widget.onChanged?.call(_selectedValues);
    }
  }

  // void _removeSelectedItem(dynamic item) {
  //   setState(() {
  //     _selectedValues.remove(item);
  //   });
  //   widget.onChanged?.call(_selectedValues);
  // }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
      borderSide: BorderSide(color: AppColors.greyLite),
    );

    return IgnorePointer(
      ignoring: widget.disabled ?? false,
      child: InkWell(
        onTap: _openMultiSelectDialog,
        child: InputDecorator(
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            filled: widget.filled ?? false,
            fillColor: widget.fillColor ?? AppColors.greyLite,
            labelText: widget.labelText,
            labelStyle: widget.labelStyle ?? AppTextStyle.ts14MB,
            enabledBorder: border,
            focusedBorder: border,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _selectedValues.isEmpty
                    ? Text(widget.hintText ?? "Select options", style: AppTextStyle.ts14MB.copyWith(color: Colors.grey))
                    : Wrap(
                        spacing: 6,
                        runSpacing: 8,
                        children: _selectedValues.map((item) {
                          String label = item["title"];
                          // If it is "Other", append message
                          if (item["title"] == "Other" &&
                              item["message"] != null &&
                              item["message"].toString().trim().isNotEmpty) {
                            label = "Other - ${item["message"]}";
                          }
                          return
                          // Chip(
                          //   label: Text(label, softWrap: true, maxLines: null, overflow: TextOverflow.visible),
                          //   deleteIcon: const Icon(Icons.close, size: 18),
                          //   onDeleted: () => _removeSelectedItem(item),
                          //   backgroundColor: Colors.blue.shade50,
                          //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          //   visualDensity: VisualDensity.compact,
                          // );
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              spacing: 8,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(child: Text(label, softWrap: true)),
                                // GestureDetector(
                                //   onTap: () => _removeSelectedItem(item),
                                //   child: const Icon(Icons.close, size: 18, color: Colors.red),
                                // ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),

              const Icon(Icons.arrow_drop_down, size: 28, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
