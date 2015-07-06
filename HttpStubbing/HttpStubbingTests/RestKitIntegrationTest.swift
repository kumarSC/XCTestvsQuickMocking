import Quick
import Nimble
import Nocilla
import SwiftyJSON

@testable
import ATRestKit

class RestKitIntegrationTest: QuickSpec {

    override func spec() {

        beforeSuite {LSNocilla.sharedInstance().start()}
        afterSuite {LSNocilla.sharedInstance().stop()}
        afterEach{LSNocilla.sharedInstance().clearStubs()}

        describe("Rest Kit") {
            context("Service Call") {
                it("makes a successful call") {
                    var successfulJSON : JSON!
                    let Data = TestHelper()
                    //Get the corresponding response from the data file
                    successfulJSON = Data.getJSONFromFile("MockResponse/getIssueSuccesfulResponse")
                    guard let url = NSURL(string:"http://jira.mobile.test/jira/rest/api/2/issue/") else { fail("Wrong URL"); return }
                    let provider = RKProvider(endPointUrl: url, authenticationHeader: ["Authorization":"Basic YWRtaW46YWRtaW4="])
                    //Stub http request with nocilla
                    stubRequest("GET","http://jira.mobile.test/jira/rest/api/2/issue/REST-2").andReturn(200).withBody("\(successfulJSON)")
                    let request = provider.get("REST-2", parameters: nil)
                    waitUntil(timeout: 10) {
                        done in
                        provider.handleResponse(request, complete:
                            Response<[String:AnyObject]>(
                                success: { (headerResponse, bodyResponse) -> () in
                                    var response = JSON(bodyResponse!)
                                    expect(200).to(equal(headerResponse.statusCode))
                                    expect(successfulJSON["key"].stringValue).to(equal(response["key"].stringValue))
                                    expect(successfulJSON["id"].stringValue).to(equal(response["id"].stringValue))
                                    done()
                                },
                                failure: { (error) -> () in
                                    fail("Service call failed")
                                    done()
                            })
                        )
                    }
                }

                it("calls an invalid URL") {
                    var invalidurlJSON : JSON!
                    let Data = TestHelper()
                    invalidurlJSON = Data.getJSONFromFile("MockResponse/IssueDoesNotExist404")
                    guard let url = NSURL(string:"https://sushant.jira-dev.test/rest/api/2/issue/NoSuchIssueId") else { fail("Wrong URL"); return }
                    let provider = RKProvider(endPointUrl: url, authenticationHeader: ["Authorization":"Basic YWRtaW46YWRtaW4="])
                    //Stub http request with nocilla
                    stubRequest("GET","https://sushant.jira-dev.test/rest/api/2/issue/NoSuchIssueId/INVALID").andReturn(404).withBody("\(invalidurlJSON)")
                    let request = provider.get("INVALID", parameters: nil)
                    waitUntil(timeout: 10) {
                        done in
                        provider.handleResponse(request, complete:
                            Response<[String:AnyObject]>(
                                success: { (headerResponse, bodyResponse) -> () in
                                    fail("Unexpected request succeeded")
                                },
                                failure: { (request, responseHeader, responseBody, error) -> () in
                                    expect(404).to(equal(responseHeader.statusCode))
                                    print(error?.localizedDescription)
                                    done()
                            })
                        )
                    }
                }

                it("receives an invalid response data") {
                    var htmlContent : NSData!
                    let Data = TestHelper()
                    htmlContent = Data.getHTMLFromFile("MockResponse/IssueMethodNotAllowed405")
                    guard let url = NSURL(string:"https://sushant.jira-dev.test/rest/api/2/issue/NoSuchIssueId/") else { fail("Wrong URL"); return }
                    let provider = RKProvider(endPointUrl: url, authenticationHeader: ["Authorization":"Basic YWRtaW46YWRtaW4="])
                    //Stub http request with nocilla for html response
                    stubRequest("GET","https://sushant.jira-dev.test/rest/api/2/issue/NoSuchIssueId/INVALID").andReturn(405).withHeaders(["Content-Type": "text/html","Authorization": "Basic YWRtaW46YWRtaW"]).withBody("\(htmlContent)")
                    let request = provider.get("INVALID", parameters: nil)
                    waitUntil(timeout: 10) {
                        done in
                        provider.handleResponse(request, complete:
                            Response<[String:AnyObject]>(
                                success: { (headerResponse, bodyResponse) -> () in
                                    fail("Unexpected request succeeded")
                                },
                                failure: { (request, responseHeader, responseBody, error) -> () in
                                    expect(405).to(equal(responseHeader.statusCode))
                                    //Raise error for invalid data in response
                                    print(error?.localizedDescription)
                                    done()
                            })
                        )
                    }
                }

                it("receives a response body as an array") {
                    let arrResponse:Array = [["created_at":"2015-04-02T23:07:32Z","id":1,"password_digest":"$2a$10$kTITRarwKawgabFVDJMJUO/qxNJQD7YawClND.Hp0KjPTLlZfo3oy","updated_at":"2013-04-02T23:07:32Z","username":"sushant"]]
                    guard let url = NSURL(string:"https://sushant.jira-dev.test/rest/api/2/issue") else { fail("Wrong URL"); return }
                    let provider = RKProvider(endPointUrl: url, authenticationHeader: ["Authorization":""])
                    //Stub http request with nocilla
                    stubRequest("GET","https://sushant.jira-dev.test/rest/api/2/issue/arrayItem").andReturn(200).withBody("[{\"created_at\":\"2015-04-02T23:07:32Z\",\"id\":1,\"password_digest\":\"$2a$10$kTITRarwKawgabFVDJMJUO/qxNJQD7YawClND.Hp0KjPTLlZfo3oy\",\"updated_at\":\"2013-04-02T23:07:32Z\",\"username\":\"sushant\"}]")
                    let request = provider.get("arrayItem", parameters: nil)
                    waitUntil(timeout: 10) {
                        done in
                        provider.handleResponse(request, complete:
                            Response<[AnyObject]>(
                                success: { (headerResponse, bodyResponse) -> () in
                                    if let body = bodyResponse {
                                        expect(body).to(contain(arrResponse[0]))
                                    }
                                    expect(headerResponse.statusCode).to(equal(200))
                                    done()
                                },
                                failure: { (_,header,_,error) -> () in
                                    fail("Failed to receive an array response")
                                    done()
                            })
                        )
                    }
                }
            }}
    }
}
