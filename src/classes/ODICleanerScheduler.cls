global class ODICleanerScheduler implements Schedulable {
    
  global void execute(SchedulableContext ctx) {
    Database.executeBatch(new ODICleaner(null), 500);
  }
    
  public static void runSchedule(String name) {
    // run every night at 11pm
    ODICleanerScheduler scheduler = new ODICleanerScheduler();
    String schedule = '0 0 23 * * ? *';
	System.schedule(name, schedule, scheduler);
  }

}