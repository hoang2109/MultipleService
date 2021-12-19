//
//  MainLoadAdapter.swift
//  MultipleService
//
//  Created by Hoang Nguyen on 19/12/21.
//

import Foundation

class MainServiceAdapter: MainService {
    
    private let serviceA: ServiceA
    private let serviceB: ServiceB
    private let serviceC: ServiceC
    
    private let queue = DispatchQueue(label: "MainLoadAdapter.Queue")
    
    init(serviceA: ServiceA, serviceB: ServiceB, serviceC: ServiceC) {
        self.serviceA = serviceA
        self.serviceB = serviceB
        self.serviceC = serviceC
    }
    
    private struct PartialData {
        var dataA: String? {
            didSet {
                checkCompletion()
            }
        }
        var dataB: String? {
            didSet {
                checkCompletion()
            }
        }
        var dataC: String? {
            didSet {
                checkCompletion()
            }
        }
        var error: Error? {
            didSet {
                checkCompletion()
            }
        }
        
        var completion: ((MainService.Result) -> Void)?
        
        mutating func checkCompletion() {
            if let error = error {
                completion?(.failure(error))
                completion = nil
            } else if let dataA = dataA, let dataB = dataB, let dataC = dataC {
                completion?(.success(MainData(dataA: dataA, dataB: dataB, dataC: dataC)))
                completion = nil
            }
        }
    }
    
    func load(completion: @escaping (MainService.Result) -> Void) {
        var partialData = PartialData(completion: completion)
        
        serviceA.loadServiceA { [weak self] result in
            self?.queue.async {
                switch result {
                case .success(let data):
                    partialData.dataA = data
                case .failure(let error):
                    partialData.error = error
                }
            }
        }
        
        serviceB.loadServiceB { [weak self] result in
            self?.queue.async {
                switch result {
                case .success(let data):
                    partialData.dataB = data
                case .failure(let error):
                    partialData.error = error
                }
            }
        }
        
        serviceC.loadServiceC { [weak self] result in
            self?.queue.async {
                switch result {
                case .success(let data):
                    partialData.dataC = data
                case .failure(let error):
                    partialData.error = error
                }
            }
        }
    }
}
