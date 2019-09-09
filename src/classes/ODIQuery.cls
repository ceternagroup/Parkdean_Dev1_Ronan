@RestResource(urlMapping='/ODI/v1/query')
global class ODIQuery {
    
  @HttpPost
  global static String doPost() {
    RestRequest req = RestContext.request;
    String query = req.requestBody.toString();
    Response res = runQuery(query);
    return JSON.serialize(res);
  }
    
  public static Response runQuery(String query) {
   	Response res = new Response();
    List<sObject> records = new List<sObject>();
    String error = null;
    try {
      records = Database.query(query);
    } catch(QueryException err) {
      error = err.getMessage();
    }
    res.result = records;
    res.error = error;
   	return res;
  }
    
  public class Response {
    public List<sObject> result;
    public String error;
  }

}