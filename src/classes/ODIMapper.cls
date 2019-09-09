/*
 * @class ODIMapper
 * @desc - This class handles ALL mapping from ODI -> SF and SF -> ODI
 */
public class ODIMapper {
    
  // helper methods
  private static String getString(Boolean value) {
    if (value == true) return 'Yes';
    if (value == false) return 'No';
    return null;
  }
  private static String getValue(Object value) {
    if (value == null) return null;
    return String.valueOf(value);
  }
  private static Date getDate(String value) {
    if (value == null) return null;
    if (value.indexOf('T') != -1) value = value.replace('T', ' ');
    return Date.valueOf(value); 
  }
  private static Time getTime(String value) {
    if (value == null || value.indexOf(':') == -1) return null;
    String hour = value.split(':')[0];
    String minute = value.split(':')[1];
    return Time.newInstance(Integer.valueOf(hour), Integer.valueOf(minute), 0, 0);
  }
    
  /* ================= *
   *                   *  
   *       STOCK       *
   *                   *
   * ================= */
  public class StockClass {
    public Boolean ACCESSIBLE_YN;
    public Boolean AVAILABLE_TO_ALL;
    public String Bedrooms;
    public String CH;
    public Boolean CH_YN;
    public Integer DAYS_ON_SALE;
    public String DG;
    public Boolean DG_YN;
    public Boolean FIXED_ASSET_YN;
    public Boolean LIEN_YN;
    public Decimal LENGTH;
    public Integer LETTING_CAT_ID;
    public String LETTING_LINK_ID;
    public String MAKE;
    public DateTime MANUFACTURE_DT;
    public String MODEL;
    public Boolean NEW_YN;
    public String NEWUSED;
    public Decimal NO_OF_BERTHS;
    public Integer NUMBER_BEDROOMS;
    public Integer PARK_ID; // ODI
    public String ParkID; // SF
    public String PARK_CODE;
    public String PARK_SHORT_DESC;
    public String PITCH_STATUS_CODE;
    public String PITCH_STATUS_DESC;
    public Integer PITCH_STATUS_ENUM;
    public Boolean RAMTECH_YN;
    public String RAMTECH_NO;
    public Boolean SEPERATE_WC_YN;
    public String SERIAL_NO;
    public String ServiceName;
    public Decimal SIV;
    public Integer STOCK_REQUEST_ID;
    public Boolean SUITABLE_FOR_RETAIL_YN;
    public Boolean TRADE_STOCK_YN;
    public Boolean TWIN_YN;
    public String VAN_COLOUR_DESC;
    public Integer VAN_ID;
    public Decimal VAN_PRICE_TOTAL;
    public String VAN_ORDER_REASON_DESC;
    public String VAN_SOURCE_DESC;
    public String VAN_STOCK_NO;
    public String VAN_TYPE_DESC;
    public Integer VAN_TYPE_ENUM;
    public Decimal WIDTH;
    public Decimal YEAR_MADE;
    public List<String> Images;
    public List<String> Features;
    public List<PriceClass> Prices;
    public PolicyClass Policy;
  }
  // StockClass -> Product2
  public static Product2 mapProduct(StockClass i) {
    Product2 p = new Product2();
    p.Foreign_Key__c = getValue(i.VAN_ID); // REQUIRED
    p.Accessible_Unit__c = getString(i.ACCESSIBLE_YN);
    p.Bedrooms__c = i.Bedrooms;
    p.Births__c = getValue(i.NO_OF_BERTHS);
    p.Central_Heating__c = i.CH_YN;
    p.Central_Heating_Yes_No__c = i.CH;
    p.Colour__c = i.VAN_COLOUR_DESC;
    p.CSN__c = i.VAN_STOCK_NO;
    p.Days_on_Sale__c = i.DAYS_ON_SALE;
    p.Double_Glazing__c = i.DG_YN;
    p.Double_Glazing_Yes_No__c = i.DG;
    p.ExternalId = getValue(i.VAN_ID);
    p.Features__c = i.Features == null ? null : String.join(i.Features, ', ');
    P.Holiday_Home_description__c = i.Features == null ? null : '• ' + String.join(i.Features, '\n • ');
    p.Fixed_Asset__c = getString(i.FIXED_ASSET_YN);
    p.IsActive = i.AVAILABLE_TO_ALL;
    p.IsNew__c = i.NEW_YN;
    p.Length__c = i.LENGTH;
    p.Letting_Cat_ID__c = getValue(i.LETTING_CAT_ID);
    p.Line_Van__c = getString(i.LIEN_YN);
    p.Manufacturer__c = i.MAKE;
    p.Model__c = i.MODEL;
    p.Model_Year__c =i.YEAR_MADE;
    p.Name = i.MAKE + ' ' + i.MODEL + ' ' + i.YEAR_MADE;
    p.New_or_Used__c = i.NEWUSED;
    p.Not_available_for_IPS__c = i.LETTING_LINK_ID == null ? true : false;
    p.Number_of_bedrooms__c = getValue(i.NUMBER_BEDROOMS);
    p.Park__c = i.ParkId;
    p.Pitch_Status_Code__c = i.PITCH_STATUS_CODE;
    p.Pitch_Status_Description__c = i.PITCH_STATUS_DESC;
    p.Pitch_Status_Enum__c = i.PITCH_STATUS_ENUM;
    p.Purchase_purpose__c = i.VAN_ORDER_REASON_DESC;
    p.Ramtech__c = getString(i.RAMTECH_YN);
    p.Ramtech_ID__c = i.RAMTECH_NO;
    p.Rental_Product__c = i.ServiceName;
    p.Seperate_WC__c = getString(i.SEPERATE_WC_YN);
    p.Serial_Number__c = i.SERIAL_NO;
    p.SIV__c = i.SIV;
    p.Suitable_For_Retail__c = getString(i.SUITABLE_FOR_RETAIL_YN);
    p.Source__c = i.VAN_SOURCE_DESC;
    p.Stock_Grade_New__c = i.LETTING_LINK_ID;
    p.Trade_Stock__c = getString(i.TRADE_STOCK_YN);
    p.Twin_Unit__c = getString(i.TWIN_YN);
    p.Unit_Type__c = i.VAN_TYPE_DESC;
    p.Width__c = i.WIDTH;
    p.YearOfManufacture__c = i.MANUFACTURE_DT == null ? null : i.MANUFACTURE_DT.year();
    // policy
    if (i.Policy != null) {
      PolicyClass pi = i.Policy;
      p.Finance_Allowed__c = pi.FinanceAllowed;
      p.Max_Length_of_Term_Allowed__c = pi.FinanceMaxTerm;
      p.Deposit_Minimum__c = pi.FinanceMinDeposit;
    }
    return p;
  }
    

