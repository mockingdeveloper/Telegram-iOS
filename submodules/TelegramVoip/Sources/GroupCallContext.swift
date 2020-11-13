import Foundation
import SwiftSignalKit
import TgVoipWebrtc

private final class ContextQueueImpl: NSObject, OngoingCallThreadLocalContextQueueWebrtc {
    private let queue: Queue
    
    init(queue: Queue) {
        self.queue = queue
        
        super.init()
    }
    
    func dispatch(_ f: @escaping () -> Void) {
        self.queue.async {
            f()
        }
    }
    
    func dispatch(after seconds: Double, block f: @escaping () -> Void) {
        self.queue.after(seconds, f)
    }
    
    func isCurrent() -> Bool {
        return self.queue.isCurrent()
    }
}

private struct ConferenceDescription {
    struct Transport {
        struct Candidate {
            var id: String
            var generation: Int
            var component: String
            var `protocol`: String
            var tcpType: String?
            var ip: String
            var port: Int
            var foundation: String
            var priority: Int
            var type: String
            var network: Int
            var relAddr: String?
            var relPort: Int?
        }
        
        struct Fingerprint {
            var fingerprint: String
            var setup: String
            var hashType: String
        }
        
        var candidates: [Candidate]
        var fingerprints: [Fingerprint]
        var ufrag: String
        var pwd: String
    }
    
    struct ChannelBundle {
        var id: String
        var transport: Transport
    }
    
    struct Content {
        struct Channel {
            struct SsrcGroup {
                var sources: [Int]
                var semantics: String
            }
            
            struct PayloadType {
                var id: Int
                var name: String
                var clockrate: Int
                var channels: Int
                var parameters: [String: Any]?
            }
            
            struct RtpHdrExt {
                var id: Int
                var uri: String
            }
            
            var id: String?
            var endpoint: String
            var channelBundleId: String
            var sources: [Int]
            var ssrcs: [Int]
            var rtpLevelRelayType: String
            var expire: Int?
            var initiator: Bool
            var direction: String
            var ssrcGroups: [SsrcGroup]
            var payloadTypes: [PayloadType]
            var rtpHdrExts: [RtpHdrExt]
        }
        
        var name: String
        var channels: [Channel]
    }
    
    var id: String
    var channelBundles: [ChannelBundle]
    var contents: [Content]
    
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String else {
            assert(false)
            return nil
        }
        self.id = id
        
        var channelBundles: [ChannelBundle] = []
        if let channelBundlesJson = json["channel-bundles"] as? [Any] {
            for channelBundleValue in channelBundlesJson {
                if let channelBundleJson = channelBundleValue as? [String: Any] {
                    if let channelBundle = ChannelBundle(json: channelBundleJson) {
                        channelBundles.append(channelBundle)
                    }
                }
            }
        }
        self.channelBundles = channelBundles
        
        var contents: [Content] = []
        if let contentsJson = json["contents"] as? [Any] {
            for contentValue in contentsJson {
                if let contentJson = contentValue as? [String: Any] {
                    if let content = Content(json: contentJson) {
                        contents.append(content)
                    }
                }
            }
        }
        self.contents = contents
    }
}

private extension ConferenceDescription.Transport.Candidate {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String else {
            assert(false)
            return nil
        }
        self.id = id
        
        if let generationString = json["generation"] as? String, let generation = Int(generationString) {
            self.generation = generation
        } else {
            self.generation = 0
        }
        
        guard let component = json["component"] as? String else {
            assert(false)
            return nil
        }
        self.component = component
        
        guard let `protocol` = json["protocol"] as? String else {
            assert(false)
            return nil
        }
        self.protocol = `protocol`
        
        if let tcpType = json["tcptype"] as? String {
            self.tcpType = tcpType
        } else {
            self.tcpType = nil
        }
        
        guard let ip = json["ip"] as? String else {
            assert(false)
            return nil
        }
        self.ip = ip
        
        guard let portString = json["port"] as? String, let port = Int(portString) else {
            assert(false)
            return nil
        }
        self.port = port
        
        guard let foundation = json["foundation"] as? String else {
            assert(false)
            return nil
        }
        self.foundation = foundation
        
        guard let priorityString = json["priority"] as? String, let priority = Int(priorityString) else {
            assert(false)
            return nil
        }
        self.priority = priority
        
        guard let type = json["type"] as? String else {
            assert(false)
            return nil
        }
        self.type = type
        
        guard let networkString = json["network"] as? String, let network = Int(networkString) else {
            assert(false)
            return nil
        }
        self.network = network
        
        if let relAddr = json["rel-addr"] as? String {
            self.relAddr = relAddr
        } else {
            self.relAddr = nil
        }
        
        if let relPortString = json["rel-port"] as? String, let relPort = Int(relPortString) {
            self.relPort = relPort
        } else {
            self.relPort = nil
        }
    }
}

private extension ConferenceDescription.Transport.Fingerprint {
    init?(json: [String: Any]) {
        guard let fingerprint = json["fingerprint"] as? String else {
            assert(false)
            return nil
        }
        self.fingerprint = fingerprint
        
        guard let setup = json["setup"] as? String else {
            assert(false)
            return nil
        }
        self.setup = setup
        
        guard let hashType = json["hash"] as? String else {
            assert(false)
            return nil
        }
        self.hashType = hashType
    }
}

private extension ConferenceDescription.Transport {
    init?(json: [String: Any]) {
        guard let ufrag = json["ufrag"] as? String else {
            assert(false)
            return nil
        }
        self.ufrag = ufrag
        
        guard let pwd = json["pwd"] as? String else {
            assert(false)
            return nil
        }
        self.pwd = pwd
        
        var candidates: [Candidate] = []
        if let candidatesJson = json["candidates"] as? [Any] {
            for candidateValue in candidatesJson {
                if let candidateJson = candidateValue as? [String: Any] {
                    if let candidate = Candidate(json: candidateJson) {
                        candidates.append(candidate)
                    }
                }
            }
        }
        self.candidates = candidates
        
        var fingerprints: [Fingerprint] = []
        if let fingerprintsJson = json["fingerprints"] as? [Any] {
            for fingerprintValue in fingerprintsJson {
                if let fingerprintJson = fingerprintValue as? [String: Any] {
                    if let fingerprint = Fingerprint(json: fingerprintJson) {
                        fingerprints.append(fingerprint)
                    }
                }
            }
        }
        self.fingerprints = fingerprints
    }
}

private extension ConferenceDescription.ChannelBundle {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String else {
            assert(false)
            return nil
        }
        self.id = id
        
        guard let transportJson = json["transport"] as? [String: Any] else {
            assert(false)
            return nil
        }
        guard let transport = ConferenceDescription.Transport(json: transportJson) else {
            assert(false)
            return nil
        }
        self.transport = transport
    }
}

private extension ConferenceDescription.Content.Channel.SsrcGroup {
    init?(json: [String: Any]) {
        guard let sources = json["sources"] as? [Int] else {
            assert(false)
            return nil
        }
        self.sources = sources
        
        guard let semantics = json["semantics"] as? String else {
            assert(false)
            return nil
        }
        self.semantics = semantics
    }
}

private extension ConferenceDescription.Content.Channel.PayloadType {
    init?(json: [String: Any]) {
        guard let idString = json["id"] as? String, let id = Int(idString) else {
            assert(false)
            return nil
        }
        self.id = id
        
        guard let name = json["name"] as? String else {
            assert(false)
            return nil
        }
        self.name = name
        
        guard let clockrateString = json["clockrate"] as? String, let clockrate = Int(clockrateString) else {
            assert(false)
            return nil
        }
        self.clockrate = clockrate
        
        guard let channelsString = json["channels"] as? String, let channels = Int(channelsString) else {
            assert(false)
            return nil
        }
        self.channels = channels
        
        self.parameters = json["parameters"] as? [String: Any]
    }
}

private extension ConferenceDescription.Content.Channel.RtpHdrExt {
    init?(json: [String: Any]) {
        guard let idString = json["id"] as? String, let id = Int(idString) else {
            assert(false)
            return nil
        }
        self.id = id
        
        guard let uri = json["uri"] as? String else {
            assert(false)
            return nil
        }
        self.uri = uri
    }
}

private extension ConferenceDescription.Content.Channel {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? String else {
            assert(false)
            return nil
        }
        self.id = id
        
        guard let endpoint = json["endpoint"] as? String else {
            assert(false)
            return nil
        }
        self.endpoint = endpoint
        
        guard let channelBundleId = json["channel-bundle-id"] as? String else {
            assert(false)
            return nil
        }
        self.channelBundleId = channelBundleId
        
        guard let sources = json["sources"] as? [Int] else {
            assert(false)
            return nil
        }
        self.sources = sources
        
        if let ssrcs = json["ssrcs"] as? [Int] {
            self.ssrcs = ssrcs
        } else {
            self.ssrcs = []
        }
        
        guard let rtpLevelRelayType = json["rtp-level-relay-type"] as? String else {
            assert(false)
            return nil
        }
        self.rtpLevelRelayType = rtpLevelRelayType
        
