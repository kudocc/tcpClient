tcpClient
=========

iOS app using custom protocol to interact with [simple echo server](https://github.com/kudocc/simpleServer) (support VoIP which means when application is suspended, it can receive the packet sended from server on VoIp socket)

Before build the project, you should change the ip address and port of your sever in `config.plist` file.

You can send some text to echo server and receive the text from server. When we receive a packet from server, if app is in background, I present a local notification to notify user, I think it's a standard way for VoIP application.

There are two implementations on tcp client, one is based on C socket, the other is Core Foundation streams.

You can custom the protocol, all custom protocols are subclass from `BaseNetworkPacket` class. There is an example protocol named TextPacket, you can create another one like it. Two c++ class `CSerialization` and `CDeserialization` implement serialization and deserialization.
