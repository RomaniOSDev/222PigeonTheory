import Foundation

enum AppLinks {
    case privacyPolicy
    case termsOfUse

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://pigeon222theory.site/privacy/260"
        case .termsOfUse:
            return "https://pigeon222theory.site/terms/260"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }
}
