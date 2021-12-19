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
        serviceA.loadServiceA { resultA in
            if case let .failure(error) = resultA {
                return completion(.failure(error))
            }
            serviceB.loadServiceB { resultB in
                if case let .failure(error) = resultB {
                    return completion(.failure(error))
                }
                serviceC.loadServiceC { resultC in
                    if case let .failure(error) = resultC {
                        return completion(.failure(error))
                    }
                    let dataA = try! resultA.get()
                    let dataB = try! resultB.get()
                    let dataC = try! resultC.get()
                    
                    completion(.success(MainData(dataA: dataA, dataB: dataB, dataC: dataC)))
                }
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
