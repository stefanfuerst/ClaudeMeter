//
//  DualBarIcon.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-12-28.
//

import SwiftUI

/// Dual bar menu bar icon showing session (top) and weekly (bottom) usage
struct DualBarIcon: View {
    let percentage: Double        // Session percentage
    let weeklyPercentage: Double  // Weekly percentage
    let status: UsageStatus       // Session pacing status
    let weeklyStatus: UsageStatus // Weekly pacing status
    let isLoading: Bool
    let isStale: Bool

    private let barWidth: CGFloat = 16
    private let barHeight: CGFloat = 4
    private let barSpacing: CGFloat = 1

    var body: some View {
        HStack(spacing: 2) {
            if isLoading {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(statusColor)
            } else {
                // Show session percentage (left)
                Text("\(Int(percentage))%")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(statusColor)

                // Two stacked progress bars
                VStack(spacing: barSpacing) {
                    // Session bar (top) - blue/cyan
                    ProgressBar(
                        percentage: percentage,
                        color: sessionBarColor,
                        isStale: isStale
                    )
                    .frame(width: barWidth, height: barHeight)

                    // Weekly bar (bottom) - purple
                    ProgressBar(
                        percentage: weeklyPercentage,
                        color: weeklyBarColor,
                        isStale: isStale
                    )
                    .frame(width: barWidth, height: barHeight)
                }

                // Show weekly percentage (right)
                Text("\(Int(weeklyPercentage))%")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(isStale ? .gray : weeklyStatus.color)
            }

            if isStale && !isLoading {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 22)
        .padding(.horizontal, 4)
        .accessibilityLabel("Session: \(Int(percentage)) percent, Weekly: \(Int(weeklyPercentage)) percent")
        .accessibilityValue(status.accessibilityDescription)
    }

    private var statusColor: Color {
        isStale ? .gray : status.color
    }

    private var sessionBarColor: Color {
        if isStale { return .gray }
        return status.color
    }

    private var weeklyBarColor: Color {
        if isStale { return .gray }
        return weeklyStatus.color
    }
}

/// Individual progress bar component
private struct ProgressBar: View {
    let percentage: Double
    let color: Color
    let isStale: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.gray.opacity(0.3))

                // Fill
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color)
                    .frame(width: geo.size.width * min(percentage / 100, 1.0))
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            DualBarIcon(percentage: 35, weeklyPercentage: 20, status: .safe, weeklyStatus: .safe, isLoading: false, isStale: false)
            DualBarIcon(percentage: 65, weeklyPercentage: 45, status: .warning, weeklyStatus: .safe, isLoading: false, isStale: false)
            DualBarIcon(percentage: 92, weeklyPercentage: 78, status: .critical, weeklyStatus: .warning, isLoading: false, isStale: false)
        }
        HStack(spacing: 20) {
            DualBarIcon(percentage: 45, weeklyPercentage: 30, status: .safe, weeklyStatus: .safe, isLoading: true, isStale: false)
            DualBarIcon(percentage: 45, weeklyPercentage: 30, status: .safe, weeklyStatus: .safe, isLoading: false, isStale: true)
        }
    }
    .padding()
}
