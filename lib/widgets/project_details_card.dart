import 'package:flutter/material.dart';
import 'package:lf_survey/constants/app_colors.dart';
import 'package:lf_survey/constants/app_text_style.dart';

class ProjectDetailsCard extends StatelessWidget {
  final String title;
  final String projectName;
  final String projectId;
  final String address;
  final String phone;

  const ProjectDetailsCard({
    super.key,
    required this.title,
    required this.projectName,
    required this.projectId,
    required this.address,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(title, style: AppTextStyle.ts16RB),
            ),
            const SizedBox(height: 4),
            Container(width: double.infinity, height: 1, color: Colors.grey.shade300),

            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(projectName, style: AppTextStyle.ts14RB),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: AppColors.red,
                  child: Text(projectId, style: AppTextStyle.ts14RW),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Address & Phone
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: RichText(
                      text: TextSpan(
                        text: "Address : ",
                        style: AppTextStyle.ts12RB,
                        children: [
                          TextSpan(
                            text: address,
                            style: AppTextStyle.ts12RB.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: RichText(
                      text: TextSpan(
                        text: "Phone No : ",
                        style: AppTextStyle.ts12RB,
                        children: [
                          TextSpan(
                            text: phone,
                            style: AppTextStyle.ts12RB.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
