/*
 Playonworld
Version 2
*/

import 'dart:convert';

import 'package:Playon/APIs/api.dart';
import 'package:Playon/APIs/spotify_api.dart';
import 'package:Playon/CustomWidgets/gradient_containers.dart';
import 'package:Playon/Helpers/matcher.dart';
import 'package:Playon/Helpers/playlist.dart';
import 'package:Playon/Services/youtube_services.dart';
import 'package:Playon/Services/yt_music.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// ignore: avoid_classes_with_only_static_members
class SearchAddPlaylist {
  static Future<Map> addYtPlaylist(String inLink) async {
    final String link = '$inLink&';
    try {
      final RegExpMatch? id = RegExp(r'.*list\=(.*?)&').firstMatch(link);
      if (id != null) {
        final Map metadata = await YtMusicService().getPlaylistDetails(id[1]!);
        return metadata;
      }
      return {};
    } catch (e) {
      Logger.root.severe('Error while adding YT playlist: $e');
      return {};
    }
  }

  static Future<Map> addSpotifyPlaylist(
    String title,
    String accessToken,
    String playlistId,
  ) async {
    try {
      final List tracks =
          await SpotifyApi().getAllTracksOfPlaylist(accessToken, playlistId);
      return {
        'title': title,
        'count': tracks.length,
        'tracks': tracks,
      };
    } catch (e) {
      Logger.root.severe('Error while adding Spotify playlist: $e');
      return {};
    }
  }

  static Future<Map> addRessoPlaylist(String inLink) async {
    try {
      final RegExpMatch? id = RegExp(r'.*?id\=(.*)&').firstMatch('$inLink&');
      if (id != null) {
        final List tracks = await getRessoSongs(playlistId: id[1]!);
        return {
          'title': 'Resso Playlist',
          'count': tracks.length,
          'tracks': tracks,
        };
      } else {
        final Request req = Request('Get', Uri.parse(inLink))
          ..followRedirects = false;
        final Client baseClient = Client();
        final StreamedResponse response = await baseClient.send(req);
        final Uri redirectUri =
            Uri.parse(response.headers['location'].toString());
        baseClient.close();
        final RegExpMatch? id2 =
            RegExp(r'.*?id\=(.*)&').firstMatch('$redirectUri&');
        if (id2 != null) {
          final List tracks = await getRessoSongs(playlistId: id2[1]!);
          return {
            'title': 'Resso Playlist',
            'count': tracks.length,
            'tracks': tracks,
          };
        }
      }
      return {};
    } catch (e) {
      Logger.root.severe('Error while adding Resso playlist: $e');
      return {};
    }
  }

  static Future<List> getRessoSongs({required String playlistId}) async {
    const url = 'https://api.resso.app/resso/playlist/detail?playlist_id=';
    final Uri link = Uri.parse(url + playlistId);
    final Response response = await get(link);
    if (response.statusCode != 200) {
      return [];
    }
    final res = await jsonDecode(response.body);
    return res['tracks'] as List;
  }

  static Future<Map> addJioSaavnPlaylist(String inLink) async {
    try {
      final String id = inLink.split('/').last;
      if (id != '') {
        final Map data =
            await SaavnAPI().getSongFromToken(id, 'playlist', n: -1);
        return {
          'title': data['title'],
          'count': data['songs'].length,
          'tracks': data['songs'],
        };
      }
      return {};
    } catch (e) {
      Logger.root.severe('Error while adding JioSaavn playlist: $e');
      return {};
    }
  }

  static Stream<Map> ytSongsAdder(String playName, List tracks) async* {
    int done = 0;
    for (final track in tracks) {
      String? trackName;
      try {
        trackName = (track as Video).title;
        yield {'done': ++done, 'name': trackName};
      } catch (e) {
        yield {'done': ++done, 'name': ''};
      }
      try {
        final Map data = await SaavnAPI().fetchSongSearchResults(
          searchQuery: trackName!.split('|')[0],
          count: 3,
        );
        final List result = data['songs'] as List;
        final index = findBestMatch(
          result,
          {
            'title': trackName,
            'artist': trackName,
          },
        );
        if (index != -1) {
          addMapToPlaylist(playName, result[index] as Map);
        } else {
          YouTubeServices.instance
              .formatVideo(
            video: track as Video,
            getUrl: false,
            quality: 'low',
          )
              .then((songMap) {
            if (songMap != null) {
              addMapToPlaylist(playName, songMap);
            }
          });
        }
      } catch (e) {
        Logger.root.severe('Error in $done: $e');
      }
    }
  }

  static Stream<Map> spotifySongsAdder(String playName, List tracks) async* {
    int done = 0;
    for (final track in tracks) {
      String? trackName;
      String? artistName;
      try {
        trackName = track['track']['name'].toString();
        artistName = (track['track']['artists'] as List)
            .map((e) => e['name'])
            .toList()
            .join(', ');
        yield {'done': ++done, 'name': '$trackName - $artistName'};
      } catch (e) {
        yield {'done': ++done, 'name': ''};
      }
      try {
        final Map data = await SaavnAPI().fetchSongSearchResults(
          searchQuery: '$trackName - $artistName',
          count: 3,
        );
        final List result = data['songs'] as List;
        final index = findBestMatch(
          result,
          {
            'title': trackName,
            'artist': artistName,
          },
        );
        if (index != -1) {
          addMapToPlaylist(playName, result[index] as Map);
        }
      } catch (e) {
        Logger.root.severe('Error in $done: $e');
      }
    }
  }

  static Stream<Map> ressoSongsAdder(String playName, List tracks) async* {
    int done = 0;
    for (final track in tracks) {
      String? trackName;
      String? artistName;
      try {
        trackName = track['name'].toString();
        artistName = (track['artists'] as List)
            .map((e) => e['name'])
            .toList()
            .join(', ');

        yield {'done': ++done, 'name': '$trackName - $artistName'};
      } catch (e) {
        yield {'done': ++done, 'name': ''};
      }
      try {
        final Map data = await SaavnAPI().fetchSongSearchResults(
          searchQuery: '$trackName - $artistName',
          count: 3,
        );
        final List result = data['songs'] as List;
        final index = findBestMatch(
          result,
          {
            'title': trackName,
            'artist': artistName,
          },
        );
        if (index != -1) {
          addMapToPlaylist(playName, result[index] as Map);
        }
      } catch (e) {
        Logger.root.severe('Error in $done: $e');
      }
    }
  }

  static Future<void> showProgress(
    int total,
    BuildContext cxt,
    Stream songAdd,
  ) async {
    if (total != 0) {
      await showModalBottomSheet(
        isDismissible: false,
        backgroundColor: Colors.transparent,
        context: cxt,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStt) {
              return BottomGradientContainer(
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: StreamBuilder<Object>(
                    stream: songAdd as Stream<Object>?,
                    builder: (BuildContext ctxt, AsyncSnapshot snapshot) {
                      final Map? data = snapshot.data as Map?;
                      final int done = (data ?? const {})['done'] as int? ?? 0;
                      final String name =
                          (data ?? const {})['name'] as String? ?? '';
                      if (done == total) Navigator.pop(ctxt);
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Text(
                              AppLocalizations.of(context)!.convertingSongs,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            height: 90,
                            width: 90,
                            child: Stack(
                              children: [
                                Center(
                                  child: Text('$done / $total'),
                                ),
                                Center(
                                  child: SizedBox(
                                    height: 85,
                                    width: 85,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(ctxt).colorScheme.secondary,
                                      ),
                                      value: done / total,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Text(
                              '$name\n',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      );
    }
  }
}