        if let expire = json["expire"] as? Int {
            self.expire = expire
        } else {
            self.expire = nil
        }
        
        guard let initiator = json["initiator"] as? Bool else {
            assert(false)
            return nil
        }
        self.initiator = initiator
        
        guard let direction = json["direction"] as? String else {
            assert(false)
            return nil
        }
        self.direction = direction
        
        var ssrcGroups: [SsrcGroup] = []
        if let ssrcGroupsJson = json["ssrc-groups"] as? [Any] {
            for ssrcGroupValue in ssrcGroupsJson {
                if let ssrcGroupJson = ssrcGroupValue as? [String: Any] {
                    if let ssrcGroup = SsrcGroup(json: ssrcGroupJson) {
                        ssrcGroups.append(ssrcGroup)
                    }
                }
            }
        }
        self.ssrcGroups = ssrcGroups
        
        var payloadTypes: [PayloadType] = []
        if let payloadTypesJson = json["payload-types"] as? [Any] {
            for payloadTypeValue in payloadTypesJson {
                if let payloadTypeJson = payloadTypeValue as? [String: Any] {
                    if let payloadType = PayloadType(json: payloadTypeJson) {
                        payloadTypes.append(payloadType)
                    }
                }
            }
        }
        self.payloadTypes = payloadTypes
        
        var rtpHdrExts: [RtpHdrExt] = []
        if let rtpHdrExtsJson = json["rtp-hdrexts"] as? [Any] {
            for rtpHdrExtValue in rtpHdrExtsJson {
                if let rtpHdrExtJson = rtpHdrExtValue as? [String: Any] {
                    if let rtpHdrExt = RtpHdrExt(json: rtpHdrExtJson) {
                        rtpHdrExts.append(rtpHdrExt)
                    }
                }
            }
        }
        self.rtpHdrExts = rtpHdrExts
    }
}

private extension ConferenceDescription.Content {
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String else {
            assert(false)
            return nil
        }
        self.name = name
        
        var channels: [Channel] = []
        if let channelsJson = json["channels"] as? [Any] {
            for channelValue in channelsJson {
                if let channelJson = channelValue as? [String: Any] {
                    if let channel = Channel(json: channelJson) {
                        channels.append(channel)
                    }
                }
            }
        }
        self.channels = channels
    }
}

private extension ConferenceDescription.Content.Channel.SsrcGroup {
    func outgoingColibriDescription() -> [String: Any] {
        var result: [String: Any] = [:]
        
        result["sources"] = self.sources
        result["semantics"] = self.semantics
        
        return result
    }
}

private extension ConferenceDescription.Content.Channel.PayloadType {
    func outgoingColibriDescription() -> [String: Any] {
        var result: [String: Any] = [:]
        
        result["id"] = self.id
        result["name"] = self.name
        result["channels"] = self.channels
        result["clockrate"] = self.clockrate
        result["rtcp-fbs"] = [
            [
                "type": "transport-cc"
            ] as [String: Any],
            [
                "type": "ccm fir"
            ] as [String: Any],
            [
                "type": "nack"
            ] as [String: Any],
            [
                "type": "nack pli"
            ] as [String: Any],
        ] as [Any]
        if let parameters = self.parameters {
            result["parameters"] = parameters
        }
        
        return result
    }
}

private extension ConferenceDescription.Content.Channel.RtpHdrExt {
    func outgoingColibriDescription() -> [String: Any] {
        var result: [String: Any] = [:]
        
        result["id"] = self.id
        result["uri"] = self.uri
        
        return result
    }
}

private extension ConferenceDescription.Content.Channel {
    func outgoingColibriDescription() -> [String: Any] {
        var result: [String: Any] = [:]
        
        if let id = self.id {
            result["id"] = id
        }
        result["expire"] = self.expire ?? 10
        result["initiator"] = self.initiator
        result["endpoint"] = self.endpoint
        result["direction"] = self.direction
        result["channel-bundle-id"] = self.channelBundleId
        result["rtp-level-relay-type"] = self.rtpLevelRelayType
        if !self.sources.isEmpty {
            result["sources"] = self.sources
        }
        if !self.ssrcs.isEmpty {
            result["ssrcs"] = self.ssrcs
        }
        if !self.ssrcGroups.isEmpty {
            result["ssrc-groups"] = self.ssrcGroups.map { $0.outgoingColibriDescription() }
        }
        if !self.payloadTypes.isEmpty {
            result["payload-types"] = self.payloadTypes.map { $0.outgoingColibriDescription() }
        }
        if !self.rtpHdrExts.isEmpty {
            result["rtp-hdrexts"] = self.rtpHdrExts.map { $0.outgoingColibriDescription() }
        }
        result["rtcp-mux"] = true
        
        return result
    }
}

private extension ConferenceDescription.Content {
    func outgoingColibriDescription() -> [String: Any] {
        var result: [String: Any] = [:]
        
        result["name"] = self.name
        result["channels"] = self.channels.map { $0.outgoingColibriDescription() }
        
        return result
    }
}

private extension ConferenceDescription.Transport.Fingerprint {
    func outgoingColibriDescription() -> [String: Any] {
        var result: [String: Any] = [:]
        
        result["fingerprint"] = self.fingerprint
        result["setup"] = self.setup
        result["hash"] = self.hashType
        
        return result
    }
}

private extension ConferenceDescription.Transport.Candidate {
    func outgoingColibriDescription() -> [String: Any] {
        var result: [String: Any] = [:]
        
        result["id"] = self.id
        result["generation"] = self.generation
        result["component"] = self.component
        result["protocol"] = self.protocol
        if let tcpType = self.tcpType {
            result["tcptype"] = tcpType
        }
        result["ip"] = self.ip
        result["port"] = self.port
        result["foundation"] = self.foundation
        result["priority"] = self.priority
        result["type"] = self.type
        result["network"] = self.network
        if let relAddr = self.relAddr {
            result["rel-addr"] = relAddr
        }
        if let relPort = self.relPort {
            result["rel-port"] = relPort
        }
        
        return result
    }
}

private extension ConferenceDescription.Transport {
    func outgoingColibriDescription() -> [String: Any] {
        var result: [String: Any] = [:]
        
        result["xmlns"] = "urn:xmpp:jingle:transports:ice-udp:1"
        result["rtcp-mux"] = true
        
        if !self.ufrag.isEmpty {
            result["ufrag"] = self.ufrag
            result["pwd"] = self.pwd
        }
        
        if !self.fingerprints.isEmpty {
            result["fingerprints"] = self.fingerprints.map { $0.outgoingColibriDescription() }
        }
        
        if !self.candidates.isEmpty {
            result["candidates"] = self.candidates.map { $0.outgoingColibriDescription() }
        }
        
        return result
    }
}

private extension ConferenceDescription.ChannelBundle {
    func outgoingColibriDescription() -> [String: Any] {
        var result: [String: Any] = [:]
        
        result["id"] = self.id
        result["transport"] = self.transport.outgoingColibriDescription()
        
        return result
    }
}

private struct RemoteOffer {
    struct State: Equatable {
        struct Item: Equatable {
            var isMain: Bool
            var audioSsrc: Int
            var videoSsrc: Int?
            var isRemoved: Bool
        }
        
        var items: [Item]
    }
    
    var sdpList: [String]
    var state: State
}

private extension ConferenceDescription {
    func outgoingColibriDescription() -> [String: Any] {
        var result: [String: Any] = [:]
        
        result["id"] = self.id
        result["contents"] = self.contents.map { $0.outgoingColibriDescription() }
        result["channel-bundles"] = self.channelBundles.map { $0.outgoingColibriDescription() }
        
        return result
    }
    
