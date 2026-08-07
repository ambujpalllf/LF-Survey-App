import 'package:flutter/material.dart';
import 'package:lf_survey/constants/app_text_style.dart';
import 'package:lf_survey/model/residential/prj_search_details.dart';

class CustomTable extends StatefulWidget {
  // final List<TableData> tableData;
  final List<PrjSearchDatum> tableData;
  final double columnWidth;

  const CustomTable({super.key, required this.tableData, this.columnWidth = 150});

  @override
  State<CustomTable> createState() => _CustomTableState();
}

class _CustomTableState extends State<CustomTable> {
  final headers = const [
    'ADDRESS',
    'AREA',
    'BUILDER',
    'BUILDER CONTACT',
    'BUILDER ID',
    'CITY',
    'LOCATION',
    'PROJECT CONTACT',
    'PROJECT ID',
    'PROJECT NAME',
    'RERA NO',
    'ROAD',
    'SUBURB',
  ];
  final ScrollController scrollBarC = ScrollController();
  @override
  void dispose() {
    super.dispose();
    scrollBarC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollBarC,
      interactive: true,
      thickness: 8,
      thumbVisibility: true,
      trackVisibility: true,
      radius: Radius.circular(10),
      child: SingleChildScrollView(
        controller: scrollBarC,
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: FixedColumnWidth(widget.columnWidth),
          border: TableBorder(
            top: BorderSide(color: Colors.blue),
            bottom: BorderSide(color: Colors.blue),
            left: BorderSide(color: Colors.blue),
            right: BorderSide(color: Colors.blue),
            verticalInside: BorderSide(color: Colors.black38),
            horizontalInside: BorderSide(color: Colors.white),
          ),
          children: [
            // Header row
            TableRow(
              decoration: const BoxDecoration(color: Colors.blue),
              children: headers
                  .map(
                    (h) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(h, style: AppTextStyle.ts12BW),
                    ),
                  )
                  .toList(),
            ),

            // Data rows
            ...widget.tableData.map((item) {
              return TableRow(
                children: [
                  _buildCell(item.address),
                  _buildCell(item.area),
                  _buildCell(item.builder),
                  _buildCell(item.buildercontact),
                  _buildCell("${item.builderid}"),
                  _buildCell(item.city),
                  _buildCell(item.location),
                  _buildCell(item.projectcontact),
                  _buildCell("${item.projectId}"),
                  _buildCell(item.projectName),
                  _buildCell(item.reraNo),
                  _buildCell(item.road),
                  _buildCell(item.suburb),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(String? text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text ?? '', style: AppTextStyle.ts12RB, softWrap: true),
    );
  }
}
