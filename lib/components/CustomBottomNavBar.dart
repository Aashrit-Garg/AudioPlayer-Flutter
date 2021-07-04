import 'package:flutter/material.dart';

import '../enums.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    required Key key,
    required this.selectedMenu,
    required this.playPause,
  }) : super(key: key);

  final MenuState selectedMenu;
  final StreamBuilder playPause;

  @override
  Widget build(BuildContext context) {
    final Color inActiveIconColor = Color(0xFFB6B6B6);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -15),
            blurRadius: 20,
            color: Color(0xFFDADADA).withOpacity(0.15),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
          top: false,
          child: Container(
            height: 200,
            child: Column(
              children: [
                playPause,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.home,
                        color: MenuState.home == selectedMenu
                            ? Colors.redAccent
                            : Colors.black,
                      ),
                      onPressed: () {},
                    ),
                    // IconButton(
                    //   icon: SvgPicture.asset("assets/icons/Heart Icon.svg"),
                    //   onPressed: () {},
                    // ),
                    // IconButton(
                    //   icon: SvgPicture.asset("assets/icons/Chat bubble Icon.svg"),
                    //   onPressed: () {},
                    // ),
                    IconButton(
                      icon: Icon(
                        Icons.person,
                        color: MenuState.profile == selectedMenu
                            ? Colors.redAccent
                            : Colors.black,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
