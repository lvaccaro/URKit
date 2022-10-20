//
//  Bytewords.swift
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

import Foundation

public enum BytewordsDecodingError: LocalizedError {
    case invalidWord
    case invalidChecksum
    
    public var errorDescription: String? {
        switch self {
        case .invalidWord:
            return "Invalid Bytewords word."
        case .invalidChecksum:
            return "Invalid Bytewords checksum."
        }
    }
}

public struct Bytewords {
    public enum Style {
        case standard
        case uri
        case minimal
    }

    public static func encodedLength(_ len: Int, style: Style = .standard) -> Int {
        switch style {
        case .standard, .uri:
            return len * 4 + (len - 1)
        case .minimal:
            return len * 2
        }
    }

    public static func encode(_ data: Data, style: Style = .standard) -> String {
        switch style {
        case .standard:
            return encode(data, separator: " ")
        case .uri:
            return encode(data, separator: "-")
        case .minimal:
            return encodeMinimal(data)
        }
    }

    public static func decode(_ string: String, style: Style = .standard) throws -> Data {
        switch style {
        case .standard:
            return try decode(string, separator: " ")
        case .uri:
            return try decode(string, separator: "-")
        case .minimal:
            return try decodeMinimal(string)
        }
    }

    private static func encode(_ data: Data, separator: String) -> String {
        let words = appendChecksum(to: data).map { byte in
            indexToBytewords[byte]!
        }
        return words.joined(separator: separator)
    }

    private static func encodeMinimal(_ data: Data) -> String {
        let words = appendChecksum(to: data).map { byte in
            indexToMinimalBytewords[byte]!
        }
        return words.joined(separator: "")
    }

    private static func decode(_ string: String, separator: Character) throws -> Data {
        let words = string.split(separator: separator)
        let values = try words.map { word -> UInt8 in
            guard let value = bytewordsToIndex[String(word)] else {
                throw BytewordsDecodingError.invalidWord
            }
            return value
        }
        let data = Data(values)
        return try stripChecksum(from: data)
    }

    private static func decodeMinimal(_ string: String) throws -> Data {
        let words = string.chunked(into: 2)
        let values = try words.map { word -> UInt8 in
            guard let value = minimalBytewordsToIndex[word] else {
                throw BytewordsDecodingError.invalidWord
            }
            return value
        }
        let data = Data(values)
        return try stripChecksum(from: data)
    }

    private static let bytewords = """
    ableacidalsoapexaquaarchatomauntawayaxisbackbaldbarnbeltbetabias\
    bluebodybragbrewbulbbuzzcalmcashcatschefcityclawcodecolacookcost\
    cruxcurlcuspcyandarkdatadaysdelidicedietdoordowndrawdropdrumdull\
    dutyeacheasyechoedgeepicevenexamexiteyesfactfairfernfigsfilmfish\
    fizzflapflewfluxfoxyfreefrogfuelfundgalagamegeargemsgiftgirlglow\
    goodgraygrimgurugushgyrohalfhanghardhawkheathelphighhillholyhope\
    hornhutsicedideaidleinchinkyintoirisironitemjadejazzjoinjoltjowl\
    judojugsjumpjunkjurykeepkenokeptkeyskickkilnkingkitekiwiknoblamb\
    lavalazyleaflegsliarlimplionlistlogoloudloveluaulucklungmainmany\
    mathmazememomenumeowmildmintmissmonknailnavyneednewsnextnoonnote\
    numbobeyoboeomitonyxopenovalowlspaidpartpeckplaypluspoempoolpose\
    puffpumapurrquadquizraceramprealredorichroadrockroofrubyruinruns\
    rustsafesagascarsetssilkskewslotsoapsolosongstubsurfswantacotask\
    taxitenttiedtimetinytoiltombtoystriptunatwinuglyundouniturgeuser\
    vastveryvetovialvibeviewvisavoidvowswallwandwarmwaspwavewaxywebs\
    whatwhenwhizwolfworkyankyawnyellyogayurtzapszerozestzinczonezoom
    """

    private static let indexToBytewords: [UInt8 : String] = {
        var result: [UInt8 : String] = [:]
        var a = bytewords.makeIterator()
        (0...255).forEach { i in
            let word = String((1...4).map { _ in a.next()! })
            result[UInt8(i)] = word
        }
        return result
    }()

    public static let allWords: [String] = {
        var result: [String] = .init()
        result.reserveCapacity(256)
        var a = bytewords.makeIterator()
        (0...255).forEach { i in
            let word = String((1...4).map { _ in a.next()! })
            result.append(word)
        }
        return result
    }()

    private static let indexToMinimalBytewords: [UInt8 : String] = {
        var result: [UInt8 : String] = [:]
        var a = bytewords.makeIterator()
        (0...255).forEach { i in
            let letters = (1...4).map { _ in a.next()! }
            let word = String([letters[0], letters[3]])
            result[UInt8(i)] = word
        }
        return result
    }()

    private static let bytewordsToIndex: [String : UInt8] = {
        var result: [String: UInt8] = [:]
        var a = bytewords.makeIterator()
        (0...255).forEach { i in
            let word = String((1...4).map { _ in a.next()! })
            result[word] = UInt8(i)
        }
        return result
    }()

    private static let minimalBytewordsToIndex: [String: UInt8] = {
        var result: [String: UInt8] = [:]
        var a = bytewords.makeIterator()
        (0...255).forEach { i in
            let letters = (1...4).map { _ in a.next()! }
            let word = String([letters[0], letters[3]])
            result[word] = UInt8(i)
        }
        return result
    }()

    private static func appendChecksum(to data: Data) -> Data {
        var d = data
        let checksum = CRC32.checksum(data: data)
        d.append(checksum.serialized)
        return d
    }

    private static func stripChecksum(from data: Data) throws -> Data {
        let checksumSize = MemoryLayout<UInt32>.size
        guard data.count > checksumSize else { throw BytewordsDecodingError.invalidChecksum }
        let message = data.prefix(data.count - checksumSize)
        let checksum = CRC32.checksum(data: message)
        let messageChecksum = deserialize(UInt32.self, Data(data.suffix(checksumSize)))
        guard messageChecksum == checksum else { throw BytewordsDecodingError.invalidChecksum }
        return message
    }
}
