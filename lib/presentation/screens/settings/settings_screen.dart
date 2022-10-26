import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share/flutter_share.dart';

import '../../../data/constants/constants.dart';
import 'cubit/settings_cubit.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsCubit cubit;

  const SettingsScreen({
    super.key,
    required this.cubit,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(),
    );
  }

  Widget _body() {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  'Dark Theme',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: Theme.of(context).textTheme.headline4!.fontSize,
                  ),
                ),
                value: state.isDarkTheme,
                onChanged: (onChanged) {
                  widget.cubit.swithTheme();
                },
              ),
              SwitchListTile(
                title: Text(
                  'Align messages to the left',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: Theme.of(context).textTheme.headline4!.fontSize,
                  ),
                ),
                value: state.isMessageLeftAlign,
                onChanged: (onChanged) {
                  widget.cubit.alingMessages();
                },
              ),
              SwitchListTile(
                title: Text(
                  'Hide date bubble',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: Theme.of(context).textTheme.headline4!.fontSize,
                  ),
                ),
                value: state.isDateBubbleHiden,
                onChanged: (onChanged) {
                  widget.cubit.hideBubble();
                },
              ),
              _fontSizeSlider(context),
            ],
          ),
        );
      },
    );
  }

  Widget _fontSizeSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppPadding.kDefaultPadding),
        Padding(
          padding: const EdgeInsets.only(
            left: AppPadding.kDefaultPadding,
          ),
          child: Text(
            'Font size',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: Theme.of(context).textTheme.headline4!.fontSize,
            ),
          ),
        ),
        const SizedBox(height: AppPadding.kSmallPadding),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.kDefaultPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Small',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: Theme.of(context).textTheme.headline2!.fontSize,
                ),
              ),
              Expanded(
                child: BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    return Slider(
                      value: state.fontSize,
                      min: 0,
                      max: 6,
                      divisions: 5,
                      onChanged: (value) {
                        widget.cubit.setFontSize(value);
                      },
                    );
                  },
                ),
              ),
              Text(
                'Large',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: Theme.of(context).textTheme.headline2!.fontSize,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.kDefaultPadding,
          ),
          child: InkWell(
            onTap: () {
              widget.cubit.resetState();
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                borderRadius: BorderRadius.circular(AppPadding.kSmallPadding),
              ),
              child: Center(
                child: Text(
                  'Set default settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: Theme.of(context).textTheme.headline3!.fontSize,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.kDefaultPadding,
            vertical: AppPadding.kMediumPadding,
          ),
          child: InkWell(
            onTap: _shareApp,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                borderRadius: BorderRadius.circular(AppPadding.kSmallPadding),
              ),
              child: Center(
                child: Text(
                  'Share app',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: Theme.of(context).textTheme.headline3!.fontSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 84.0,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.onBackground,
          size: 36,
        ),
      ),
      title: Text(
        'Settings',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
          fontSize: Theme.of(context).textTheme.headline6!.fontSize,
        ),
      ),
    );
  }

  Future<void> _shareApp() async {
    await FlutterShare.share(
      title: 'Example share',
      text: 'Share app with other people',
      linkUrl: 'https://google.com',
      chooserTitle: 'Example Chooser Title',
    );
  }
}