  /* ================= *
   *                   *  
   *       PRICE       *
   *                   *
   * ================= */
  public class PriceClass {
    public Decimal ANCILLARIES_PRICE;
    public Decimal INSURANCE_PRICE;
    public String PITCH_TYPE_DESC;
    public String PITCH_ID;
    public Decimal STOCK_PRICE;
    public Decimal SITEFEE_PRICE;
    public Decimal TOTAL_PACKAGE_DISCOUNT;
    public Decimal TOTAL_PACKAGE_PRICE;
    public Boolean PRO_RATA;
  }
  // Price -> Price__c
  public static Price__c mapPrice(PriceClass i, String foreignKey) {
    Price__c p = new Price__c();
    p.Discount_Price__c = i.TOTAL_PACKAGE_DISCOUNT;
    p.Insurance_Price__c = i.INSURANCE_PRICE;
    p.Mandatory_Ancillary_Price__c = i.ANCILLARIES_PRICE;
    p.Pitch_Price__c = i.SITEFEE_PRICE;
    p.Pitch_Type__c = i.PITCH_TYPE_DESC;
    p.Total_Price__c = i.TOTAL_PACKAGE_PRICE;
    p.Unit_Price__c = i.STOCK_PRICE;
    p.Foreign_Key__c = foreignKey + '-' + i.PITCH_TYPE_DESC + '-' + i.PRO_RATA + '-' + i.PITCH_ID;
    return p;
  }

    
  /* ================= *
   *                   *  
   *       POLICY      *
   *                   *
   * ================= */
  public class PolicyClass {
    public Boolean FinanceAllowed;
    public Decimal FinanceMaxTerm;
    public Decimal FinanceMinDeposit;
  }

    
  /* ================= *
   *                   *  
   *    STOCK IMAGE    *
   *                   *
   * ================= */
  // Content -> Stock_Image__c
  public static Stock_Image__c mapImage(String imageURL, String foreignKey) {
    Stock_Image__c s = new Stock_Image__c();
    s.Image_URL__c = imageURL;
    s.Foreign_Key__c = foreignKey + '-' + imageURL;
    return s;
  }

    
  /* ================= *
   *                   *  
   *      PITCHES      *
   *                   *
   * ================= */
  public class PitchClass {
    public Integer PARK_ID;
    public Integer PITCH_ID;
    public String PITCH_NO;
    public String PITCH_DESC;
    public Integer PITCH_STATUS_ENUM;
    public String PITCH_STATUS_DESC;
    public Decimal SITE_FEE_FULL;
    public Decimal SITE_FEE_PRORATED;
    public Decimal DISCOUNT;
    public String PARK_CODE;
    public String PARK_DESC;
    public Integer AREA_ID;
    public String AREA_CODE;
    public String AREA_DESC;
    public Integer AREA_TYPE_ENUM;
    public String AREA_TYPE_DESC;
    public Decimal ZONE_ID;
    public String ZONE_CODE;
    public String ZONE_DESC;
    public String PAZP;
    public Integer BASE_TYPE_ENUM;
    public String BASE_TYPE_DESC;
    public Integer GAS_TYPE_ENUM;
    public Integer ELECTRIC_TYPE_ENUM;
    public Decimal LENGTH;
    public Decimal WIDTH;
    public Boolean FLOOD_RISK;
    public Boolean WATER_SEWER_YN;
    public Boolean TELEPHONE_YN;
    public Boolean CABLE_TV_YN;
    public Boolean PATIO_YN;
    public Boolean GARDEN_YN;
    public Boolean TWIN_YN;
    public Integer PITCH_TYPE_ENUM;
    public String PITCH_TYPE_DESC;
  }
  // PitchClass -> Line_Item__c
  public static Line_Item__c mapPitch(PitchClass i) {
    Line_Item__c l = new Line_Item__c();
    l.Area_Code__c = i.AREA_CODE;
    l.Area_Name__c = i.AREA_DESC;
    l.Area_Type__c = i.AREA_TYPE_DESC;
    l.Base_Type__c = i.BASE_TYPE_DESC;
    l.Cable_TV__c = i.CABLE_TV_YN;
    l.Discount__c = i.DISCOUNT;
    l.Electric_Type__c = getValue(i.ELECTRIC_TYPE_ENUM);
    l.Flood_Risk__c = i.FLOOD_RISK;
    l.Garden__c = i.GARDEN_YN;
    l.Gas_Type__c = getValue(i.GAS_TYPE_ENUM);
    l.Length__c = i.LENGTH;
    l.Patio__c = i.PATIO_YN;
    l.Pitch_Description__c = i.PITCH_DESC;
    l.Pitch_Id__c = getValue(i.PITCH_ID);
    l.Pitch_Number__c = i.PITCH_NO;
    l.Pitch_Status__c = i.PITCH_STATUS_DESC;
    l.Pitch_Type__c = i.PITCH_TYPE_DESC;
    l.Telephone_Line__c = i.TELEPHONE_YN;
    l.Twin_pitch__c = i.TWIN_YN;
    l.Sewer_Water_Connections__c = i.WATER_SEWER_YN;
    l.Width__c = i.WIDTH;
    l.Zone_Code__c = i.ZONE_CODE;
    l.Zone_Name__c = i.ZONE_DESC;
    return l;
  }
    
