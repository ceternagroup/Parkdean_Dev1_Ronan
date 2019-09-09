<aura:application controller="PitchCatalogue" implements="lightning:isUrlAddressable,force:appHostable" extends="force:slds" access="global">
    
  <aura:attribute name="selectedProduct" type="Map"></aura:attribute>
  <aura:attribute name="quoteId" type="String" default="0Q01X00000000UbSAI"></aura:attribute>
  <aura:attribute name="quote" type="Map"></aura:attribute>
  <aura:attribute name="loaded" type="Boolean"></aura:attribute>
    
  <aura:handler name="init" value="{!this}" action="{!c.loadQuote}"></aura:handler>
    
  <div class="app-header">
    <div class="app-header--quote">{!v.quote.Name}</div>
    <div class="app-header--park">{!v.quote.Park_Name__c}</div>
    <lightning:button variant="brand" label="Back to Quote" onclick="{!c.goBack}"></lightning:button>
  </div>
    
  <div class="app-lhs">
    <div class="slds-card">
      <aura:if isTrue="{!v.loaded}">
        <c:PitchCatalogue quoteId="{!v.quoteId}" parkId="{!v.quote.Park__c}"/>
      </aura:if>
    </div>  
  </div>
    
</aura:application>