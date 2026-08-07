// import 'package:flutter/material.dart';
// import 'package:lf_survey/constants/app_text_style.dart';
// import 'package:lf_survey/model/residential/prj_search_details.dart';

// class CustomTable1 extends StatefulWidget {
//   final List<TableData1> tableData;
//   final double columnWidth;

//   const CustomTable1({super.key, required this.tableData, this.columnWidth = 150});

//   @override
//   State<CustomTable1> createState() => _CustomTable1State();
// }

// class _CustomTable1State extends State<CustomTable1> {
//   final headers = const [
//     "AUDIT",
//     "AVGSIZE",
//     "CONSTRUCTIONSTATUS",
//     "DATAENTRYID",
//     "DATA_ENTRY_NAME",
//     "DISCOUNTRATE",
//     "DOS",
//     "EMPNAME",
//     "ENDDATE",
//     "FLAT",
//     "FLATSIZE",
//     "FLATSOLD",
//     "FLATUNSOLD",
//     "MODIFY_NAME",
//     "RATEPERSQT",
//     "REMARKS",
//     "ROADID",
//     "STARTDATE",
//     "STATUS",
//     "STOREY",
//     "SUBPROJECT_ID",
//     "SUBPROJECT_NAME",
//   ];
//   final ScrollController scrollBarC = ScrollController();
//   @override
//   void dispose() {
//     super.dispose();
//     scrollBarC.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scrollbar(
//       controller: scrollBarC,
//       thumbVisibility: true, // always show scrollbar
//       trackVisibility: true,
//       interactive: true,
//       thickness: 8,
//       radius: Radius.circular(10),
//       child: SingleChildScrollView(
//         controller: scrollBarC,
//         scrollDirection: Axis.horizontal,
//         child: Table(
//           defaultColumnWidth: FixedColumnWidth(widget.columnWidth),
//           border: TableBorder(
//             top: BorderSide(color: Colors.blue),
//             bottom: BorderSide(color: Colors.blue),
//             left: BorderSide(color: Colors.blue),
//             right: BorderSide(color: Colors.blue),
//             // verticalInside: BorderSide(color: Colors.black38),
//             verticalInside: BorderSide(color: Colors.blue),
//             horizontalInside: BorderSide(color: Colors.blue),
//           ),
//           children: [
//             // Header row
//             TableRow(
//               decoration: const BoxDecoration(color: Colors.blue),
//               children: headers
//                   .map(
//                     (h) => Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(h, style: AppTextStyle.ts12BW),
//                     ),
//                   )
//                   .toList(),
//             ),

//             // Data rows
//             ...widget.tableData.map((item) {
//               return TableRow(
//                 children: [
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell("${item.dos}"),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell(""),
//                   _buildCell("${item.subprojectId}"),
//                   _buildCell(item.subprojectName),
//                 ],
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCell(String? text) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(text ?? '', style: AppTextStyle.ts12RB, softWrap: true),
//     );
//   }
// }
