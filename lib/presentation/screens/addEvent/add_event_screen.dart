import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/constants/constants.dart';
import '../../../data/models/event.dart';
import 'cubit/add_event_cubit.dart';

class AddEventScreen extends StatefulWidget {
  final _textFieldController = TextEditingController();
  final AddEventCubit cubit;
  final Event? event;

  AddEventScreen({
    super.key,
    required this.cubit,
    this.event,
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  String appBarTitle = 'Create event';
  @override
  void initState() {
    final event = widget.event;

    if (event != null) {
      appBarTitle = 'Edit ${event.title}';
      widget._textFieldController.text = event.title;
      widget.cubit.selectIcon(event.iconData);
      widget.cubit.setUpdatingStatus();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(
        context,
        appBarTitle,
      ),
      body: Column(
        children: [
          _textField(context),
          _subtitle(context),
          _gridIcons(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fabOnPressed,
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _textField(BuildContext context) {
    return Container(
      height: 50,
      child: Center(
        child: Container(
          width: 344,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: widget._textFieldController,
            onChanged: (value) {
              //TODO valid data
            },
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Event name',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _subtitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.kBigPadding,
            vertical: AppPadding.kMediumPadding,
          ),
          child: Text(
            'Icons',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 24,
            ),
          ),
        )
      ],
    );
  }

  Widget _gridIcons(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.kBigPadding,
        ),
        child: BlocBuilder<AddEventCubit, AddEventState>(
          builder: (context, state) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppPadding.kBigPadding,
                crossAxisSpacing: AppPadding.kBigPadding,
              ),
              itemCount: state.gridIcons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    context
                        .read<AddEventCubit>()
                        .selectIcon(state.gridIcons[index]);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: state.selectedIcon == state.gridIcons[index]
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withOpacity(0.1),
                          offset: const Offset(2, 2),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      state.gridIcons[index],
                      size: 36,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context, String title) {
    return AppBar(
      toolbarHeight: 84.0,
      leading: IconButton(
        onPressed: () {
          widget.cubit.setCreatingStatus();
          widget.cubit.clearState();
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back,
          color: Theme.of(context).colorScheme.onBackground,
          size: 36,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onBackground,
          fontSize: 30,
        ),
      ),
    );
  }

  void _fabOnPressed() {
    if (widget._textFieldController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Input the event name'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } else {
      var event = widget.event;
      if (event == null) {
        event = Event(
          id: '',
          title: widget._textFieldController.text,
          lastMessage: 'No messages',
          lastActivity: DateTime.now(),
          iconData: context.read<AddEventCubit>().state.selectedIcon,
        );
      } else {
        event = event.copyWith(
          title: widget._textFieldController.text,
          iconData: context.read<AddEventCubit>().state.selectedIcon,
        );
      }
      widget.cubit.fabHandler(event);
      widget.cubit.clearState();
      widget.cubit.setCreatingStatus();
      widget._textFieldController.clear();
      Navigator.pop(context);
    }
  }
}
