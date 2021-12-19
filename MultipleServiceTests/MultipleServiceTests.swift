//
//  MultipleServiceTests.swift
//  MultipleServiceTests
//
//  Created by Hoang Nguyen on 19/12/21.
//

import XCTest
@testable import MultipleService

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
            DispatchQueue.global().async {
                completion(self.resultAStub)
            }
        }
        
        var resultBStub: ServiceA.Result = .success("")
        func loadServiceB(completion: @escaping (ServiceB.Result) -> Void) {
            DispatchQueue.global().async {
                completion(self.resultBStub)
            }
        }
        
        var resultCStub: ServiceA.Result = .success("")
        func loadServiceC(completion: @escaping (ServiceC.Result) -> Void) {
            DispatchQueue.global().async {
                completion(self.resultCStub)
            }
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
