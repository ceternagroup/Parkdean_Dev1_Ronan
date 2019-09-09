<aura:application implements="lightning:isUrlAddressable,force:appHostable" extends="force:slds" access="global">
    
  <aura:attribute name="quoteId" type="String" default="0Q01X00000000UbSAI"></aura:attribute>
    
  <c:IPSCalculator quoteId="{!v.quoteId}"></c:IPSCalculator>
     
</aura:application>