  /* ================= *
   *                   *  
   *    ANCILLARYS     *
   *                   *
   * ================= */
  public class AncillaryClass {
    public Integer PriceTypeEnum;
    public String PriceTypeDescription;
    public Integer PriceTypeOrdering;
    public Boolean Mandatory;
    public List<AncillaryOptionClass> Options;
  }
  // Ancillary -> Line_Item__c
  public static Line_Item__c mapAncillary(AncillaryClass i, String recordTypeId, String quoteId) {
    Line_Item__c l = new Line_Item__c();
    l.RecordTypeId = recordTypeId;
    l.Name = i.PriceTypeDescription;
    l.Quote__c = quoteId;
    l.Mandatory__c = i.Mandatory;
    l.Ancillary_Description__c = i.PriceTypeDescription;
    l.Price_Type__c = i.PriceTypeEnum;
    return l;
  }
  public class AncillaryOptionClass {
     public Integer PriceDefaultId;
     public String PriceDefaultDesc;
     public Integer PriceDefaultOrdering;
     public Decimal Price;
     public Decimal Discount;
  }
  // AncillaryOption -> Ancillary_Option__c
  public static Ancillary_Option__c mapAncillaryOption(AncillaryOptionClass i) {
    Ancillary_Option__c a = new Ancillary_Option__c();
    a.Name = i.PriceDefaultDesc;
    a.Price_Default_Id__c = i.PriceDefaultId;
    a.Price_Default_Description__c = i.PriceDefaultDesc;
    a.Price_Default_Ordering__c = i.PriceDefaultOrdering;
    a.Price__c = i.Price;
    a.Discount__c = i.Discount;
    return a;
  }
    
  /* ================= *
   *                   *  
   *        SLA        *
   *                   *
   * ================= */
  public class AncillaryAltClass {
     public String PriceTypeEnum;
     public String PriceDefaultId;
     public String Price;
  }
  // Quote, PersonAccount, Inbound_PX_unit__c AncillaryAltClass -> SLAClass
  public static Map<String, Object> mapSLA(Quote q, String vanId, String pitchId, List<Inbound_PX_unit__c> i, Account p, List<AncillaryAltClass> a) {
    Map<String, Object> sla = new Map<String, Object>();
    sla.put('DestinationPitchId', getValue(pitchId));
    sla.put('ExpectedDtOccupancy', getValue(q.Expected_handover_date__c));
    sla.put('VanId', getValue(vanId));
    sla.put('AccountId', getValue(q.Opportunity.Wizard_Account_Id__c));
    sla.put('OpportunityId', getValue(q.OpportunityId));
    sla.put('OwnerId', getValue(q.Opportunity.Owner_ID_External__c));
    sla.put('ParkId', getValue(q.Park__r.Park_ID__c));
    sla.put('VacantPitchId', null);
    sla.put('DueLaterDate', getValue(q.Cash_due_date__c));
    sla.put('SalesManCode', getValue(q.Wizard_User_ID__c));
    sla.put('ContactId', getValue(p.Id));
    // px values
    sla.put('Pex1VanId', i.size() > 0 ? getValue(i[0].Van_Id__c) : null);
    sla.put('Pex1SIV', i.size() > 0 ? getValue(i[0].Stand_In_Value__c) : null);
    sla.put('Pex1Discount', i.size() > 0 ? getValue(i[0].Write_Down__c) : null);
    sla.put('Pex1FinanceSettlement', i.size() > 0 ? getValue(i[0].Settlement__c) : null);
    sla.put('PEX1ManufacturerDesc', i.size() > 0 ? getValue(i[0].Make__c) : null);
    sla.put('PEX1ModelYear', i.size() > 0 ? getValue(i[0].Year__c) : null);
    sla.put('PEX1GGModelID', i.size() > 0 ? getValue(i[0].GGModelID__c) : null);
    sla.put('PEX1GGQualifyModelId', i.size() > 0 ? getValue(i[0].GGQualifyModelID__c) : null);
    sla.put('PEX1GGOModelID', i.size() > 0 ? getValue(i[0].GGOModelID__c) : null);
    sla.put('PEX_1_Create_New_Unit_YN',  getValue(q.PEX_1_Create_New_Unit_YN__c));
    sla.put('Pex2VanId', null);
    sla.put('Pex2SIV', null);
    sla.put('Pex2Discount', null);
    sla.put('Pex2FinanceSettlement', null);
    // ips
    sla.put('IPSToSale', getValue(q.IPS_to_sale2__c));
    sla.put('IPSToRent', getValue(q.IPS_to_rent2__c));
    sla.put('InitialDeposit', getValue(q.Cash_deposit_paid__c));
    sla.put('InitialDesposit', getValue(q.Cash_deposit_paid__c));
    sla.put('Deposit', getValue(q.Total_deposit_required__c));
    sla.put('DepositDueDate', getValue(q.Deposit_due_date__c));
    sla.put('Discount', getValue(q.Discount__c));
    sla.put('ExpectedHandoverDate', getValue(q.Expected_handover_date__c));
    sla.put('ExpectedValidationDate', getValue(q.Expected_validation_date__c));
    sla.put('SubletAmount', getValue(q.Sublet_amount__c));
    sla.put('FinanceAmount', getValue(q.Balance_to_Finance__c));
    sla.put('FinanceSellingRate', getValue(q.APR__c));
    sla.put('FinanceMonthlyPayments', getValue(q.Monthly_Payment__c));
    sla.put('FinanceYears', getValue(q.Term__c));
    sla.put('FinanceCompanyId', getValue(q.Finance_Company_ID__c));
    sla.put('FinanceAgreementNo', getValue(q.Finance_Agreement_Number__c));
    sla.put('FinanceDueFrom', getValue(q.Balance_to_Finance__c));
    sla.put('FinanceDueTo', getValue(q.Finance_settlement__c));
    sla.put('FinanceInvoiceDate', getValue(q.Invoice_Date__c));
    sla.put('FinanceAdminFee', getValue(q.Admin_Fee__c));
    sla.put('FinanceBaseRate', getValue(q.APR__c));
    sla.put('SourceId', '52');
    sla.put('Ancillaries', a);
    // trade sale
    sla.put('TradeAccount', getValue(p.tradeAccount__c));
    sla.put('CSN', getValue(q.CSV_Number__c));
    sla.put('TradeAmount', getValue(q.Trade_Sale_Amount__c));
    return sla;
  }

