import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soup_reminders/features/calendar/google_calendar_service.dart';
import 'package:soup_reminders/features/tasks/models/task_models.dart';

final googleCalendarServiceProvider =
    Provider<GoogleCalendarService>((ref) => GoogleCalendarService());

/// Auth state for the Google account (email if signed in, null otherwise).
final googleAccountProvider =
    NotifierProvider<GoogleAccountNotifier, String?>(GoogleAccountNotifier.new);

class GoogleAccountNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  GoogleCalendarService get _service =>
      ref.read(googleCalendarServiceProvider);

  Future<bool> restore() async {
    final ok = await _service.trySilentSignIn();
    if (ok) state = 'restored';
    return ok;
  }

  Future<bool> signIn() async {
    final email = await _service.signIn();
    state = email;
    return email != null;
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = null;
  }
}

/// Fetches the calendar events for a given day. Used during planning to seed
/// the fixed blocks. Returns an empty list (not an error) when not signed in.
final calendarEventsProvider =
    FutureProvider.family<List<CalendarEvent>, DateTime>((ref, day) async {
  final service = ref.watch(googleCalendarServiceProvider);
  if (!service.isSignedIn) {
    final restored = await ref.read(googleAccountProvider.notifier).restore();
    if (!restored) return const [];
  }
  return service.eventsForDay(day);
});
