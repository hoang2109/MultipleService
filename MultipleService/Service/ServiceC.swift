//
//  ServiceC.swift
//  MultipleService
//
//  Created by Hoang Nguyen on 19/12/21.
//

import Foundation

protocol ServiceC {
    typealias Result = Swift.Result<String, Error>
    
    func loadServiceC(completion: @escaping (Result) -> Void)
}
