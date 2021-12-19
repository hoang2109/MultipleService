//
//  MainService.swift
//  MultipleService
//
//  Created by Hoang Nguyen on 19/12/21.
//

import Foundation

struct MainData: Equatable {
    let dataA: String
    let dataB: String
    let dataC: String
}

protocol MainService {
    typealias Result = Swift.Result<MainData, Error>
    
    func load(completion: @escaping (Result) -> Void)
}