    func offerSdp(sessionId: UInt32, bundleId: String, bridgeHost: String, transport: ConferenceDescription.Transport, currentState: RemoteOffer.State?, isAnswer: Bool) -> RemoteOffer? {
        struct StreamSpec {
            var isMain: Bool
            var audioSsrc: Int
            var videoSsrc: Int?
            var isRemoved: Bool
        }
        
        func createSdp(sessionId: UInt32, bundleStreams: [StreamSpec]) -> String {
            var sdp = ""
            func appendSdp(_ string: String) {
                if !sdp.isEmpty {
                    sdp.append("\n")
                }
                sdp.append(string)
            }
            
            appendSdp("v=0")
            appendSdp("o=- \(sessionId) 2 IN IP4 0.0.0.0")
            appendSdp("s=-")
            appendSdp("t=0 0")
            
            var bundleString = "a=group:BUNDLE"
            for stream in bundleStreams {
                bundleString.append(" ")
                if let videoSsrc = stream.videoSsrc {
                    let audioMid: String
                    let videoMid: String
                    if stream.isMain {
                        audioMid = "0"
                        videoMid = "1"
                    } else {
                        audioMid = "audio\(stream.audioSsrc)"
                        videoMid = "video\(videoSsrc)"
                    }
                    bundleString.append("\(audioMid) \(videoMid)")
                } else {
                    let audioMid: String
                    if stream.isMain {
                        audioMid = "0"
                    } else {
                        audioMid = "audio\(stream.audioSsrc)"
                    }
                    bundleString.append("\(audioMid)")
                }
            }
            appendSdp(bundleString)
            
            appendSdp("a=ice-lite")
            
            for stream in bundleStreams {
                let audioMid: String
                let videoMid: String?
                if stream.isMain {
                    audioMid = "0"
                    if let _ = stream.videoSsrc {
                        videoMid = "1"
                    } else {
                        videoMid = nil
                    }
                } else {
                    audioMid = "audio\(stream.audioSsrc)"
                    if let videoSsrc = stream.videoSsrc {
                        videoMid = "video\(videoSsrc)"
                    } else {
                        videoMid = nil
                    }
                }
                
                appendSdp("m=audio \(stream.isMain ? "1" : "0") RTP/SAVPF 111 126")
                if stream.isMain {
                    appendSdp("c=IN IP4 0.0.0.0")
                }
                appendSdp("a=mid:\(audioMid)")
                if stream.isRemoved {
                    appendSdp("a=inactive")
                } else {
                    if stream.isMain {
                        appendSdp("a=ice-ufrag:\(transport.ufrag)")
                        appendSdp("a=ice-pwd:\(transport.pwd)")
                        
                        for fingerprint in transport.fingerprints {
                            appendSdp("a=fingerprint:\(fingerprint.hashType) \(fingerprint.fingerprint)")
                            //appendSdp("a=setup:\(fingerprint.setup)")
                            //appendSdp("a=setup:active")
                            appendSdp("a=setup:passive")
                        }
                        
                        for candidate in transport.candidates {
                            var candidateString = "a=candidate:"
                            candidateString.append("\(candidate.foundation) ")
                            candidateString.append("\(candidate.component) ")
                            var protocolValue = candidate.protocol
                            if protocolValue == "ssltcp" {
                                protocolValue = "tcp"
                            }
                            candidateString.append("\(protocolValue) ")
                            candidateString.append("\(candidate.priority) ")
                            
                            var ip = candidate.ip
                            if ip.hasPrefix("192.") {
                                ip = bridgeHost
                            } else {
                                continue
                            }
                            candidateString.append("\(ip) ")
                            candidateString.append("\(candidate.port) ")
                            
                            candidateString.append("typ \(candidate.type) ")
                            
                            switch candidate.type {
                            case "srflx", "prflx", "relay":
                                if let relAddr = candidate.relAddr, let relPort = candidate.relPort {
                                    candidateString.append("raddr \(relAddr) rport \(relPort) ")
                                }
                                break
                            default:
                                break
                            }
                            
                            if protocolValue == "tcp" {
                                guard let tcpType = candidate.tcpType else {
                                    continue
                                }
                                candidateString.append("tcptype \(tcpType) ")
                            }
                            
                            candidateString.append("generation \(candidate.generation)")
                            
                            appendSdp(candidateString)
                        }
                    }
                    
                    appendSdp("a=rtpmap:111 opus/48000/2")
                    appendSdp("a=rtpmap:126 telephone-event/8000")
                    appendSdp("a=fmtp:111 minptime=10; useinbandfec=1; usedtx=1")
                    appendSdp("a=rtcp:1 IN IP4 0.0.0.0")
                    appendSdp("a=rtcp-mux")
                    appendSdp("a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level")
                    appendSdp("a=extmap:3 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time")
                    appendSdp("a=extmap:5 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01")
                    appendSdp("a=rtcp-fb:111 transport-cc")
                    
                    if isAnswer {
                        appendSdp("a=recvonly")
                    } else {
                        if stream.isMain {
                            appendSdp("a=sendrecv")
                        } else {
                            appendSdp("a=sendonly")
                            appendSdp("a=bundle-only")
                        }
                        
                        appendSdp("a=ssrc-group:FID \(stream.audioSsrc)")
                        appendSdp("a=ssrc:\(stream.audioSsrc) cname:stream\(stream.audioSsrc)")
                        appendSdp("a=ssrc:\(stream.audioSsrc) msid:stream\(stream.audioSsrc) audio\(stream.audioSsrc)")
                        appendSdp("a=ssrc:\(stream.audioSsrc) mslabel:audio\(stream.audioSsrc)")
                        appendSdp("a=ssrc:\(stream.audioSsrc) label:audio\(stream.audioSsrc)")
                    }
                }
                
                if let videoMid = videoMid {
                    appendSdp("m=video 0 RTP/SAVPF 100")
                    appendSdp("a=mid:\(videoMid)")
                    if stream.isRemoved {
                        appendSdp("a=inactive")
                        continue
                    } else {
                        appendSdp("a=rtpmap:100 VP8/90000")
                        appendSdp("a=fmtp:100 x-google-start-bitrate=800")
                        appendSdp("a=rtcp:1 IN IP4 0.0.0.0")
                        appendSdp("a=rtcp-mux")
                        
                        appendSdp("a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time")
                        appendSdp("a=extmap:4 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01")
                        
                        appendSdp("a=rtcp-fb:100 transport-cc")
                        appendSdp("a=rtcp-fb:100 ccm fir")
                        appendSdp("a=rtcp-fb:100 nack")
                        appendSdp("a=rtcp-fb:100 nack pli")
                        
                        if stream.isMain {
                            appendSdp("a=sendrecv")
                        } else {
                            appendSdp("a=sendonly")
                        }
                        appendSdp("a=bundle-only")
                        
                        appendSdp("a=ssrc-group:FID \(stream.videoSsrc)")
                        appendSdp("a=ssrc:\(stream.videoSsrc) cname:stream\(stream.audioSsrc)")
                        appendSdp("a=ssrc:\(stream.videoSsrc) msid:stream\(stream.audioSsrc) video\(stream.videoSsrc)")
                        appendSdp("a=ssrc:\(stream.videoSsrc) mslabel:video\(stream.videoSsrc)")
                        appendSdp("a=ssrc:\(stream.videoSsrc) label:video\(stream.videoSsrc)")
                    }
                }
            }
            
            appendSdp("")
            
            return sdp
        }
        
        var streams: [StreamSpec] = []
        var maybeMainStreamAudioSsrc: Int?
        
        for audioContent in self.contents {
            if audioContent.name != "audio" {
                continue
            }
            for audioChannel in audioContent.channels {
                if audioChannel.channelBundleId == bundleId {
                    precondition(audioChannel.sources.count == 1)
                    streams.append(StreamSpec(
                        isMain: true,
                        audioSsrc: audioChannel.sources[0],
                        videoSsrc: nil,
                        isRemoved: false
                    ))
                    maybeMainStreamAudioSsrc = audioChannel.sources[0]
                    if false && isAnswer {
                        precondition(audioChannel.ssrcs.count <= 1)
                        if audioChannel.ssrcs.count == 1 {
                            streams.append(StreamSpec(
                                isMain: false,
                                audioSsrc: audioChannel.ssrcs[0],
                                videoSsrc: nil,
                                isRemoved: false
                            ))
                        }
                    }
                } else {
                    precondition(audioChannel.ssrcs.count <= 1)
                    if audioChannel.ssrcs.count == 1 {
                        streams.append(StreamSpec(
                            isMain: false,
                            audioSsrc: audioChannel.ssrcs[0],
                            videoSsrc: nil,
                            isRemoved: false
                        ))
                    }
                }
                
                /*for videoContent in self.contents {
                    if videoContent.name != "video" {
                        continue
                    }
                    for videoChannel in videoContent.channels {
                        if videoChannel.channelBundleId == audioChannel.channelBundleId {
                            if audioChannel.channelBundleId == bundleId {
                                precondition(audioChannel.sources.count == 1)
                                precondition(videoChannel.sources.count == 1)
                                streams.append(StreamSpec(
                                    isMain: true,
                                    audioSsrc: audioChannel.sources[0],
                                    videoSsrc: videoChannel.sources[0],
                                    isRemoved: false
                                ))
                                maybeMainStreamAudioSsrc = audioChannel.sources[0]
                            } else {
                                precondition(audioChannel.ssrcs.count <= 1)
                                precondition(videoChannel.ssrcs.count <= 2)
                                if audioChannel.ssrcs.count == 1 && videoChannel.ssrcs.count <= 2 {
                                    streams.append(StreamSpec(
                                        isMain: false,
                                        audioSsrc: audioChannel.ssrcs[0],
                                        videoSsrc: videoChannel.ssrcs[0],
                                        isRemoved: false
                                    ))
                                }
                            }
                        }
                    }
                }*/
            }
        }
        
        guard let mainStreamAudioSsrc = maybeMainStreamAudioSsrc else {
            preconditionFailure()
        }
        
        var bundleStreams: [StreamSpec] = []
        if let currentState = currentState {
            for item in currentState.items {
                let isRemoved = !streams.contains(where: { $0.audioSsrc == item.audioSsrc })
                bundleStreams.append(StreamSpec(
                    isMain: item.audioSsrc == mainStreamAudioSsrc,
                    audioSsrc: item.audioSsrc,
                    videoSsrc: item.videoSsrc,
                    isRemoved: isRemoved
                ))
            }
        }
        
        for stream in streams {
            if bundleStreams.contains(where: { $0.audioSsrc == stream.audioSsrc }) {
                continue
            }
            bundleStreams.append(stream)
        }
        
        var sdpList: [String] = []
        
        sdpList.append(createSdp(sessionId: sessionId, bundleStreams: bundleStreams))
        
        return RemoteOffer(
            sdpList: sdpList,
            state: RemoteOffer.State(
                items: bundleStreams.map { stream in
                    RemoteOffer.State.Item(
                        isMain: stream.isMain,
                        audioSsrc: stream.audioSsrc,
                        videoSsrc: stream.videoSsrc,
                        isRemoved: stream.isRemoved
                    )
                }
            )
        )
    }
    
