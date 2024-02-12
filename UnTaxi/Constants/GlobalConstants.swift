//
//  GlobalConstants.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/4/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation

struct GlobalConstants {
    static var bundleId = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
    static var appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "0.0"
    static var enviroment: String = "prod"
    static var serverDomain = bundleId == "com.xoait.UnTaxi" ? "xoaserver" : "xoait"
    static var urlServer: String = enviroment == "dev" ? "testing-untaxi.xoaserver.com" : "\(serverName).\(serverDomain).com"
    static var serverName: String {
        switch bundleId {
        case "com.xoait.UnTaxi":
            return "untaxi"
        case "com.xoait.condorcar":
            return "condorcar"
        case "com.xoait.logisticfastcar":
            return "logistic"
        case "com.donelkys.VipCar":
            return "vipcar"
        case "com.donelkys.AndyTaxi":
            return "andytaxi"
        case "com.xoait.Jipicar":
            return "jipicar"
        case "com.xoait.Jipitaxi":
            return "jipitaxi"
        case "com.xoait.OrientExpress":
            return "orientexpress"
        case "com.donelkys.Conaitor":
            return "conaitor"
        case "www.xoait.llamadafacil":
            return "llamadafacil"
        case "com.xoait.ellasdrive":
            return "ellasdrive"
        case "com.xoait.9deabril":
            return "9deabril"
        case "com.xoait.taxisgap":
            return "gap"
        case "com.donelkys.RuedaCar":
            return "ruedacar"
        case "com.xoait.AutoAmigo":
            return "autoamigo"
        default:
            return "testing-untaxi.xoaserver.com"
        }
    }
    static var urlHost: String = "https://\(urlServer)"//premium.xoait.com" //testing-untaxi.xoaserver.com
    static var socketurlHost: String = "https://client-\(urlServer)" //premium.xoait.com"
    static var paymentsUrl = "https://pay-\(urlServer)"
    static var paymentsUrlTesting = "https://pay-testing-untaxi.xoaserver.com"
    
    static var apiLoginUrl: String = "\(urlHost)/auth/client-login"
    static var passRecoverUrl: String = "\(urlHost)/recover-password"
    static var createPassUrl: String = "\(urlHost)/verify"
    static var passChangeUrl: String = "\(urlHost)/change-password"
    static var updateProfileUrl: String = "\(urlHost)/profile"
    static var registerUrl: String = "\(urlHost)/register"
    static var newRegisterUrl: String = "\(urlHost)/register-test"
    static var removeClient: String = "\(urlHost)/removeclient"
    static var subiraudioUrl: String = "\(urlHost)/voz"
    static var searchAddressUrl: String = "https://geosecure.xoaserver.com/api/?q=" //https://geosecure.xoaserver.com/api/?q=el%20dorado,Ecuador&limit=10&lon=-79.89725013269098&lat=-2.1363502421557943
    static var searchReverseAddressUrl: String = "https://geosecure.xoaserver.com/reverse?"
    
    static var listCardsUrl: String = "\(paymentsUrl)/card"
    static var addCardsUrl: String = "\(paymentsUrl)/card-add?token="
    static var removeCardsUrl: String = "\(paymentsUrl)/card"
    
    
    static var apiUser: String = "oinergb@xoait.com"
    static var apiPassword: String = "kmbz2vCVKzHLNChd"
    
    static var serverData = "173.249.32.181:6027"
    
    static var appNumberId: String {
        switch bundleId{
        case "com.xoait.UnTaxi":
            return "1149206387"
        case "com.xoait.condorcar":
            return "1598743783"
        case "com.xoait.logisticfastcar":
            return "1602099094"
        case "com.donelkys.VipCar":
            return "1493881639"
        case "com.donelkys.AndyTaxi":
            return "1453297748"
        case "com.xoait.Jipicar":
            return "1234014455"
        case "com.xoait.Jipitaxi":
            return "1449425062"
        case "com.xoait.OrientExpress":
            return "1432206841"
        case "com.donelkys.Conaitor":
            return "1391455068"
        case "com.xoait.llamadafacil":
            return "1619546373"
        case "com.xoait.ellasdrive":
            return "1629245831"
        case "com.xoait.9deabril":
            return "1634957284"
        case "com.xoait.taxisgap":
            return "1642066736"
        case "com.donelkys.RuedaCar":
            return "1454338686"
        case "com.xoait.AutoAmigo":
            return "1563504584"
        default:
            return "1149206387"
        }
    }
    
    static var storeInfoURL: String = "http://itunes.apple.com/lookup?bundleId=\(bundleId)"
    
    static var itunesURL: String {
        return "itms-apps://itunes.apple.com/us/app/apple-store/id\(appNumberId)?mt=8"
    }
    
