import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:page_transition/page_transition.dart';

import '../../../data/constants/constants.dart';
import '../../../data/models/event.dart';
import '../addEvent/add_event_screen.dart';
import '../addEvent/cubit/add_event_cubit.dart';
import '../chat/chat_screen.dart';
import '../chat/cubit/chat_cubit.dart';
import '../settings/cubit/settings_cubit.dart';
import '../settings/settings_screen.dart';
import 'cubit/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  final PageController _pageController = PageController();
  final HomeCubit cubit;

  HomeScreen({
    super.key,
    required this.cubit,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      drawer: _drawer(context),
      body: _body(context),
      floatingActionButton: _fab(context),
    );
  }

  Widget _body(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        PageView(
          controller: widget._pageController,
          onPageChanged: (value) {
            widget.cubit.selectPage(value);
          },
          children: [
            _homePage(context),
            Container(
              key: const ValueKey('Daily'),
              color: Colors.cyan,
              child: const Center(
                child: Text('Daily'),
              ),
            ),
            Container(
              key: const ValueKey('Timeline'),
              color: Colors.amber,
              child: const Center(
                child: Text('Timeline'),
              ),
            ),
            Container(
              key: const ValueKey('Explore'),
              color: Colors.yellow,
              child: const Center(
                child: Text('Explore'),
              ),
            ),
          ],
        ),
        _bottomNavBar(context),
      ],
    );
  }

  Widget _bottomNavBar(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: 90,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppPadding.kBigPadding,
          0,
          AppPadding.kBigPadding,
          AppPadding.kDefaultPadding,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppPadding.kDefaultPadding),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return NavigationBar(
                backgroundColor: Colors.transparent,
                selectedIndex: state.selectedPage,
                animationDuration: const Duration(milliseconds: 400),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (selectedIndex) {
                  widget._pageController
                      .animateToPage(
                        selectedIndex,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn,
                      )
                      .then((value) => widget.cubit.selectPage(selectedIndex));
                },
                destinations: [
                  NavigationDestination(
                    icon: Icon(
                      Icons.home_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 36.0,
                    ),
                    selectedIcon: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: 24.0,
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.event_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 36.0,
                    ),
                    selectedIcon: Icon(
                      Icons.event,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    label: 'Daily',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.timeline_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 36.0,
                    ),
                    selectedIcon: Icon(
                      Icons.timeline,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    label: 'Timeline',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.explore_outlined,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 36.0,
                    ),
                    selectedIcon: Icon(
                      Icons.explore_outlined,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    label: 'Explore',
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _homePage(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              if (state.favoriteEvents.isNotEmpty) _favoriteBlock(context),
              if (state.events.isNotEmpty) _latestBlock(context),
            ],
          ),
        );
      },
    );
  }

  Widget _latestBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppPadding.kBigPadding),
          child: Text(
            'Latest',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: Theme.of(context).textTheme.headline5!.fontSize,
            ),
          ),
        ),
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            // return AnimatedList(
            //   shrinkWrap: true,
            //   primary: false,
            //   initialItemCount: state.events.length,
            //   itemBuilder: (context, index, animation) {
            //     return _eventTile(
            //       context,
            //       state.events[index],
            //       index,
            //     );
            //   },
            // );

            return ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: state.events.length,
              itemBuilder: (context, index) {
                return _eventTile(
                  context,
                  state.events[index],
                );
              },
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _favoriteBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppPadding.kBigPadding),
          child: Text(
            'Favorite',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: Theme.of(context).textTheme.headline5!.fontSize,
            ),
          ),
        ),
        const SizedBox(height: AppPadding.kSmallPadding),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.kBigPadding,
          ),
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return GridView.builder(
                shrinkWrap: true,
                primary: false,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppPadding.kMediumPadding,
                  crossAxisSpacing: AppPadding.kMediumPadding,
                ),
                itemCount: state.favoriteEvents.length,
                itemBuilder: (context, index) {
                  return _eventCard(
                    context,
                    state.favoriteEvents[index],
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppPadding.kBigPadding),
      ],
    );
  }

  Widget _eventCard(BuildContext context, Event event) {
    var scale = 1.0;

    return GestureDetector(
      onTap: () {
        context.read<ChatCubit>().setEvent(event);
        context.read<ChatCubit>().setEvents(
              widget.cubit.state.favoriteEvents + widget.cubit.state.events,
            );
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: ChatScreen(cubit: context.read<ChatCubit>()),
            duration: const Duration(milliseconds: 250),
          ),
        );
      },
      child: StatefulBuilder(
        builder: (context, setState) {
          return AnimatedScale(
            key: ValueKey(event.id),
            scale: scale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeIn,
            onEnd: () => widget.cubit.removeFromFavorite(event),
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              tween: Tween<double>(begin: 0, end: 1.0),
              builder: (context, scale, child) {
                //TODO question!!
                // как анимировать stateless widget только при создании
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Container(
                width: 166,
                height: 166,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withOpacity(0.1),
                      offset: const Offset(2, 2),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppPadding.kSmallPadding),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFF374A48),
                            ),
                            child: Icon(
                              event.iconData,
                              color: const Color(0xFFFAFAFA),
                              size: 48,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.all(AppPadding.kSmallPadding),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => scale = 0.01);
                              },
                              child: Icon(
                                Icons.favorite,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppPadding.kSmallPadding,
                        0,
                        0,
                        AppPadding.kSmallPadding,
                      ),
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color(0xFF374A48),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppPadding.kSmallPadding,
                        0,
                        0,
                        AppPadding.kSmallPadding,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.sms_outlined,
                            size: 18,
                            color: Color(0xFF374A48),
                          ),
                          const SizedBox(width: AppPadding.kSmallPadding),
                          Text(
                            event.lastMessage,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374A48),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppPadding.kSmallPadding,
                        0,
                        0,
                        AppPadding.kSmallPadding,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.history_outlined,
                            size: 18,
                            color: Color(0xFF374A48),
                          ),
                          const SizedBox(width: AppPadding.kSmallPadding),
                          Text(
                            _lastActivityHandler(event.lastActivity),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374A48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _eventTile(BuildContext context, Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.kBigPadding,
        vertical: AppPadding.kSmallPadding,
      ),
      child: Slidable(
        startActionPane: ActionPane(
          extentRatio: 0.30,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              autoClose: true,
              onPressed: (context) {
                widget.cubit.addToFavorite(event);
              },
              backgroundColor: Theme.of(context).colorScheme.background,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              icon: Icons.favorite_outline,
            ),
            SlidableAction(
              autoClose: true,
              onPressed: (context) {
                //TODO complete event
              },
              backgroundColor: Theme.of(context).colorScheme.background,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              icon: Icons.done,
            ),
          ],
        ),
        endActionPane: ActionPane(
          extentRatio: 0.30,
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              autoClose: true,
              onPressed: (context) {
                context.read<AddEventCubit>().setUpdatingStatus();

                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: AddEventScreen(
                      cubit: context.read<AddEventCubit>(),
                      event: event,
                    ),
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                  ),
                );
              },
              backgroundColor: Theme.of(context).colorScheme.background,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              icon: Icons.edit,
            ),
            SlidableAction(
              autoClose: true,
              onPressed: (context) {
                widget.cubit.deleteEvent(event);
              },
              backgroundColor: Theme.of(context).colorScheme.background,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              icon: Icons.delete,
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            context.read<ChatCubit>().setEvent(event);
            context.read<ChatCubit>().setEvents(
                  widget.cubit.state.favoriteEvents + widget.cubit.state.events,
                );
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child: ChatScreen(cubit: context.read<ChatCubit>()),
                duration: const Duration(milliseconds: 250),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.1),
                  offset: const Offset(2, 2),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.kSmallPadding),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF374A48),
                    ),
                    child: Icon(
                      event.iconData,
                      color: const Color(0xFFFAFAFA),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: AppPadding.kMediumPadding),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.headline4!.fontSize,
                          color: const Color(0xFF374A48),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.sms_outlined,
                            size: 18,
                            color: Color(0xFF374A48),
                          ),
                          const SizedBox(width: AppPadding.kSmallPadding),
                          Text(
                            event.lastMessage,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374A48),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawer(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.kMediumPadding,
            vertical: AppPadding.kDefaultPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.leftToRight,
                      child: SettingsScreen(
                        cubit: context.read<SettingsCubit>(),
                      ),
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.settings,
                  size: 30,
                ),
                label: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.headline5!.fontSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        0,
        0,
        8,
        85,
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: AddEventScreen(
                cubit: context.read<AddEventCubit>(),
              ),
              duration: const Duration(
                milliseconds: 250,
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 84.0,
      leading: Padding(
        padding: const EdgeInsets.only(
          left: AppPadding.kMediumPadding,
        ),
        child: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.menu,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      actions: [
        Center(
          child: Text(
            'Home',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headline6!.fontSize,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: AppPadding.kBigPadding)
      ],
    );
  }

  String _lastActivityHandler(DateTime date) {
    final prefix = 'Last activity:';
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return '$prefix ${date.hour}:${date.minute}';
    } else if (date.day == now.subtract(const Duration(days: 1)).day) {
      return '$prefix yesterday';
    } else if (date.day < now.subtract(const Duration(days: 1)).day &&
        date.day >= now.subtract(const Duration(days: 7)).day) {
      return '$prefix ${_weekdayHandler(date)}';
    } else {
      return '$prefix ${date.day}.${date.month}.${date.year}';
    }
  }

  String _weekdayHandler(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'mon.';
      case 2:
        return 'tue. ';
      case 3:
        return 'wed.';
      case 4:
        return 'thu.';
      case 5:
        return 'fri.';
      case 6:
        return 'sat.';
      case 7:
        return 'sun.';
      default:
        return 'last week';
    }
  }
}
