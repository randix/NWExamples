# NWExamples

## Introduction

There is currently a dearth of examples for Apple's Network Framework libraries. And the Apple documentation is at the level of "expert" documentation. 

A version of this was written in C#, contact the author if that might be useful.
This version in Swift is designed to run on iOS and macOS. 

The purpose was to a very lightweight RPC system. This works very similar to a WebSocket, only it starts as a clean transport system, whereas a WebSocket could be considered as an enhancement to an HTTP/HTTPS server. This eliminates all of the overhead of the HTTP/HTTPS server.

## What is here?

There are client and server classes for TCP and UDP examples of using the Network Framkework. This supports TLS and working through a proxy (at the simplest level).

## APIs

### MTSMessage

<pre>
enum MTSRequest {
    case RPC1         // user defined RPCs
    case RMC2
}
    
class MTSMessage {
    route: MTSRequest
    jwt: String         // JSON Web Token (if desired)
    data: Data 
    reply: Bool = false
}
</pre>

### TCP Server

This supports multiple incoming clients. 

<pre>
class MTSServer

init(log: (_ log: String) -> Void, port: UInt16,  mtsAccept: (_ from: MTSClient) -> Void, mtsReceive: (_ from: MTSClient, receive: MTSMessage) -> Void)

func withTLS(certificate: Data, clientCertificateRequired: Bool = false) -> MTSServer

func clientCertificateRequired(_ flag: Bool) -> Void

func start() -> MTSServer

func stop() -> Void

func send(_ message: MTSMessage, to: MTSClient)
</pre>

### TCP Client

<pre>
class MTSClient

init(_ log: (_ log: String) -> Void, url: String, mtsConnect: () -> Void, mtsReceive: (_ receive: MTSMessage) -> Void, mtsDisconnect: () -> Void) 

func withTLS(_ certificate: Data?) -> MTSClient

func withProxy(_ proxyURL: String, proxyUser: String?, proxyPassword: String?) -> MTSClient

func connect() -> MTSClient

func stop() -> Void

func send(_ message: MTSMessage)
</pre>

### UDP Server

This supports only one client per port, and does not support UDP proxies.

<pre>
class UDPServer

init(_ log: (_ log: String) -> Void, port: UInt16, udpReceiver: (_ from: UDPClient, _ receive: Data) -> Void)

func withTLS(certificate: Data, clientCertificateRequired: Bool = false) -> UDPServer

func clientCertificateRequired(_ flag: Bool) -> Void

func start() -> UDPServer

func stop() -> Void

func send(_ message: Data)
  
</pre>

### UDP Client

<pre>
class UDPClient

init(_ log: (_ log: String) -> Void, url: String, udpReceiver: (_ receive: Data) -> Void)

func start() -> UDPServer

func stop() -> Void

func send(_ message: Data)
</pre>