    //    static var storeInfoURL: String = "http://itunes.apple.com/lookup?bundleId=com.xoait.UnTaxi"
    //    static var itunesURL: String = "itms-apps://itunes.apple.com/us/app/apple-store/id1149206387?mt=8"
    //
    //    static var mapBoxToken = "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2tha2h0M2piMG54ajJ5bW42Nmh3ODVxZyJ9.l9q-_04bUOhy7Gnwdfdx5g"
    static var mapBoxToken: String {
        switch bundleId {
        case "com.xoait.UnTaxi":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2tha2h0M2piMG54ajJ5bW42Nmh3ODVxZyJ9.l9q-_04bUOhy7Gnwdfdx5g"
        case "com.xoait.condorcar":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2t3aWpmNTRvMThudDJvb3p6djg0ZWh5dyJ9.MOPaJtWmIK2vhGe9YWbk6g"
        case "com.xoait.logisticfastcar":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2t4bW8xZXhrNDJvOTJvb2NmOTA3bnlmNCJ9.wbBeow7LD539M5A4Ws133A"
        case "com.donelkys.VipCar":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2t5Nm4xNTdhMHg2NjJvcGZibTA4NWZ4ZSJ9.Lb7H-B2kcZFgL8y7tJl2-A"
        case "com.donelkys.AndyTaxi":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2wwbnlpd2dtMWtuMjNqbWd2enpjdTJxcyJ9.b7aI4EiuoI4LZ34tx1luug"
        case "com.xoait.Jipicar":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2wxOGRnemV1MGJzNjNqcW40Y2JwMGJiMyJ9.WzV1U80iGEcXKQKE-hwwZw"
        case "com.xoait.Jipitaxi":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2wxY3BhYzZoMDB0aDNjbnViM3gybm1kcyJ9.HRoEGHzXLlMzghQSALHBQQ"
        case "com.xoait.OrientExpress":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2tyNTJ1N2NqMXd6ZjJxbGQ1Y2o1cTBwYiJ9.1g_kSx6O5as-2EDgNimi0Q"
        case "com.donelkys.Conaitor":
            return "sk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2ttN3V0cXN2MTFxZjJucGJzbHRzMzVyZCJ9.Dt6GBrNQiHY9vp1CUXXaEA"
        case "com.xoait.ellasdrive":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2w0YWNyY3FnMWIzbzNibXJjOGg2N3htbCJ9.NsGz8YYJTrVDAyqEHHL68Q"
        case "com.xoait.9deabril":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2w1bng0cmgxMGFsNDNlbWt6MzVxY20xeiJ9.PbQ67C9hsd6KkCSIkokLMw"
        case "com.xoait.taxisgap":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2w3YzBkMmVhMHAzODN3cnZ5b29saDVqYyJ9.W2m5W323X_v6Ys7jDL_oUQ"
        case "com.donelkys.RuedaCar":
            return "sk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2ttbWo4MG94MGh2NTJ3bjNmOWZ0M3VuMSJ9.2V8KcgIcOqEkMXAZ9eOnkA"
        case "com.xoait.AutoAmigo":
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2tubHRhMmwxMGtscjJ2bnloMm9wOWFydyJ9.TZjHwLdkwB4-qRN555PFkg"
        default:
            return "pk.eyJ1IjoiZG9uZWxreXMiLCJhIjoiY2t1eXc3NGprMmJ0MzJwbnlrY2wzZndkNSJ9.M99SzZUpM8rQrPDsKneeVQ"
        }
    }
    
    static var registerValidationIsAnable: Bool {
        switch bundleId {
        case "com.xoait.UnTaxi":
            return true
        default:
            return false
        }
    }
    //    static var googleAdsID = "ca-app-pub-1778988557303127/2416922071"
    
}

struct CustomAdsConstants {
    static var itunesBriceURL = "itms://itunes.apple.com/us/app/apple-store/id1290022053?mt=8"
}

struct GoogleAdsConstant {
    
    static let bundleId: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
    
    static var appBannerID: String {
        //let bundleId: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
        switch bundleId {
        case "com.xoait.UnTaxi":
            return "ca-app-pub-1778988557303127/2416922071"
        case "com.xoait.condorcar":
            return ""
        case "com.xoait.logisticfastcar":
            return ""
        case "com.donelkys.VipCar":
            return "ca-app-pub-1778988557303127/5412891786"
        case "com.donelkys.AndyTaxi":
            return "ca-app-pub-1778988557303127/9751076636"
        case "com.xoait.Jipicar":
            return ""
        case "com.xoait.Jipitaxi":
            return ""
        case "com.xoait.OrientExpress":
            return "ca-app-pub-1778988557303127/3696623966"
        case "com.donelkys.Conaitor":
            return "ca-app-pub-1778988557303127/5963556124"
        case "www.xoait.llamadafacil":
            return "ca-app-pub-1778988557303127/7218810544"
        case "com.xoait.ellasdrive":
            return ""
        case "com.xoait.9deabril":
            return "ca-app-pub-1778988557303127/2833607311"
        case "com.xoait.taxisgap":
            return ""
        case "com.donelkys.RuedaCar":
            return "ca-app-pub-1778988557303127/6607865054"
        case "com.xoait.AutoAmigo":
            return "ca-app-pub-1778988557303127/2626310486"
        default:
            return ""
        }
    }
    
    static var appLaunchBannerID: String {
        //let bundleId: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
        switch bundleId {
        case "com.xoait.UnTaxi":
            return "ca-app-pub-1778988557303127/4672710000"
        case "com.xoait.condorcar":
            return ""
        case "com.xoait.logisticfastcar":
            return ""
        case "com.donelkys.VipCar":
            return ""
        case "com.donelkys.AndyTaxi":
            return ""
        case "com.xoait.Jipicar":
            return ""
        case "com.xoait.Jipitaxi":
            return ""
        case "com.xoait.OrientExpress":
            return "ca-app-pub-1778988557303127/1739973643"
        case "com.donelkys.Conaitor":
            return ""
        case "www.xoait.llamadafacil":
            return ""
        case "com.xoait.ellasdrive":
            return ""
        case "com.xoait.9deabril":
            return ""
        case "com.xoait.taxisgap":
            return ""
        case "com.donelkys.RuedaCar":
            return ""
        case "com.xoait.AutoAmigo":
            return "ca-app-pub-1778988557303127/8987429343"
        default:
            return ""
        }
    }
}
