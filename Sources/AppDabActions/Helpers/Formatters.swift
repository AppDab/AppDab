import Foundation

internal struct Formatters {
    static let dateTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()

    static let relativeDateTimeFormatter: RelativeDateTimeFormatter = {
        let relativeDateTimeFormatter = RelativeDateTimeFormatter()
        relativeDateTimeFormatter.locale = Locale(identifier: "en_US")
        return relativeDateTimeFormatter
    }()
    
    static let dateFolderFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    static let archiveDateTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy, HH.mm"
        return dateFormatter
    }()

}
