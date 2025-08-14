
import Foundation

struct AdsControllerModel: Codable {
    let hasDiscount: Bool

    let adUrl: String

    let title: String

    let createdAt: Date

    let description: String

    let category: String

    let isNew: Bool

    let thumbUrl: String

    let isActive: Bool

    let priority: Int

    let updatedAt: Date

    init(adUrl: String, thumbUrl: String, title: String, description: String, isActive: Bool, createdAt: Date, updatedAt: Date, isNew: Bool, priority: Int, hasDiscount: Bool, category: String) {
        self.adUrl = adUrl
        self.thumbUrl = thumbUrl
        self.title = title
        self.description = description
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isNew = isNew
        self.priority = priority
        self.hasDiscount = hasDiscount
        self.category = category
    }

    enum CodingKeys: String, CodingKey {
        case adUrl = "ad_url"
        case thumbUrl = "thumb_url"
        case title
        case description
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isNew = "is_new"
        case priority
        case hasDiscount = "has_discount"
        case category
    }
}

struct AdsControllerListModel: Codable {
    let adList: [AdsControllerModel]

    enum CodingKeys: String, CodingKey {
        case adList = "ad_list"
    }
    
}
