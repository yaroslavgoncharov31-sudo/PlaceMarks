import Foundation

struct WikipediResponse: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Int : Page]
}

struct Page: Codable, Comparable {
    let pageid: Int
    let title: String
    let terms: [String : [String]]?

    var description: String {
        terms?["description"]?.first ?? "No further information"
    }

    static func <(rhs: Page, lhs: Page) -> Bool {
        lhs.title < rhs.title
    }
}
