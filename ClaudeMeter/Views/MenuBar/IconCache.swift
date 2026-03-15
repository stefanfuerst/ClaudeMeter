//
//  IconCache.swift
//  ClaudeMeter
//
//  Created by Edd on 2026-01-09.
//

import AppKit

/// Simple in-memory cache for rendered menu bar icons.
final class IconCache {
    private let cache = NSCache<NSString, NSImage>()

    init() {
        cache.countLimit = Constants.Cache.maxIconCacheSize
    }

    func get(
        percentage: Double,
        status: UsageStatus,
        isLoading: Bool,
        isStale: Bool,
        iconStyle: IconStyle,
        weeklyPercentage: Double,
        weeklyStatus: UsageStatus = .safe
    ) -> NSImage? {
        cache.object(forKey: cacheKey(
            percentage: percentage,
            status: status,
            isLoading: isLoading,
            isStale: isStale,
            iconStyle: iconStyle,
            weeklyPercentage: weeklyPercentage,
            weeklyStatus: weeklyStatus
        ))
    }

    func set(
        _ image: NSImage,
        percentage: Double,
        status: UsageStatus,
        isLoading: Bool,
        isStale: Bool,
        iconStyle: IconStyle,
        weeklyPercentage: Double,
        weeklyStatus: UsageStatus = .safe
    ) {
        cache.setObject(
            image,
            forKey: cacheKey(
                percentage: percentage,
                status: status,
                isLoading: isLoading,
                isStale: isStale,
                iconStyle: iconStyle,
                weeklyPercentage: weeklyPercentage,
                weeklyStatus: weeklyStatus
            )
        )
    }

    private func cacheKey(
        percentage: Double,
        status: UsageStatus,
        isLoading: Bool,
        isStale: Bool,
        iconStyle: IconStyle,
        weeklyPercentage: Double,
        weeklyStatus: UsageStatus
    ) -> NSString {
        let percent = String(format: "%.2f", percentage)
        let weekly = String(format: "%.2f", weeklyPercentage)
        return "\(percent)|\(weekly)|\(status.rawValue)|\(weeklyStatus.rawValue)|\(isLoading)|\(isStale)|\(iconStyle.rawValue)" as NSString
    }
}
