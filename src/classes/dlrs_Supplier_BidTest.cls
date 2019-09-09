/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Supplier_BidTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Supplier_BidTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Supplier_Bid__c());
    }
}