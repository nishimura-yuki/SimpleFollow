@isTest
public class FollowMailSchedulerTest{

   public static testMethod void test_submitSchedule(){
   
         List<EmailTemplate> templates = new List<EmailTemplate>();
         templates = [Select Id from EmailTemplate where FolderId = :UserInfo.getOrganizationId() limit 1];
   
         List<Contact> contacts = new List<Contact>();
         Contact c1 = new Contact();
         c1.LastName = 'テストの人';
         c1.Email = 'test1@test.com';
         Contact c2 = new Contact();
         c2.LastName = 'test_test';
         c2.Email = 'test2@test.com';
         contacts.add(c1);
         contacts.add(c2);
         
         insert contacts;
         
         List<String> ids = new List<String>();
         ids.add(contacts.get(0).Id);
         ids.add(contacts.get(1).Id);         
         
         Test.startTest();
   
         LIST<AggregateResult> before = [select count(Id) rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];
         Integer beforeSchedule = Integer.ValueOf(before.get(0).get('rowCount'));
   
         //スケジュール登録
         FollowMailScheduler.submitSchedule(ids , templates.get(0).Id , DateTime.now().addDays(1));
         system.assertEquals( 0 , Limits.getEmailInvocations() );
         LIST<AggregateResult> after = [select count(Id)rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];         
         system.assertEquals(  (beforeSchedule+1) , Integer.ValueOf(after.get(0).get('rowCount')));         

         Test.stopTest();
         
         //system.assertEquals( 1 , Limits.getEmailInvocations() );
         after = [select count(Id)rowCount from  AsyncApexJob where Status = 'Queued' and JobType = 'ScheduledApex' ];         
         system.assertEquals(  beforeSchedule , Integer.ValueOf(after.get(0).get('rowCount')));         
         
   }

}