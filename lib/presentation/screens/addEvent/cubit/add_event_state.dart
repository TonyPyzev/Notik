part of 'add_event_cubit.dart';

class AddEventState extends Equatable {
  final List<IconData> gridIcons;
  final IconData selectedIcon;
  final AddEventStatus status;

  const AddEventState({
    this.gridIcons = icons,
    this.selectedIcon = Icons.abc,
    this.status = AddEventStatus.create,
  });

  @override
  List<Object?> get props => [
        gridIcons,
        selectedIcon,
        status,
      ];

  AddEventState copyWith({
    List<IconData>? gridIcons,
    IconData? selectedIcon,
    AddEventStatus? status,
    Event? event,
  }) {
    return AddEventState(
      gridIcons: gridIcons ?? this.gridIcons,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      status: status ?? this.status,
    );
  }
}

enum AddEventStatus {
  create,
  update,
}

const List<IconData> icons = [
  Icons.search,
  Icons.home,
  Icons.shopping_cart,
  Icons.delete,
  Icons.description,
  Icons.lightbulb,
  Icons.paid,
  Icons.article,
  Icons.emoji_events,
  Icons.sports_esports,
  Icons.fitness_center,
  Icons.work_outline,
  Icons.spa,
  Icons.celebration,
  Icons.payment,
  Icons.pets,
  Icons.account_balance,
  Icons.savings,
  Icons.family_restroom,
  Icons.crib,
  Icons.music_note,
  Icons.local_bar,
];
