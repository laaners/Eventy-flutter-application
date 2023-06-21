// ignore_for_file: use_build_context_synchronously

import 'package:dima_app/screens/poll_create/poll_create.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/screen_transition.dart';
import 'package:dima_app/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_poll_event.dart';
import 'firebase_poll_event_invite.dart';
import 'firebase_user.dart';

class PollEventUserMethods {
  static createNewPoll({required BuildContext context}) async {
    // the result from pop is the poll id
    final pollId = await Navigator.of(context, rootNavigator: true).push(
      ScreenTransition(
        builder: (context) => const PollCreateScreen(),
      ),
    );
    if (pollId != null) {
      showSnackBar(context, "Successfully created event!");
    }
  }

  static optionsRisManager({
    required BuildContext context,
    required String pollEventId,
    required dynamic ris,
  }) async {
    String curUid = Provider.of<FirebaseUser>(context, listen: false).user!.uid;
    if (ris == "create_event_$curUid") {
      LoadingOverlay.show(context);
      await Provider.of<FirebasePollEvent>(context, listen: false)
          .closePoll(pollId: pollEventId);
      LoadingOverlay.hide(context);
    } else if (ris == "delete_poll_$curUid") {
      LoadingOverlay.show(context);
      await Provider.of<FirebasePollEvent>(context, listen: false)
          .deletePollEvent(
        context: context,
        pollId: pollEventId,
      );
      LoadingOverlay.hide(context);
    } else if (ris == "exit_poll") {
      LoadingOverlay.show(context);
      await Provider.of<FirebasePollEventInvite>(context, listen: false)
          .deletePollEventInvite(
        context: context,
        inviteeId: curUid,
        pollEventId: pollEventId,
      );
      LoadingOverlay.hide(context);
    }
  }
}