  /* ================= *
   *                   *  
   *      PX Unit      *
   *                   *
   * ================= */
  public class PXUnitClass {
    public String MANUFACTURER_DESC;
    public String RANGE_DESC;
    public String MODEL_DESCRIPTION;
    public String CONFIG_DESC;
    public Integer MODEL_YEAR;
    public Decimal LENGTH;
    public Decimal WIDTH;
    public Integer GG_MODEL_ID;
    public Integer QUALIFY_MODEL_ID;
    public Integer GGO_MODEL_ID;
    public Decimal GLASS_TRADE;
    public Decimal GLASS_RETAIL;
    public Decimal MRRP;
  }
  public static Inbound_PX_Unit__c mapPX(PXUnitClass i) {
    Inbound_PX_Unit__c x = new Inbound_PX_Unit__c();
    x.Bedrooms__c = i.CONFIG_DESC;
    x.Length__c = getValue(i.LENGTH);
    x.Make__c = i.MANUFACTURER_DESC;
    x.Model__c = i.RANGE_DESC;
    x.Name = i.MODEL_DESCRIPTION;
    x.Size__c = i.LENGTH + ' ' + i.WIDTH;
    x.Stand_In_Value__c = i.GLASS_TRADE;
    x.GGOModelID__c = getValue(i.GGO_MODEL_ID);
    x.GGModelID__c = getValue(i.GG_MODEL_ID);
    x.GGQualifyModelID__c = getValue(i.QUALIFY_MODEL_ID);
    x.Width__c = getValue(i.WIDTH);
    x.Year__c = i.MODEL_YEAR;
    return x;
  }
  
    
  /* ================= *
   *                   *  
   *        IPS        *
   *                   *
   * ================= */
  public class IPSClass {
    public Integer SchemeID;
    public String SchemeName;
    public Integer SupplierID;
    public String ParkID;
    public Integer PARK_ID;
    public List<IPSService> Services;
    public List<IPSRule> Rules;
  }
  public class IPSService {
    public Integer ServiceID;
    public List<IPSBreak> Breaks;
  }
  public class IPSRule {
    public Integer MinimumOfX;
    public String DatesFrom;
    public String DatesTo;
  }
  public class IPSBreak {
    public String DateFrom;
    public String Duration;
    public Decimal Percentage;
    public Decimal Vat;
    public Integer Peak;
    public Decimal Price;
    public Integer Active;
  }
  public static Park__c mapPark(IPSClass i) {
    Park__c p = new Park__c();
    p.Id = i.ParkID;
    //p.Park_ID__c = i.PARK_ID;
    p.IPS_Rules__c = JSON.serialize(i.Rules);
    return p;
  }
  public static Price_Rule__c mapIPS(IPSBreak i, String parkId, Integer serviceId) {
    Price_Rule__c r = new Price_Rule__c();
    DateTime d = i.DateFrom == null ? null : DateTime.valueOf(i.DateFrom.replace('T', ' '));
    r.Park__c = parkID;
    r.Peak_season__c = i.Peak == 1 || i.Peak == 2 ? true : false;
    r.Peak_summer__c = i.Peak == 2 ? true : false;
    r.Stock_Grade_New__c = String.valueOf(serviceId);
    String day = d.format('EEE');
    r.Weekend_Price__c = day == 'Mon' ? null: i.Price;
    r.Week_Price__c = day == 'Mon' ? i.Price : null;
    r.Week_Start__c = getDate(String.valueOf(d));
    r.Do_not_Allow__c = i.Active == 0 ? false : true;
    r.Foreign_Key__c = parkID + '-' + serviceId + '-' + i.DateFrom;
    return r;
  }
  