    mutating func updateLocalChannelFromSdpAnswer(bundleId: String, sdpAnswer: String) {
        var maybeAudioChannel: ConferenceDescription.Content.Channel?
        var videoChannel: ConferenceDescription.Content.Channel?
        for content in self.contents {
            for channel in content.channels {
                if channel.endpoint == bundleId {
                    if content.name == "audio" {
                        maybeAudioChannel = channel
                    } else if content.name == "video" {
                        videoChannel = channel
                    }
                    break
                }
            }
        }
        
        guard var audioChannel = maybeAudioChannel else {
            assert(false)
            return
        }
        
        let lines = sdpAnswer.components(separatedBy: "\n")
        
        var videoLines: [String] = []
        var audioLines: [String] = []
        var isAudioLine = false
        var isVideoLine = false
        for line in lines {
            if line.hasPrefix("m=audio") {
                isAudioLine = true
                isVideoLine = false
            } else if line.hasPrefix("m=video") {
                isVideoLine = true
                isAudioLine = false
            }
            
            if isAudioLine {
                audioLines.append(line)
            } else if isVideoLine {
                videoLines.append(line)
            }
        }
        
        func getLines(prefix: String) -> [String] {
            var result: [String] = []
            for line in lines {
                if line.hasPrefix(prefix) {
                    var cleanLine = String(line[line.index(line.startIndex, offsetBy: prefix.count)...])
                    if cleanLine.hasSuffix("\r") {
                        cleanLine.removeLast()
                    }
                    result.append(cleanLine)
                }
            }
            return result
        }
        
        func getLines(prefix: String, isAudio: Bool) -> [String] {
            var result: [String] = []
            for line in (isAudio ? audioLines : videoLines) {
                if line.hasPrefix(prefix) {
                    var cleanLine = String(line[line.index(line.startIndex, offsetBy: prefix.count)...])
                    if cleanLine.hasSuffix("\r") {
                        cleanLine.removeLast()
                    }
                    result.append(cleanLine)
                }
            }
            return result
        }
        
        var audioSources: [Int] = []
        var videoSources: [Int] = []
        for line in getLines(prefix: "a=ssrc:", isAudio: true) {
            let scanner = Scanner(string: line)
            if #available(iOS 13.0, *) {
                if let ssrc = scanner.scanInt() {
                    if !audioSources.contains(ssrc) {
                        audioSources.append(ssrc)
                    }
                }
            }
        }
        for line in getLines(prefix: "a=ssrc:", isAudio: false) {
            let scanner = Scanner(string: line)
            if #available(iOS 13.0, *) {
                if let ssrc = scanner.scanInt() {
                    if !videoSources.contains(ssrc) {
                        videoSources.append(ssrc)
                    }
                }
            }
        }
        
        audioChannel.sources = audioSources
        
        audioChannel.payloadTypes = [
            ConferenceDescription.Content.Channel.PayloadType(
                id: 111,
                name: "opus",
                clockrate: 48000,
                channels: 2,
                parameters: [
                    "fmtp": [
                        "minptime=10;useinbandfec=1"
                    ] as [Any],
                    "rtcp-fbs": [
                        [
                            "type": "transport-cc"
                        ] as [String: Any],
                    ] as [Any]
                ]
            ),
            ConferenceDescription.Content.Channel.PayloadType(
                id: 126,
                name: "telephone-event",
                clockrate: 8000,
                channels: 1
            )
        ]
        
        audioChannel.rtpHdrExts = [
            ConferenceDescription.Content.Channel.RtpHdrExt(
                id: 1,
                uri: "urn:ietf:params:rtp-hdrext:ssrc-audio-level"
            ),
            ConferenceDescription.Content.Channel.RtpHdrExt(
                id: 3,
                uri: "http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time"
            ),
            ConferenceDescription.Content.Channel.RtpHdrExt(
                id: 5,
                uri: "http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01"
            ),
        ]
        
        videoChannel?.sources = videoSources
        /*audioChannel.ssrcGroups = [ConferenceDescription.Content.Channel.SsrcGroup(
            sources: audioSources,
            semantics: "SIM"
        )]*/
            
        videoChannel?.payloadTypes = [
            ConferenceDescription.Content.Channel.PayloadType(
                id: 100,
                name: "VP8",
                clockrate: 9000,
                channels: 1,
                parameters: [
                    "fmtp": [
                        "x-google-start-bitrate=800"
                    ] as [Any],
                    "rtcp-fbs": [
                        [
                            "type": "transport-cc"
                        ] as [String: Any],
                        [
                            "type": "ccm fir"
                        ] as [String: Any],
                        [
                            "type": "nack"
                        ] as [String: Any],
                        [
                            "type": "nack pli"
                        ] as [String: Any],
                    ] as [Any]
                ]
            )
        ]
        
        audioChannel.rtpHdrExts = [
            ConferenceDescription.Content.Channel.RtpHdrExt(
                id: 2,
                uri: "http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time"
            ),
            ConferenceDescription.Content.Channel.RtpHdrExt(
                id: 4,
                uri: "http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01"
            ),
        ]
        
        guard let ufrag = getLines(prefix: "a=ice-ufrag:").first else {
            assert(false)
            return
        }
        guard let pwd = getLines(prefix: "a=ice-pwd:").first else {
            assert(false)
            return
        }
        
        var fingerprints: [ConferenceDescription.Transport.Fingerprint] = []
        for line in getLines(prefix: "a=fingerprint:") {
            let components = line.components(separatedBy: " ")
            if components.count != 2 {
                continue
            }
            fingerprints.append(ConferenceDescription.Transport.Fingerprint(
                fingerprint: components[1],
                setup: "active",
                hashType: components[0]
            ))
        }
        
        for i in 0 ..< self.contents.count {
            for j in 0 ..< self.contents[i].channels.count {
                if self.contents[i].channels[j].endpoint == bundleId {
                    if self.contents[i].name == "audio" {
                        self.contents[i].channels[j] = audioChannel
                    } else if self.contents[i].name == "video", let videoChannel = videoChannel {
                        self.contents[i].channels[j] = videoChannel
                    }
                }
            }
        }
        
        var candidates: [ConferenceDescription.Transport.Candidate] = []
        /*for line in getLines(prefix: "a=candidate:") {
            let scanner = Scanner(string: line)
            if #available(iOS 13.0, *) {
                candidates.append(ConferenceDescription.Transport.Candidate(
                    id: "",
                    generation: 0,
                    component: "",
                    protocol: "",
                    tcpType: nil,
                    ip: "",
                    port: 0,
                    foundation: "",
                    priority: 0,
                    type: "",
                    network: 0,
                    relAddr: nil,
                    relPort: nil
                ))
            }
        }*/
        
        let transport = ConferenceDescription.Transport(
            candidates: candidates,
            fingerprints: fingerprints,
            ufrag: ufrag,
            pwd: pwd
        )
        
        var found = false
        for i in 0 ..< self.channelBundles.count {
            if self.channelBundles[i].id == bundleId {
                self.channelBundles[i].transport = transport
                found = true
                break
            }
        }
        if !found {
            self.channelBundles.append(ConferenceDescription.ChannelBundle(
                id: bundleId,
                transport: transport
            ))
        }
    }
}

private enum HttpError {
    case generic
    case network
    case server(String)
}

private enum HttpMethod {
    case get
    case post([String: Any])
    case patch([String: Any])
}

private func httpJsonRequest<T>(url: String, method: HttpMethod, resultType: T.Type) -> Signal<T, HttpError> {
    return Signal { subscriber in
        guard let url = URL(string: url) else {
            subscriber.putError(.generic)
            return EmptyDisposable
        }
        let completed = Atomic<Bool>(value: false)
        
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 1000.0)
        
        switch method {
        case .get:
            break
        case let .post(data):
            guard let body = try? JSONSerialization.data(withJSONObject: data, options: []) else {
                subscriber.putError(.generic)
                return EmptyDisposable
            }
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
            request.httpMethod = "POST"
        case let .patch(data):
            guard let body = try? JSONSerialization.data(withJSONObject: data, options: []) else {
                subscriber.putError(.generic)
                return EmptyDisposable
            }
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
            request.httpMethod = "PATCH"
            
            //print("PATCH: \(String(data: body, encoding: .utf8)!)")
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, _, error in
            if let error = error {
                print("\(error)")
                subscriber.putError(.server("\(error)"))
                return
            }
            
            let _ = completed.swap(true)
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? T {
                subscriber.putNext(json)
                subscriber.putCompletion()
            } else {
                subscriber.putError(.network)
            }
        })
        task.resume()
        
        return ActionDisposable {
            if !completed.with({ $0 }) {
                task.cancel()
            }
        }
    }
}

