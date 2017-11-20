//
//  PrimeEngine.swift
//  primeFinderApp
//
//  Created by Yasin TURKOGLU on 11.10.2017.
//  Copyright © 2017 Yasin TURKOGLU. All rights reserved.
//

import UIKit

private struct IsThis {
    func aPrime(_ integer: UInt64) -> Bool {
        switch integer {
        case 0, 1:
            return false
        case 2, 3:
            return true
        default:
            for m in 2...UInt64(sqrt(Double(integer))) {
                if integer % m == 0 {
                    return false
                }
            }
            return true
        }
    }
}

private struct SortThePrimes: Sequence {
    var withRepetition: UInt64
    let startingFrom: UInt64
    let toUpwards:Bool
    func makeIterator() -> PrimesIterator {
        return PrimesIterator(self)
    }
}

private struct PrimesIterator: IteratorProtocol {
    var sortThePrimes: SortThePrimes
    let isThis: IsThis
    var increase:UInt64 = 1
    init(_ sortThePrimes: SortThePrimes) {
        self.sortThePrimes = sortThePrimes
        self.isThis = IsThis()
    }
    mutating func next() -> UInt64? {
        if self.sortThePrimes.withRepetition > 0 {
            if self.sortThePrimes.toUpwards {
                let testNumber = self.sortThePrimes.startingFrom + self.increase
                self.increase += 1
                if self.isThis.aPrime(testNumber) {
                    self.sortThePrimes.withRepetition -= 1
                    return testNumber
                } else {
                    return 0
                }
            } else {
                if self.sortThePrimes.startingFrom > self.increase {
                    let testNumber = self.sortThePrimes.startingFrom - self.increase
                    self.increase += 1
                    if self.isThis.aPrime(testNumber) {
                        self.sortThePrimes.withRepetition -= 1
                        return testNumber
                    } else {
                        return 0
                    }
                } else {
                    return nil
                }
            }
        } else {
            return nil
        }
    }
}



enum PrimeProcessType: Int {
    case PPTIsPrime = 0
    case PPTFindNext = 1
    case PPTFindPrev = 2
}

typealias CalculationResult = (processType: PrimeProcessType, startValue: UInt64, isStartValuePrime: Bool, calculatedValues: [UInt64])

protocol PrimeEngineDelegate:class {
    func primeEngine(updateUI completed: Int)
}

class PrimeEngine {

    weak var delegate:PrimeEngineDelegate!
    static let sharedInstance = PrimeEngine()
    private init() {}
    private var cancel:Bool = false
    private var inProgress:Bool = false

    func cancelCurrentOperation() {
        self.cancel = true
    }
    
    func isThereAnyOperationInProgress() -> Bool {
        return self.inProgress
    }
    
    func processWith(type: PrimeProcessType, start: UInt64, repetetions: UInt64, completionHandler:@escaping (CalculationResult!) -> Void) {
        if !self.inProgress {
            if type == .PPTIsPrime {
                self.inProgress = true
                DispatchQueue.global(qos: .utility).async {
                    var isStartValueAPrime:Bool = false
                    if IsThis().aPrime(start) {
                        isStartValueAPrime = true
                    }
                    DispatchQueue.main.async {
                        self.inProgress = false
                        completionHandler(CalculationResult(processType: type, startValue: start, isStartValuePrime: isStartValueAPrime, calculatedValues: []))
                    }
                }
            } else {
                self.inProgress = true
                DispatchQueue.global(qos: .utility).async {
                    var isStartValueAPrime:Bool = false
                    if IsThis().aPrime(start) {
                        isStartValueAPrime = true
                    }
                    var primes = [UInt64]()
                    var toUpwards:Bool = true
                    if type == .PPTFindPrev {
                        toUpwards = false
                    }
                    let sortedPrimes = SortThePrimes(withRepetition: repetetions, startingFrom: start, toUpwards: toUpwards)
                    var steps:Float = 0
                    var previousPrecentage:Int = 0
                    for prime in sortedPrimes {
                        if prime != 0 {
                            primes.append(prime)
                            steps += 1
                            let percentage = Int((steps * 100.0) / Float(repetetions))
                            if previousPrecentage != percentage {
                                previousPrecentage = percentage
                                if percentage % 10 == 0 {
                                    DispatchQueue.main.async {
                                        self.delegate.primeEngine(updateUI: percentage)
                                    }
                                }
                            }
                        }
                        if self.cancel {
                            self.cancel = false
                            break
                        }
                    }
                    DispatchQueue.main.async {
                        self.inProgress = false
                        let _ = delay(delay: 0.1, completionHandler: {
                            completionHandler(CalculationResult(processType: type, startValue: start, isStartValuePrime: isStartValueAPrime, calculatedValues: primes))
                        })
                    }
                }
            }
        } else {
            completionHandler(nil)
        }
    }
    
    
}
