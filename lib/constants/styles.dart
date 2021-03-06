import 'package:flutter/material.dart';

/* Colors */

// aimimi theme color palette
const themeColor = Color(0xff80D3DC);
const themeShadedColor = Color(0xff1C4B56);
const themeMutedColor = Color(0xff759198);

// mono color palette
const monoPrimaryColor = Color(0xff000000);
const monoSecondaryColor = Color(0xff999999);
const monoTintedColor = Color(0xffC2C2C2);
const monoButtonTextColor = Color(0xff888888);

// background color palette
const backgroundColor = Color(0xffF2F4F6);
const backgroundTintedColor = Color(0xffF8FAFB);
const backgroundShadedColor = Color(0xffEFF0F1);

/* TextField */

const textFieldBorder = OutlineInputBorder(
  borderSide: BorderSide(
    width: 0,
    style: BorderStyle.none,
  ),
  borderRadius: BorderRadius.all(Radius.circular(8)),
);

const searchFieldBorder = OutlineInputBorder(
  borderSide: BorderSide(
    width: 0,
    style: BorderStyle.none,
  ),
  borderRadius: BorderRadius.all(Radius.circular(14)),
);

/* TextStyle */

const appBarTitleTextStyle = TextStyle(
  color: themeShadedColor,
  fontSize: 22,
  fontWeight: FontWeight.w700,
);

const textFieldTitleTextStyle = TextStyle(
  color: themeShadedColor,
  fontSize: 16,
  fontWeight: FontWeight.w700,
);

const textFieldHintTextStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: monoSecondaryColor,
);

/* AppBar */
AppBar singleViewAppBar(String titleText) => AppBar(
      key: UniqueKey(),
      elevation: 0,
      iconTheme: IconThemeData(color: themeShadedColor),
      title: Text(titleText, style: appBarTitleTextStyle),
    );
