//
//  ULID.swift
//  CloudVaultTests
//
//  Created by Gustavo Tavares on 31.05.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import XCTest
@testable import CloudVault

final class ULIDSwiftTests: XCTestCase {
    func length() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ULID.generateULID().count, 26)
    }

    static var allTests = [
        ("ULIDlength", length),
    ]
}
