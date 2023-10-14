import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:instagram_flutter/enums/bottom_nav_item.dart';

part 'nav_bar_state.dart';

class NavBarCubit extends Cubit<NavBarState> {
  NavBarCubit() : super(NavBarState.initial());

  void updateNavBarItem(BottomNavItem item){
    if(state.selectedItem != item){
      emit(NavBarState(selectedItem: item));
    }
  }
}
