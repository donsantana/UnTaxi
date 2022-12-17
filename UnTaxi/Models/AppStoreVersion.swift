//
//  AppStoreVersion.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 10/29/22.
//  Copyright © 2022 Done Santana. All rights reserved.
//

import Foundation

struct ItunesAppInfo: Codable {
	let resultCount: Int?
	let results: [ItunesAppInfo.Result]?
struct Result: Codable {
		 let screenshotUrls, ipadScreenshotUrls: [String]?
		 let appletvScreenshotUrls: [String]?
		 let artworkUrl60, artworkUrl512: String?
		 let artworkUrl100, artistViewURL: String?
		 let supportedDevices: [String]?
		 let advisories: [String]?
		 let isGameCenterEnabled: Bool?
		 let kind: String?
		 let features: [String]?
		 let trackCensoredName: String?
		 let languageCodesISO2A: [String]?
		 let fileSizeBytes, sellerURL, contentAdvisoryRating: String?
		 let averageUserRatingForCurrentVersion: Double?
		 let userRatingCountForCurrentVersion: Int?
		 let averageUserRating: Double?
		 let trackViewURL, trackContentRating: String?
		 let isVppDeviceBasedLicensingEnabled: Bool?
		 let minimumOSVersion: String?
		 let trackID: Int?
		 let trackName, releaseDate, primaryGenreName: String?
		 let genreIDS: [String]?
		 let formattedPrice, currentVersionReleaseDate: String?
		 let releaseNotes: String?
		 let primaryGenreID: Int?
		 let sellerName, currency, wrapperType: String?
		 let version: String? //this is what we need
		 let artistID: Int?
		 let artistName: String?
		 let genres: [String]?
		 let price: Double?
		 let description, bundleID: String?
		 let userRatingCount: Int?
		 enum CodingKeys: String, CodingKey {
				 case screenshotUrls, ipadScreenshotUrls
				 case appletvScreenshotUrls, artworkUrl60
				 case artworkUrl512, artworkUrl100
				 case artistViewURL = "artistViewUrl"
				 case supportedDevices, advisories
				 case isGameCenterEnabled, kind
				 case features, trackCensoredName
				 case languageCodesISO2A, fileSizeBytes
				 case sellerURL = "sellerUrl"
				 case contentAdvisoryRating
				 case averageUserRatingForCurrentVersion
				 case userRatingCountForCurrentVersion
				 case averageUserRating
				 case trackViewURL = "trackViewUrl"
				 case trackContentRating
				 case isVppDeviceBasedLicensingEnabled
				 case minimumOSVersion = "minimumOsVersion"
				 case trackID = "trackId"
				 case trackName, releaseDate, primaryGenreName
				 case genreIDS = "genreIds"
				 case formattedPrice, currentVersionReleaseDate
				 case releaseNotes
				 case primaryGenreID = "primaryGenreId"
				 case sellerName, currency, version, wrapperType
				 case artistID = "artistId"
				 case artistName, genres, price, description
				 case bundleID = "bundleId"
				 case userRatingCount
		 }
	 }
 }
// MARK: Convenience initializers
extension ItunesAppInfo {
	init?(data: Data) {
		guard let me = try? JSONDecoder().decode(ItunesAppInfo.self, from: data) else { return nil }
		self = me
	}
}
//
//
//// MARK: - AppStoreResponse
//struct AppStoreResponse: Codable {
//		let resultCount: Int
//		let results: [Result]
//}
//
//// MARK: - Result
//struct Result: Codable {
//		let releaseNotes: String
//		let releaseDate: String
//		let version: String
//}
//
//private extension Bundle {
//		var releaseVersionNumber: String? {
//				infoDictionary?["CFBundleShortVersionString"] as? String
//		}
//}
//
//struct AppStoreUpdateChecker {
//		static func isNewVersionAvailable() async -> Bool {
//				guard let bundleID = Bundle.main.bundleIdentifier,
//								let currentVersionNumber = Bundle.main.releaseVersionNumber,
//								let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(bundleID)") else {
//						// Invalid inputs
//						return false
//				}
//
//				do {
//						let (data, _) = try await URLSession.shared.data(from: url)
//						let appStoreResponse = try JSONDecoder().decode(AppStoreResponse.self, from: data)
//
//						guard let latestVersionNumber = appStoreResponse.results.first?.version else {
//								// No app with matching bundleID found
//								return false
//						}
//
//						return currentVersionNumber != latestVersionNumber
//				}
//				catch {
//						// TODO: Handle error
//						return false
//				}
//		}
//}
//
//// Usage:
//Task {
//		if await AppStoreUpdateChecker.isNewVersionAvailable() {
//				print("New version of app is availabe. Showing blocking alert!")
//		}
//}
