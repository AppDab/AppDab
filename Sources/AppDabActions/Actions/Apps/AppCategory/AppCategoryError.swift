public enum AppCategoryError: ActionError, Equatable {
    case invalidCategoryId(String)
    case invalidSubcategoryId(String)
    case noSubcategories(String)

    public var description: String {
        switch self {
        case .invalidCategoryId(let categoryId):
            return "The category id '\(categoryId)' is invalid"
        case .invalidSubcategoryId(let subcategoryId):
            return "The subcategory id '\(subcategoryId)' is invalid"
        case .noSubcategories(let subcategoryId):
            return "The parent category supplied for subcategory id '\(subcategoryId)' has no subcategories"
        }
    }
}