public final class GroupCallContext {
    private final class Impl {
        private let queue: Queue
        private let context: GroupCallThreadLocalContext
        private let disposable = MetaDisposable()
        
        private let colibriHost: String
        private let sessionId: UInt32
        
        private var audioSessionDisposable: Disposable?
        private let pollDisposable = MetaDisposable()
        
        private var conferenceId: String?
        private var localBundleId: String?
        private var localTransport: ConferenceDescription.Transport?
        
        let memberCount = ValuePromise<Int>(0, ignoreRepeated: true)
        let videoStreamList = ValuePromise<[String]>([], ignoreRepeated: true)
        
        private var isMutedValue: Bool = false
        let isMuted = ValuePromise<Bool>(false, ignoreRepeated: true)
        
        init(queue: Queue, audioSessionActive: Signal<Bool, NoError>, video: OngoingCallVideoCapturer?) {
            self.queue = queue
            
            self.sessionId = UInt32.random(in: 0 ..< UInt32(Int32.max))
            self.colibriHost = "192.168.93.24"
            
            var relaySdpAnswerImpl: ((String) -> Void)?
            
            let videoStreamList = self.videoStreamList
            
            self.context = GroupCallThreadLocalContext(queue: ContextQueueImpl(queue: queue), relaySdpAnswer: { sdpAnswer in
                queue.async {
                    relaySdpAnswerImpl?(sdpAnswer)
                }
            }, incomingVideoStreamListUpdated: { streamList in
                queue.async {
                    videoStreamList.set(streamList)
                }
            }, videoCapturer: video?.impl)
            
            relaySdpAnswerImpl = { [weak self] sdpAnswer in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.relaySdpAnswer(sdpAnswer: sdpAnswer)
            }
            
            self.audioSessionDisposable = (audioSessionActive
            |> filter { $0 }
            |> take(1)
            |> deliverOn(queue)).start(next: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.requestConference()
            })
        }
        
        deinit {
            self.disposable.dispose()
            self.audioSessionDisposable?.dispose()
            self.pollDisposable.dispose()
        }
        
