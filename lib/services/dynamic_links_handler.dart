import 'package:dima_app/models/poll_event_model.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class DynamicLinksHandler extends ChangeNotifier {
  PendingDynamicLinkData? _dynamicLink;
  bool pushed = true;

  // getter
  PendingDynamicLinkData? get dynamicLink => _dynamicLink;

  void setLink(PendingDynamicLinkData? newLink) {
    _dynamicLink = newLink;
    pushed = false;
    notifyListeners();
  }

  static Future<void> pollEventLinkSharing({
    required BuildContext context,
    required PollEventModel pollData,
  }) async {
    LoadingOverlay.show(context);
    String url =
        "https://eventy.page.link?pollId=${pollData.pollEventName}_${pollData.organizerUid}";
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(url),
      uriPrefix: "https://eventy.page.link",
      androidParameters: const AndroidParameters(
        packageName: "com.example.dima_app",
      ),
      iosParameters: const IOSParameters(
        bundleId: "com.example.dima_app",
      ),
    );
    /*
    final dynamicLongLink =
        await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParams);
    */
    final ShortDynamicLink dynamicShortLink =
        await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    Uri finalUrl = dynamicShortLink.shortUrl;
    // print(finalUrl);
    // print(dynamicLongLink);
    await Share.share(finalUrl.toString());
    // ignore: use_build_context_synchronously
    await Clipboard.setData(ClipboardData(text: finalUrl.toString()));
    LoadingOverlay.hide(context);
  }
}
