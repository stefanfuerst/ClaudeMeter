//
//  UsageCardView.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import SwiftUI

/// Reusable usage card component
struct UsageCardView: View {
    let title: String
    let usageLimit: UsageLimit
    let icon: String
    let windowDuration: TimeInterval?

    var body: some View {
        let effectiveStatus: UsageStatus = {
            if let windowDuration {
                return usageLimit.pacingStatus(windowDuration: windowDuration)
            }
            return usageLimit.status
        }()

        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and title
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(effectiveStatus.color)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                // Status badge
                HStack(spacing: 4) {
                    Image(systemName: effectiveStatus.iconName)
                        .font(.caption)
                    Text(effectiveStatus.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(effectiveStatus.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(effectiveStatus.color.opacity(0.15))
                .cornerRadius(8)
            }

            // Usage percentage
            Text("\(Int(usageLimit.percentage))%")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(effectiveStatus.color)

            // Progress bar (dual: time elapsed + actual usage)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))

                    // Time elapsed progress (shows how much of the window has passed)
                    if let windowDuration {
                        let timeElapsed = usageLimit.timeElapsedPercentage(windowDuration: windowDuration)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: geometry.size.width * min(timeElapsed / 100, 1.0))
                    }

                    // Actual usage progress (up to 100%)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(effectiveStatus.color)
                        .frame(width: geometry.size.width * min(usageLimit.percentage / 100, 1.0))

                    // Over-limit usage (above 100%) in red
                    if usageLimit.percentage > 100 {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.red)
                            .frame(width: geometry.size.width * ((usageLimit.percentage - 100) / 100))
                            .offset(x: geometry.size.width)
                    }
                }
            }
            .frame(height: 8)

            // Reset time and pacing indicator
            HStack(spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    if let windowDuration {
                        let elapsed = Int(usageLimit.timeElapsedPercentage(windowDuration: windowDuration))
                        Text("Resets \(usageLimit.resetDescription). \(elapsed)% elapsed")
                            .font(.caption)
                    } else {
                        Text("Resets \(usageLimit.resetDescription)")
                            .font(.caption)
                    }
                }
                .help(usageLimit.resetTimeFormatted)

                Spacer()

                if let windowDuration,
                   usageLimit.isAtRisk(windowDuration: windowDuration) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .help("You may hit your limit before it resets")
                        .accessibilityLabel("At risk of hitting limit")
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(Int(usageLimit.percentage))% used, \(effectiveStatus.accessibilityDescription)")
        .accessibilityValue({
            if let windowDuration {
                let elapsed = Int(usageLimit.timeElapsedPercentage(windowDuration: windowDuration))
                return "Resets \(usageLimit.resetDescription). \(elapsed)% elapsed"
            } else {
                return "Resets \(usageLimit.resetDescription)"
            }
        }())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        UsageCardView(
            title: "5-Hour Session",
            usageLimit: UsageLimit(
                utilization: 35.0,
                resetAt: Date().addingTimeInterval(7200)
            ),
            icon: "gauge.with.dots.needle.67percent",
            windowDuration: Constants.Pacing.sessionWindow
        )

        UsageCardView(
            title: "Weekly Usage",
            usageLimit: UsageLimit(
                utilization: 75.0,
                resetAt: Date().addingTimeInterval(86400 * 3)
            ),
            icon: "calendar",
            windowDuration: Constants.Pacing.weeklyWindow
        )

        UsageCardView(
            title: "Over Limit",
            usageLimit: UsageLimit(
                utilization: 115.0,
                resetAt: Date().addingTimeInterval(3600)
            ),
            icon: "exclamationmark.triangle.fill",
            windowDuration: Constants.Pacing.sessionWindow
        )
    }
    .padding()
    .frame(width: 320)
}