  /* ================= *
   *                   *  
   *        Lead       *
   *                   *
   * ================= */
  public class LeadClass {
    public Integer PrimaryId;
    public String LeadId;
    public String ContactId;
    public String AccountId;
    public String Salutation;
    public String FirstName;
    public String LastName;
    public String Street;
    public String PostalCode;
    public String Country;
    public String City;
    public String County;
    public String Email;
    public String MobilePhone;
    public String Phone;
    public Boolean IsOwner;
    public String RecordTypeName;
    public String LeadSource;
    public String EnquiryMethod;
    public String LeadSourceLevel2;
    public Boolean DoNotContact;
    public List<ComplianceClass> Compliance;
    public List<EnquiryClass> Enquiries;
  }
  public class ComplianceClass {
    public String Preference;
    public List<ComplianceMethodClass> Methods;
  }
  public class ComplianceMethodClass {
    public String Method;
    public Boolean OptIn;
  }
  public static Lead mapToLead(LeadClass i) {
    Lead l = new Lead();
    l.Id = i.LeadId;
    l.Primary_Id__c = getValue(i.PrimaryId);
    l.Auto_Created__c = true;
    if (i.Salutation != null) l.Salutation = i.Salutation;
    if (i.FirstName != null) l.FirstName = i.FirstName;
    if (i.LastName != null) l.LastName = i.LastName;
    if (i.Street != null) l.Street = i.Street;
    if (i.City != null) l.City = i.City;
    if (i.County != null) l.State = i.County;
    if (i.PostalCode != null) l.PostalCode = i.PostalCode;
    if (i.Country != null) l.Country = i.Country;
    if (i.Email != null) l.Email = i.Email;
    if (i.MobilePhone != null) l.MobilePhone = i.MobilePhone;
    if (i.Phone != null) l.Phone = i.Phone;
    if (i.DoNotContact != null) l.Do_not_Contact__c = i.DoNotContact == null ? false : i.DoNotContact;
    if (i.LeadSource != null) l.LeadSource = i.LeadSource;
    if (i.LeadSourceLevel2 != null) l.Lead_source_Level_2__c = i.LeadSourceLevel2;
    if (i.EnquiryMethod != null) l.Enquiry_Method__c = i.EnquiryMethod == null ? 'Digital import' : i.EnquiryMethod;
    if (i.Compliance != null) {
    for (Integer x = 0; x < i.Compliance.size(); x++) {
      String pref = i.Compliance[x].Preference;
      for (Integer y = 0; y < i.Compliance[x].Methods.size(); y++) {
        ComplianceMethodClass cmethod = i.Compliance[x].Methods[y];
        String method = cmethod.Method;
        Boolean optin = cmethod.OptIn == null ? false : cmethod.OptIn;
        if (pref == 'Holiday' && method == 'Email') l.Holidays_Email_Opt_In__c = optin;
        if (pref == 'Holiday' && method == 'Post') l.Holidays_Post_Opt_In__c = optin;
        if (pref == 'Holiday' && method == 'SMS') l.Holidays_SMS_Opt_In__c = optin;
        if (pref == 'Holiday' && method == 'Telephone') l.Holidays_Telephone_Opt_In__c = optin;
        if (pref == 'Sales' && method == 'Email') l.Email_Opt_in__c = optin;
        if (pref == 'Sales' && method == 'Post') l.Post_Opt_In__c = optin;
        if (pref == 'Sales' && method == 'SMS') l.SMS_Opt_In__c = optin;
        if (pref == 'Sales' && method == 'Telephone') l.Telephone_Opt_In__c = optin;
      }   
    }
    }
    return l;
  }
  public static Account mapToContact(LeadClass i, String recordTypeId) {
    Account c = new Account();
    c.Id = i.ContactId;
    c.Primary_Id__pc = getValue(i.PrimaryId);
    if (i.Salutation != null) c.Salutation = i.Salutation;
    if (i.FirstName != null) c.FirstName = i.FirstName;
    if (i.LastName != null) c.LastName = i.LastName;
    if (i.Street != null) c.BillingStreet = i.Street;
    if (i.PostalCode != null) c.BillingPostalCode = i.PostalCode;
    if (i.Country != null) c.BillingCountry = i.Country;
    if (i.City != null) c.BillingCity = i.City;
    if (i.County != null) c.BillingState = i.County;
    if (i.Email != null) c.PersonEmail = i.Email;
    if (i.MobilePhone != null) c.PersonMobilePhone = i.MobilePhone;
    if (i.Phone != null) c.Phone = i.Phone;
    if (i.DoNotContact != null) c.Do_not_Contact__pc = i.DoNotContact == null ? false : i.DoNotContact;
    if (i.Compliance != null) {
    for (Integer x = 0; x < i.Compliance.size(); x++) {
      String pref = i.Compliance[x].Preference;
      for (Integer y = 0; y < i.Compliance[x].Methods.size(); y++) {
        ComplianceMethodClass cmethod = i.Compliance[x].Methods[y];
        String method = cmethod.Method;
        Boolean optin = cmethod.OptIn == null ? false : cmethod.OptIn;
        if (pref == 'Holiday' && method == 'Email') c.Holidays_Email_Opt_In__pc = optin;
        if (pref == 'Holiday' && method == 'Post') c.Holidays_Post_Opt_In__pc = optin;
        if (pref == 'Holiday' && method == 'SMS') c.Holidays_SMS_Opt_In__pc = optin;
        if (pref == 'Holiday' && method == 'Telephone') c.Holidays_Telephone_Opt_In__pc = optin;
        if (pref == 'Sales' && method == 'Email') c.Email_Opt_in__pc = optin;
        if (pref == 'Sales' && method == 'Post') c.Post_Opt_In__pc = optin;
        if (pref == 'Sales' && method == 'SMS') c.SMS_Opt_In__pc = optin;
        if (pref == 'Sales' && method == 'Telephone') c.Telephone_Opt_In__pc = optin;
      }   
    }
      }
    return c;
  }
  public class EnquiryClass {
    public String SubmissionOn;
    public String SubmissionBy;
    public String SubmissionCampaignSource;
    public String SubmissionSource;
    public String SubmissionPath;
    public String SubmissionLinkID;
    public String LeadSource;
    public String LeadSourceLevel2;
    public List<Map<String, String>> Parks;
    public List<String> Regions;
    public String TimeOfCall;
    public Boolean OrderABrochure;
    public Boolean ArrangeVisit;
    public String DateOfVisit;
    public String TimeOfVisit;
    public Boolean FinanceOption;
    public String Notes;
    public String Query;
  }
  public static Lead setEnquiryLead(Lead record, ODIMapper.EnquiryClass e) {
    String parkNames = '';
    String parkIds = '';
    if (e.Parks != null) {
      for (Integer p = 0; p < e.Parks.size(); p++) {
        Map<String, String> park = e.Parks[p];
        String semicolon = p < e.Parks.size() - 1 ? ';' : '';
        String comma = p < e.Parks.size() - 1 ? ',' : '';
        parkNames += String.valueOf(park.get('Name')) + semicolon;
        parkIds += String.valueOf(park.get('Id')) + comma;
      }   
    }
    record.Enquiry_Date__c = getDate(e.SubmissionOn);
    record.SubmissionCampaignSource__c = e.SubmissionCampaignSource;
    record.SubmissionSource__c = e.SubmissionSource;
    record.SubmissionPath__c = e.SubmissionPath;
    record.LeadSource = e.LeadSource;
    record.Lead_source_Level_2__c = e.LeadSourceLevel2;
    record.Park_IDs__c = parkIds;
    record.Park_Codes__c = parkNames;
    record.SubmissionLinkID__c = e.SubmissionLinkID;
    record.Region__c = e.Regions != null ? String.join(e.Regions, ',') : null;
    record.Description = e.Notes;
    record.Time_of_Call__c = getTime(e.TimeOfCall);
    record.Brochure_Request__c = getString(e.OrderABrochure);
    record.Arrange_a_Visit__c = e.ArrangeVisit == null ? false : e.ArrangeVisit;
    record.Date_of_Visit__c = getDate(e.DateOfVisit);
    record.Time_of_Visit__c = getTime(e.TimeOfVisit);
    record.Finance_Option__c = e.FinanceOption == null ? false : e.FinanceOption;
    return record;
  }
  public static Account setEnquiryContact(Account record, ODIMapper.EnquiryClass e) {
    String parkNames = '';
    String parkIds = '';
    if (e.Parks != null) {
      for (Integer p = 0; p < e.Parks.size(); p++) {
        Map<String, String> park = e.Parks[p];
        String semicolon = p < e.Parks.size() - 1 ? ';' : '';
        String comma = p < e.Parks.size() - 1 ? ',' : '';
        parkNames += String.valueOf(park.get('Name')) + semicolon;
        parkIds += String.valueOf(park.get('Id')) + comma;
      }   
    }
    record.Latest_Enquiry_Date__c = getDate(e.SubmissionOn);
    record.SubmissionCampaignSource__c = e.SubmissionCampaignSource;
    record.SubmissionSource__c = e.SubmissionSource;
    record.SubmissionPath__c = e.SubmissionPath;
    record.PersonLeadSource = e.LeadSource;
    record.Lead_source_Level_2__c = e.LeadSourceLevel2;
    record.Enquiry_Park_IDs__c = parkIds;
    record.SubmissionLinkID__c = e.SubmissionLinkID;
    record.Enquiry_Parks__pc = parkNames;
    record.Enquiry_Regions__c = e.Regions != null ? String.join(e.Regions, ',') : null;
    record.Description = e.Notes;
    record.Time_of_Call__c = getTime(e.TimeOfCall);
    record.Brochure_Request__c = getString(e.OrderABrochure);
    record.Arrange_a_Visit__c = e.ArrangeVisit == null ? false : e.ArrangeVisit;
    record.Date_of_Visit__c = getDate(e.DateOfVisit);
    record.Time_of_Visit__c = getTime(e.TimeOfVisit);
    record.Finance_Option__c = e.FinanceOption == null ? false : e.FinanceOption;
    return record;
  }
  public static List<Task> mapEnquiries(LeadClass i, String recordTypeId, String whoId, String whatId) {
    List<Task> enquiries = new List<Task>();
    if (i.Enquiries != null) {
    for (Integer x = 0; x < i.Enquiries.size(); x++) {
      EnquiryClass e = i.Enquiries[x];
      Task t = new Task();
      t.SubmissionCampaignSource__c = e.SubmissionCampaignSource;
      t.SubmissionSource__c = e.SubmissionSource;
      t.SubmissionPath__c = e.SubmissionPath;
      t.RecordTypeId = recordTypeId;
      t.ActivityDate = getDate(e.SubmissionOn);
      t.Enquiry_Source__c = e.LeadSource;
      t.Enquiry_Source_Level_2__c = e.LeadSourceLevel2;
      String parkNames = '';
      String parkIds = '';
      if (e.Parks != null) {
        for (Integer p = 0; p < e.Parks.size(); p++) {
          Map<String, String> park = e.Parks[p];
          String semicolon = p < e.Parks.size() - 1 ? ';' : '';
          String comma = p < e.Parks.size() - 1 ? ',' : '';
          parkNames += String.valueOf(park.get('Name')) + semicolon;
          parkIds += String.valueOf(park.get('Id')) + comma;
        }   
      }
      t.Enquiry_Park__c = parkNames;
      t.Enquiry_Park_Ids__c = parkIds;
      t.Enquiry_Region__c = e.Regions != null ? String.join(e.Regions, ',') : null;
      t.Description = e.Notes;
      t.Time_of_Call__c = getTime(e.TimeOfCall);
      t.Brochure_R__c = getString(e.OrderABrochure);
      if (e.OrderABrochure == true) t.Brochure_delivery__c = 'Email';
      t.Arrange_a_Visit__c = e.ArrangeVisit == null ? false : e.ArrangeVisit;
      t.Date_of_Visit__c = getDate(e.DateOfVisit);
      t.Time_of_Visit__c = getTime(e.TimeOfVisit);
      t.Finance_Option__c = e.FinanceOption == null ? false : e.FinanceOption;
      if (e.TimeOfCall != null && e.TimeOfCall.indexOf(':') != -1) {
        Integer hour = Integer.valueOf(e.TimeOfCall.split(':')[0]);
        Integer mins = Integer.valueOf(e.TimeOfCall.split(':')[1]);
        t.Time_of_Call__c = Time.newInstance(hour, mins, 0, 0);
      }
      t.Priority = 'Normal';
      t.Status = 'Open';
      t.Subject = 'New Enquiry - ' + e.LeadSource;
      t.WhoId = whoId;
      t.WhatId = whatId;
      enquiries.add(t);
    }  
    }
    return enquiries;
  }
    
