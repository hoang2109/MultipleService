//
//  ServiceB.swift
//  MultipleService
//
//  Created by Hoang Nguyen on 19/12/21.
//

import Foundation

protocol ServiceB {
    typealias Result = Swift.Result<String, Error>
    
    func loadServiceB(completion: @escaping (Result) -> Void)
}
