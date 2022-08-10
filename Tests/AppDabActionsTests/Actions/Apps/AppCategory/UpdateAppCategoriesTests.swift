import AppDabActions
import Bagbutik_Models
import Foundation
import XCTest

final class UpdateAppCategoriesTests: ActionsTestCase {
    let fetchResponse = AppCategoriesResponse(
        data: [.init(id: "GAMES", links: .init(self: ""), relationships: .init(subcategories: .init(data: [.init(id: "GAMES_TRIVIA"), .init(id: "GAMES_CASUAL")]))),
               .init(id: "STICKERS", links: .init(self: ""), relationships: .init(subcategories: .init(data: [.init(id: "STICKERS_PLACES_AND_OBJECTS"), .init(id: "STICKERS_EMOJI_AND_EXPRESSIONS")]))),
               .init(id: "FINANCE", links: .init(self: ""))],
        links: .init(self: "")
    )
    let updateResponse = AppInfoResponse(
        data: .init(id: "some-id", links: .init(self: "")),
        links: .init(self: "")
    )

    func testUpdateAppCategories_AllValues() async {
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/appCategories", method: .get))
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/appInfos/some-id", method: .patch))
        let appInfo = try! await updateAppCategories(forAppInfoId: "some-id",
                                                     primaryCategoryId: .set("GAMES"),
                                                     primarySubcategoryOneId: .set("GAMES_TRIVIA"),
                                                     primarySubcategoryTwoId: .set("GAMES_CASUAL"),
                                                     secondaryCategoryId: .set("STICKERS"),
                                                     secondarySubcategoryOneId: .set("STICKERS_PLACES_AND_OBJECTS"),
                                                     secondarySubcategoryTwoId: .set("STICKERS_EMOJI_AND_EXPRESSIONS"))
        XCTAssertEqual(appInfo, updateResponse.data)
    }

    func testUpdateAppCategories_ClearAll() async {
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/appCategories", method: .get))
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/appInfos/some-id", method: .patch))
        let appInfo = try! await updateAppCategories(forAppInfoId: "some-id",
                                                     primaryCategoryId: .clear,
                                                     primarySubcategoryOneId: .clear,
                                                     primarySubcategoryTwoId: .clear,
                                                     secondaryCategoryId: .clear,
                                                     secondarySubcategoryOneId: .clear,
                                                     secondarySubcategoryTwoId: .clear)
        XCTAssertEqual(appInfo, updateResponse.data)
    }

    func testUpdateAppCategories_NilAll() async {
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/appCategories", method: .get))
        mockBagbutikService.setResponse(updateResponse, for: Endpoint(path: "/v1/appInfos/some-id", method: .patch))
        let appInfo = try! await updateAppCategories(forAppInfoId: "some-id")
        XCTAssertEqual(appInfo, updateResponse.data)
    }

    func testUpdateAppCategories_InvalidCategory() async {
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/appCategories", method: .get))
        await XCTAssertAsyncThrowsError(try await updateAppCategories(forAppInfoId: "some-id", primaryCategoryId: .set("INVALID"))) { error in
            XCTAssertEqual(error as! AppCategoryError, .invalidCategoryId("INVALID"))
        }
    }

    func testUpdateAppCategories_ParentWithNoSubcategories() async {
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/appCategories", method: .get))
        await XCTAssertAsyncThrowsError(try await updateAppCategories(forAppInfoId: "some-id",
                                                                      primaryCategoryId: .set("FINANCE"),
                                                                      primarySubcategoryOneId: .set("GAMES_CASUAL"))) { error in
            XCTAssertEqual(error as! AppCategoryError, .noSubcategories("GAMES_CASUAL"))
        }
    }
    
    func testUpdateAppCategories_InvalidSubcategory() async {
        mockBagbutikService.setResponse(fetchResponse, for: Endpoint(path: "/v1/appCategories", method: .get))
        await XCTAssertAsyncThrowsError(try await updateAppCategories(forAppInfoId: "some-id",
                                                                      primaryCategoryId: .set("GAMES"),
                                                                      primarySubcategoryOneId: .set("GAMES_SPORTS"))) { error in
            XCTAssertEqual(error as! AppCategoryError, .invalidSubcategoryId("GAMES_SPORTS"))
        }
    }
}

extension AppInfo: Equatable {
    public static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.id == rhs.id
    }
}
