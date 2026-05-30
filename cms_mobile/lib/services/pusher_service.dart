import 'dart:developer';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../constants/api_constants.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  factory PusherService() => _instance;
  PusherService._internal();

  final PusherChannelsFlutter _pusher = PusherChannelsFlutter.getInstance();
  final List<void Function(PusherEvent)> _listeners = [];

  Future<void> init() async {
    try {
      log("Pusher: Initializing...");
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
      );
      log("Pusher: Connecting...");
      await _pusher.connect();
    } catch (e) {
      log("Pusher initialization error: $e");
    }
  }

  void addListener(void Function(PusherEvent) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(PusherEvent) listener) {
    _listeners.remove(listener);
  }

  Future<void> subscribe(String channelName) async {
    log("Pusher: Subscribing to $channelName");
    try {
      await _pusher.subscribe(channelName: channelName);
    } catch (e) {
      log("Pusher: Already subscribed or error: $e");
    }
  }

  Future<void> unsubscribe(String channelName) async {
    log("Pusher: Unsubscribing from $channelName");
    await _pusher.unsubscribe(channelName: channelName);
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Pusher Connection State Change: $previousState -> $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    log("Pusher Error: $message (code: $code) $e");
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("Pusher Subscription Succeeded: $channelName data: $data");
  }

  void onEvent(PusherEvent event) {
    log("Pusher Event Received: ${event.eventName} on ${event.channelName} with data: ${event.data}");
    for (var listener in _listeners) {
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

