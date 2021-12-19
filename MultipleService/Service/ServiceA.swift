//
//  ServiceA.swift
//  MultipleService
//
//  Created by Hoang Nguyen on 19/12/21.
//

import Foundation

protocol ServiceA {
    typealias Result = Swift.Result<String, Error>
    
    func loadServiceA(completion: @escaping (Result) -> Void)
}

