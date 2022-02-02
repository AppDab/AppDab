import Bagbutik

public enum UpdateCategoryParameter {
    case set(String)
    case clear
}

@discardableResult
public func updateAppCategories(forAppInfoId appInfoId: String,
                                primaryCategoryId: UpdateCategoryParameter? = nil,
                                primarySubcategoryOneId: UpdateCategoryParameter? = nil,
                                primarySubcategoryTwoId: UpdateCategoryParameter? = nil,
                                secondaryCategoryId: UpdateCategoryParameter? = nil,
                                secondarySubcategoryOneId: UpdateCategoryParameter? = nil,
                                secondarySubcategoryTwoId: UpdateCategoryParameter? = nil) async throws -> AppInfo {
    ActionsEnvironment.logger.info("🚀 Fetching list of available categories...")
    let categoriesResponse = try await ActionsEnvironment.service.request(.listAppCategories(includes: [.subcategories]))
    ActionsEnvironment.logger.info("👍 Did fetch list of available categories")

    let (primaryCategoryId, realPrimaryCategory) = try validateCategoryId(primaryCategoryId, realCategories: categoriesResponse.data)
    let primaryCategory: AppInfoUpdateRequest.Data.Relationships.PrimaryCategory?
    switch primaryCategoryId {
    case .set(let primaryCategoryId):
        primaryCategory = .init(data: .init(id: primaryCategoryId))
    case .clear:
        primaryCategory = .init(data: nil)
    case .none:
        primaryCategory = nil
    }

    let primarySubcategoryOne: AppInfoUpdateRequest.Data.Relationships.PrimarySubcategoryOne?
    switch try validateSubcategoryId(primarySubcategoryOneId, parentCategory: realPrimaryCategory) {
    case .set(let subcategoryId):
        primarySubcategoryOne = .init(data: .init(id: subcategoryId))
    case .clear:
        primarySubcategoryOne = .init(data: nil)
    case .none:
        primarySubcategoryOne = nil
    }

    var primarySubcategoryTwo: AppInfoUpdateRequest.Data.Relationships.PrimarySubcategoryTwo?
    switch try validateSubcategoryId(primarySubcategoryTwoId, parentCategory: realPrimaryCategory) {
    case .set(let subcategoryId):
        primarySubcategoryTwo = .init(data: .init(id: subcategoryId))
    case .clear:
        primarySubcategoryTwo = .init(data: nil)
    case .none:
        primarySubcategoryTwo = nil
    }

    let (secondaryCategoryId, realsecondaryCategory) = try validateCategoryId(secondaryCategoryId, realCategories: categoriesResponse.data)
    let secondaryCategory: AppInfoUpdateRequest.Data.Relationships.SecondaryCategory?
    switch secondaryCategoryId {
    case .set(let secondaryCategoryId):
        secondaryCategory = .init(data: .init(id: secondaryCategoryId))
    case .clear:
        secondaryCategory = .init(data: nil)
    case .none:
        secondaryCategory = nil
    }

    let secondarySubcategoryOne: AppInfoUpdateRequest.Data.Relationships.SecondarySubcategoryOne?
    switch try validateSubcategoryId(secondarySubcategoryOneId, parentCategory: realsecondaryCategory) {
    case .set(let subcategoryId):
        secondarySubcategoryOne = .init(data: .init(id: subcategoryId))
    case .clear:
        secondarySubcategoryOne = .init(data: nil)
    case .none:
        secondarySubcategoryOne = nil
    }

    var secondarySubcategoryTwo: AppInfoUpdateRequest.Data.Relationships.SecondarySubcategoryTwo?
    switch try validateSubcategoryId(secondarySubcategoryTwoId, parentCategory: realsecondaryCategory) {
    case .set(let subcategoryId):
        secondarySubcategoryTwo = .init(data: .init(id: subcategoryId))
    case .clear:
        secondarySubcategoryTwo = .init(data: nil)
    case .none:
        secondarySubcategoryTwo = nil
    }

    let requestBody = AppInfoUpdateRequest(data: .init(id: appInfoId, relationships: .init(
        primaryCategory: primaryCategory,
        primarySubcategoryOne: primarySubcategoryOne,
        primarySubcategoryTwo: primarySubcategoryTwo,
        secondaryCategory: secondaryCategory,
        secondarySubcategoryOne: secondarySubcategoryOne,
        secondarySubcategoryTwo: secondarySubcategoryTwo
    )))
    ActionsEnvironment.logger.info("🚀 Updating categories...")
    let appInfoResponse = try await ActionsEnvironment.service.request(.updateAppInfo(id: appInfoId, requestBody: requestBody))
    ActionsEnvironment.logger.info("👍 Categories updated")
    return appInfoResponse.data
}

private func validateCategoryId(_ categoryParameter: UpdateCategoryParameter?,
                                realCategories: [AppCategory]) throws -> (UpdateCategoryParameter?, AppCategory?) {
    switch categoryParameter {
    case .set(let categoryId):
        guard let realCategory = realCategories.first(where: { $0.id == categoryId }) else {
            throw AppCategoryError.invalidCategoryId(categoryId)
        }
        return (categoryParameter, realCategory)
    case .clear:
        return (categoryParameter, nil)
    case .none:
        return (nil, nil)
    }
}

private func validateSubcategoryId(_ subcategoryParameter: UpdateCategoryParameter?,
                                   parentCategory: AppCategory?) throws -> (UpdateCategoryParameter?) {
    switch subcategoryParameter {
    case .set(let subcategoryId):
        guard let subcategories = parentCategory?.relationships?.subcategories?.data else {
            throw AppCategoryError.noSubcategories(subcategoryId)
        }
        guard subcategories.contains(where: { $0.id == subcategoryId }) else {
            throw AppCategoryError.invalidSubcategoryId(subcategoryId)
        }
        return subcategoryParameter
    case .clear:
        return subcategoryParameter
    case .none:
        return nil
    }
}
