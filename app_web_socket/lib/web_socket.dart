import 'package:tekartik_web_socket/web_socket.dart';

import 'src/web_socket.dart' as src;

/// The Web socket client factory for your flutter application.
///
WebSocketChannelClientFactory get webSocketChannelClientFactory =>
    src.webSocketChannelClientFactory;