   /* ================= *
   *                   *  
   *      Bookings     *
   *                   *
   * ================= */
  public class BookingClass {
    public Integer PrimaryId;
    public String LeadID;
    public String ContactID;
    public Integer ID;
    public Integer BookingID;
    public Integer ClientID;
    public Integer BookingTypeID;
    public Integer SupplierID;
    public String ParkID;
    public String SupplierTypeName;
    public String ServiceTypeName;
    public String BookingTypeName;
    public String AgentName;
    public String BookingDepart;
    public Integer BookingNights;
    public Decimal BookingGross;
    public Integer ReevooParkScore;
    public Integer ReevooAccomScore;
    public Integer HotHolsCampaign;
    public Integer Adults;
    public Integer Teenagers;
    public Integer Children;
    public Integer Infants;
  }
  public static Holiday_Booking__c mapBooking(BookingClass i) {
    Holiday_Booking__c h = new Holiday_Booking__c();
    h.Agent_Name__c = i.AgentName;
    h.Arrival_Date__c = getDate(i.BookingDepart);
    h.Booking_ID__c = getValue(i.BookingID);
    h.PDR_Contact__c = i.ContactID;
    h.Lead__c = i.LeadID;
    h.Gross_Holiday_Value__c = i.BookingGross;
    h.Holiday_Type__c = i.SupplierTypeName;
    h.Number_of_adults__c = i.Adults;
    h.Number_of_children__c = i.Children;
    h.Number_of_infants__c = i.Infants;
    h.Park__c = i.ParkID;
    h.Reevoo_ParkScore__c = i.ReevooParkScore;
    h.Reevoo_AccomScore__c = i.ReevooAccomScore;
    h.Hot_Hols_Campaign__c = i.HotHolsCampaign;
    h.Nights__c = i.BookingNights;
    h.Accom_Type__c = i.ServiceTypeName;
    h.Number_of_Teenagers__c = i.Teenagers;
    return h;
  }
    
    
  /* ================= *
   *                   *  
   *     Complaints    *
   *                   *
   * ================= */
  public class ComplaintClass {
    public Integer ComplaintID;
    public String DateCreated;
    public String Method;
    public String Category;
    public String SubCategory;
    public String Status;
    public Decimal TotalGoodwillGiven;
    public List<ComplaintLinkClass> Links;
  }
  public class ComplaintLinkClass {
    public Integer PrimaryId;
    public String LeadID;
    public String ContactID;
    public Integer ClientID;
    public Integer BookingID;
    public Integer ComplaintLinkID;
  }
  public static Complaint__c mapComplaint(ComplaintClass i) {
    Complaint__c c = new Complaint__c();
    c.Complaint_Id__c = getValue(i.ComplaintID);
    c.Complaint_Type__c = i.Category;
    c.Date_of_Complaint__c = getDate(i.DateCreated);
    c.Complain_Sub_Category__c = i.SubCategory;
    c.Complaint_Status__c = i.Status;
    c.GoodWillGiven__c = i.TotalGoodwillGiven;
    return c;
  }
  public static Complaint_Junction__c mapComplaintLink(ComplaintLinkClass i, String foreignKey) {
    Complaint_Junction__c c = new Complaint_Junction__c();
    c.Lead__c = i.LeadID;
    c.PDR_Contact__c = i.ContactID;
    c.Complaint_Link_Id__c = foreignKey + '-' + i.ComplaintLinkID;
    return c;
  }
  
