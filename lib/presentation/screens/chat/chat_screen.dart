import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/constants/constants.dart';
import '../../../data/models/note.dart';
import '../settings/cubit/settings_cubit.dart';
import 'cubit/chat_cubit.dart';

class ChatScreen extends StatefulWidget {
  late final TextEditingController _searchingController =
      TextEditingController();
  final TextEditingController _textFieldController = TextEditingController();
  final ChatCubit cubit;

  ChatScreen({
    super.key,
    required this.cubit,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    widget.cubit.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
            buildWhen: (prev, curr) {
              if (prev.notes != curr.notes) return true;
              if (curr.status != curr.status) return true;
              return false;
            },
            builder: (context, state) {
              if (state.status == ChatStatus.searching &&
                  state.searchingNotes.isNotEmpty) {
                return ListView.builder(
                  reverse: true,
                  itemCount: state.searchingNotes.length,
                  itemBuilder: (context, index) {
                    return _messageHandler(
                      context,
                      index == state.searchingNotes.length - 1
                          ? null
                          : state.searchingNotes[index + 1],
                      state.searchingNotes[index],
                      index,
                    );
                  },
                );
              }
              return ListView.builder(
                reverse: true,
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  return _messageHandler(
                    context,
                    index == state.notes.length - 1
                        ? null
                        : state.notes[index + 1],
                    state.notes[index],
                    index,
                  );
                },
              );
            },
          ),
        ),
        BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (prev, curr) {
            if (prev.status != curr.status) return true;
            if (prev.selectedEventId != curr.selectedEventId) return true;
            return false;
          },
          builder: (context, state) {
            if (state.status == ChatStatus.sendTo ||
                state.status == ChatStatus.forwardTo) {
              return _eventsBar(context, state);
            } else {
              return const SizedBox();
            }
          },
        ),
        _bottomTextField(context),
      ],
    );
  }

  PreferredSize _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(84),
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          // AppBar with searching text field
          if (state.status == ChatStatus.searching) {
            return AppBar(
              toolbarHeight: 84.0,
              leading: IconButton(
                onPressed: () {
                  widget.cubit.clearState();
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onBackground,
                  size: 36,
                ),
              ),
              title: Container(
                width: 250,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withOpacity(0.1),
                      offset: const Offset(3, 3),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.kMediumPadding,
                    vertical: AppPadding.kSmallPadding,
                  ),
                  child: TextField(
                    controller: widget._searchingController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      widget.cubit.searchNotes(value.trim());
                    },
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    widget.cubit.resetStatus();
                    widget._searchingController.clear();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 36,
                  ),
                ),
              ],
            );
          }
          // Deafult AppBar
          else {
            return AppBar(
              toolbarHeight: 84.0,
              leading: IconButton(
                onPressed: () {
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
                state.event.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    widget.cubit.setStatus(ChatStatus.searching);
                  },
                  icon: Icon(
                    Icons.search_outlined,
                    color: Theme.of(context).colorScheme.onBackground,
                    size: 36,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _messageHandler(
    BuildContext context,
    Note? prevNote,
    Note currNote,
    int index,
  ) {
    if (context.read<SettingsCubit>().state.isDateBubbleHiden) {
      return _message(context, currNote);
    }
    if (prevNote == null) {
      return _messageWithDateBubble(
        context,
        currNote,
        _formatDateBubbleText(currNote.date),
      );
    } else {
      if (prevNote.date.day == currNote.date.day) {
        return _message(context, currNote);
      } else {
        return _messageWithDateBubble(
          context,
          currNote,
          _formatDateBubbleText(currNote.date),
        );
      }
    }
  }

  Widget _messageWithDateBubble(
    BuildContext context,
    Note note,
    String bubbleText,
  ) {
    return Column(
      children: [
        _dateBubble(context, bubbleText),
        _message(context, note),
      ],
    );
  }

  Widget _message(BuildContext context, Note note) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppPadding.kBigPadding,
            AppPadding.kSmallPadding,
            AppPadding.kBigPadding,
            0,
          ),
          child: Slidable(
            startActionPane:
                !context.read<SettingsCubit>().state.isMessageLeftAlign
                    ? null
                    : ActionPane(
                        extentRatio: 0.4,
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            autoClose: true,
                            onPressed: (context) {
                              widget.cubit.deleteNote(note);
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            foregroundColor:
                                Theme.of(context).colorScheme.onBackground,
                            icon: Icons.delete,
                          ),
                          SlidableAction(
                            autoClose: true,
                            onPressed: (context) {
                              if (state.status == ChatStatus.initial) {
                                widget.cubit.setStatus(ChatStatus.forwardTo);
                                widget.cubit.selectNote(note);
                              } else {
                                widget.cubit.selectNote(note);
                              }
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            foregroundColor:
                                Theme.of(context).colorScheme.onBackground,
                            icon: Icons.subdirectory_arrow_left,
                          ),
                          SlidableAction(
                            autoClose: true,
                            onPressed: (context) {
                              widget.cubit.setStatus(ChatStatus.editingNote);
                              widget.cubit.setEditingNoteId(note.id);
                              widget._textFieldController.text = note.text;
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            foregroundColor:
                                Theme.of(context).colorScheme.onBackground,
                            icon: Icons.edit,
                          ),
                          SlidableAction(
                            autoClose: true,
                            onPressed: (context) {
                              _shareApp(note.text);
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            foregroundColor:
                                Theme.of(context).colorScheme.onBackground,
                            icon: Icons.share,
                          ),
                        ],
                      ),
            endActionPane:
                context.read<SettingsCubit>().state.isMessageLeftAlign
                    ? null
                    : ActionPane(
                        extentRatio: 0.5,
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            autoClose: true,
                            onPressed: (context) {
                              widget.cubit.deleteNote(note);
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            foregroundColor:
                                Theme.of(context).colorScheme.onBackground,
                            icon: Icons.delete,
                          ),
                          SlidableAction(
                            autoClose: true,
                            onPressed: (context) {
                              if (state.status == ChatStatus.initial) {
                                widget.cubit.setStatus(ChatStatus.forwardTo);
                                widget.cubit.selectNote(note);
                              } else {
                                widget.cubit.selectNote(note);
                              }
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            foregroundColor:
                                Theme.of(context).colorScheme.onBackground,
                            icon: Icons.subdirectory_arrow_left,
                          ),
                          SlidableAction(
                            autoClose: true,
                            onPressed: (context) {
                              widget.cubit.setStatus(ChatStatus.editingNote);
                              widget.cubit.setEditingNoteId(note.id);
                              widget._textFieldController.text = note.text;
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            foregroundColor:
                                Theme.of(context).colorScheme.onBackground,
                            icon: Icons.edit,
                          ),
                          SlidableAction(
                            autoClose: true,
                            onPressed: (context) {
                              _shareApp(note.text);
                            },
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            foregroundColor:
                                Theme.of(context).colorScheme.onBackground,
                            icon: Icons.share,
                          ),
                        ],
                      ),
            child: Row(
              mainAxisAlignment:
                  context.read<SettingsCubit>().state.isMessageLeftAlign
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.selectedNotesIds.contains(note.id))
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.done,
                          color: Theme.of(context).colorScheme.onSecondary,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: AppPadding.kMediumPadding),
                    ],
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (state.status == ChatStatus.forwardTo) {
                          widget.cubit.selectNote(note);
                        }
                      },
                      onLongPress: () {
                        if (state.status == ChatStatus.initial) {
                          widget.cubit.setStatus(ChatStatus.forwardTo);
                          widget.cubit.selectNote(note);
                        }
                      },
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 300,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(
                            AppPadding.kMediumPadding,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppPadding.kMediumPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (note.text.isNotEmpty)
                                HashTagText(
                                  onTap: (text) {
                                    widget.cubit
                                        .setStatus(ChatStatus.searching);
                                    widget.cubit.searchNotes(text);
                                  },
                                  text: note.text,
                                  basicStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .headline2!
                                        .fontSize,
                                  ),
                                  decoratedStyle: TextStyle(
                                    color: Colors.cyan,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .headline2!
                                        .fontSize,
                                  ),
                                ),
                              if (note.imageName.isNotEmpty)
                                FutureBuilder(
                                  future:
                                      widget.cubit.uploadImage(note.imageName),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: AppPadding.kDefaultPadding,
                                        ),
                                        child: Image.network(
                                          snapshot.data as String,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppPadding.kSmallPadding / 2),
                    Text(
                      _formateTime(note.date),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dateBubble(BuildContext context, String bubbleText) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(
            AppPadding.kMediumPadding,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.kSmallPadding,
            vertical: AppPadding.kSmallPadding / 2,
          ),
          child: Text(
            bubbleText,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _eventsBar(BuildContext context, ChatState state) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppPadding.kDefaultPadding,
      ),
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: state.events.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(
                AppPadding.kSmallPadding,
              ),
              child: GestureDetector(
                onTap: () {
                  widget.cubit.selectEvent(state.events[index].id);
                },
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: state.events[index].id == state.selectedEventId
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        state.events[index].iconData,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: AppPadding.kSmallPadding),
                    Text(
                      state.events[index].title,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bottomTextField(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.background,
            height: 75,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.kSmallPadding,
                  ),
                  child: BlocBuilder<ChatCubit, ChatState>(
                    buildWhen: (prev, curr) => prev.status != curr.status,
                    builder: (context, state) {
                      return IconButton(
                        onPressed: _assistantButtonHandler,
                        icon: _assistantButtonIconHandler(state),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withOpacity(0.1),
                          offset: const Offset(3, 3),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppPadding.kMediumPadding,
                        vertical: AppPadding.kSmallPadding,
                      ),
                      child: HashTagTextField(
                        //TODO question!
                        controller: widget._textFieldController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        decoratedStyle: const TextStyle(
                          color: Colors.cyan,
                        ),
                        basicStyle: const TextStyle(
                          color: Color(0xFF374A48),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.kDefaultPadding - 2,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      final trimmedText =
                          widget._textFieldController.text.trim();

                      if (trimmedText.isNotEmpty ||
                          widget.cubit.state.status == ChatStatus.forwardTo ||
                          widget.cubit.state.image != null) {
                        _sendButtonHandler(trimmedText);
                      } else {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                    },
                    onLongPress: () {
                      final trimmedText =
                          widget._textFieldController.text.trim();

                      if (trimmedText.isNotEmpty) {
                        widget.cubit.setStatus(ChatStatus.sendTo);
                      } else {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                    },
                    child: BlocBuilder<ChatCubit, ChatState>(
                      buildWhen: (prev, curr) {
                        if (prev.status != curr.status) return true;
                        if (prev.selectedEventId != curr.selectedEventId) {
                          return true;
                        }
                        return false;
                      },
                      builder: (context, state) {
                        return _sendButtonIconHandler(state);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formateTime(DateTime messageDate) {
    return '${messageDate.hour < 10 ? '0${messageDate.hour}' : messageDate.hour}:${messageDate.minute < 10 ? '0${messageDate.minute}' : messageDate.minute}';
  }

  String _formatDateBubbleText(DateTime date) {
    final now = DateTime.now();

    if (date.day == now.day &&
        date.month == now.month &&
        date.year == now.year) {
      return 'Today';
    } else if (date.day == now.subtract(const Duration(days: 1)).day) {
      return 'Yesterday';
    } else if (date.day < now.subtract(const Duration(days: 1)).day &&
        date.day >= now.subtract(const Duration(days: 7)).day) {
      return '${_weekdayHandler(date)}';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }

  String _weekdayHandler(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Mon.';
      case 2:
        return 'Tue. ';
      case 3:
        return 'Wed.';
      case 4:
        return 'Thu.';
      case 5:
        return 'Fri.';
      case 6:
        return 'Sat.';
      case 7:
        return 'Sun.';
      default:
        return 'Last week';
    }
  }

  void _sendButtonHandler(String text) {
    final cubit = widget.cubit;
    final state = widget.cubit.state;
    final note = Note(
      id: '',
      eventId: state.event.id,
      text: _textValidation(text),
      date: DateTime.now(),
    );

    switch (state.status) {
      case ChatStatus.editingNote:
        cubit.editNote(text);
        cubit.resetStatus();
        break;
      case ChatStatus.sendTo:
        if (state.selectedEventId.isNotEmpty) {
          cubit.sendToEvent(note);
          cubit.resetStatus();
        } else {
          cubit.resetStatus();
        }
        break;
      case ChatStatus.forwardTo:
        if (state.selectedEventId.isNotEmpty &&
            state.selectedNotesIds.isNotEmpty) {
          cubit.forwardToEvent();
          cubit.resetStatus();
        } else {
          cubit.resetStatus();
        }
        break;
      default:
        cubit.createNote(note);
        break;
    }

    widget._textFieldController.clear();
  }

  Icon _sendButtonIconHandler(ChatState state) {
    final defIconColor = Theme.of(context).colorScheme.onBackground;
    final defIconSize = 24.0;

    switch (state.status) {
      case ChatStatus.editingNote:
        return Icon(
          Icons.done,
          color: defIconColor,
          size: defIconSize,
        );
      case ChatStatus.sendTo:
        if (state.selectedEventId.isNotEmpty) {
          return Icon(
            Icons.done,
            color: defIconColor,
            size: defIconSize,
          );
        } else {
          return Icon(
            Icons.close,
            color: defIconColor,
            size: defIconSize,
          );
        }
      case ChatStatus.forwardTo:
        if (state.selectedEventId.isNotEmpty &&
            state.selectedNotesIds.isNotEmpty) {
          return Icon(
            Icons.subdirectory_arrow_left,
            color: defIconColor,
            size: defIconSize,
          );
        } else {
          return Icon(
            Icons.close,
            color: defIconColor,
            size: defIconSize,
          );
        }

      default:
        return Icon(
          Icons.east,
          color: defIconColor,
          size: defIconSize,
        );
    }
  }

  void _assistantButtonHandler() {
    final cubit = widget.cubit;
    final state = widget.cubit.state;

    switch (state.status) {
      case ChatStatus.editingNote:
        cubit.resetStatus();
        widget._textFieldController.clear();
        break;
      default:
        _pickImage();
        break;
    }
  }

  Icon _assistantButtonIconHandler(ChatState state) {
    final defIconColor = Theme.of(context).colorScheme.onBackground;
    final defIconSize = 24.0;

    switch (state.status) {
      case ChatStatus.editingNote:
        return Icon(
          Icons.cancel,
          color: defIconColor,
          size: defIconSize,
        );
      default:
        return Icon(
          Icons.attachment,
          color: defIconColor,
          size: defIconSize,
        );
    }
  }

  String _textValidation(String text) {
    return text;
  }

  SnackBar _snackBar(String message) {
    return SnackBar(
      content: Text(
        message,
      ),
    );
  }

  Future _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image == null) return;
    widget.cubit.setImage(image);
  }

  Future<void> _shareApp(String text) async {
    await FlutterShare.share(
      title: 'Share note',
      text: text,
      linkUrl: 'https://google.com',
      chooserTitle: 'Example Chooser Title',
    );
  }
}
