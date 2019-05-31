# NWExamples

## Introduction

There is currently a dearth of examples for Apple's Network Framework libraries. And the Apple documentation is at the level of "expert" documentation. 

A version of this was written in C#, this version is designed to run on iOS and macOS. 

The purpose was to a very lightweight RPC system. This works very similar to a WebSocket, only it starts as a clean transport system, whereas a WebSocket could be considered as an enhancement to an HTTP/HTTPS server. This eliminates all of the overhead of the HTTP/HTTPS server.

## What is here?

There are client and server classes for TCP and UDP examples of using the Network Framkework. This supports TLS and working through a proxy (at the simplest level).

## APIs

### MTSMessage

enum MTSRequest {
    case RPC1         // user defined RPCs
    case RMC2
}
    
class MTSMessage {
    route: MTSRequest
    jwt: String
    Reply: Bool
    Data: Data 
}

### TCP Server

class MTSServer

init(log: (_ log: String) -> Void, port: UInt16, mtsReceiver: (_ receive: MTSMessage) -> Void)

func withTLS(certificate: Data, clientCertificateRequired: Bool) -> MTSServer

func clientCertificateRequired(_ flag: Bool) -> Void

func start() -> MTSServer

func stop() -> Void

### TCP Client

class MTSClient

init(_ log: (_ log: String) -> Void, url: String, mtsReceiver: (_ receive: MTSMessage) -> Void) 

init(_ log: (_ log: String) -> Void, hostname: String, port: UInt16, mtsReceiver: (_ receive: MTSMessage) -> Void) 

func withTLS(_ certificate: Data?) -> MTSClient

func withProxy(_ proxyURL: String, proxyUser: String?, proxyPassword: String?) -> MTSClient

func Connect() -> MTSClient

func Stop() -> Void
