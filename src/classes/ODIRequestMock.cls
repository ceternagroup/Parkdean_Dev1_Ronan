/*
 * @class ODIRequestMock
 * @desc - Used to mock the callback from ODI when a request is given.
 */
global class ODIRequestMock implements HttpCalloutMock {
    
  // return basic response
  global HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
      res.setBody('{"example":"test", "Errors": [], "NewSaleId": 10, "data": [], "Ancillaries": [{"PriceTypeEnum": 1, "PriceTypeDescription": "Test", "Mandatory": true, "Options": [{"PriceDefaultDesc": "Test", "PriceDefaultId": 1}]}]}');
    res.setStatusCode(200);
    return res;
  }
    
}