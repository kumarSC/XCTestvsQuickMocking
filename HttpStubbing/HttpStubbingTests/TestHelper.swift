import UIKit
import XCTest
import Quick
import Nimble
import Nocilla
import SwiftyJSON


public class TestHelper : XCTestCase {

    var json = JSON("")
    func getJSONFromFile (fileName: String) -> JSON {
        if let path = NSBundle(forClass: self.classForCoder).URLForResource(fileName, withExtension: "json") {
            if let data = NSData(contentsOfURL: path ) {
                json = JSON(data: data, error: nil)
            }
        }
        return json
    }

    func getHTMLFromFile (fileName: String) -> NSData {
        var data = NSData()
        if let path = NSBundle(forClass: self.classForCoder).URLForResource(fileName, withExtension: "html") {
            data = NSData(contentsOfURL: path )!
        }
        return data
    }
}

