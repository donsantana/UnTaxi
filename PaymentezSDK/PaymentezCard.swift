//
//  File.swift
//  PaymentezSDKSample
//
//  Created by Gustavo Sotelo on 02/05/16.
//  Copyright © 2016 Paymentez. All rights reserved.
//

import Foundation


public enum PaymentezCardType: String
{
    case visa = "vi"
    case masterCard = "mc"
    case amex = "ax"
    case diners = "di"
    case discover = "dc"
    case jcb = "jb"
    case elo = "el"
    case credisensa = "cs"
    case solidario = "so"
    case exito = "ex"
    case alkosto = "ak"
    case notSupported = ""
}
let REGEX_AMEX = "^3[47][0-9]{5,}$"
let REGEX_VISA = "^4[0-9]{6,}$"
let REGEX_MASTERCARD = "^5[1-5][0-9]{5,}$"
let REGEX_DINERS = "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
let REGEX_DISCOVER = "^65[4-9][0-9]{13}|64[4-9][0-9]{13}|6011[0-9]{12}|(622(?:12[6-9]|1[3-9][0-9]|[2-8][0-9][0-9]|9[01][0-9]|92[0-5])[0-9]{10})$"
let REGEX_JCB = "^(?:2131|1800|35[0-9]{3})[0-9]{11}$"


public typealias ValidationCallback = (_ cardType: PaymentezCardType, _ cardImageUrl:String?, _ cvvLength:Int?, _ maskString:String?, _ showOtp:Bool) -> Void

@objcMembers open class PaymentezCard:NSObject
{
    
    open var status:String?
    open var transactionId:String?
    open var token:String?
    open var cardHolder:String?
    open var fiscalNumber: String?
    open var termination:String?
    open var isDefault:Bool = false
    open var expiryMonth:String?
    open var expiryYear:String?
    open var bin:String?
    open var nip:String?
    open var msg:String?
    open var cardType:PaymentezCardType = .notSupported
    internal var cardNumber:String? {
        didSet {
            if cardNumber != nil
            {
                self.termination = String(self.cardNumber!.suffix(4))
            }
        }
    }
    internal var cvc:String?
    open var type:String?
    {
        didSet
        {
            if self.type == "vi"
            {
                self.cardType = .visa
                
            }
            if self.type == "ax"
            {
                self.cardType = .amex
            }
            if self.type == "mc"
            {
                self.cardType = .masterCard
            }
            if self.type == "di"
            {
                self.cardType = .diners
            }
            if self.type == "al"
            {
                self.cardType = .alkosto
            }
            if self.type == "ex"
            {
                self.cardType = .exito
            }
        }
    }



