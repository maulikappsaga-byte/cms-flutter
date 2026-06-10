import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../constants/api_constants.dart';
import 'clinic_detail_api.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final List<void Function(PusherEvent)> _listeners = [];
  String _connectionState = 'DISCONNECTED';
  int? _clinicId;

  String get connectionState => _connectionState;
  int? get clinicId => _clinicId;

  Future<void> init() async {
    try {
      if (_clinicId == null) {
        print("Pusher: Fetching clinic details to get clinic ID...");
        try {
          final details = await ClinicDetailApi().getClinicDetails();
          final dynamic fetchedId = details['data']?['clinic']?['id'];
          if (fetchedId != null) {
            _clinicId = int.tryParse(fetchedId.toString());
          }
          print("Pusher: Fetched clinic ID $_clinicId");
        } catch (e) {
          print("Pusher: Error fetching clinic ID: $e");
        }
      }

      print("Pusher: Initializing...");
      await _pusher.init(
        apiKey: ApiConstants.pusherAppKey,
        cluster: ApiConstants.pusherCluster,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        onAuthorizer: onAuthorizer,
      );
      print("Pusher: Connecting...");
      await _pusher.connect();
    } catch (e) {
      print("Pusher initialization error: $e");
    }
  }

  dynamic onAuthorizer(String channelName, String socketId, dynamic options) async {
    try {
      final authUrl = '${ApiConstants.baseUrl}/broadcasting/auth';
      print("Pusher: Authorizing channel $channelName with socketId $socketId");
      final response = await http.post(
        Uri.parse(authUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': ApiConstants.apiKey,
        },
        body: jsonEncode({
          'socket_id': socketId,
          'channel_name': channelName,
        }),
      );
      
      if (response.statusCode == 200) {
        print("Pusher: Authorized successfully.");
        return jsonDecode(response.body);
      } else {
        print("Pusher: Auth failed with status ${response.statusCode}: ${response.body}");
        throw Exception('Failed to authorize Pusher channel');
      }
    } catch (e) {
      print("Pusher: Authorizer error: $e");
      rethrow;
    }
  }

  /// Disconnect, reinitialize, and reconnect. Safe to call from lifecycle hooks.
  Future<void> reconnect() async {
    try {
      await _pusher.disconnect();
    } catch (_) {}
    await init();
  }

  void addListener(void Function(PusherEvent) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(PusherEvent) listener) {
    _listeners.remove(listener);
  }

  Future<void> subscribe(String channelName) async {
    print("Pusher: Subscribing to $channelName");
    try {
      await _pusher.subscribe(channelName: channelName);
    } catch (e) {
      print("Pusher: Already subscribed or error: $e");
    }
  }

  Future<void> unsubscribe(String channelName) async {
    print("Pusher: Unsubscribing from $channelName");
    await _pusher.unsubscribe(channelName: channelName);
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    _connectionState = currentState?.toString() ?? 'UNKNOWN';
    print("Pusher Connection State Change: $previousState -> $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    log("Pusher Error: $message (code: $code) $e");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("Pusher Subscription Succeeded: $channelName data: $data");
  }

  void onEvent(PusherEvent event) {
    print("Pusher Event Received: ${event.eventName} on ${event.channelName} with data: ${event.data}");
    // Iterate over a snapshot copy so that adding/removing listeners
    // during dispatch cannot cause a ConcurrentModificationError.
    for (var listener in List.of(_listeners)) {
      listener(event);
    }
  }

  void onSubscriptionError(String message, dynamic e) {
    log("Pusher Subscription Error: $message $e");
  }

  void onDecryptionFailure(String event, String reason) {
    log("Pusher Decryption Failure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    log("Pusher Member Added: $channelName member: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    log("Pusher Member Removed: $channelName member: $member");
  }

  Future<void> disconnect() async {
    await _pusher.disconnect();
  }
}