        func requestConference() {
            self.disposable.set((httpJsonRequest(url: "http://\(self.colibriHost):8080/colibri/conferences/", method: .get, resultType: [Any].self)
            |> deliverOn(self.queue)).start(next: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                if let conferenceJson = result.first as? [String: Any] {
                    if let conferenceId = ConferenceDescription(json: conferenceJson)?.id {
                        strongSelf.disposable.set((httpJsonRequest(url: "http://\(strongSelf.colibriHost):8080/colibri/conferences/\(conferenceId)", method: .get, resultType: [String: Any].self)
                        |> deliverOn(strongSelf.queue)).start(next: { result in
                            guard let strongSelf = self else {
                                return
                            }
                            if let conference = ConferenceDescription(json: result) {
                                strongSelf.allocateChannels(conference: conference)
                            }
                        }))
                    }
                } else {
                    strongSelf.disposable.set((httpJsonRequest(url: "http://\(strongSelf.colibriHost):8080/colibri/conferences/", method: .post([:]), resultType: [String: Any].self)
                    |> deliverOn(strongSelf.queue)).start(next: { result in
                        guard let strongSelf = self else {
                            return
                        }
                        if let conference = ConferenceDescription(json: result) {
                            strongSelf.allocateChannels(conference: conference)
                        }
                    }))
                }
            }))
        }
        
        private var currentOfferState: RemoteOffer.State?
        
        func allocateChannels(conference: ConferenceDescription) {
            let bundleId = UUID().uuidString
            
            var conference = conference
            let audioChannel = ConferenceDescription.Content.Channel(
                id: nil,
                endpoint: bundleId,
                channelBundleId: bundleId,
                sources: [],
                ssrcs: [],
                rtpLevelRelayType: "translator",
                expire: 10,
                initiator: true,
                direction: "sendrecv",
                ssrcGroups: [],
                payloadTypes: [],
                rtpHdrExts: []
            )
            let videoChannel: ConferenceDescription.Content.Channel? = nil /*ConferenceDescription.Content.Channel(
                id: nil,
                endpoint: bundleId,
                channelBundleId: bundleId,
                sources: [],
                ssrcs: [],
                rtpLevelRelayType: "translator",
                expire: 10,
                initiator: true,
                direction: "sendrecv",
                ssrcGroups: [],
                payloadTypes: [],
                rtpHdrExts: []
            )*/
            
            var foundAudioContent = false
            var foundVideoContent = false
            for i in 0 ..< conference.contents.count {
                if conference.contents[i].name == "audio" {
                    for j in 0 ..< conference.contents[i].channels.count {
                        let channel = conference.contents[i].channels[j]
                        conference.contents[i].channels[j] = ConferenceDescription.Content.Channel(
                            id: channel.id,
                            endpoint: channel.endpoint,
                            channelBundleId: channel.channelBundleId,
                            sources: channel.sources,
                            ssrcs: channel.ssrcs,
                            rtpLevelRelayType: channel.rtpLevelRelayType,
                            expire: channel.expire,
                            initiator: channel.initiator,
                            direction: channel.direction,
                            ssrcGroups: [],
                            payloadTypes: [],
                            rtpHdrExts: []
                        )
                    }
                    conference.contents[i].channels.append(audioChannel)
                    foundAudioContent = true
                    break
                } else if conference.contents[i].name == "video", let videoChannel = videoChannel {
                    for j in 0 ..< conference.contents[i].channels.count {
                        let channel = conference.contents[i].channels[j]
                        conference.contents[i].channels[j] = ConferenceDescription.Content.Channel(
                            id: channel.id,
                            endpoint: channel.endpoint,
                            channelBundleId: channel.channelBundleId,
                            sources: channel.sources,
                            ssrcs: channel.ssrcs,
                            rtpLevelRelayType: channel.rtpLevelRelayType,
                            expire: channel.expire,
                            initiator: channel.initiator,
                            direction: channel.direction,
                            ssrcGroups: [],
                            payloadTypes: [],
                            rtpHdrExts: []
                        )
                    }
                    conference.contents[i].channels.append(videoChannel)
                    foundVideoContent = true
                    break
                }
            }
            if !foundAudioContent {
                conference.contents.append(ConferenceDescription.Content(
                    name: "audio",
                    channels: [audioChannel]
                ))
            }
            if !foundVideoContent, let videoChannel = videoChannel {
                conference.contents.append(ConferenceDescription.Content(
                    name: "video",
                    channels: [videoChannel]
                ))
            }
            conference.channelBundles.append(ConferenceDescription.ChannelBundle(
                id: bundleId,
                transport: ConferenceDescription.Transport(
                    candidates: [],
                    fingerprints: [],
                    ufrag: "",
                    pwd: ""
                )
            ))
            
            var payload = conference.outgoingColibriDescription()
            if var contents = payload["contents"] as? [[String: Any]] {
                for contentIndex in 0 ..< contents.count {
                    if var channels = contents[contentIndex]["channels"] as? [Any] {
                        for i in (0 ..< channels.count).reversed() {
                            if var channel = channels[i] as? [String: Any] {
                                if channel["endpoint"] as? String != bundleId {
                                    channel = ["id": channel["id"]!]
                                    channels[i] = channel
                                    channels.remove(at: i)
                                }
                            }
                        }
                        contents[contentIndex]["channels"] = channels
                    }
                }
                payload["contents"] = contents
            }
            
            self.disposable.set((httpJsonRequest(url: "http://\(self.colibriHost):8080/colibri/conferences/\(conference.id)", method: .patch(payload), resultType: [String: Any].self)
            |> deliverOn(self.queue)).start(next: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                guard let conference = ConferenceDescription(json: result) else {
                    return
                }
                
                var maybeTransport: ConferenceDescription.Transport?
                for channelBundle in conference.channelBundles {
                    if channelBundle.id == bundleId {
                        maybeTransport = channelBundle.transport
                        break
                    }
                }
                
                guard let transport = maybeTransport else {
                    assert(false)
                    return
                }
                
                strongSelf.conferenceId = conference.id
                strongSelf.localBundleId = bundleId
                strongSelf.localTransport = transport
                
                let queue = strongSelf.queue
                strongSelf.context.emitOffer(adjustSdp: { sdp in
                    return sdp
                }, completion: { offerSdp in
                    queue.async {
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.relaySdpAnswer(sdpAnswer: offerSdp)
                    }
                })
            }))
        }
        
        private func relaySdpAnswer(sdpAnswer: String) {
            guard let conferenceId = self.conferenceId, let localBundleId = self.localBundleId else {
                return
            }
            
            print("===== relaySdpAnswer =====")
            print(sdpAnswer)
            print("===== -------------- =====")
            
            self.disposable.set((httpJsonRequest(url: "http://\(self.colibriHost):8080/colibri/conferences/\(conferenceId)", method: .get, resultType: [String: Any].self)
            |> deliverOn(self.queue)).start(next: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                guard var conference = ConferenceDescription(json: result) else {
                    return
                }
                
                conference.updateLocalChannelFromSdpAnswer(bundleId: localBundleId, sdpAnswer: sdpAnswer)
                
                var payload = conference.outgoingColibriDescription()
                if var contents = payload["contents"] as? [[String: Any]] {
                    for contentIndex in 0 ..< contents.count {
                        if var channels = contents[contentIndex]["channels"] as? [Any] {
                            for i in (0 ..< channels.count).reversed() {
                                if var channel = channels[i] as? [String: Any] {
                                    if channel["endpoint"] as? String != localBundleId {
                                        channel = ["id": channel["id"]!]
                                        channels[i] = channel
                                        channels.remove(at: i)
                                    }
                                }
                            }
                            contents[contentIndex]["channels"] = channels
                        }
                    }
                    payload["contents"] = contents
                }
                
                strongSelf.disposable.set((httpJsonRequest(url: "http://\(strongSelf.colibriHost):8080/colibri/conferences/\(conference.id)", method: .patch(payload), resultType: [String: Any].self)
                |> deliverOn(strongSelf.queue)).start(next: { result in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    guard let conference = ConferenceDescription(json: result) else {
                        return
                    }
                    
                    guard let localTransport = strongSelf.localTransport else {
                        return
                    }
                    
                    if conference.id == strongSelf.conferenceId {
                        if let offer = conference.offerSdp(sessionId: strongSelf.sessionId, bundleId: localBundleId, bridgeHost: strongSelf.colibriHost, transport: localTransport, currentState: strongSelf.currentOfferState, isAnswer: true) {
                            //strongSelf.currentOfferState = offer.state
                            
                            strongSelf.memberCount.set(offer.state.items.filter({ !$0.isRemoved }).count)
                            
                            for sdp in offer.sdpList {
                                strongSelf.context.setOfferSdp(sdp, isPartial: true)
                            }
                        }
                        
                        strongSelf.queue.after(2.0, {
                            self?.pollOnceDelayed()
                        })
                    }
                }))
            }))
        }
        
        private func pollOnceDelayed() {
            guard let conferenceId = self.conferenceId, let localBundleId = self.localBundleId, let localTransport = self.localTransport else {
                return
            }
            self.pollDisposable.set((httpJsonRequest(url: "http://\(self.colibriHost):8080/colibri/conferences/\(conferenceId)", method: .get, resultType: [String: Any].self)
            |> delay(1.0, queue: self.queue)
            |> deliverOn(self.queue)).start(next: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                guard let conference = ConferenceDescription(json: result) else {
                    return
                }
                
                guard conference.id == strongSelf.conferenceId else {
                    return
                }
                
                if let offer = conference.offerSdp(sessionId: strongSelf.sessionId, bundleId: localBundleId, bridgeHost: strongSelf.colibriHost, transport: localTransport, currentState: strongSelf.currentOfferState, isAnswer: false) {
                    strongSelf.currentOfferState = offer.state
                    strongSelf.memberCount.set(offer.state.items.filter({ !$0.isRemoved }).count)
                    
                    for sdp in offer.sdpList {
                        strongSelf.context.setOfferSdp(sdp, isPartial: false)
                    }
                    
                    strongSelf.pollOnceDelayed()
                    
                    /*strongSelf.context.emitOffer(adjustSdp: { sdp in
                        var resultLines: [String] = []
                        
                        func appendSdp(_ line: String) {
                            resultLines.append(line)
                        }
                        
                        var sharedPort = "0"
                        
                        let lines = sdp.components(separatedBy: "\n")
                        for line in lines {
                            var cleanLine = line
                            if cleanLine.hasSuffix("\r") {
                                cleanLine.removeLast()
                            }
                            if cleanLine.isEmpty {
                                continue
                            }
                            
                            if cleanLine.hasPrefix("a=group:BUNDLE 0 1") {
                                cleanLine = "a=group:BUNDLE 0 1"
                                
                                for item in offer.state.items {
                                    if item.isMain {
                                        continue
                                    }
                                    cleanLine.append(" audio\(item.audioSsrc) video\(item.videoSsrc)")
                                }
                            } else if cleanLine.hasPrefix("m=audio ") {
                                let scanner = Scanner(string: cleanLine)
                                if #available(iOS 13.0, *) {
                                    if let _ = scanner.scanString("m=audio "), let value = scanner.scanInt() {
                                        sharedPort = "\(value)"
                                    }
                                }
                            }
                            
                            appendSdp(cleanLine)
                        }
                        
                        for item in offer.state.items {
                            if item.isMain {
                                continue
                            }
                            
                            let audioSsrc = item.audioSsrc
                            let videoSsrc = item.videoSsrc
                            
                            appendSdp("m=audio \(sharedPort) RTP/SAVPF 111 126")
                            appendSdp("a=mid:audio\(audioSsrc)")
                            
                            appendSdp("a=rtpmap:111 opus/48000/2")
                            appendSdp("a=rtpmap:126 telephone-event/8000")
                            appendSdp("a=fmtp:111 minptime=10; useinbandfec=1; usedtx=1")
                            appendSdp("a=rtcp:1 IN IP4 0.0.0.0")
                            appendSdp("a=rtcp-mux")
                            appendSdp("a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level")
                            appendSdp("a=extmap:3 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time")
                            appendSdp("a=extmap:5 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01")
                            appendSdp("a=rtcp-fb:111 transport-cc")
                            
                            appendSdp("a=recvonly")
                            appendSdp("a=bundle-only")
                            
                            appendSdp("a=ssrc-group:FID \(audioSsrc)")
                            appendSdp("a=ssrc:\(audioSsrc) cname:stream\(audioSsrc)")
                            appendSdp("a=ssrc:\(audioSsrc) msid:stream\(audioSsrc) audio\(audioSsrc)")
                            appendSdp("a=ssrc:\(audioSsrc) mslabel:audio\(audioSsrc)")
                            appendSdp("a=ssrc:\(audioSsrc) label:audio\(audioSsrc)")
                            
                            appendSdp("m=video \(sharedPort) RTP/SAVPF 100")
                            appendSdp("a=mid:video\(videoSsrc)")
                            
                            appendSdp("a=rtpmap:100 VP8/90000")
                            appendSdp("a=fmtp:100 x-google-start-bitrate=800")
                            appendSdp("a=rtcp:1 IN IP4 0.0.0.0")
                            appendSdp("a=rtcp-mux")
                            
                            appendSdp("a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time")
                            appendSdp("a=extmap:4 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01")
                            
                            appendSdp("a=rtcp-fb:100 transport-cc")
                            appendSdp("a=rtcp-fb:100 ccm fir")
                            appendSdp("a=rtcp-fb:100 nack")
                            appendSdp("a=rtcp-fb:100 nack pli")
                            
                            appendSdp("a=recvonly")
                            appendSdp("a=bundle-only")
                            
                            appendSdp("a=ssrc-group:FID \(videoSsrc)")
                            appendSdp("a=ssrc:\(videoSsrc) cname:stream\(audioSsrc)")
                            appendSdp("a=ssrc:\(videoSsrc) msid:stream\(audioSsrc) video\(videoSsrc)")
                            appendSdp("a=ssrc:\(videoSsrc) mslabel:video\(videoSsrc)")
                            appendSdp("a=ssrc:\(videoSsrc) label:video\(videoSsrc)")
                        }
                        
                        let resultSdp = resultLines.joined(separator: "\n")
                        print("------ modified local sdp ------")
                        print(resultSdp)
                        print("------")
                        return resultSdp
                    }, completion: { _ in
                        queue.async {
                            guard let strongSelf = self else {
                                return
                            }
                                
                            strongSelf.memberCount.set(offer.state.items.filter({ !$0.isRemoved }).count)
                            
                            for sdp in offer.sdpList {
                                print("===== setOffer polled =====")
                                print(sdp)
                                print("===== -------------- =====")
                                strongSelf.context.setOfferSdp(sdp, isPartial: false)
                            }
                            
                            strongSelf.pollOnceDelayed()
                        }
                    })*/
                }
            }))
        }
        
        func toggleIsMuted() {
            self.isMutedValue = !self.isMutedValue
            self.isMuted.set(self.isMutedValue)
            self.context.setIsMuted(self.isMutedValue)
        }
        
        func setIsMuted(_ isMuted: Bool) {
            if self.isMutedValue != isMuted {
                self.isMutedValue = isMuted
                self.isMuted.set(self.isMutedValue)
                self.context.setIsMuted(self.isMutedValue)
            }
        }
        
        func makeIncomingVideoView(id: String, completion: @escaping (OngoingCallContextPresentationCallVideoView?) -> Void) {
            self.context.makeIncomingVideoView(withStreamId: id, completion: { view in
                if let view = view {
                    completion(OngoingCallContextPresentationCallVideoView(
                        view: view,
                        setOnFirstFrameReceived: { [weak view] f in
                            view?.setOnFirstFrameReceived(f)
                        },
                        getOrientation: { [weak view] in
                            if let view = view {
                                return OngoingCallVideoOrientation(view.orientation)
                            } else {
                                return .rotation0
                            }
                        },
                        getAspect: { [weak view] in
                            if let view = view {
                                return view.aspect
                            } else {
                                return 0.0
                            }
                        },
                        setOnOrientationUpdated: { [weak view] f in
                            view?.setOnOrientationUpdated { value, aspect in
                                f?(OngoingCallVideoOrientation(value), aspect)
                            }
                        },
                        setOnIsMirroredUpdated: { [weak view] f in
                            view?.setOnIsMirroredUpdated { value in
                                f?(value)
                            }
                        }
                    ))
                } else {
                    completion(nil)
                }
            })
        }
    }
    
    private let queue = Queue()
    private let impl: QueueLocalObject<Impl>
    
    public init(audioSessionActive: Signal<Bool, NoError>, video: OngoingCallVideoCapturer?) {
        let queue = self.queue
        self.impl = QueueLocalObject(queue: queue, generate: {
            return Impl(queue: queue, audioSessionActive: audioSessionActive, video: video)
        })
    }
    
    public var memberCount: Signal<Int, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.impl.with { impl in
                disposable.set(impl.memberCount.get().start(next: { value in
                    subscriber.putNext(value)
                }))
            }
            return disposable
        }
    }
    
    public var videoStreamList: Signal<[String], NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.impl.with { impl in
                disposable.set(impl.videoStreamList.get().start(next: { value in
                    subscriber.putNext(value)
                }))
            }
            return disposable
        }
    }
    
    public var isMuted: Signal<Bool, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.impl.with { impl in
                disposable.set(impl.isMuted.get().start(next: { value in
                    subscriber.putNext(value)
                }))
            }
            return disposable
        }
    }
    
    public func toggleIsMuted() {
        self.impl.with { impl in
            impl.toggleIsMuted()
        }
    }
    
    public func setIsMuted(_ isMuted: Bool) {
        self.impl.with { impl in
            impl.setIsMuted(isMuted)
        }
    }
    
    public func makeIncomingVideoView(id: String, completion: @escaping (OngoingCallContextPresentationCallVideoView?) -> Void) {
        self.impl.with { impl in
            impl.makeIncomingVideoView(id: id, completion: completion)
        }
    }
}

