//
//  DataFormatter+ResumeRange.swift
//  ResumeBuilder
//
//  Created by Mohsin Khan on 09/11/25.
//
import Foundation

extension DateFormatter {
    static func resumeRange(_ s: Date, _ e: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "MMM yyyy"
        return "\(f.string(from: s)) – \(f.string(from: e))"
    }
}
