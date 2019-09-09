/*
 * @class ODIRequest
 * @desc - Sends a log to ODI, used before and after a request is made
 */
public class ODILogger {
    
  /*
   * @method sendLog()
   * @desc - General log sending function, sends a log with the given method and text
   * 
   * @param {String} method - the name of the function that called the logger
   * @param {String} text - the message to send
   * 
   * @return null
   */
  public static void sendLog(String method, String text) {
    Log log = createLog(method, text);
    String body = JSON.serialize(log);
    Http h = new Http();
	HttpRequest req = new HttpRequest();
	req.setEndpoint('http://81.174.155.71:57240/api/testbed/trace');
    req.setHeader('Authorization', 'Basic c2FsZXNmb3JjZWFwaTppcGFlY3JvZnNlbGFzRDE3MTVFQjU=');
    req.setHeader('Content-Type', 'application/json');
    req.setMethod('POST');
    req.setBody(body);
    HttpResponse res = h.send(req);
    System.debug('ODI Logger: ' + res.getBody());
  }
    
  /*
   * @method createLog()
   * @desc - Creates a new Log to send
   * 
   * @param {String} method - the name of the function that called the logger
   * @param {String} text - the message to send
   * 
   * @return {Log} - returns a new Log object
   */
  @TestVisible
  private static Log createLog(String method, String text) {
    Log log = new Log();
    log.id = 0;
    log.source = 'SFDC';
    log.method = method;
    log.text = text;
    log.data = new Map<String, String>();
    return log;
  }
    
  /*
   * @class Log()
   * @desc - Used to send a log to ODI
   * 
   * @attribute {Integer} id - unused currently
   * @attribute {String} source - always 'SFDC'
   * @attribute {String} method - used to set the apex method that called the logger
   * @attribute {String} text - the message to send
   * @attribute {Map<String, String>} data - unused currently
   */
  public class Log {
    public Integer id;
    public String source;
    public String method;
    public String text;
    public Map<String, String> data;
  }

}