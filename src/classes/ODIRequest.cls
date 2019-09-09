/*
 * @class ODIRequest
 * @desc - Sends a request to ODI, to retrieve data.
 *   Each request also sends a log to the ODI logging system for traceability.
 */
public class ODIRequest {
    
  /*
   * @method sendRequest()
   * @desc - General request sending function, sends the given parameters to ODI
   *   and returns the response.
   * 
   * @param {String} name - the name to give for the post, in the form 'saf.get.x'
   * @param {Map<String, Object>} params - the parameters ODI needs for this get request.
   * 
   * @return {String} - returns a JSON string in the ODI ReadWrite format.
   */
  public static String sendRequest(String name, Map<String, Object> params) {
    Post post = createPost(name, params);
    String body = JSON.serialize(post);
    System.debug(body);
    Http h = new Http();
	HttpRequest req = new HttpRequest();
	req.setEndpoint(Label.ODI_URL);
    req.setHeader('Authorization', Label.ODI_Auth);
    req.setTimeout(120000);
    req.setMethod('GET');
    req.setBody(body);
    System.debug('ODI Request: ' + body);
    HttpResponse res = h.send(req);
    String response = res.getBody();
    System.debug('ODI Response: ' + response);
    return response;
  }
    
  /*
   * @method sendFutureRequest()
   * @desc - Same as send request but we don't care about a result, used for future updates
   * 
   * @param {String} name - the name to give for the post, in the form 'saf.get.x'
   * @param {Map<String, Object>} params - the parameters ODI needs for this get request.
   * 
   * @return null
   */
  @Future(callout=true)
  public static void sendFutureRequest(String name, String body) {
    System.debug(body);
    Http h = new Http();
	HttpRequest req = new HttpRequest();
	req.setEndpoint(Label.ODI_URL);
    req.setHeader('Authorization', Label.ODI_Auth);
    req.setTimeout(120000);
    req.setMethod('GET');
    req.setBody(body);
    System.debug('ODI Future Request: ' + body);
    HttpResponse res = h.send(req);
    String response = res.getBody();
    System.debug('ODI Response: ' + response);
  }
    
  /*
   * @method sendPitchRequest()
   * @desc - Requests a set of pitches for a given van and park combination
   * 
   * @param {String} vanId - the ExternalId of the stock record
   * @param {String} parkId - the ExternalId of the stock's related park record
   * @param {String} expOccupancy - the expected occupancy from the quote
   * @param {String} accountId - the ExternalId of the quote's opportunity (wizard account)
   * 
   * @return {String} - returns a JSON string in the ODI ReadWrite format.
   */
  @RemoteAction
  public static String sendPitchRequest(String vanId, String parkId, String expOccupancy, String accountId) {
    Map<String, Object> req = new Map<String, Object>();
    req.put('VAN_ID', vanId);
    req.put('PARK_ID', parkId);
    req.put('EXPECTED_DT_OCCUPANCY', expOccupancy); // YYYY-MM-DD
    req.put('ACCOUNT_ID', null);
    return sendRequest('saf.get.pitches', req);
  }
    
  /*
   * @method sendPXRequest()
   * @desc - Requests the available PX units for a given year and make search
   * 
   * @param {String} modelYear - the year of the stock to look for
   * @param {String} modelMake - the make of the stock to look for
   * 
   * @return {String} - returns a JSON string in the ODI ReadWrite format.
   */
  @RemoteAction
  public static String sendPXRequest(String modelYear, String modelMake) {
    Map<String, Object> req = new Map<String, Object>();
    req.put('MANUFACTURER_DESC', modelMake);
    req.put('YEAR', Integer.valueOf(modelYear));
    return sendRequest('saf.get.pxunits', req);
  }

  /*
   * @method sendAncRequest()
   * @desc - Requests the ancillaries for a given user selection
   * 
   * @param {String} vanId - the ExternalId of the stock record
   * @param {String} saleType - the 'type' of Sale
   * @param {String} parkId - the ExternalId of the stock's related park record
   * @param {String} expOccupancy - the expected occupancy from the quote
   * @param {String} accountId - the ExternalId of the quote's opportunity (wizard account)
   * 
   * @return {String} - returns a JSON string in the ODI ReadWrite format.
   */
  @RemoteAction
  public static String sendAncRequest(String vanId, String saleType, String pitchId, String expOccupancy, String accountId, String ownerId, String pexVanId) {
    Map<String, Object> req = new Map<String, Object>();
    req.put('VanId', vanId);
    req.put('SaleTypeEnum', saleType);
    req.put('DestinationPitchId', pitchId);
    req.put('ExpectedDtOccupancy', expOccupancy);
    req.put('AccountId', accountId);
    req.put('OwnerId', ownerId);
    req.put('Pex1VanId', pexVanId);
    return sendRequest('saf.get.ancillaries', req);
  }
    
  /*
   * @method sendSLARequest()
   * @desc - Sends an SLA, built in the ODISLA class
   * 
   * @param {Map<String, Object>} sla - the sla with all needed wizard values
   * 
   * @return {String} - returns a JSON string in the ODI ReadWrite format.
   */
  public static String sendSLARequest(Map<String, Object> sla) {
    return sendRequest('saf.create.sale', sla);
  }
    
  /*
   * @method sendSLARequest()
   * @desc - Sends an account to be marked as a private seller
   * 
   * @param {String} wizardAccountId - wiz account to set
   * 
   * @return {String} - returns a JSON string in the ODI ReadWrite format.
   */
  public static String sendPrivateSeller(String wizardAccountId) { 
    Map<String, Object> req = new Map<String, Object>();
    req.put('ACCOUNT_ID', wizardAccountId);
    return sendRequest('saf.private.seller', req);
  }
    
  /*
   * @method createPost()
   * @desc - Create an post, passing in a name and the parameters to set
   * 
   * @param {String} name - the name to give for the post, in the form 'saf.get.x'
   * @param {Map<String, Object>} params - the parameters ODI needs for this get request.
   * 
   * @return {Post} - returns a Post object
   */
  public static Post createPost(String name, Map<String, Object> params) {
    Post post = new Post();
    post.DataType = 'json';
    List<Map<String, Object>> readWrites = new List<Map<String, Object>>();
    Map<String, Object> readWrite = new Map<String, Object>();
    readWrite.put('Name', name);
    readWrite.put('Parameters', params);
    readWrites.add(readWrite);
    post.ReadWrites = readWrites;
    return post;
  }
    
    
  /*
   * @class Post()
   * @desc - Used to send data to ODI
   * 
   * @attribute {String} DataType - always 'json'
   * @attribute {List<Map<String, Object>>} ReadWrites - stores the parameters as a single ReadWrite
   * 
   */
  public class Post {
    public String DataType;
    public List<Map<String, Object>> ReadWrites;
  }

}