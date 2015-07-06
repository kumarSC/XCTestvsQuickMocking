import UIKit
import XCTest
import Quick
import Nimble
import Nocilla
import SwiftyJSON



@testable
import ATRestKit

class NocillaTestCase: XCTestCase {

    var expectation:  XCTestExpectation!



    override  class func setUp() {
        super.setUp()
        LSNocilla.sharedInstance().start()
    }

    override  class func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().stop()
    }

    override  func setUp() {
        super.setUp()

    }

    override  func tearDown() {
        super.tearDown()
        LSNocilla.sharedInstance().clearStubs()
    }

    func test_Mock_Issue_Successful_Call () {

        var expectedJSON : JSON
        let jsonData = TestHelper()
        //Get the corresponding response from the data file
        expectedJSON = jsonData.getJSONFromFile("MockResponse/getIssueSuccesfulResponse")
        //Set the expectation for async operation to complete
        expectation = expectationWithDescription("Mocking successful response")
        guard let url = NSURL(string:"http://jira.mobile.test/jira/rest/api/2/issue/") else { fail("Wrong URL");
            return }
        let provider = RKProvider(endPointUrl: url, authenticationHeader: ["Authorization":"Basic YWRtaW46YWRtaW4="])
        //Stub http request with nocilla
        stubRequest("GET","http://jira.mobile.test/jira/rest/api/2/issue/REST-2").andReturn(200).withBody("\(expectedJSON)")
        let request = provider.get("REST-2", parameters: nil)
        provider.handleResponse(request, complete:
            Response<[String:AnyObject]>(
                success: { (headerResponse, bodyResponse) -> () in
                    var response = JSON(bodyResponse!)
                    XCTAssertEqual(200, headerResponse.statusCode)
                    XCTAssertEqual(expectedJSON["key"].stringValue, response["key"].stringValue)
                    XCTAssertEqual(expectedJSON["id"].stringValue, response["id"].stringValue)
                    self.expectation.fulfill()
                },
                failure: { (error) -> () in
                    XCTFail("Fake response failed for succesful call")
            })
        )
        //Wait for expectation to complete
        waitForExpectationsWithTimeout(10, handler: nil)

    }


    func test_Mock_Issue_Invalid_Url () {


        var json : JSON
        let jsonData = TestHelper()
        //Get the corresponding response from the data file
        json = jsonData.getJSONFromFile("MockResponse/IssueDoesNotExist404")
        //Set the expectation for async operation to complete
        expectation = expectationWithDescription("Mocking invalid url")
        guard let url = NSURL(string:"https://sushant.jira-dev.test/rest/api/2/issue/NoSuchIssueId") else { fail("Wrong URL");
            return }
        let provider = RKProvider(endPointUrl: url, authenticationHeader: ["Authorization":"Basic YWRtaW46YWRtaW4="])
        //Stub http request with nocilla
        stubRequest("GET","https://sushant.jira-dev.test/rest/api/2/issue/NoSuchIssueId/INVALID").andReturn(404).withBody("\(json)")
        let request = provider.get("INVALID", parameters: nil)

        provider.handleResponse(request, complete:
            Response<[String:AnyObject]>(
                success: { (headerResponse, bodyResponse) -> () in
                    XCTFail("Request succeeded unexpectedly")
                },
                failure: { (request, responseHeader, responseBody, error) -> () in
                    XCTAssertEqual(404, responseHeader.statusCode)
                    print(error?.localizedDescription)
                    self.expectation.fulfill()
            })
        )
        //Wait for expectation to complete
        waitForExpectationsWithTimeout(10) { (error)  -> Void in
            if let responseError = error  {
                XCTFail(responseError.localizedDescription)
            }
        }
    }

    func test_Mock_Issue_Html_Response () {


        var htmlContent : NSData
        let htmlData = TestHelper()
        //Get the corresponding response from the data file
        htmlContent = htmlData.getHTMLFromFile("MockResponse/IssueMethodNotAllowed405")
        //Set the expectation for async operation to complete
        expectation = expectationWithDescription("Mocking invalid url")
        guard let url = NSURL(string:"https://sushant.jira-dev.test/rest/api/2/issue/NoSuchIssueId") else { fail("Wrong URL");
            return }
        let provider = RKProvider(endPointUrl: url, authenticationHeader: ["Authorization":"Basic YWRtaW46YWRtaW4="])
        //Stub http request with nocilla
        stubRequest("GET","https://sushant.jira-dev.test/rest/api/2/issue/NoSuchIssueId/INVALID").andReturn(405).withHeaders(["Content-Type": "text/html"]).withBody("\(htmlContent)")
        let request = provider.get("INVALID", parameters: nil)
        provider.handleResponse(request, complete:
            Response<[String:AnyObject]>(
                success: { (headerResponse, bodyResponse) -> () in
                    XCTFail("Request succeeded unexpectedly")
                },
                failure: { (request, responseHeader, responseBody, error) -> () in
                    XCTAssertEqual(405, responseHeader.statusCode)
                    print(error?.localizedDescription)
                    self.expectation.fulfill()
            })
        )
        //Wait for expectation to complete
        waitForExpectationsWithTimeout(10) { (error)  -> Void in
            if let responseError = error  {
                XCTFail(responseError.localizedDescription)
            }
        }
    }
    
    
}




