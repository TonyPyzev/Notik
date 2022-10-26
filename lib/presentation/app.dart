import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repository/event_repository.dart';
import 'components/user_auth.dart';
import 'screens/addEvent/cubit/add_event_cubit.dart';
import 'screens/chat/cubit/chat_cubit.dart';
import 'screens/home/cubit/home_cubit.dart';
import 'screens/home/home_screen.dart';
import 'screens/settings/cubit/settings_cubit.dart';

class NotikApp extends StatelessWidget {
  final String _title = 'Notik';

  NotikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HomeCubit(
            EventRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => AddEventCubit(
            EventRepository(),
          ),
        ),
        BlocProvider(
          create: (context) => ChatCubit(),
        ),
        BlocProvider(
          create: (context) => SettingsCubit(),
        ),
      ],
      child: UserAuth(
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: _title,
              theme: context.read<SettingsCubit>().fetchTheme(),
              home: HomeScreen(
                cubit: context.read<HomeCubit>(),
              ),
            );
          },
        ),
      ),
    );
  }
}
