import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../common/globals.dart';
import '../common/sources.dart';
import '../common/widgets.dart';

class SinglePlayerMultipleVideoScreen extends StatefulWidget {
  const SinglePlayerMultipleVideoScreen({Key? key}) : super(key: key);

  @override
  State<SinglePlayerMultipleVideoScreen> createState() =>
      _SinglePlayerMultipleVideoScreenState();
}

class _SinglePlayerMultipleVideoScreenState
    extends State<SinglePlayerMultipleVideoScreen> {
  final Player player = Player();
  VideoController? controller;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      controller = await VideoController.create(
        player,
        enableHardwareAcceleration: enableHardwareAcceleration.value,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    Future.microtask(() async {
      debugPrint('Disposing [Player] and [VideoController]...');
      await controller?.dispose();
      await player.dispose();
    });
    super.dispose();
  }

  List<Widget> get items => [
        for (int i = 0; i < sources.length; i++)
          ListTile(
            title: Text(
              'Video $i',
              style: const TextStyle(
                fontSize: 14.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              player.open(Media(sources[i]));
            },
          ),
      ];

  @override
  Widget build(BuildContext context) {
    final horizontal =
        MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('package:media_kit'),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'file',
            tooltip: 'Open [File]',
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.any,
              );
              if (result?.files.isNotEmpty ?? false) {
                await player.open(Media(result!.files.first.path!));
              }
            },
            child: const Icon(Icons.file_open),
          ),
          const SizedBox(width: 16.0),
          FloatingActionButton(
            heroTag: 'uri',
            tooltip: 'Open [Uri]',
            onPressed: () => showURIPicker(context, player),
            child: const Icon(Icons.link),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: horizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 8.0,
                            color: Colors.black,
                            clipBehavior: Clip.antiAlias,
                            margin: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Video(controller: controller)),
                                      Expanded(
                                          child: Video(controller: controller)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SeekBar(player: player),
                        const SizedBox(height: 32.0),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1.0, thickness: 1.0),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: items,
                    ),
                  ),
                ],
              )
            : ListView(
                children: [
                  Container(
                    color: Colors.black,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 9.0 / 16.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: Video(controller: controller)),
                              Expanded(child: Video(controller: controller)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SeekBar(player: player),
                  const SizedBox(height: 32.0),
                  const Divider(height: 1.0, thickness: 1.0),
                  ...items,
                ],
              ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('全屏'),
            ),
          ),
        ],
      ),
    );
  }
}