    public static func createCard(cardHolder:String, cardNumber:String, expiryMonth:NSInteger, expiryYear:NSInteger, cvc:String) ->PaymentezCard?
    {
        let paymentezCard = PaymentezCard()
        if getTypeCard(cardNumber) == .notSupported
        {
            return nil
        }
        let today = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.month, .year], from: today)
        
        let todayMonth = components.month!
        let todayYear = components.year!
        
        if expiryYear < todayYear
        {
            return nil
        }
        if expiryMonth <= todayMonth && expiryYear == todayYear
        {
            return nil
        }
        
        
        paymentezCard.cardNumber = cardNumber
        paymentezCard.cardHolder = cardHolder
        paymentezCard.expiryMonth = "\(expiryMonth)"
        paymentezCard.expiryYear = "\(expiryYear)"
        paymentezCard.cvc = cvc
        return paymentezCard
        
    }
    
    
    static func validateExpDate(_ expDate:String) -> Bool
    {
        let today = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.month, .year], from: today)
        
        let todayMonth = components.month!
        let todayYear = components.year! - 2000
        
        let valExp = expDate.components(separatedBy: "/")
        if valExp.count > 1
        {
            let expYear = Int(valExp[1])!
            let expMonth = Int(valExp[0])!
            if expYear > todayYear
            {
                return true
            }
            else if expYear == todayYear && expMonth > todayMonth && expMonth <= 12
            {
                return true
            }
        }
        
        return false
    }
    
    public func getJSONString() ->String?
    {
        var json:Any? = nil
        do{
            json = try JSONSerialization.data(withJSONObject: self.getDict(), options: .prettyPrinted)
        }
        catch {
            
        }
        if json != nil
        {
            let theJSONText = String(data: json as! Data,
                                     encoding: .ascii)
            return theJSONText
        }
        return nil
        
    }
    
    public func getDict() -> NSDictionary
    {
        let dict = [
            "bin" : self.bin,
            "status": self.status,
            "token": self.token,
            "expiry_year": self.expiryYear,
            "expiry_month": self.expiryMonth,
            "transaction_reference": self.transactionId,
            "holder_name": self.cardHolder,
            "type": self.type,
            "number": self.termination,
            "message": ""
        ]
        return dict as NSDictionary
    }
    
    public func getCardTypeAsset() ->UIImage?
    {
        let bundle = Bundle(for: PaymentezCard.self)
        if cardType == PaymentezCardType.amex
        {
            return UIImage(named:"stp_card_amex", in: bundle, compatibleWith: nil)
        }
        else if cardType == PaymentezCardType.masterCard
        {
            return UIImage(named:"stp_card_mastercard", in: bundle, compatibleWith: nil)
            
        }
        else if cardType == PaymentezCardType.visa
        {
            return UIImage(named:"stp_card_visa", in: bundle, compatibleWith: nil)
        }
        else if cardType == PaymentezCardType.diners
        {
            return UIImage(named:"stp_card_diners", in: bundle, compatibleWith: nil)
        }
        else if cardType == PaymentezCardType.discover
        {
            return UIImage(named:"stp_card_discover", in: bundle, compatibleWith: nil)
        }
        else if cardType == PaymentezCardType.jcb
        {
            return UIImage(named:"stp_card_jcb", in: bundle, compatibleWith: nil)
        }
        else {
            return UIImage(named: "stp_card_unknown", in: bundle, compatibleWith: nil)
        }

    }
    
    public static func getTypeCard(_ cardNumber:String) -> PaymentezCardType
    {
        if cardNumber.count < 15  || cardNumber.count > 16
        {
            return PaymentezCardType.notSupported
        }
        let predicateAmex = NSPredicate(format: "SELF MATCHES %@", REGEX_AMEX)
        if predicateAmex.evaluate(with: cardNumber)
        {
            return PaymentezCardType.amex
        }
        let predicateVisa = NSPredicate(format: "SELF MATCHES %@", REGEX_VISA)
        if predicateVisa.evaluate(with: cardNumber)
        {
            return PaymentezCardType.visa
        }
        let predicateMC = NSPredicate(format: "SELF MATCHES %@", REGEX_MASTERCARD)
        if predicateMC.evaluate(with: cardNumber)
        {
            return PaymentezCardType.masterCard
        }
        let predicateDiners = NSPredicate(format: "SELF MATCHES %@", REGEX_DINERS)
        if predicateDiners.evaluate(with: cardNumber)
        {
            return PaymentezCardType.diners
        }
        let predicateDiscover = NSPredicate(format: "SELF MATCHES %@", REGEX_DISCOVER)
        if predicateDiscover.evaluate(with: cardNumber)
        {
            return PaymentezCardType.discover
        }
        let predicateJCB = NSPredicate(format: "SELF MATCHES %@", REGEX_JCB)
        if predicateJCB.evaluate(with: cardNumber)
        {
            return PaymentezCardType.jcb
        }
        return PaymentezCardType.notSupported
        
        
    }
    
    
    
    public static func validate(cardNumber:String, callback:@escaping ValidationCallback){
        
        PaymentezSDKClient.validateCard(cardNumber: cardNumber) { (data, err) in
            if err == nil{
                
                guard let dataDict = data else {
                    callback(.notSupported, nil, nil, nil, false)
                    print("Not supported")
                    return
                }
                guard let cardType = dataDict["card_type"] as? String else{
                    callback(.notSupported, nil, nil, nil, false)
                    print("Not card type")
                    return
                }
                let urlLogo = dataDict["url_logo_png"] as? String
                guard let cvvLength = dataDict["cvv_length"] as? Int else{
                    callback(.notSupported, nil, nil, nil, false)
                    print("Not cvv_length")
                    return
                }
                guard let maskString = dataDict["card_mask"] as? String else{
                    callback(.notSupported, nil, nil, nil, false)
                    print("Not mask")
                    return
                }
                let showOtp = dataDict["otp"] as? Bool ?? false
                callback(PaymentezCardType(rawValue: cardType) ?? PaymentezCardType(rawValue: "")! , urlLogo, cvvLength, maskString, showOtp)
                
            } else{
                callback(.notSupported, nil, nil, nil, false)
                
            }
        }
    }
    
    
    
    
}

@objcMembers open class PaymentezTransaction:NSObject
{
    open var authorizationCode:NSNumber?
    open var amount:NSNumber?
    open var paymentDate: Date?
    open var status:String?
    open var carrierCode:String?
    open var message:String?
    open var statusDetail:NSNumber?
    open var transactionId:String?
    open var carrierData:[String:Any]?
    
    static func parseTransaction(_ data:Any?) ->PaymentezTransaction
    {
        let data = data as! [String:Any]
        let trx = PaymentezTransaction()
        trx.amount = data["amount"] as? NSNumber
        trx.status = data["status"] as? String
        trx.statusDetail = data["status_detail"] as? Int as NSNumber?
        trx.transactionId = data["transaction_id"] as? String
        trx.carrierData = data["carrier_data"] as? [String:Any]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        if let paymentdate = (data["payment_date"] as? String)
        {
            trx.paymentDate = dateFormatter.date(from: paymentdate)
        }
        
        return trx
        
    }
    static func parseTransactionV2(_ data:Any?) ->PaymentezTransaction
    {
        let data = data as! [String:Any]
        let trx = PaymentezTransaction()
        trx.amount = data["amount"] as? NSNumber
        trx.status = data["status"] as? String
        trx.statusDetail = data["status_detail"] as? Int as NSNumber?
        trx.transactionId = data["id"] as? String
        trx.authorizationCode = data["authorization_code"] as? Int as NSNumber?
        trx.carrierCode = data["carrier_code"] as? String
        trx.message = data["message"] as? String
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        
        if let paymentdate = (data["payment_date"] as? String)
        {
            trx.paymentDate = dateFormatter.date(from: paymentdate)
        }
        
        return trx

    }
}
