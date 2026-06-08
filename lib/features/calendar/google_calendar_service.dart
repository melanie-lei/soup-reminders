import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;
import 'package:soup_reminders/features/tasks/models/task_models.dart';

/// An [http.BaseClient] that injects Google auth headers into every request,
/// so the googleapis client can call the Calendar API.
class _AuthClient extends http.BaseClient {
  _AuthClient(this._headers, this._inner);

  final Map<String, String> _headers;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

/// Wraps Google Sign-In + the Calendar API.
///
/// NOTE (native follow-up): Google Sign-In needs platform config —
/// `google-services.json` (Android) / `GoogleService-Info.plist` + URL scheme
/// (iOS), and an OAuth client with the Calendar scope enabled. Wire those up
/// alongside the UI. The sign-in + fetch logic is complete here.
class GoogleCalendarService {
  GoogleCalendarService({GoogleSignIn? signIn})
      : _googleSignIn = signIn ??
            GoogleSignIn(scopes: const [gcal.CalendarApi.calendarReadonlyScope]);

  final GoogleSignIn _googleSignIn;

  bool get isSignedIn => _googleSignIn.currentUser != null;

  /// Attempt a silent sign-in (returns true if a session was restored).
  Future<bool> trySilentSignIn() async {
    final account = await _googleSignIn.signInSilently();
    return account != null;
  }

  /// Interactive sign-in. Returns the account email on success, null if the
  /// user cancelled.
  Future<String?> signIn() async {
    final account = await _googleSignIn.signIn();
    return account?.email;
  }

  Future<void> signOut() => _googleSignIn.signOut();

  /// Fetch calendar events for [day] (local time) as fixed [CalendarEvent]s.
  ///
  /// All-day events are skipped (they have no start/end time to block out).
  Future<List<CalendarEvent>> eventsForDay(DateTime day) async {
    final account = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (account == null) {
      throw StateError('Not signed in to Google');
    }

    final headers = await account.authHeaders;
    final client = _AuthClient(headers, http.Client());
    try {
      final api = gcal.CalendarApi(client);
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));

      final events = await api.events.list(
        'primary',
        timeMin: dayStart.toUtc(),
        timeMax: dayEnd.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      final result = <CalendarEvent>[];
      for (final e in events.items ?? const <gcal.Event>[]) {
        final start = e.start?.dateTime?.toLocal();
        final end = e.end?.dateTime?.toLocal();
        if (start == null || end == null) continue; // skip all-day events
        result.add(CalendarEvent(
          id: e.id ?? '${start.millisecondsSinceEpoch}',
          title: e.summary ?? '(no title)',
          start: start,
          end: end,
        ));
      }
      return result;
    } finally {
      client.close();
    }
  }
}
