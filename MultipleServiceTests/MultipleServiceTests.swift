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
    
    func loadServiceA(completion: @escaping (Result) -> Void)
}

protocol ServiceB {
    typealias Result = Swift.Result<String, Error>
    
    func loadServiceB(completion: @escaping (Result) -> Void)
}

protocol ServiceC {
    typealias Result = Swift.Result<String, Error>
    
    func loadServiceC(completion: @escaping (Result) -> Void)
}

struct MainData: Equatable {
    let dataA: String
    let dataB: String
    let dataC: String
}

protocol MainService {
    typealias Result = Swift.Result<MainData, Error>
    
    func load(completion: @escaping (Result) -> Void)
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
        
        serviceA.loadServiceA { result in
            switch result {
            case .success(let data):
                partialData.dataA = data
            case .failure(let error):
                partialData.error = error
            }
        }
        
        serviceB.loadServiceB { result in
            switch result {
            case .success(let data):
                partialData.dataB = data
            case .failure(let error):
                partialData.error = error
            }
        }
        
        serviceC.loadServiceC { result in
            switch result {
            case .success(let data):
                partialData.dataC = data
            case .failure(let error):
                partialData.error = error
            }
        }
    }
}


class MultipleServiceTests: XCTestCase {

    func test_canInit() {
        let (sut, _) = makeSUT()
        XCTAssertNotNil(sut)
    }
    
    func test_load_deliversSuccessMainDataOnAllServicesSuccess() {
        let (sut, loader) = makeSUT()
        
        let expected = MainData(dataA: "Data A", dataB: "Data B", dataC: "Data C")
        loader.resultAStub = .success(expected.dataA)
        loader.resultBStub = .success(expected.dataB)
        loader.resultCStub = .success(expected.dataC)
        
        let exp = expectation(description: "Waiting for completion")
        var captureResult: MainService.Result?
        sut.load { result in
            captureResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(try captureResult?.get(), expected)
    }
    
    func test_load_deliversErrorOnServiceALoadFailed() {
        let (sut, loader) = makeSUT()
        
        let expected = anyError()
        loader.resultAStub = .failure(anyError())
        
        let exp = expectation(description: "Waiting for completion")
        var captureResult: MainService.Result?
        sut.load { result in
            captureResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(captureResult?.error as NSError?, expected)
    }
    
    func test_load_deliversErrorOnServiceBLoadFailed() {
        
        let (sut, loader) = makeSUT()
        
        let expected = anyError()
        loader.resultBStub = .failure(anyError())
        
        let exp = expectation(description: "Waiting for completion")
        var captureResult: MainService.Result?
        sut.load { result in
            captureResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(captureResult?.error as NSError?, expected)
    }
    
    func test_load_deliversErrorOnServiceCLoadFailed() {
        
        let (sut, loader) = makeSUT()
        
        let expected = anyError()
        loader.resultCStub = .failure(anyError())
        
        let exp = expectation(description: "Waiting for completion")
        var captureResult: MainService.Result?
        sut.load { result in
            captureResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 0.1)
        
        XCTAssertEqual(captureResult?.error as NSError?, expected)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: MainLoadAdapter, loader: LoaderStub) {
        let loader = LoaderStub()
        let sut = MainLoadAdapter(serviceA: loader, serviceB: loader, serviceC: loader)
        
        return (sut, loader)
    }

    class LoaderStub: ServiceA, ServiceB, ServiceC {
        var resultAStub: ServiceA.Result = .success("")
        func loadServiceA(completion: @escaping (ServiceA.Result) -> Void) {
            completion(resultAStub)
        }
        
        var resultBStub: ServiceA.Result = .success("")
        func loadServiceB(completion: @escaping (ServiceB.Result) -> Void) {
            completion(resultBStub)
        }
        
        var resultCStub: ServiceA.Result = .success("")
        func loadServiceC(completion: @escaping (ServiceC.Result) -> Void) {
            completion(resultCStub)
        }
    }
    
    func anyError() -> NSError {
        NSError(domain: "Any Error", code: 0)
    }
}

private extension Result {
    var error: Failure? {
        switch self {
        case let .failure(error):
            return error
        case .success:
            return nil
        }
    }
}
