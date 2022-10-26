part of 'home_cubit.dart';

class HomeState extends Equatable {
  final List<Event> favoriteEvents;
  final List<Event> events;
  final int selectedPage;

  const HomeState({
    this.favoriteEvents = const [],
    this.events = const [],
    this.selectedPage = 0,
  });

  @override
  List<Object> get props => [
        favoriteEvents,
        events,
        selectedPage,
      ];

  HomeState copyWith({
    List<Event>? favoriteEvents,
    List<Event>? events,
    int? selectedPage,
  }) {
    return HomeState(
      favoriteEvents: favoriteEvents ?? this.favoriteEvents,
      events: events ?? this.events,
      selectedPage: selectedPage ?? this.selectedPage,
    );
  }
}
