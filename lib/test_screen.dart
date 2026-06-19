import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rotijugaad/common/widgets/clickable_text.dart';
import 'package:rotijugaad/common/widgets/gender_selector.dart';
import 'package:rotijugaad/common/widgets/heading_subheading.dart';
import 'package:rotijugaad/common/widgets/language_selector.dart';
import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import 'common/models/id_name.dart';
import 'common/widgets/app_dropdown.dart';
import 'common/widgets/chips_selector.dart';
import 'common/widgets/expected_salary_field.dart';
import 'common/widgets/labeled_form_field.dart';

class TestScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  final states = const [
    IdName(id: 'tg', name: 'Telangana'),
    IdName(id: 'mh', name: 'Maharashtra'),
  ];
  String? currentStateId = 'tg';

  Set<String> skills = {'ms_office'};
  final skillOptions = const [
    IdName(id: 'gd', name: 'Graphic Designer'),
    IdName(id: 'acc', name: 'Accountant'),
    IdName(id: 'ms_office', name: 'MS Office'),
    IdName(id: 'mkt', name: 'Marketing'),
    IdName(id: 'other', name: 'Other'),
  ];

  final salaryCtrl = TextEditingController(text: '20,000');
  // PayPeriod period = PayPeriod.monthly;

  @override
  Widget build(BuildContext context) {
    final s = context.spacing;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Row(
                //   children: [
                //     Expanded(
                //       child: ElevatedButton(
                //         onPressed: () {},
                //         child: const Text('Elevated'),
                //       ),
                //     ),
                //     SizedBox(width: s.sm),
                //     Expanded(
                //       child: FilledButton(
                //         onPressed: () {},
                //         child: const Text('Filled'),
                //       ),
                //     ),
                //     SizedBox(width: s.sm),
                //     Expanded(
                //       child: OutlinedButton(
                //         onPressed: () {},
                //         child: const Text('Outlined'),
                //       ),
                //     ),
                //   ],
                // ),
                // SizedBox(height: 20),
                // LanguageSelector(),
                // SizedBox(height: 20),
                // TextFormField(),
                // SizedBox(height: 20),
                // LabeledFormField(
                //   title: 'Email ID',
                //   hintText: 'name@example.com',
                //   keyboardType: TextInputType.emailAddress,
                //   optional: true,
                //   controller: TextEditingController(),
                //   validator: (v) =>
                //       (v == null || v.isEmpty) ? 'Email required' : null,
                // ),
                // SizedBox(height: 20,),
                // LabeledFormField(
                //   title: 'Password',
                //   hintText: 'Enter password',
                //   isPassword: true,
                //   controller: TextEditingController(),
                // ),
                //
                // SizedBox(height: 20,),
                // LabeledFormField(
                //   title: 'Assistant Code',
                //   hintText: 'Not editable',
                //   enabled: false,   // greys out and disables focus
                // ),
                //
                // SizedBox(height: 20,),
                // LabeledFormField(
                //   title: 'Date of Birth',
                //   controller: TextEditingController(),
                //   pickerMode: FieldPickerMode.date,
                //   firstDate: DateTime(1970),
                //   lastDate: DateTime(2100),
                //   dateFormat: DateFormat('dd MMM yyyy'),
                //   suffixIcon: Icon(Icons.date_range),
                // ),
                // SizedBox(height: 20,),
                // LabeledFormField(
                //   title: 'Preferred Time',
                //   controller: TextEditingController(),
                //   pickerMode: FieldPickerMode.time,
                //   timeFormat: DateFormat('hh:mm a'),
                //   suffixIcon: Icon(Icons.lock_clock),
                // ),
                // SizedBox(height: 20,),
                // LabeledFormField(
                //   title: 'Schedule',
                //   controller: TextEditingController(),
                //   pickerMode: FieldPickerMode.dateTime,
                //   dateFormat: DateFormat('yyyy-MM-dd'),
                //   timeFormat: DateFormat('HH:mm'),
                // ),
                // SizedBox(height: 20,),
                // LabeledFormField(
                //   title: 'Search',
                //   hintText: 'Type to search',
                //   prefixIcon: const Icon(Icons.search_rounded),
                //   suffixIcon: const Icon(Icons.clear_rounded),
                //   onTap: () {}, // custom action if needed
                // )

                AppDropdown(
                  title: 'Current State',
                  items: states,
                  valueId: currentStateId,
                  onChanged: (v) => setState(() => currentStateId = v?.id),
                ),
                SizedBox(height: 20,),
                // ExpectedSalaryField(
                //   title: 'Expected Salary',
                //   amountController: salaryCtrl,
                //   period: period,
                //   onPeriodChanged: (p) => setState(() => period = p),
                // ),
                SizedBox(height: 20,),
                ChipsSelector(
                  title: 'Skills',
                  options: skillOptions,
                  selectedIds: skills,
                  onChanged: (s) => setState(() => skills = s),
                  optional: true,
                ),
                SizedBox(height: 20,),
                GenderSelector(title: "Select Gender", value: Gender.female, onChanged: (gender){

                }),
                
                SizedBox(height: 20,),
                Align(
                    alignment: Alignment.centerLeft,
                    child: HeadingSubheading("Sign in to your Account", "Let’s sign in to your account")),
                
                SizedBox(height: 20,),
                ClickableText("Already have an account?", "Login", (){


                }),
                SizedBox(height: 20,),
                Toolbar("", (){

                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
