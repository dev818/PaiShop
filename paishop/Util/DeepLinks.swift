
import Foundation

/*
//Example - paishop://store/36
struct SelectStoreDeepLink: DeepLink {
    static let template = DeepLinkTemplate()
        .term("store")
        .int(named: "index")
    
    init(values: DeepLinkValues) {
        let index = values.path["index"] as! Int
        storeIndex = Int64(index)
    }
    
    let storeIndex: Int64
}

//Example - paishop://product/490
struct SelectProductDeepLink: DeepLink {
    static let template = DeepLinkTemplate()
        .term("product")
        .int(named: "index")

    init(values: DeepLinkValues) {
        let index = values.path["index"] as! Int
        productIndex = Int64(index)
    }
    
    let productIndex: Int64
}
*/


//Example - paishop://share?store=36
struct SelectStoreDeepLink: DeepLink {
    static let template = DeepLinkTemplate()
        .term("share")
        .queryStringParameters([
            .requiredInt(named: "store")
            ])
    
    init(values: DeepLinkValues) {
        let index = values.query["store"] as! Int
        storeIndex = Int64(index)
    }
    
    let storeIndex: Int64
}

//Example - paishop://share?product=490
struct SelectProductDeepLink: DeepLink {
    static let template = DeepLinkTemplate()
        .term("share")
        .queryStringParameters([
            .requiredInt(named: "product")
            ])
    
    init(values: DeepLinkValues) {
        let index = values.query["product"] as! Int
        productIndex = Int64(index)
    }
    
    let productIndex: Int64
}



