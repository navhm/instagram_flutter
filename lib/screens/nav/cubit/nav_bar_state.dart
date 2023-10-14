part of 'nav_bar_cubit.dart';

class NavBarState extends Equatable {
  const NavBarState({required this.selectedItem});

  final BottomNavItem selectedItem;

  factory NavBarState.initial(){
    return const NavBarState(selectedItem: BottomNavItem.feed);
  }

  @override
  bool? get stringify => true;


  @override
  List<Object> get props => [selectedItem];
}