private struct ParsedJoinPayload {
    var payload: String
    var audioSsrc: UInt32
}

private func parseSdpIntoJoinPayload(sdp: String) -> ParsedJoinPayload? {
    let lines = sdp.components(separatedBy: "\n")
    
    var videoLines: [String] = []
    var audioLines: [String] = []
    var isAudioLine = false
    var isVideoLine = false
    for line in lines {
        if line.hasPrefix("m=audio") {
            isAudioLine = true
            isVideoLine = false
        } else if line.hasPrefix("m=video") {
            isVideoLine = true
            isAudioLine = false
        }
        
        if isAudioLine {
            audioLines.append(line)
        } else if isVideoLine {
            videoLines.append(line)
        }
    }
    
    func getLines(prefix: String) -> [String] {
        var result: [String] = []
        for line in lines {
            if line.hasPrefix(prefix) {
                var cleanLine = String(line[line.index(line.startIndex, offsetBy: prefix.count)...])
                if cleanLine.hasSuffix("\r") {
                    cleanLine.removeLast()
                }
                result.append(cleanLine)
            }
        }
        return result
    }
    
    func getLines(prefix: String, isAudio: Bool) -> [String] {
        var result: [String] = []
        for line in (isAudio ? audioLines : videoLines) {
            if line.hasPrefix(prefix) {
                var cleanLine = String(line[line.index(line.startIndex, offsetBy: prefix.count)...])
                if cleanLine.hasSuffix("\r") {
                    cleanLine.removeLast()
                }
                result.append(cleanLine)
            }
        }
        return result
    }
    
    var audioSources: [Int] = []
    for line in getLines(prefix: "a=ssrc:", isAudio: true) {
        let scanner = Scanner(string: line)
        if #available(iOS 13.0, *) {
            if let ssrc = scanner.scanInt() {
                if !audioSources.contains(ssrc) {
                    audioSources.append(ssrc)
                }
            }
        }
    }
    
    guard let ssrc = audioSources.first else {
        return nil
    }
    
    guard let ufrag = getLines(prefix: "a=ice-ufrag:").first else {
        return nil
    }
    guard let pwd = getLines(prefix: "a=ice-pwd:").first else {
        return nil
    }
    
    var resultPayload: [String: Any] = [:]
    
    var fingerprints: [[String: Any]] = []
    for line in getLines(prefix: "a=fingerprint:") {
        let components = line.components(separatedBy: " ")
        if components.count != 2 {
            continue
        }
        fingerprints.append([
            "hash": components[0],
            "fingerprint": components[1],
            "setup": "active"
        ])
    }
    
    resultPayload["fingerprints"] = fingerprints
    
    resultPayload["ufrag"] = ufrag
    resultPayload["pwd"] = pwd
    
    resultPayload["ssrc"] = ssrc
    
    guard let payloadData = try? JSONSerialization.data(withJSONObject: resultPayload, options: []) else {
        return nil
    }
    guard let payloadString = String(data: payloadData, encoding: .utf8) else {
        return nil
    }
    
    return ParsedJoinPayload(
        payload: payloadString,
        audioSsrc: UInt32(ssrc)
    )
}

