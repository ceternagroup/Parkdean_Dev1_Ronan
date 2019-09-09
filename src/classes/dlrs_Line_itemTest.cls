/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Line_itemTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Line_itemTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Line_item__c());
    }
}