  /* ================= *
   *                   *  
   *      Account      *
   *                   *
   * ================= */
  public class AccountClass {
    public String AccountID;
    public String ContactID;
    public String ACCOUNT_NO;
    public Integer ACCOUNT_ID;
    public String OpportunityId;
    public Decimal LENGTH;
    public String OWN_INS_NAME;
    public Integer OWNER_ID;
    public String MAKE;
    public String MODEL;
    public Integer NUMBER_BEDROOMS;
    public Integer NO_OF_BERTHS;
    public Integer PARK_ID;
    public String ParkID;
    public String PAZP;
    public String SERIAL_NO;
    public String SITE_FEE_DATE;
    public Decimal SIV;
    public Integer VAN_ID;
    public String VAN_STOCK_NO;
    public String VAN_TYPE_DESC;
    public Decimal WIDTH;
    public Integer YEAR_MADE;
    public List<SaleClass> Sales;
  }
  public static Opportunity mapAccount(AccountClass i, String recordTypeId, Integer syncItemId) {
    Opportunity o = new Opportunity();
    o.Id = i.OpportunityId;
    o.AccountId = i.ContactID;
    o.CSV_Number__c = i.VAN_STOCK_NO;
    o.HH_Insurance_Name__c = i.OWN_INS_NAME;
    // now using opp id, as we could get issues using ACCOUNT_ID as might have multiple opps
    // as there's not the equivalent opp level in the wizard system
    o.Foreign_Key__c = i.OpportunityId == null ? getValue(syncItemId) : i.OpportunityId;
    o.Owner_Account_Number__c = getValue(i.ACCOUNT_NO);
    o.Wizard_Account_Id__c = getValue(i.ACCOUNT_ID);
    o.Owner_ID_External__c = getValue(i.OWNER_ID);
    o.Post_Sync_Link_Id__c = syncItemId;
    o.Park__c = i.ParkID;
    o.Park_ID_External__c = getValue(i.PARK_ID);
    o.Pitch__c = i.PAZP;
    o.Site_Fee_Date__c = getDate(i.SITE_FEE_DATE);
    o.SIV__c = i.SIV;
    o.Van_Length__c = i.LENGTH;
    o.Van_Width__c = i.WIDTH;
    o.Van_Make__c = i.MAKE;
    o.Van_Model__c = i.MODEL;
    o.Van_Number_of_Bedrooms__c = i.NUMBER_BEDROOMS;
    o.Van_Number_of_Berths__c = i.NO_OF_BERTHS;
    o.Van_Serial_Number__c = i.SERIAL_NO;
    o.Van_Type_Description__c = i.VAN_TYPE_DESC;
    o.Van_Year_Made__c = i.YEAR_MADE;
    o.Van_ID__c = i.VAN_ID;
    // if new account from wiz 
    if (i.OpportunityId == null) {
      o.Name = 'Test';
      o.StageName = 'Closed Won';
      o.RecordTypeId = recordTypeId;   
      o.CloseDate = Date.today();
      o.Other_Insert__c = true;
    }
    return o;
  }
    