private func parseJoinResponseIntoSdp(sessionId: UInt32, mainStreamAudioSsrc: UInt32, payload: String, isAnswer: Bool, otherSsrcs: [UInt32]) -> String? {
    guard let payloadData = payload.data(using: .utf8) else {
        return nil
    }
    guard let jsonPayload = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any] else {
        return nil
    }
    
    guard let transport = jsonPayload["transport"] as? [String: Any] else {
        return nil
    }
    guard let pwd = transport["pwd"] as? String else {
        return nil
    }
    guard let ufrag = transport["ufrag"] as? String else {
        return nil
    }
    
    struct ParsedFingerprint {
        var hashValue: String
        var fingerprint: String
        var setup: String
    }
    
    var fingerprints: [ParsedFingerprint] = []
    guard let fingerprintsValue = transport["fingerprints"] as? [[String: Any]] else {
        return nil
    }
    for fingerprintValue in fingerprintsValue {
        guard let hashValue = fingerprintValue["hash"] as? String else {
            continue
        }
        guard let fingerprint = fingerprintValue["fingerprint"] as? String else {
            continue
        }
        guard let setup = fingerprintValue["setup"] as? String else {
            continue
        }
        fingerprints.append(ParsedFingerprint(
            hashValue: hashValue,
            fingerprint: fingerprint,
            setup: setup
        ))
    }
    
    struct ParsedCandidate {
        var port: String
        var `protocol`: String
        var network: String
        var generation: String
        var id: String
        var component: String
        var foundation: String
        var priority: String
        var ip: String
        var type: String
        var tcpType: String?
        var relAddr: String?
        var relPort: String?
    }
    
    var candidates: [ParsedCandidate] = []
    guard let candidatesValue = transport["candidates"] as? [[String: Any]] else {
        return nil
    }
    for candidateValue in candidatesValue {
        guard let port = candidateValue["port"] as? String else {
            continue
        }
        guard let `protocol` = candidateValue["protocol"] as? String else {
            continue
        }
        guard let network = candidateValue["network"] as? String else {
            continue
        }
        guard let generation = candidateValue["generation"] as? String else {
            continue
        }
        guard let id = candidateValue["id"] as? String else {
            continue
        }
        guard let component = candidateValue["component"] as? String else {
            continue
        }
        guard let foundation = candidateValue["foundation"] as? String else {
            continue
        }
        guard let priority = candidateValue["priority"] as? String else {
            continue
        }
        guard let ip = candidateValue["ip"] as? String else {
            continue
        }
        guard let type = candidateValue["type"] as? String else {
            continue
        }
        
        let tcpType = candidateValue["tcptype"] as? String
        
        let relAddr = candidateValue["rel-addr"] as? String
        let relPort = candidateValue["rel-port"] as? String
        
        candidates.append(ParsedCandidate(
            port: port,
            protocol: `protocol`,
            network: network,
            generation: generation,
            id: id,
            component: component,
            foundation: foundation,
            priority: priority,
            ip: ip,
            type: type,
            tcpType: tcpType,
            relAddr: relAddr,
            relPort: relPort
        ))
    }
    
    struct StreamSpec {
        var isMain: Bool
        var audioSsrc: Int
        var isRemoved: Bool
    }
    
    func createSdp(sessionId: UInt32, bundleStreams: [StreamSpec]) -> String {
        var sdp = ""
        func appendSdp(_ string: String) {
            if !sdp.isEmpty {
                sdp.append("\n")
            }
            sdp.append(string)
        }
        
        appendSdp("v=0")
        appendSdp("o=- \(sessionId) 2 IN IP4 0.0.0.0")
        appendSdp("s=-")
        appendSdp("t=0 0")
        
        var bundleString = "a=group:BUNDLE"
        for stream in bundleStreams {
            bundleString.append(" ")
            let audioMid: String
            if stream.isMain {
                audioMid = "0"
            } else {
                audioMid = "audio\(stream.audioSsrc)"
            }
            bundleString.append("\(audioMid)")
        }
        appendSdp(bundleString)
        
        appendSdp("a=ice-lite")
        
        for stream in bundleStreams {
            let audioMid: String
            if stream.isMain {
                audioMid = "0"
            } else {
                audioMid = "audio\(stream.audioSsrc)"
            }
            
            appendSdp("m=audio \(stream.isMain ? "1" : "0") RTP/SAVPF 111 126")
            if stream.isMain {
                appendSdp("c=IN IP4 0.0.0.0")
            }
            appendSdp("a=mid:\(audioMid)")
            if stream.isRemoved {
                appendSdp("a=inactive")
            } else {
                if stream.isMain {
                    appendSdp("a=ice-ufrag:\(ufrag)")
                    appendSdp("a=ice-pwd:\(pwd)")
                    
                    for fingerprint in fingerprints {
                        appendSdp("a=fingerprint:\(fingerprint.hashValue) \(fingerprint.fingerprint)")
                        appendSdp("a=setup:passive")
                    }
                    
                    for candidate in candidates {
                        var candidateString = "a=candidate:"
                        candidateString.append("\(candidate.foundation) ")
                        candidateString.append("\(candidate.component) ")
                        var protocolValue = candidate.protocol
                        if protocolValue == "ssltcp" {
                            protocolValue = "tcp"
                        }
                        candidateString.append("\(protocolValue) ")
                        candidateString.append("\(candidate.priority) ")
                        
                        let ip = candidate.ip
                        candidateString.append("\(ip) ")
                        candidateString.append("\(candidate.port) ")
                        
                        candidateString.append("typ \(candidate.type) ")
                        
                        switch candidate.type {
                        case "srflx", "prflx", "relay":
                            if let relAddr = candidate.relAddr, let relPort = candidate.relPort {
                                candidateString.append("raddr \(relAddr) rport \(relPort) ")
                            }
                            break
                        default:
                            break
                        }
                        
                        if protocolValue == "tcp" {
                            guard let tcpType = candidate.tcpType else {
                                continue
                            }
                            candidateString.append("tcptype \(tcpType) ")
                        }
                        
                        candidateString.append("generation \(candidate.generation)")
                        
                        appendSdp(candidateString)
                    }
                }
                
                appendSdp("a=rtpmap:111 opus/48000/2")
                appendSdp("a=rtpmap:126 telephone-event/8000")
                appendSdp("a=fmtp:111 minptime=10; useinbandfec=1; usedtx=1")
                appendSdp("a=rtcp:1 IN IP4 0.0.0.0")
                appendSdp("a=rtcp-mux")
                appendSdp("a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level")
                appendSdp("a=extmap:3 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time")
                appendSdp("a=extmap:5 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01")
                appendSdp("a=rtcp-fb:111 transport-cc")
                
                if isAnswer {
                    appendSdp("a=recvonly")
                } else {
                    if stream.isMain {
                        appendSdp("a=sendrecv")
                    } else {
                        appendSdp("a=sendonly")
                        appendSdp("a=bundle-only")
                    }
                    
                    appendSdp("a=ssrc-group:FID \(stream.audioSsrc)")
                    appendSdp("a=ssrc:\(stream.audioSsrc) cname:stream\(stream.audioSsrc)")
                    appendSdp("a=ssrc:\(stream.audioSsrc) msid:stream\(stream.audioSsrc) audio\(stream.audioSsrc)")
                    appendSdp("a=ssrc:\(stream.audioSsrc) mslabel:audio\(stream.audioSsrc)")
                    appendSdp("a=ssrc:\(stream.audioSsrc) label:audio\(stream.audioSsrc)")
                }
            }
        }
        
        appendSdp("")
        
        return sdp
    }
    
    var bundleStreams: [StreamSpec] = []
    bundleStreams.append(StreamSpec(
        isMain: true,
        audioSsrc: Int(mainStreamAudioSsrc),
        isRemoved: false
    ))
    
    for ssrc in otherSsrcs {
        bundleStreams.append(StreamSpec(
            isMain: false,
            audioSsrc: Int(ssrc),
            isRemoved: false
        ))
    }
    
    /*var bundleStreams: [StreamSpec] = []
    if let currentState = currentState {
        for item in currentState.items {
            let isRemoved = !streams.contains(where: { $0.audioSsrc == item.audioSsrc })
            bundleStreams.append(StreamSpec(
                isMain: item.audioSsrc == mainStreamAudioSsrc,
                audioSsrc: item.audioSsrc,
                videoSsrc: item.videoSsrc,
                isRemoved: isRemoved
            ))
        }
    }
    
    for stream in streams {
        if bundleStreams.contains(where: { $0.audioSsrc == stream.audioSsrc }) {
            continue
        }
        bundleStreams.append(stream)
    }*/
    
    return createSdp(sessionId: sessionId, bundleStreams: bundleStreams)
}

public final class OngoingGroupCallContext {
    private final class Impl {
        let queue: Queue
        let context: GroupCallThreadLocalContext
        
        let sessionId = UInt32.random(in: 0 ..< UInt32(Int32.max))
        var mainStreamAudioSsrc: UInt32?
        var initialAnswerPayload: String?
        var otherSsrcs: [UInt32] = []
        
        let joinPayload = Promise<String>()
        
        init(queue: Queue) {
            self.queue = queue
            
            self.context = GroupCallThreadLocalContext(queue: ContextQueueImpl(queue: queue), relaySdpAnswer: { _ in
            }, incomingVideoStreamListUpdated: { _ in
            }, videoCapturer: nil)
            
            let queue = self.queue
            self.context.emitOffer(adjustSdp: { sdp in
                return sdp
            }, completion: { [weak self] offerSdp in
                queue.async {
                    guard let strongSelf = self else {
                        return
                    }
                    if let payload = parseSdpIntoJoinPayload(sdp: offerSdp) {
                        strongSelf.mainStreamAudioSsrc = payload.audioSsrc
                        strongSelf.joinPayload.set(.single(payload.payload))
                    }
                }
            })
        }
        
        func setJoinResponse(payload: String, ssrcs: [Int32]) {
            guard let mainStreamAudioSsrc = self.mainStreamAudioSsrc else {
                return
            }
            if let sdp = parseJoinResponseIntoSdp(sessionId: self.sessionId, mainStreamAudioSsrc: mainStreamAudioSsrc, payload: payload, isAnswer: true, otherSsrcs: []) {
                self.initialAnswerPayload = payload
                self.context.setOfferSdp(sdp, isPartial: true)
                self.addSsrcs(ssrcs: ssrcs)
            }
        }
        
        func addSsrcs(ssrcs: [Int32]) {
            if ssrcs.isEmpty {
                return
            }
            guard let mainStreamAudioSsrc = self.mainStreamAudioSsrc else {
                return
            }
            guard let initialAnswerPayload = self.initialAnswerPayload else {
                return
            }
            let mappedSsrcs = ssrcs.map(UInt32.init(bitPattern:))
            var otherSsrcs = self.otherSsrcs
            for ssrc in mappedSsrcs {
                if ssrc == mainStreamAudioSsrc {
                    continue
                }
                if !otherSsrcs.contains(ssrc) {
                    otherSsrcs.append(ssrc)
                }
            }
            if self.otherSsrcs != otherSsrcs {
                self.otherSsrcs = otherSsrcs
                
                if let sdp = parseJoinResponseIntoSdp(sessionId: self.sessionId, mainStreamAudioSsrc: mainStreamAudioSsrc, payload: initialAnswerPayload, isAnswer: false, otherSsrcs: self.otherSsrcs) {
                    self.context.setOfferSdp(sdp, isPartial: false)
                }
            }
        }
        
        func setIsMuted(_ isMuted: Bool) {
        }
    }
    
    private let queue = Queue()
    private let impl: QueueLocalObject<Impl>
    
    public var joinPayload: Signal<String, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.impl.with { impl in
                disposable.set(impl.joinPayload.get().start(next: { value in
                    subscriber.putNext(value)
                }))
            }
            return disposable
        }
    }
    
    public init() {
        let queue = self.queue
        self.impl = QueueLocalObject(queue: queue, generate: {
            return Impl(queue: queue)
        })
    }
    
    public func setIsMuted(_ isMuted: Bool) {
        self.impl.with { impl in
            impl.setIsMuted(isMuted)
        }
    }
    
    public func setJoinResponse(payload: String, ssrcs: [Int32]) {
        self.impl.with { impl in
            impl.setJoinResponse(payload: payload, ssrcs: ssrcs)
        }
    }
    
    public func addSsrcs(ssrcs: [Int32]) {
        self.impl.with { impl in
            impl.addSsrcs(ssrcs: ssrcs)
        }
    }
}
