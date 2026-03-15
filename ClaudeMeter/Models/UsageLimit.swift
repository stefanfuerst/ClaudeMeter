//
//  UsageLimit.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// A single usage limit (session, weekly, or Sonnet)
struct UsageLimit: Codable, Equatable, Sendable {
    /// Utilization percentage (0-100)
    let utilization: Double

    /// ISO8601 timestamp when limit resets
    let resetAt: Date

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetAt = "reset_at"
    }
}

extension UsageLimit {
    /// Percentage used (0-100+) - alias for utilization
    var percentage: Double {
        utilization
    }

    /// Status level based on percentage
    /// Uses thresholds from Constants.Thresholds.Status
    var status: UsageStatus {
        switch utilization {
        case 0..<Constants.Thresholds.Status.warningStart:
            return .safe
        case Constants.Thresholds.Status.warningStart..<Constants.Thresholds.Status.criticalStart:
            return .warning
        default:
            return .critical
        }
    }

    /// Human-readable reset time (uses system timezone via RelativeDateTimeFormatter)
    var resetDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: resetAt, relativeTo: Date())
    }

    /// Exact reset time formatted in user's timezone for tooltip display
    var resetTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: resetAt)
    }

    /// Check if limit has been exceeded
    var isExceeded: Bool {
        utilization >= 100
    }

    /// Check if reset time has passed but usage hasn't reset
    var isResetting: Bool {
        resetAt < Date() && utilization > 0
    }

    /// Returns percentage of time window that has elapsed (0-100)
    /// - Parameter windowDuration: Duration of the usage window (e.g., 5 hours for session)
    func timeElapsedPercentage(windowDuration: TimeInterval) -> Double {
        let now = Date()
        guard resetAt > now else { return 100 }

        let windowStart = resetAt.addingTimeInterval(-windowDuration)
        let elapsed = now.timeIntervalSince(windowStart)
        guard elapsed > 0 else { return 0 }

        let percentage = (elapsed / windowDuration) * 100
        return min(max(percentage, 0), 100)
    }

    /// Returns status based on pacing (usage vs time elapsed) rather than absolute usage
    /// - Parameter windowDuration: Duration of the usage window (e.g., 5 hours for session)
    func pacingStatus(windowDuration: TimeInterval) -> UsageStatus {
        let timeElapsed = timeElapsedPercentage(windowDuration: windowDuration)

        // If not enough time has passed, use absolute status
        guard timeElapsed > 5 else { return status }

        // Calculate pacing ratio: how much you're using relative to time passing
        let ratio = utilization / timeElapsed

        // Apply thresholds based on ratio
        switch ratio {
        case 0..<1.0:
            return .safe  // Using less than time elapsed
        case 1.0..<Constants.Pacing.riskThreshold:
            return .warning  // Over-pacing but not critical
        default:
            return .critical  // Significantly over-pacing
        }
    }

    /// Returns true if current usage rate will likely exceed limit before reset
    /// - Parameter windowDuration: Duration of the usage window (e.g., 5 hours for session)
    func isAtRisk(windowDuration: TimeInterval) -> Bool {
        let now = Date()
        guard resetAt > now else { return false }

        let windowStart = resetAt.addingTimeInterval(-windowDuration)
        let elapsed = now.timeIntervalSince(windowStart)
        guard elapsed > 0 else { return false }

        let timeElapsedPct = elapsed / windowDuration
        let usagePct = min(utilization, 100) / 100
        guard timeElapsedPct > 0 else { return false }

        return (usagePct / timeElapsedPct) > Constants.Pacing.riskThreshold
    }
}