  /* ================= *
   *                   *  
   *        Sale       *
   *                   *
   * ================= */
  public class SaleClass {
    public String AccountID;
    public Decimal AMOUNT_DUE_LATER;
    public String AMOUNT_DUE_LATER_DATE;
    public String ACTUAL_DT_OCCUPANCY;
    public String CANCELLATION_DATE;
    public String COMPLETION_DATE;
    public String ContactID;
    public String CSI_NO;
    public String DATE_SOLD;
    public Decimal DEPOSIT_AMOUNT;
    public Integer DESTINATION_PITCH_ID;
    public String DEPOSIT_DUE_DATE;
    public String EXPECTED_VALIDATION_DT;
    public String EXPECTED_DT_OCCUPANCY;
    public Decimal FINANCE_AMOUNT;
    public Decimal INITIAL_DEPOSIT_TAKEN;
    public Decimal MONTHLY_PAYMENTS;
    public String ParkID;
    public String QUALIFYING_DT;
    public String REASON_CANCELLED_DESC;
    public Integer SALE_ID;
    public String SLA_NO;
    public String SALE_STATUS_DESC;
    public Decimal SUBLET_AMOUNT;
    public String TENURE_END_DT;
    public String VALIDATION_DATE;
    public String VAN_STOCK_NO;
  }
  public static Quote mapSale(SaleClass i, String quoteTypeId, AccountClass a) {
    Quote q = new Quote();
    q.Foreign_Key__c = getValue(i.SALE_ID);
    q.Name = 'Test';
    q.Cash_due_later__c = i.AMOUNT_DUE_LATER;
    q.Cash_due_date__c = getDate(i.AMOUNT_DUE_LATER_DATE);
    q.Cash_deposit_paid__c = i.INITIAL_DEPOSIT_TAKEN;
    q.Actual_handover_date__c = getDate(i.ACTUAL_DT_OCCUPANCY);
    q.Cancelled_date__c = getDate(i.CANCELLATION_DATE);
    q.Completed_date__c = getDate(i.COMPLETION_DATE);
    q.CSI_Sales_Invoice__c = i.CSI_NO;
    q.CSV_Number__c = i.VAN_STOCK_NO;
    q.Date_sold__c = getDate(i.DATE_SOLD);
    q.Signup_Date__c = getDate(i.DATE_SOLD);
    q.Total_deposit_required__c = i.DEPOSIT_AMOUNT;
    q.Deposit_due_date__c = getDate(i.DEPOSIT_DUE_DATE);
    q.Destination_Pitch_ID__c = getValue(i.DESTINATION_PITCH_ID);
    q.Expected_validation_date__c = getDate(i.EXPECTED_VALIDATION_DT);
    q.Expected_handover_date__c = getDate(i.EXPECTED_DT_OCCUPANCY);
    q.Balance_to_Finance__c = i.FINANCE_AMOUNT;
    q.Qualified_date__c = getDate(i.QUALIFYING_DT);
    q.Cancellation_Reason__c = i.REASON_CANCELLED_DESC;
    q.Park__c = i.ParkID;
    q.Sale_Status_Description__c = i.SALE_STATUS_DESC;
    if (i.SALE_STATUS_DESC == 'Unvalidated') q.Status = 'SLA Accepted';
    if (i.SALE_STATUS_DESC == 'Validated') q.Status = 'Agree/Handover';
    if (i.SALE_STATUS_DESC == 'Completed') q.Status = 'Closed Won';
    if (i.SALE_STATUS_DESC == 'Cancelled') q.Status = 'Cancelled';
    q.SLA__c = i.SLA_NO;
    q.Sublet_amount__c = i.SUBLET_AMOUNT;
    q.Tenure_End_date__c = i.TENURE_END_DT;
    q.Validated_date__c = getDate(i.VALIDATION_DATE);
    if (a.OpportunityId == null) {
      q.RecordTypeId = quoteTypeId;
      q.Other_Insert__c = true;
    }
    return q;
  }  
    
}