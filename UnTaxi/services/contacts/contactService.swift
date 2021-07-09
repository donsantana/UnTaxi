//
//  contactService.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/24/21.
//  Copyright © 2021 Done Santana. All rights reserved.
//

import Foundation
import Contacts

struct FetchedContact {
  var firstName: String
  var lastName: String
  var telephone: String
  
  init(firstName: String, lastName: String, telephone: String) {
    self.firstName = firstName
    self.lastName = lastName
    self.telephone = telephone.replacingOccurrences(of: "+593 ", with: "0")
  }
  func fullName()->String{
    return "\(firstName) \(lastName)"
  }
  
}


class ContactService {
  var contacts: [FetchedContact] = []
  
  init() {
    self.fetchContacts()
  }
  
  private func fetchContacts() {
      // 1.
      let store = CNContactStore()
    store.requestAccess(for: .contacts) { [self] (granted, error) in
          if let error = error {
              print("failed to request access", error)
              return
          }
          if granted {
              // 2.
              let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
              let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
              do {
                  // 3.
               
                  try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                    if contact.givenName != ""{
                      self.contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: contact.phoneNumbers.first?.value.stringValue ?? ""))
                    }
                  })
              } catch let error {
                  print("Failed to enumerate contact", error)
              }
            self.contacts.sort(by: {$0.firstName < $1.firstName})
          } else {
              print("access denied")
          }
      }
  }
  
}
