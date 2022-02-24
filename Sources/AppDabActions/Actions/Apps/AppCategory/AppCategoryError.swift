/// Error happening when manipulating app categories.
public enum AppCategoryError: ActionError, Equatable {
    /// The category id is invalid.
    case invalidCategoryId(String)
    /// The subcategory id is invalid.
    case invalidSubcategoryId(String)
    /// The parent category for the supplied subcategory id has no subcategories.
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
