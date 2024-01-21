/*
 Playonworld
Version 2
*/

import 'package:Playon/CustomWidgets/gradient_containers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String? appVersion;

  @override
  void initState() {
    main();
    super.initState();
  }

  Future<void> main() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double separationHeight = MediaQuery.sizeOf(context).height * 0.035;

    return GradientContainer(
      child: Stack(
        children: [
          // Positioned(
          //   left: MediaQuery.sizeOf(context).width / 2,
          //   top: MediaQuery.sizeOf(context).width / 5,
          //   child: SizedBox(
          //     width: MediaQuery.sizeOf(context).width,
          //     child: const Image(
          //       fit: BoxFit.fill,
          //       image: AssetImage(
          //         'assets/logo-trans.png',
          //       ),
          //     ),
          //   ),
          // ),
          const GradientContainer(
            child: null,
            opacity: true,
          ),
          Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.secondary,
              elevation: 0,
              title: Text(
                AppLocalizations.of(context)!.about,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: SafeArea(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: separationHeight * 3,
                      ),
                      Card(
                        elevation: 15,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: const SizedBox(
                          width: 150,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Image(
                              image: AssetImage('assets/logo-trans.png'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppLocalizations.of(context)!.appTitle,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: separationHeight / 4,
                      ),
                      Text('v$appVersion'),
                      SizedBox(
                        height: separationHeight * 10,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          launchUrl(
                            Uri.parse(
                              'https://www.buymeacoffee.com/playon',
                            ),
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width / 3,
                          child: const Image(
                            image: AssetImage('assets/black-button.png'),
                          ),
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.madeBy,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!.aboutLine1,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
