//
//  RepositoryFile.swift
//  CloudVault
//
//  Created by Gustavo Tavares on 08.06.20.
//  Copyright © 2020 Gustavo Tavares. All rights reserved.
//

import Foundation
public class RepositoryFile {
    
    let url: URL
    private var _data: Data?
    
    init(url: URL) {
        self.url = url
        self._data = nil
    }

    init(url: URL, data: Data?) {
        self.url = url
        self._data = data
    }

    var data: Data? {
        
        if self._data != nil { return self._data }       
        self._data = try? Data(contentsOf: url)
        return self._data
        
    }
    
}

extension RepositoryFile: Identifiable, CustomStringConvertible {
    public var id: String { self.url.absoluteString }
    public var description: String { self.url.absoluteString }
}

