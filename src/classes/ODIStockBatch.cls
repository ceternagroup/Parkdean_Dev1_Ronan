@RestResource(urlMapping='/ODI/v1/stock')
global without sharing class ODIStockBatch {
    
  global static List<Product2> productsUpserts = new List<Product2>();
  global static List<Product2> productsDelete = new List<Product2>();
    
  global static List<Stock_Image__c> imagesUpserts = new List<Stock_Image__c>();
    
  global static List<Price__c> pricesUpserts = new List<Price__c>();
    
  @HttpPost
  global static String doPost() {
    RestRequest req = RestContext.request;
    PostClass body = (PostClass) JSON.deserialize(req.requestBody.toString(), PostClass.class);
    Integer newSyncSetId = body.Control.NewSyncSetID;
    Integer syncDefinitionId = body.Control.SyncDefinitionID;
    for (Integer i = 0; i < body.Elements.size(); i++) {
      ElementsClass el = body.Elements[i];
      String action = el.IsDelete == 1 ? 'DELETE' : 'UPSERT';
      ODIMapper.StockClass p = el.Element;
      // process contents
      Product2 product = ODIMapper.mapProduct(p);
      product.Link_Id__c = String.valueOf(el.LinkID);
      if (action == 'DELETE') productsDelete.add(product);
      if (action == 'UPSERT') productsUpserts.add(product);
      String foreignKey = String.valueOf(p.VAN_ID);
      Product2 productFK = new Product2(Foreign_Key__c = foreignKey);
      List<String> typeDupe = new List<String>();
      if (action != 'DELETE') {
      for (Integer j = 0; j < p.Prices.size(); j++) {
        // sometimes they have duplicate standard or null prices?
        if (typeDupe.indexOf(p.Prices[j].PITCH_TYPE_DESC) == -1) {
          typeDupe.add(p.Prices[j].PITCH_TYPE_DESC);
          Price__c price = ODIMapper.mapPrice(p.Prices[j], foreignKey);
          price.Stock__r = productFK;
          if (action == 'UPSERT') pricesUpserts.add(price);
        }
      }  
      for (Integer j = 0; j < p.Images.size(); j++) {
        if (p.Images[j] != null) {
          Stock_Image__c image = ODIMapper.mapImage(p.Images[j], foreignKey);
          image.Product__r = productFK;
          if (action == 'UPSERT') imagesUpserts.add(image);
        }
      } 
      }
    }
    ODIHelper.Message result = new ODIHelper.Message();
    result.DataType = 'json';
    result.ReadWrites = new List<ODIHelper.ReadWrite>();
    List<ODIHelper.ReadWrite> runs = new List<ODIHelper.ReadWrite>();
    // handle products
    ODIHelper.ReadWrite productUpsertsRes = ODIHelper.handleRecords(productsUpserts, 'ExternalId', 'UPSERT', 'Product2', Product2.Fields.Foreign_Key__c, newSyncSetId, syncDefinitionId);
    // @TODO when we delete a product we need to delete it's price and images?
    ODIHelper.ReadWrite productDeletesRes = ODIHelper.handleRecords(productsDelete, 'ExternalId', 'DELETE', 'Product2', Product2.Fields.Foreign_Key__c, newSyncSetId, syncDefinitionId);
    // for price & stock we don't need to return IDs
    ODIHelper.ReadWrite imagesUpsertsRes = ODIHelper.handleRecords(imagesUpserts, 'Foreign_Key__c', 'UPSERT', 'Stock_Image__c', Stock_Image__c.Fields.Foreign_Key__c, newSyncSetId, syncDefinitionId);
    ODIHelper.ReadWrite pricesUpsertsRes = ODIHelper.handleRecords(pricesUpserts, 'Foreign_Key__c', 'UPSERT', 'Price__c', Price__c.Fields.Foreign_Key__c, newSyncSetId, syncDefinitionId);
    // add readwrites if not null
    if (productUpsertsRes != null) result.ReadWrites.add(productUpsertsRes);
    if (productDeletesRes != null) result.ReadWrites.add(productDeletesRes);
    if (imagesUpsertsRes != null) result.ReadWrites.add(imagesUpsertsRes);
    if (pricesUpsertsRes != null) result.ReadWrites.add(pricesUpsertsRes);
    return JSON.serialize(result);
  }
    
  public class PostClass {
    public ControlClass Control;
    public List<ElementsClass> Elements;
    public List<Object> Errors;
  }
    
  public class ControlClass {
    public Integer Changes;
    public Integer LastChangeSyncSetID;
    public Integer SyncDefinitionID;
    public String LinkSystem;
    public String Model;
    public Integer NewSyncSetID;
    public String OwnerSchemeFeed;
  }
    
  public class ElementsClass {
    public ODIMapper.StockClass Element;
    public Integer IsCreate;
    public Integer IsDelete;
    public Integer IsUpdate;
    public Integer LinkID;
    public Integer SyncItemID;
  }
    
}