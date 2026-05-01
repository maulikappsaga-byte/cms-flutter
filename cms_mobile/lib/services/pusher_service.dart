import 'dart:developer';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();

  Future<void> init() async {
    try {
      print("Pusher: Initializing...");
      await _pusher.init(
        apiKey: "0885b0f4711b8de140c5",
        cluster: "ap2",
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
      );
      print("Pusher: Connecting...");
      await _pusher.connect();
    } catch (e) {
      print("Pusher initialization error: $e");
    }
  }

  Future<void> subscribe(String channelName) async {
    print("Pusher: Subscribing to $channelName");
    await _pusher.subscribe(channelName: channelName);
  }

  Future<void> unsubscribe(String channelName) async {
    print("Pusher: Unsubscribing from $channelName");
    await _pusher.unsubscribe(channelName: channelName);
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    print("Pusher Connection State Change: $previousState -> $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    print("Pusher Error: $message (code: $code) $e");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    print("Pusher Subscription Succeeded: $channelName data: $data");
  }

  void onEvent(PusherEvent event) {
    print("Pusher Event Received: ${event.eventName} on ${event.channelName} with data: ${event.data}");
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
