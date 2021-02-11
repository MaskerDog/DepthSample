//
//  DebugUtility.swift
//  DepthSample
//
//  Created by npc on 2021/02/11.
//

import Foundation

public enum LogLebel: String {
    case debug
    case info
    case warning
    case error
}

private func getFileName(from filePath: String) -> String {
    return filePath.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
}

private var date: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    formatter.locale = Locale(identifier: "ja-JP")
    return formatter.string(from: Date())
}

func debug(file: String = #file, function: String = #function, line: Int = #line, _ message: String = "") {
    #if DEBUG
    print("\(date) [\(LogLebel.debug.rawValue.uppercased())] \(getFileName(from: file)).\(function) #\(line): \(message)")
    #endif
}

func info(file: String = #file, function: String = #function, line: Int = #line, _ message: String = "") {
    #if DEBUG
    print("\(date) [\(LogLebel.info.rawValue.uppercased())] \(getFileName(from: file)).\(function) #\(line): \(message)")
    #endif
}

func warning(file: String = #file, function: String = #function, line: Int = #line, _ message: String = "") {
    #if DEBUG
    print("\(date) [\(LogLebel.warning.rawValue.uppercased())] \(getFileName(from: file)).\(function) #\(line): \(message)")
    #endif
}

func error(file: String = #file, function: String = #function, line: Int = #line, _ message: String = "") {
    #if DEBUG
    print("\(date) [\(LogLebel.error.rawValue.uppercased())] \(getFileName(from: file)).\(function) #\(line): \(message)")
    #endif
    assertionFailure(message)
}
