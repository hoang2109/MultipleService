//
//  MultipleServiceTests.swift
//  MultipleServiceTests
//
//  Created by Hoang Nguyen on 19/12/21.
//

import XCTest
@testable import MultipleService


protocol ServiceA {
    typealias Result = Swift.Result<String, Error>
    
    func loadServiceA(completion: (Result) -> Void)
}

protocol ServiceB {
    typealias Result = Swift.Result<String, Error>
    
    func loadServiceB(completion: (Result) -> Void)
}

protocol ServiceC {
    typealias Result = Swift.Result<String, Error>
    
    func loadServiceC(completion: (Result) -> Void)
}

struct MainData: Equatable {
    let dataA: String
    let dataB: String
    let dataC: String
}

protocol MainService {
    typealias Result = Swift.Result<MainData, Error>
    
    func load(completion: (Result) -> Void)
}

class MainLoadAdapter: MainService {
    
    private let serviceA: ServiceA
    private let serviceB: ServiceB
    private let serviceC: ServiceC
    
    init(serviceA: ServiceA, serviceB: ServiceB, serviceC: ServiceC) {
        self.serviceA = serviceA
        self.serviceB = serviceB
        self.serviceC = serviceC
    }
    
    func load(completion: (MainService.Result) -> Void) {
        
    }
}


class MultipleServiceTests: XCTestCase {

    func test_canInit() {
        let loader = LoaderStub()
        let sut = MainLoadAdapter(serviceA: loader, serviceB: loader, serviceC: loader)
        XCTAssertNotNil(sut)
    }
    
    // MARK: - Helpers

    class LoaderStub: ServiceA, ServiceB, ServiceC {
        var resultAStub: ServiceA.Result = .success("")
        func loadServiceA(completion: (ServiceA.Result) -> Void) {
            completion(resultAStub)
        }
        
        var resultBStub: ServiceA.Result = .success("")
        func loadServiceB(completion: (ServiceB.Result) -> Void) {
            completion(resultBStub)
        }
        
        var resultCStub: ServiceA.Result = .success("")
        func loadServiceC(completion: (ServiceC.Result) -> Void) {
            completion(resultCStub)
        }
    }
}
